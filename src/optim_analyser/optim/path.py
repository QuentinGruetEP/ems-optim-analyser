import os
import pandas as pd
import json
import sys
import yaml
from pathlib import Path

from optim_analyser.errors import ModelReferenceError

def resource_path(relative_path:list[str]):
    """ Get absolute path to resource, works for dev and for PyInstaller """
    try:
        # Running as PyInstaller bundle
        base_path = sys._MEIPASS
    except AttributeError:
        # Running in development mode - use package resources directory
        base_path = Path(__file__).parent.parent.parent.parent / "resources"
        base_path = str(base_path.resolve())
    return os.path.join(base_path, *relative_path)

def output_path(output_folder_name:str):
    """ Get absolute path to output, works for dev and for PyInstaller """
    try:
        base_path = os.path.abspath(os.path.join(sys._MEIPASS, os.pardir))
    except AttributeError:
        # Running in development mode - use workspace root
        base_path = Path(__file__).parent.parent.parent.parent
        base_path = str(base_path.resolve())
    return os.path.join(base_path, output_folder_name)

excel_plot_param_path = resource_path(["config","plot_param.xlsx"])
excel_deployment_list_path = resource_path(["config", "deployment_list.xlsx"])
model_folder = resource_path(["models"])
yml_ibm_watson_ml_properties_path = resource_path(["config","IbmWatsonMLProperties.yml"])

def get_plot_param_df(excel_plot_param_path:str)->pd.DataFrame:
    """
    Load all plotting parameters from the Excel file

    :param excel_plot_param_path: The Excel file path containing all plotting parameters
    :type excel_plot_param_path: str
    :return: The dataframe containing all the plotting parameters
    :rtype: pd.DataFrame
    """

    clients_param = pd.read_excel(excel_plot_param_path, sheet_name='PLOT_PARAM', engine='openpyxl')
    clients_param['Microgrids ref'] = pd.to_numeric(clients_param['Microgrids ref'])
    clients_param = clients_param.set_index(clients_param['Microgrids ref'])

    return clients_param

# Dictionary associating a microgrid name to each operation id
operation_id_to_microgrid_name = get_plot_param_df(excel_plot_param_path)["microgrid_name"].to_dict()

def get_deployments_models_df(excel_deployment_list_path:str)->tuple[pd.DataFrame,pd.DataFrame]:
    """
    Load all deployments and models details from the Excel file

    :param excel_deployment_list_path: The Excel file path containing all deployments and models details
    :type excel_deployment_list_path: str
    :return: The dataframe containing the model IDs corresponding to all operation IDs, and the dataframe containing the model file names corresponding to all model IDs
    :rtype: tuple[pd.DataFrame,pd.DataFrame]
    """
    deployments = pd.read_excel(excel_deployment_list_path, sheet_name='DEPLOYMENTS_PROD', engine='openpyxl').set_index('Operation ref')
    models = pd.read_excel(excel_deployment_list_path, sheet_name='MODELS', engine='openpyxl').set_index('Model ID')
    return deployments, models

def op_id_and_microgrid_name_date_from_json(json_file:str) -> tuple[str,str,str]:
    """
    Return the operation ID, the corresponding microgrid name that will be used in generated files names and the microgrid name with the optimization resquest time
    extracted from the optimization job data from the .json file

    :param json_file: The optimization job path (can be a .json or a .txt)
    :type json_file: str
    :return: The operation ID, the microgrid name, and the microgrid name with the optimization resquest time
    :rtype: tuple[str,str,str]
    """
    with open(json_file, 'r') as f:
        json_data = json.load(f)
        if 'entity' in json_data:
            json_data = json_data['entity']

        for sheet_data in json_data["decision_optimization"]["input_data"]:
            if sheet_data["id"] == "OPERATION.csv" :
                for param in sheet_data["values"] :
                    if param[0] == "operation_id":
                        operation_id = param[1]
                        microgrid_name = operation_id_to_microgrid_name.get(int(operation_id), 'microgrid_name_not_found')
                    elif param[0] == "optimisation_request_time":
                        optim_resquest_time = param[1].split(".")[0] # Remove decimals on seconds
                        optim_resquest_time = "_".join(optim_resquest_time.split(" "))
                        optim_resquest_time = ''.join(optim_resquest_time.split(":"))
                return operation_id, microgrid_name, microgrid_name + "_" + optim_resquest_time

