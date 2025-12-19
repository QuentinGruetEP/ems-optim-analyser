import http.client
import json
import os
import urllib.parse
import zipfile
from os import F_OK, R_OK, W_OK, access
from os.path import isfile

import requests


class WMLModelDeploymentClient:
    """IBM Watson ML client for model deployment operations.

    Handles model upload, software/hardware spec configuration, and deployment creation.
    """

    def __init__(
        self,
        apiKey: str,
        spaceId: str,
        modelDetails: dict,
        modelPath: str,
        softwareSpec: dict,
        hardwareSpec: dict,
        modelsOrfunctions: str = "models",
        wmlCredentials=None,
    ) -> None:
        if wmlCredentials is None:
            wmlCredentials = {
                "IAM_url": "iam.cloud.ibm.com",
                # used to access the Identity and Access Management (IAM) of IBM WML cloud service (in our case
                # allows us to have an access token that will allow us to use the different methods of the api rest ibm)
                "api_version": "2020-09-01",
                "url_API": "eu-de.ml.cloud.ibm.com",
                # Endpoint_url : is the specific URL of the service endpoint used to interact with WML. It is the URL
                # WML client sends requests to interact with the service.
            }
        wmlCredentials["apikey"] = apiKey
        wmlCredentials["space_id"] = spaceId
        self.wmlCredentials = wmlCredentials
        self.modelDetails = modelDetails
        self.modelPath = modelPath
        self.softwareSpec = softwareSpec
        self.hardwareSpec = hardwareSpec
        self.modelsOrfunctions = modelsOrfunctions
        self.assetType = "do-opl_20.1" if self.modelsOrfunctions == "models" else "python"

    def getPathFile(self):
        folderModelPath, modelFileName = os.path.split(self.modelPath)
        modelName, modelExtension = os.path.splitext(modelFileName)
        return folderModelPath, modelName

    def convertModToZip(self) -> str:
        assert access(self.modelPath, F_OK) and access(
            self.modelPath, R_OK
        ), "File {} doesn't exist or isn't readable".format(self.modelPath)
        try:
            # Create a ZipFile object to write the zip file
            pathFile = self.getPathFile()
            with zipfile.ZipFile(self.getPathFile()[0] + "/" + pathFile[1] + ".zip", "w") as zipf:
                # Add .mod file to zip file
                zipf.write(self.modelPath, arcname="model_name" + ".mod")
        except IOError:
            raise IOError("Input/Output error during conversion to .zip file.")

        print("Conversion complete. The .mod file has been converted to a .zip file:", pathFile[0])

        return pathFile[0] + "/" + pathFile[1] + ".zip"

    def deletModelZip(self, modelZipPath) -> None:

        try:
            os.remove(modelZipPath)
            print(f"The file {modelZipPath} has been deleted successfully.")
        except FileNotFoundError as fileNotFoundError:
            print(fileNotFoundError)
        except PermissionError as permissionError:
            print(permissionError)
        except Exception as error:
            print(f"An unexpected error has occurred: {error}")

    def getIAMToken(self) -> str:

        try:
            httpsConnection = http.client.HTTPSConnection(self.wmlCredentials["IAM_url"], 443)
            authRequestHeaders = {"Content-Type": "application/x-www-form-urlencoded"}

            # encode a auth_requestBody dictionary of parameters in an encoded URL query string.
            authRequestBody = urllib.parse.urlencode(
                {
                    "grant_type": "urn:ibm:params:oauth:grant-type:apikey",
                    # Data is sent in the request body as key-value pairs separated by special characters, usually "&"
                    # and "=".
                    "apikey": self.wmlCredentials["apikey"],
                }
            )
            httpsConnection.request("POST", "/identity/token", authRequestBody, authRequestHeaders)
            response = httpsConnection.getresponse()
            responseBody = response.read().decode("utf-8")
            iamToken = json.loads(responseBody)["access_token"]

        except http.client.HTTPException as exception:
            print("An HTTP error has occurred when a token access has been requested :", exception)
        finally:
            httpsConnection.close()
        return iamToken

    # Method that allows to create model
    def createModelOnWml(self, iamToken: str) -> str:
        try:
            httpsConnection = http.client.HTTPSConnection(self.wmlCredentials["url_API"])
            requestHeaders = {"Content-Type": "application/json", "Authorization": "Bearer {}".format(iamToken)}

            requestBody = {
                "name": self.modelDetails["model_name"],
                "version": self.wmlCredentials["api_version"],
                "space_id": self.wmlCredentials["space_id"],
                "description": self.modelDetails["model_description"],
                "type": self.assetType,
                "software_spec": self.softwareSpec,
            }
            httpsConnection.request(
                "POST",
                "/ml/v4/" + self.modelsOrfunctions + "?version=" + self.wmlCredentials["api_version"],
                body=json.dumps(requestBody),
                headers=requestHeaders,
            )
            response = httpsConnection.getresponse()
            responseData = response.read().decode("utf8")
            modelId = json.loads(responseData)["metadata"]["id"]

        except http.client.HTTPException as exception:
            print("An HTTP error occurred when creating the model receptacle :", exception)
        finally:
            httpsConnection.close()
        return modelId

    # method for uploading opl model content to wml
    def uploadAssetOnWml(self, modelId: str, iamToken: str, modelZipPath: str) -> None:
        try:
            requestHeaders = {"Content-Type": "application/zip", "Authorization": "Bearer {}".format(iamToken)}

            params = {
                "space_id": self.wmlCredentials["space_id"],
                "version": self.wmlCredentials["api_version"],
                "content_format": "native",
            }

            with open(modelZipPath, "rb") as file:
                zipFileContent = file.read()

            response = requests.request(
                "PUT",
                "https://" + self.wmlCredentials["url_API"] + "/ml/v4/models/" + modelId + "/content?",
                params=params,
                headers=requestHeaders,
                data=zipFileContent,
            )

        except http.client.HTTPException as exception:
            print("An HTTP error occurred when uploading into the WML :", exception)
        finally:
            response.close()

    # Method that allows to create deployments from a given model
    def deployAssetOnWml(self, modelId: str, iamToken: str = None) -> str:
        iamToken = self.getIAMToken() if iamToken is None else iamToken
        try:
            httpsConnection = http.client.HTTPSConnection(self.wmlCredentials["url_API"])
            requestHeaders = {"Content-Type": "application/json", "Authorization": "Bearer {}".format(iamToken)}

            requestBody = {
                "name": self.modelDetails["model_name"],
                "version": self.wmlCredentials["api_version"],
                "space_id": self.wmlCredentials["space_id"],
                "description": self.modelDetails["model_description"],
                "asset": {"id": modelId},  # self.createModelOnWml(iamToken=iamToken)
                "type": self.assetType,
                "hardware_spec": self.hardwareSpec,
                "batch": {},
            }
            httpsConnection.request(
                "POST",
                "/ml/v4/deployments?version=" + self.wmlCredentials["api_version"],
                body=json.dumps(requestBody),
                headers=requestHeaders,
            )
            response = httpsConnection.getresponse()
            deploymentId = json.loads(response.read().decode("utf8"))["metadata"]["id"]

        except http.client.HTTPException as exception:
            print("An HTTP error occurred when the model deployment method is requested  :", exception)
        finally:
            httpsConnection.close()
        return deploymentId

    def createAndUploadAssetOnWml(self):
        iamToken = self.getIAMToken()
        modelId = self.createModelOnWml(iamToken=iamToken)
        modelZipPath = self.convertModToZip()
        self.uploadAssetOnWml(modelId=modelId, iamToken=iamToken, modelZipPath=modelZipPath)
        self.deletModelZip(modelZipPath=modelZipPath)
        return modelId

    def createAndDeploymentAssetOnWml(self):
        iamToken = self.getIAMToken()
        modelId = self.createAndUploadAssetOnWml()
        deploymentId = self.deployAssetOnWml(modelId=modelId, iamToken=iamToken)
        return modelId, deploymentId

    # Method that allows us to check if the name sent by the user exist in the models receptacle already created
    def checkModelName(self, iamToken: str) -> bool:
        return self.modelDetails["model_name"] in self.getAllModelsOnWml(iamToken=iamToken)

    # Method has as outputs a dictionary containing model names as keys and model IDs as values
    def getAllModelsOnWml(self, iamToken: str) -> str:
        modelIdName = {}
        try:
            httpsConnection = http.client.HTTPSConnection(self.wmlCredentials["url_API"])
            requestHeaders = {"Content-Type": "application/json", "Authorization": "Bearer {}".format(iamToken)}

            httpsConnection.request(
                "GET",
                "/ml/v4/models?version="
                + self.wmlCredentials["api_version"]
                + "&space_id="
                + self.wmlCredentials["space_id"],
                headers=requestHeaders,
            )
            response = httpsConnection.getresponse()
            responseData = response.read().decode("utf8")
            Models = json.loads(responseData)
            # get Models ID and names
            for model in Models["resources"]:
                modelIdName[model["metadata"]["name"]] = model["metadata"]["id"]

        except http.client.HTTPException as exception:
            print("An HTTP error occurred when Get all models ids & names is requested :", exception)
        finally:
            httpsConnection.close()
        return modelIdName

    # Method has as outputs a dictionary containing deployement names as keys and deplyoment IDs as values
    def getAllDeploymentsOnWml(self, iamToken: str, modelName: str) -> str:
        modelIdName = {}
        try:
            httpsConnection = http.client.HTTPSConnection(self.wmlCredentials["url_API"])
            requestHeaders = {"Content-Type": "application/json", "Authorization": "Bearer {}".format(iamToken)}

            httpsConnection.request(
                "GET",
                "/ml/v4/deployments?version="
                + self.wmlCredentials["api_version"]
                + "&space_id="
                + self.wmlCredentials["space_id"]
                + "&asset_id="
                + self.getAllModelsOnWml(iamToken=iamToken)[modelName],
                headers=requestHeaders,
            )
            response = httpsConnection.getresponse()
            responseData = response.read().decode("utf8")
            Models = json.loads(responseData)
            for model in Models["resources"]:
                modelIdName[model["metadata"]["name"]] = model["metadata"]["id"]

        except http.client.HTTPException as exception:
            print("An HTTP error occurred when Get all models deployements ids & names is requested :", exception)
        finally:
            httpsConnection.close()
        return modelIdName

    # Method that allows to delete deployments from a given model
    def deleteDeploymentOnWml(self, deploymentId: str, iamToken: str = None) -> str:
        iamToken = self.getIAMToken() if iamToken is None else iamToken
        try:
            httpsConnection = http.client.HTTPSConnection(self.wmlCredentials["url_API"])

            payload = ""
            requestHeaders = {"Content-Type": "application/json", "Authorization": "Bearer {}".format(iamToken)}
            httpsConnection.request(
                "DELETE",
                "/ml/v4/deployments/"
                + deploymentId
                + "?space_id="
                + self.wmlCredentials["space_id"]
                + "&version=2020-09-01",
                body=payload,
                headers=requestHeaders,
            )
            response = httpsConnection.getresponse()

        except http.client.HTTPException as exception:
            print("An HTTP error occurred when the model deployment deletion method is requested  :", exception)
        finally:
            httpsConnection.close()

    # Method that allows to delete models
    def deleteAssetOnWml(self, modelId: str, iamToken: str = None) -> str:
        iamToken = self.getIAMToken() if iamToken is None else iamToken
        try:
            httpsConnection = http.client.HTTPSConnection(self.wmlCredentials["url_API"])

            payload = ""
            requestHeaders = {"Content-Type": "application/json", "Authorization": "Bearer {}".format(iamToken)}

            httpsConnection.request(
                "DELETE",
                "/ml/v4/models/" + modelId + "?space_id=" + self.wmlCredentials["space_id"] + "&version=2020-09-01",
                body=payload,
                headers=requestHeaders,
            )
            response = httpsConnection.getresponse()

        except http.client.HTTPException as exception:
            print("An HTTP error occurred when the model deployment deletion method is requested  :", exception)
        finally:
            httpsConnection.close()
