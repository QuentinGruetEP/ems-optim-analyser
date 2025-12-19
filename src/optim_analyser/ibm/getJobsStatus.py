from typing import Optional, Union, Callable, Tuple, List, Any
from optim_analyser.ibm.jobWMLRestClient import WMLJobClient

class getJobsStatus:

    def __init__(self, apiDomain: str, iamDomain: str, apiKey: dict, spaceId: dict, modelId: dict, deploymentId: str, runtimeVersion: float) -> None:
        self.apiDomain = apiDomain
        self.iamDomain = iamDomain
        self.apiKey = apiKey
        self.spaceId = spaceId
        self.modelId = modelId
        self.deploymentId = deploymentId
        self.runtimeVersion = runtimeVersion

    def funGetJobState(self, jobID: Optional[str] = None, accessToken: Optional[str] = None,
                       jobResponseData: Optional[dict] = None) -> Optional[str]:

        try:
            if jobID is not None and jobResponseData is not None:
                raise ValueError("You cannot provide both jobID and jobResponseData in the funGetJobState function")
            elif jobID is not None and jobResponseData is None:
                jobResponseData = WMLJobClient(apiDomain=self.apiDomain,
                                                iamDomain=self.iamDomain,
                                                apiKey=self.apiKey,
                                                spaceId=self.spaceId,
                                                modelId=self.modelId,
                                                deploymentId=self.deploymentId,
                                                runtimeVersion=self.runtimeVersion).funGetJobData(jobID, "state", accessToken)
            return jobResponseData["entity"]["decision_optimization"]["status"]["state"]
        except Exception as e:
            #logger.loggingWarning(f"An exception has occurred: {e}")
            print(f"An exception has occurred: {e}")
            return None

    def isState(self, expectedStates: list, jobID: Optional[str] = None, jobState: Optional[str] = None,
                accessToken: Optional[str] = None) -> Optional[bool]:
        try:
            if jobID is not None and jobState is not None:
                raise ValueError("You cannot provide both jobID and jobState in the isState function")
            elif jobID is not None:
                jobState = self.funGetJobState(jobID=jobID, accessToken=accessToken)
        except Exception as e:
            #logger.loggingWarning(f"One exception has occurred: {e}")
            print(f"One exception has occurred: {e}")
            return None
        return jobState.lower() in expectedStates if jobState is not None else None

    def isQueued(self, jobID: Optional[str] = None, jobState: Optional[str] = None,
                 accessToken: Optional[str] = None) -> Optional[bool]:
        return self.isState(['queued'], jobID, jobState, accessToken)

    def isRunning(self, jobID: Optional[str] = None, jobState: Optional[str] = None,
                  accessToken: Optional[str] = None) -> Optional[bool]:
        return self.isState(['running'], jobID, jobState, accessToken)

    def isCompleted(self, jobID: Optional[str] = None, jobState: Optional[str] = None,
                    accessToken: Optional[str] = None) -> Optional[bool]:
        return self.isState(['completed'], jobID, jobState, accessToken)

    def isCanceled(self, jobID: Optional[str] = None, jobState: Optional[str] = None,
                   accessToken: Optional[str] = None) -> Optional[bool]:
        return self.isState(['canceled'], jobID, jobState, accessToken)

    def isFailed(self, jobID: Optional[str] = None, jobState: Optional[str] = None,
                 accessToken: Optional[str] = None) -> Optional[bool]:
        return self.isState(['failed'], jobID, jobState, accessToken)

    def isFinished(self, jobID: Optional[str] = None, jobState: Optional[str] = None,
                   accessToken: Optional[str] = None) -> Optional[bool]:
        return self.isState(expectedStates=['completed', 'canceled', 'failed'], jobID=jobID,
                            jobState=jobState, accessToken=accessToken)

    # Jobs Status

    def funIsAllLaunchedJobsState(self, isState: Callable, jobIDs: Optional[list] = None,
                                  jobStates: Optional[list] = None, accessToken: Optional[str] = None) -> Optional[
        Union[bool, tuple[bool, bool]]]:
        if jobIDs is not None and jobStates is None:
            return all([isState(jobID=jobID, accessToken=accessToken) for jobID in jobIDs])
        elif jobIDs is None and jobStates is not None:
            return all([isState(jobState=jobState) for jobState in jobStates])
        elif jobIDs is not None and jobStates is not None:
            return (all([isState(jobID=jobID, accessToken=accessToken) for jobID in jobIDs]),
                    all([isState(jobState=jobState) for jobState in jobStates]))
        else:
            return None

    def funIsAllLaunchedJobsFinished(self, jobIDs: Optional[list] = None, jobStates: Optional[list] = None,
                                     accessToken: Optional[str] = None) -> Optional[Union[bool, tuple[bool, bool]]]:
        return self.funIsAllLaunchedJobsState(self.isFinished, jobIDs, jobStates, accessToken)

    def funIsAllLaunchedJobsCompleted(self, jobIDs: Optional[list] = None, jobStates: Optional[list] = None,
                                      accessToken: Optional[str] = None) -> Optional[Union[bool, tuple[bool, bool]]]:
        return self.funIsAllLaunchedJobsState(self.isCompleted, jobIDs, jobStates, accessToken)