def op_id_and_microgrid_name_date_from_excel(excel_input_path:str) -> str :
    """
    Return the operation ID, the corresponding microgrid name that will be used in generated files names and the microgrid name with the optimization resquest time
    extracted from the optimization job input data from the Excel file

    :param excel_input_path: The Excel file path containing the optimization input data
    :type excel_input_path: str
    :return: The operation ID, the microgrid name, and the microgrid name with the optimization resquest time
    :rtype: str
    """
    input_data = pd.read_excel(excel_input_path, sheet_name='OPERATION')
    operation_df = input_data.set_index('param_id').transpose()
    operation_id = operation_df['operation_id']['param_val']
    microgrid_name = operation_id_to_microgrid_name.get(int(operation_id), 'microgrid_name_not_found')

    optim_resquest_time = str(operation_df['optimisation_request_time']['param_val']).split(".")[0] # Remove decimals on seconds
    optim_resquest_time = "_".join(optim_resquest_time.split(" "))
    optim_resquest_time = ''.join(optim_resquest_time.split(":"))

    return operation_id, microgrid_name, microgrid_name + "_" + optim_resquest_time


def get_microgrid_param(operation_id:str)->pd.Series:
    """
    Return the specific plotting parameters corresponding to the operation ID, return default plotting parameters if no specfic parameters can be found for this operation ID

    :param operation_id: The operation ID
    :type operation_id: str
    :return: The plotting parameters of the microgrid corresponding to the operation ID
    :rtype: pd.Series
    """
    plot_param = get_plot_param_df(excel_plot_param_path)
    default_param = plot_param.loc[-1,:]

    # Load display parameters corresponding to the microgrid
    if int(operation_id) in list(plot_param.index) :
        microgrid_param = plot_param.loc[int(operation_id),:]    
    else :
        microgrid_param = default_param
    
    return microgrid_param


def get_model_path(operation_id:str)->str:
    """
    Return model file (.mod) path corresponding to the operation ID

    :param operation_id: The operation ID
    :type operation_id: str
    :return: The OPL model file (.mod) path
    :rtype: str
    """
    deployments, models = get_deployments_models_df(excel_deployment_list_path)
    try :
        model_id = deployments.at[int(operation_id),'Model Id']
    except KeyError:
        raise ModelReferenceError(f"Operation ID {operation_id} not found in sheet DEPLOYMENTS_PROD in deployment_list.xslx")
    try :
        model_file_name = models.at[model_id,'Sharepoint file']
    except pd.errors.InvalidIndexError:
        raise ModelReferenceError(f"Operation id {operation_id} refers to multiple Model IDs in deployment_list.xslx")
    except KeyError:
        try :
            model_file_name = models.at[str(model_id),'Sharepoint file']
        except KeyError:
            raise ModelReferenceError(f"Model ID {model_id} not found in sheet MODELS in deployment_list.xslx")
    return os.path.join(model_folder, model_file_name)

def get_display_paths_and_param_json(json_file:str, output_folder:str="./optimAnalyser/output/") -> tuple[str,str,str,pd.Series] :
    """
    Return all paths that will be used when displaying the optimization job contained in the .json file

    :param json_file: The optimization job path (can be a .json or a .txt)
    :type json_file: str
    :param output_folder: The folder path where all files will be saved, defaults to "./optimAnalyser/output/"
    :type output_folder: str, optional
    :return: The folder path containing the other files,
    the path to the Excel file containing all the initial optimization job data,
    the path to the .html file containing the optimization job visuals,
    and the specific plotting parameters corresponding to this optimization job
    :rtype: tuple[str,str,str,pd.Series]
    """

    operation_id, microgrid_name, optim_name = op_id_and_microgrid_name_date_from_json(json_file)

    # Create output folders
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    optim_folder = os.path.join(output_folder,microgrid_name)
    if not os.path.exists(optim_folder):
        os.makedirs(optim_folder)

    excel_init_path = os.path.join(optim_folder,optim_name + "_initial_job.xlsx")

    html_path = os.path.join(optim_folder,optim_name + ".html")

    plot_param = get_microgrid_param(operation_id)

    return (optim_folder,
            excel_init_path,
            html_path,
            plot_param)

