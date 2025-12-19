from time import sleep
import json
import os

from optim_analyser.ibm import modelDeploymentWithRestClient, jobWMLRestClient, getJobsStatus


def create_model_and_deployment_distant(ibm_watson_ml_properties:dict,
                                        modelPath:str, modelName:str, modelDescription:str="Model deployed for replay/test purposes with the optimization tool",
                                        ) -> tuple[str, list[str]]:
    
    apiKey=ibm_watson_ml_properties['API_KEY']
    spaceId=ibm_watson_ml_properties['SPACE_ID']
    hardwareSpecName=ibm_watson_ml_properties['HARDWARE_SPEC_NAME']
    hardwareSpecNumNodes=ibm_watson_ml_properties['HARDWARE_SPEC_NUM_NODES']
    
    softwareSpec = {
        "name": "do_20.1"
    }

    hardwareSpec = {
        "name": hardwareSpecName,
        "num_nodes": int(hardwareSpecNumNodes)
    }

    modelDetails = {
        "model_name": modelName,
        "model_description": modelDescription,
    }

    wmlRestClient = modelDeploymentWithRestClient.WMLModelDeploymentClient(apiKey=apiKey, spaceId=spaceId, modelDetails=modelDetails,
                                                                    modelPath=modelPath, softwareSpec=softwareSpec,
                                                                    hardwareSpec=hardwareSpec)
    model_Id = wmlRestClient.createAndUploadAssetOnWml()
    print("\nmodelId: ", model_Id)

    for dep in range(1, 2):
        deploymentDetails = {
            "model_name": modelName + '_' + str(dep),
            "model_description": modelDescription + '_' + str(dep),
        }

        deploymentId = wmlRestClient.deployAssetOnWml(modelId=model_Id)
        print("deploymentId: ", deploymentId)
    
    return model_Id, deploymentId


def run_optimization_distant(in_data:str, output_path:str, ibm_watson_ml_properties:dict, modelId:str, deploymentId:str) -> None :
    apiDomain=ibm_watson_ml_properties['API_DOMAIN']
    iamDomain=ibm_watson_ml_properties['IAM_DOMAIN']
    apiKey=ibm_watson_ml_properties['API_KEY']
    spaceId=ibm_watson_ml_properties['SPACE_ID']
    runtimeVersion=ibm_watson_ml_properties['RUN_TIME_VERSION']
    
    job = jobWMLRestClient.WMLJobClient(apiDomain=apiDomain,
                                        iamDomain=iamDomain,
                                        apiKey=apiKey,
                                        spaceId=spaceId,
                                        modelId=modelId,
                                        deploymentId=deploymentId,
                                        runtimeVersion=runtimeVersion)

    jobResponseData = job.createJob(inputData=in_data)
    jobId = job.fungetJobId(jobResponseData)
    print("\nOptimization job sent to IBM Cloud")

    jobStatus = getJobsStatus.getJobsStatus(apiDomain=apiDomain,
                                            iamDomain=iamDomain,
                                            apiKey=apiKey,
                                            spaceId=spaceId,
                                            modelId=modelId,
                                            deploymentId=deploymentId,
                                            runtimeVersion=runtimeVersion)
    while not jobStatus.isFinished(jobID=jobId):
        print("Waiting for the job to be finished ...")
        sleep(3)

    if jobStatus.isCompleted(jobID=jobId):
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        with open(output_path, 'w') as json_file:
            json.dump(job.funGetJobData(jobID=jobId)["entity"], json_file, indent=4)
        print(f"Optimization completed, please check the results at {output_path}")
    elif jobStatus.isFailed(jobID=jobId):
        print("Optimization failed, please retry")
    elif jobStatus.isCanceled(jobID=jobId):
        print("Optimization canceled, please retry")


def delete_deployment_and_model_distant(ibm_watson_ml_properties:dict,
                                        model_id:str, deployment_id:str) -> None :
    
    apiKey=ibm_watson_ml_properties['API_KEY']
    spaceId=ibm_watson_ml_properties['SPACE_ID']
    hardwareSpecName=ibm_watson_ml_properties['HARDWARE_SPEC_NAME']
    hardwareSpecNumNodes=ibm_watson_ml_properties['HARDWARE_SPEC_NUM_NODES']
    
    softwareSpec = {
        "name": "do_20.1"
    }

    hardwareSpec = {
        "name": hardwareSpecName,
        "num_nodes": int(hardwareSpecNumNodes)
    }

    modelDetails = {
        "model_name": "",
        "model_description": "",
    }

    wmlRestClient = modelDeploymentWithRestClient.WMLModelDeploymentClient(apiKey=apiKey, spaceId=spaceId, modelDetails=modelDetails,
                                                                modelPath="", softwareSpec=softwareSpec,
                                                                hardwareSpec=hardwareSpec)
    
    wmlRestClient.deleteDeploymentOnWml(deploymentId=deployment_id)
    print("Deployment on WML deleted.")

    wmlRestClient.deleteAssetOnWml(modelId=model_id)
    print("Model on WML deleted.")