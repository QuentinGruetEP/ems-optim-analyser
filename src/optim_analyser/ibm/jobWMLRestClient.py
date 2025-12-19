from typing import Optional, Union
import http.client
import json
from time import sleep
from datetime import datetime, timedelta
import urllib.parse
from datetime import timedelta


class WMLJobClient:
    """IBM Watson ML client for job submission and monitoring operations.
    
    Handles job submission, status polling, and result retrieval.
    """
    # CONST API
    VERSION_API = "/ml/v4"  # V4 indicates the major API version
    VERSION_PARAMETER = "?version=2020-09-01"  # indicate the selection of a specific version of the majeur version
    REP_MODELS = VERSION_API + "/models"
    REP_DEPLOYMENTS = VERSION_API + "/deployments"
    REP_JOBS = VERSION_API + "/deployment_jobs"
    REP_JOB = REP_JOBS + "/"
    SPACE_ID = "&space_id="

    # DEFAULT VALUES
    DEFAULT_JOB_TIMEOUT = timedelta(seconds=80)
    TIMEOUT_OFFSET = timedelta(seconds=40)
    HTTPS_CONNECTION_TIME_OUT = timedelta(seconds=120)  # seconds

    APPLICATION_JSON = "application/json"
    AUTHORIZATION = "Authorization"
    CONTENT_TYPE = "Content-Type"
    BASIC_AUTHORIZATION = "Basic Yng6Yng="
    LOG_OUTPUT_ID = "log.txt"
    METADATA = "metadata"
    JOBID = "id"

    def __init__(self,
                 apiDomain: str,
                 iamDomain: str,
                 apiKey: dict,
                 spaceId: dict,
                 modelId: dict,
                 deploymentId: str,
                 runtimeVersion: float):

        # the type annotation (Optional[str]) is used to indicate that attributes can be character strings
        self.apiDomain = apiDomain
        self.iamDomain = iamDomain
        self.apiKey = apiKey
        self.spaceId = spaceId
        self.modelId = modelId
        self.deploymentId = deploymentId
        self.runtimeVersion = runtimeVersion

    def funLookupBearerToken(self) -> str:
        global iamToken
        try:
            httpsConnection = http.client.HTTPSConnection(self.iamDomain, 443)
            REQUEST_HEADERS = {
                "Content-Type": "application/x-www-form-urlencoded"
            }

            # encode a AUTHREQUESTBODY dictionary of parameters in an encoded URL query string.
            bodyRequest = urllib.parse.urlencode({
                "grant_type": "urn:ibm:params:oauth:grant-type:apikey",
                # Data is sent in the request body as key-value pairs separated by special characters, usually "&" and "=".
                "apikey": self.apiKey
            })
            httpsConnection.request("POST", "/identity/token", bodyRequest, REQUEST_HEADERS)
            response = httpsConnection.getresponse()
            responseBody = response.read().decode('utf-8')
            iamToken = json.loads(responseBody)['access_token']
        except http.client.HTTPException as exception:
            #logger.loggingWarning(f"An HTTP error has occurred when a token access has been requested : {exception}")
            print(f"An HTTP error has occurred when a token access has been requested : {exception}")
        finally:
            httpsConnection.close()
        return iamToken

    def funGetJobPayload(self, jobName: str = "DEFAULT_JOB", inputData: Optional[list] = None) -> json:
        payload = dict()
        jsonPayload = dict()
        if inputData is None:
            payload = {}
        else:
            payload = {
                "deployment": {
                    "id": self.deploymentId
                },
                "space_id": self.spaceId,
                "name": jobName,
                "decision_optimization": {
                    "solve_parameters": {
                        "oaas.logAttachmentName": self.LOG_OUTPUT_ID,
                        "oaas.logTailEnabled": "true"
                    },

                    "input_data": inputData,
                    "output_data": [
                        {
                            "id": ".*\\.csv"
                        },
                        {
                            "id": ".*\\.txt"
                        }
                    ]
                }
            }

            jsonPayload = json.dumps(payload)

        return jsonPayload

    def funGetJobHeaders(self, accessToken: Optional[str] = None) -> dict:

        if accessToken is None:
            headers = {
                self.CONTENT_TYPE: self.APPLICATION_JSON,
                self.AUTHORIZATION: f"Bearer {self.funLookupBearerToken()}"
            }

        else:
            headers = {
                self.CONTENT_TYPE: self.APPLICATION_JSON,
                self.AUTHORIZATION: f"Bearer {accessToken}"
            }

        return headers

    def createJob(self, inputData: list, jobName: str = "DEFAULT_JOB", accessToken: Optional[str] = None) -> \
            Optional[
                Union[dict, None]]:

        """
    A function that allows to create jobs on an optimization model already deployed on IBM's Watson studio
    (WML) platform.
    Args:
      inputData (list): list containing the data from the various input tables required to run the jobs.
      inputDataFormat :
      [
			{
			    "id": "Table1.csv",
				"fields": ["xxx", ""xxx, ....],
				"values": [["xxx", "xxx"], ["xxx", "xxx"], ....]
             }

            {
			    "id": "Table2.csv",
				"fields": ["xxx", ""xxx, ....],
				"values": [["xxx", "xxx"], ["xxx", "xxx"], ....]
             }
      ]
      jobName(str) : Job name. Default = "DEFAULT_JOB.
      accessToken (str) : access token which allows to request the API to submit the job. Default = None, it is essential when launching a package of jobs with the same access token.
    Returns:
        jobResponseData (dict) : the response of the HTTPS request.
        :param inputData:
        :param accessToken:
        :param jobName:
    """
        try:
            requestStartTime = datetime.now()
            responseStatus = "5"
            while datetime.now() < requestStartTime + self.HTTPS_CONNECTION_TIME_OUT and responseStatus.startswith(
                    "5"):  # response status for server internal error start with 5
                # Establish a connection
                connection = http.client.HTTPSConnection(self.apiDomain, 443)
                # Prepare the request
                connection.request("POST", self.REP_JOBS + self.VERSION_PARAMETER,
                                   self.funGetJobPayload(jobName, inputData), self.funGetJobHeaders(accessToken))
                # Get the response
                response = connection.getresponse()
                # Read the response data
                responseData = response.read().decode("utf-8")
                responseStatus = str(response.status)

                if responseStatus == str(202):
                    jobResponseData = json.loads(responseData)
                    return jobResponseData
                else:
                    #logger.loggingWarning(f"Error creating deployment job: {responseData}")
                    print(f"Error creating deployment job: {responseData}")
                    sleep(2)
        except Exception as e:
            #logger.loggerWarning(f"An exception occurred when creating the deployment job: {e}.")
            print(f"An exception occurred when creating the deployment job: {e}.")

    def fungetJobId(self, jobResponseData: Optional[dict] = None) -> Optional[Union[str, None]]:
        if isinstance(jobResponseData, dict) and self.METADATA in jobResponseData.keys():
            if self.JOBID in jobResponseData[self.METADATA].keys():
                return jobResponseData[self.METADATA][self.JOBID] if jobResponseData is not None else None
            else:
                return None
        else:
            return None

    def funGetJobData(self, jobID, dataOrState: str = "data", accessToken: Optional[str] = None) -> (
            Optional)[Union[dict, None]]:
        try:
            connection = http.client.HTTPSConnection(self.apiDomain, 443)
            connection.request("GET", self.REP_JOB + jobID + self.VERSION_PARAMETER + self.SPACE_ID + self.spaceId,
                               self.funGetJobPayload(), self.funGetJobHeaders(accessToken))
            response = connection.getresponse()
            responseData = response.read().decode("utf-8")
            responseStatus = response.status
            if responseStatus != 200:
                #logger.loggingWarning(f"Error getting job details for job ID {jobID} : {responseData}")
                print(f"Error getting job details for job ID {jobID} : {responseData}")
                return None

            else:
                jobResponseData = json.loads(responseData)
                if dataOrState == "data":
                    #logger.loggingInfo(f"Output data is retrieved for job ID: {jobID}")
                    print(f"Output data is retrieved for job ID: {jobID}")
                else:
                    #logger.loggingInfo(f"Data state is retrieved for job ID: {jobID}")
                    print(f"Data state is retrieved for job ID: {jobID}")
                return jobResponseData

        except Exception as e:
            if dataOrState == "data":
                #logger.loggingWarning(f"An error occurred while getting job: {jobID} data : {e}")
                print(f"An error occurred while getting job: {jobID} data : {e}")
            else:
                #logger.loggingWarning(f"An error occurred while getting job: {jobID} data state : {e}")
                print(f"An error occurred while getting job: {jobID} data state : {e}")
            return None