def get_run_paths_and_param_json(json_file:str, output_folder:str="./optimAnalyser/output/") -> tuple[str,str,str,str,str,str,str,str,str,str,pd.Series] :
    """
    Return all paths that will be used when replaying and displaying the optimization job contained in the .json file

    :param json_file: The optimization job path (can be a .json or a .txt)
    :type json_file: str
    :param output_folder: The folder path where all files will be saved, defaults to "./optimAnalyser/output/"
    :type output_folder: str, optional
    :return: The path to the Excel file containing all the initial optimization job data,
    the path to the Excel file containing the input data and used to run the optimization,
    the path to the Excel file that will contain the output data after the optimization has been replayed,
    the original OPL model file path (.mod),
    the .dat file path used to run the optimization,
    the OPL model file path (.mod) used to run the optimization,
    the folder path containing the input and output Excel files,
    the .dat file path containing the added code used to add the detailed costs in the optimization output,
    the OPL model file path (.mod) containing the added code used to add the detailed costs in the optimization output,
    the path to the .html file containing the replayed job visuals,
    and the specific plotting parameters corresponding to this optimization job
    :rtype: tuple[str,str,str,str,str,str,str,str,str,str,pd.Series]
    """

    operation_id, microgrid_name, _ = op_id_and_microgrid_name_date_from_json(json_file)
    optim_folder, excel_init_path, html_path, plot_param = get_display_paths_and_param_json(json_file, output_folder)

    model_path = get_model_path(operation_id)

    run_folder = os.path.join(optim_folder, "run_cplex")
    if not os.path.exists(run_folder):
        os.makedirs(run_folder)
    run_data_folder = os.path.join(run_folder, "Data")
    if not os.path.exists(run_data_folder):
        os.makedirs(run_data_folder)

    excel_input_path = os.path.join(run_data_folder, microgrid_name + "_input.xlsx")
    excel_output_path = os.path.join(run_data_folder, microgrid_name + "_output.xlsx")
    # csvs_folder_path = os.path.join(run_data_folder, optim_name + "_csvs")

    run_dat_path = os.path.join(run_folder, microgrid_name + ".dat")
    run_model_path = os.path.join(run_folder, os.path.basename(model_path))


    dat_costs_extension_path = os.path.join(run_folder, microgrid_name + "_cost_extraction.dat")
    mod_costs_extension_path = os.path.join(run_folder, microgrid_name + "_cost_extraction.mod")

    return (excel_init_path, excel_input_path, excel_output_path,
            model_path, run_dat_path, run_model_path, run_data_folder,
            dat_costs_extension_path, mod_costs_extension_path,
            html_path,
            plot_param)

def get_display_paths_and_param_excel(excel_input_path:str, output_folder:str="./optimAnalyser/output/") -> tuple[str,str,pd.DataFrame] :
    """
    Return all paths that will be used when displaying the optimization corresponding to the Excel file

    :param excel_input_path: The Excel file path containing the optimization input data
    :type excel_input_path: str
    :param output_folder: The folder path where all files will be saved, defaults to "./optimAnalyser/output/"
    :type output_folder: str, optional
    :return: The folder path containing the other files,
    the path to the .html file containing the optimization job visuals,
    and the specific plotting parameters corresponding to this optimization
    :rtype: tuple[str,str,pd.DataFrame]
    """
    operation_id, microgrid_name, _ = op_id_and_microgrid_name_date_from_excel(excel_input_path)

    # Create output folders
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    optim_folder = os.path.join(output_folder, microgrid_name)
    if not os.path.exists(optim_folder):
        os.makedirs(optim_folder)

    html_path = os.path.join(optim_folder, microgrid_name + ".html")

    plot_param = get_microgrid_param(operation_id)

    return (optim_folder,
            html_path,
            plot_param)

def get_display_paths_and_param_scenario(excel_input_path:str, sc_folder:str, sc_name:str) -> tuple[str,pd.Series]:
    """
    Return all paths that will be used when displaying the optimization corresponding to the Excel file and the scenario name

    :param excel_input_path: The Excel file path containing the optimization input data
    :type excel_input_path: str
    :param sc_folder: The path to the folder containing all the scenario subfolders that contain the Excel data files
    :type sc_folder: str
    :param sc_name: The scenario name
    :type sc_name: str
    :return: The path to the .html file containing the optimization job visuals,
    and the specific plotting parameters corresponding to this optimization
    :rtype: tuple[str,pd.Series]
    """

    operation_id, _, _ = op_id_and_microgrid_name_date_from_excel(excel_input_path)

    html_path = os.path.join(sc_folder, sc_name + ".html")

    plot_param = get_microgrid_param(operation_id)

    return (html_path,
            plot_param)

def get_run_paths_and_param_excel(excel_input_path:str, output_folder:str="./optimAnalyser/output/") -> tuple[str,str,str,str,str,str,str,str,pd.Series] :
    """
    Return all paths that will be used when replaying and displaying the optimization corresponding to the Excel file

    :param excel_input_path: The Excel file path containing the optimization input data
    :type excel_input_path: str
    :param output_folder: The folder path where all files will be saved, defaults to "./optimAnalyser/output/"
    :type output_folder: str, optional
    :return: The original OPL model file path (.mod),
    the .dat file path used to run the optimization,
    the OPL model file path (.mod) used to run the optimization,
    the folder path containing the input and output Excel files,
    the .dat file path containing the added code used to add the detailed costs in the optimization output,
    the OPL model file path (.mod) containing the added code used to add the detailed costs in the optimization output,
    the path to the .html file containing the replayed job visuals,
    the output data Excel file path,
    and the specific plotting parameters corresponding to this optimization job
    :rtype: tuple[str,str,str,str,str,str,str,str,pd.Series]
    """

    operation_id, microgrid_name, _ = op_id_and_microgrid_name_date_from_excel(excel_input_path)
    optim_folder, html_path, plot_param = get_display_paths_and_param_excel(excel_input_path, output_folder)

    model_path = get_model_path(operation_id)

    run_folder = os.path.join(optim_folder, "run_cplex")
    if not os.path.exists(run_folder):
        os.makedirs(run_folder)
    run_data_folder = os.path.join(run_folder, "Data")
    if not os.path.exists(run_data_folder):
        os.makedirs(run_data_folder)

    # csvs_folder_path = os.paht.join(run_data_folder, optim_name + "_csvs")

    run_dat_path = os.path.join(run_folder, microgrid_name + ".dat")
    run_model_path = os.path.join(run_folder, os.path.basename(model_path))


    dat_costs_extension_path = os.path.join(run_folder, microgrid_name + "_cost_extraction.dat")
    mod_costs_extension_path = os.path.join(run_folder, microgrid_name + "_cost_extraction.mod")

    excel_output_path = excel_input_path.replace("in_prob","out_prob").replace('input', 'output')

    return (model_path, run_dat_path, run_model_path, run_data_folder,
            dat_costs_extension_path, mod_costs_extension_path,
            html_path, excel_output_path,
            plot_param)


def get_compare_paths_excel(excel_input_init_path:str, output_folder:str="./optimAnalyser/output/") -> tuple[str,pd.Series]:
    """
    Return the .html visuals comparison path and the plotting parameters for the initial optimization corresponding to the Excel file

    :param excel_input_init_path: The Excel file path containing the optimization input data
    :type excel_input_init_path: str
    :param output_folder: The folder path where the comparison visuals will be saved, defaults to "./optimAnalyser/output/"
    :type output_folder: str, optional
    :return: The .html file path where the comaprison visuals will be saved, and the plotting parameters corresponding to the Excel file
    :rtype: tuple[str,pd.Series]
    """
    _, html_path_basic, plot_param = get_display_paths_and_param_excel(excel_input_init_path, output_folder)
    html_basic_filename = os.path.splitext(os.path.basename(html_path_basic))[0]
    html_path_comparison = os.path.join(os.path.dirname(html_path_basic), html_basic_filename + "_comparison.html")

    return html_path_comparison, plot_param

def get_compare_paths_json(json_init_path:str, output_folder:str="./optimAnalyser/output/") -> tuple[str,pd.Series]:
    """
    Return the .html visuals comparison path and the plotting parameters for the initial optimization corresponding to the .json file

    :param json_init_path: The initial optimization job path (can be a .json or a .txt)
    :type json_init_path: str
    :param output_folder: The folder path where the comparison visuals will be saved, defaults to "./optimAnalyser/output/"
    :type output_folder: str, optional
    :return: The .html file path where the comaprison visuals will be saved, and the plotting parameters corresponding to the Excel file
    :rtype: tuple[str,pd.Series]
    """
    _, _, html_path_basic, plot_param = get_display_paths_and_param_json(json_init_path, output_folder)
    html_basic_filename = os.path.splitext(os.path.basename(html_path_basic))[0]
    html_path_comparison = os.path.join(os.path.dirname(html_path_basic), html_basic_filename + "_comparison.html")

    return html_path_comparison, plot_param

def get_ibm_watson_ml_properties():
    with open(yml_ibm_watson_ml_properties_path, 'r') as file :
        ibm_watson_ml_properties = yaml.safe_load(file)['ibmwatsonml']
    return ibm_watson_ml_properties