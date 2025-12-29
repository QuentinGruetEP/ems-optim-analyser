from __future__ import annotations

import os
import shutil
import time
import tkinter as tk

from optim_analyser.analysis import compare, display
from optim_analyser.config import load_config
from optim_analyser.ibm import optimizationIBM
from optim_analyser.optim import dataframes, optimization, path, replay


def display_from_json(json_path: str, output_folder: str, color_blind: bool = False) -> None:
    """
    Display the optimization job from the .json file and save the results in the output folder

    :param json_path: The optimization job path (can be a .json or a .txt)
    :type json_path: str
    :param output_folder: The folder path where all files will be saved
    :type output_folder: str
    :param color_blind: If True, the color blind palette will be used, defaults to False, defaults to False
    :type color_blind: bool, optional
    """

    # Load data from .json
    data = dataframes.json_to_dataframe(json_path)

    # Get corresponding paths and plotting parameters
    (_, _, html_path, plot_param) = path.get_display_paths_and_param_json(json_path, output_folder)

    # Display and save visuals in the .html
    display.plot_from_data(
        all_data=data, sc_name=None, html_path=html_path, subplots_param=plot_param, color_blind=color_blind
    )


def display_from_excel(
    excel_input_path: str, excel_output_path: str, output_folder: str, sc_name: str | None = None, color_blind: bool = False
) -> None:
    """
    Display the optimization job from the Excel files and save the results in the output folder

    :param excel_input_path: The input data Excel file path
    :type excel_input_path: str
    :param excel_output_path: The output data Excel file path
    :type excel_output_path: str
    :param output_folder: The folder path where all files will be saved
    :type output_folder: str
    :param sc_name: The scenario name, defaults to None
    :type sc_name: str, optional
    :param color_blind: If True, the color blind palette will be used, defaults to False
    :type color_blind: bool, optional
    """

    # Get corresponding paths and plotting parameters
    (_, html_path, plot_param) = path.get_display_paths_and_param_excel(excel_input_path, output_folder)

    # Display and save visuals in the .html
    display.plot_from_excel(
        excel_input_path,
        excel_output_path,
        sc_name=sc_name,
        html_path=html_path,
        client_param=plot_param,
        add_costs=False,
        color_blind=color_blind,
    )


def replay_from_json_and_display_local(
    json_path: str, output_folder: str, add_costs: bool = True, color_blind: bool = False
) -> None:
    """
    Replay the optimization job from the .json and display the recomputed display

    :param json_path: The optimization job path (can be a .json or a .txt)
    :type json_path: str
    :param output_folder: The folder path where all files will be saved
    :type output_folder: str
    :param add_costs: If True, the detailed repartition of the optimization costs will be added, defaults to True
    :type add_costs: bool, optional
    :param color_blind: If True, the color blind palette will be used, defaults to False
    :type color_blind: bool, optional
    """

    # Load data from .json
    data = dataframes.json_to_dataframe(json_path)

    # Get all paths and plotting parameters
    (
        excel_init_path,
        excel_input_path,
        excel_output_path,
        model_path,
        run_dat_path,
        run_model_path,
        _,
        dat_costs_extension_path,
        mod_costs_extension_path,
        html_path,
        plot_param,
    ) = path.get_run_paths_and_param_json(json_path, output_folder)

    # Create the excel with all initial data contained in the optimisation job (.json)
    optimization.prepare_excel_initial_data(data, excel_init_path)

    # Create the input Excel file and update the .dat file
    optimization.prepare_optimization(
        data,
        model_path,
        run_model_path,
        excel_input_path=excel_input_path,
        dat_path=run_dat_path,
        excel_output_path=excel_output_path,
        add_costs=add_costs,
        mod_costs_extension_path=mod_costs_extension_path,
        dat_costs_extension_path=dat_costs_extension_path,
    )
    print(f"All optimization files generated.\nPlease check the files at '{output_folder}'.\n")

    # Replay the optimisation
    replay.replay_optimization(run_model_path, run_dat_path, data, excel_output_path)
    data_recomputed = dataframes.excel_to_dataframe(excel_input_path) | dataframes.excel_to_dataframe(excel_output_path)

    # Display results and save the graphs in a html file
    display.plot_from_data(
        all_data=(data | data_recomputed),  # This should keep the data from the .json and replace the recomputed sheets
        sc_name=None,
        html_path=html_path,
        subplots_param=plot_param,
        color_blind=color_blind,
    )


def run_from_excel_and_display_local(
    excel_input_path: str,
    output_folder: str,
    text_console: tk.Text | None = None,
    add_costs: bool = True,
    color_blind: bool = False,
) -> None:
    """
    Replay the optimization job from the Excel files and display the recomputed display

    :param excel_input_path: The input data Excel file path
    :type excel_input_path: str
    :param output_folder: The folder path where all files will be saved
    :type output_folder: str
    :param add_costs: If True, the detailed repartition of the optimization costs will be added, defaults to True
    :type add_costs: bool, optional
    :param color_blind: If True, the color blind palette will be used, defaults to False
    :type color_blind: bool, optional
    """

    data = dataframes.excel_to_dataframe(excel_input_path)  # dataframes.excel_to_dataframe(excel_output_path)

    # Create all files paths
    (
        model_path,
        run_dat_path,
        run_model_path,
        run_data_folder,
        dat_costs_extension_path,
        mod_costs_extension_path,
        html_path,
        excel_output_path,
        plot_param,
    ) = path.get_run_paths_and_param_excel(excel_input_path, output_folder)

    # Create the input Excel file and update the .dat file
    optimization.prepare_optimization(
        data,
        model_path,
        run_model_path,
        excel_input_path=excel_input_path,
        dat_path=run_dat_path,
        excel_output_path=excel_output_path,
        add_costs=add_costs,
        mod_costs_extension_path=mod_costs_extension_path,
        dat_costs_extension_path=dat_costs_extension_path,
    )
    print(f"All optimization files generated.\nPlease check the files at '{output_folder}'.\n")

    run_excel_input_path = os.path.join(run_data_folder, os.path.basename(excel_input_path))
    run_excel_output_path = os.path.join(run_data_folder, os.path.basename(excel_output_path))

    shutil.copy(excel_input_path, run_excel_input_path)
    shutil.copy(excel_output_path, run_excel_output_path)

    # Replay the optimisation
    optimization.run_optimization(run_model_path, run_dat_path)
    time.sleep(1)  # Wait for CPLEX to write output data in the excel file before moving it

    # The original input and output files will be replaced by the recomputed ones
    excel_input_final_path = excel_input_path
    excel_output_final_path = excel_output_path

    data_recomputed = dataframes.excel_to_dataframe(run_excel_input_path) | dataframes.excel_to_dataframe(
        run_excel_output_path
    )

    shutil.move(run_excel_input_path, excel_input_final_path)
    shutil.move(run_excel_output_path, excel_output_final_path)

    # Display results and save the graphs in a html file
    display.plot_from_data(
        all_data=(data | data_recomputed),
        sc_name=None,
        html_path=html_path,
        subplots_param=plot_param,
        color_blind=color_blind,
    )


def run_scenarios_local(
    run_model_path: str,
    run_dat_path: str,
    run_data_folder: str,
    excel_folder_path: str,
    sc_list: list[str],
    in_place: bool,
) -> None:
    """
    Run multiple times the given optimization configuration with for each scenario given in the list and located in a subfolder of the Excel folder path

    :param run_model_path: The OPL model file path (.mod) used to run the optimization
    :type run_model_path: str
    :param run_dat_path: The .dat file path used to run the optimization
    :type run_dat_path: str
    :param run_data_folder: The folder path containing the input and output Excel files used to run the optimization
    :type run_data_folder: str
    :param excel_folder_path: The folder path containing the input and output Excel files for every scenario in their respective subfolders
    :type excel_folder_path: str
    :param sc_list: The scenario names list
    :type sc_list: list[str]
    :param in_place: If True, the output data Excel file is modified in place, otherwise the Excel files will be found in the optimization configuration parent folder
    :type in_place: bool
    """

    for sc_name in sc_list:
        print(sc_name)
        list_dir = os.listdir(os.path.join(excel_folder_path, sc_name))
        for file in list_dir:
            if file.startswith("in_prob_"):
                excel_input_path = os.path.join(excel_folder_path, sc_name, file)
        excel_output_path = excel_input_path.replace("in_prob", "out_prob")

        run_excel_input_path = os.path.join(run_data_folder, os.path.basename(excel_input_path))
        run_excel_output_path = os.path.join(run_data_folder, os.path.basename(excel_output_path))

        shutil.copy(excel_input_path, run_excel_input_path)
        shutil.copy(excel_output_path, run_excel_output_path)

        optimization.run_optimization(run_model_path, run_dat_path)
        time.sleep(1)  # Wait for CPLEX to write output data in the excel file before moving it

        if in_place:
            # The original input and output files will be replaced by the recomputed ones
            excel_input_final_path = excel_input_path
            excel_output_final_path = excel_output_path
        else:
            # The in/output excel files used for the optimization will be stored in a folder at the same level as the run_cplex folder
            run_cplex_folder = os.path.dirname(os.path.dirname(run_model_path))
            run_sc_folder = os.path.join(run_cplex_folder, sc_name)
            if not os.path.exists(run_sc_folder):
                os.makedirs(run_sc_folder)
            excel_input_final_path = os.path.join(run_sc_folder, os.path.basename(excel_input_path))
            excel_output_final_path = os.path.join(run_sc_folder, os.path.basename(excel_output_path))

        shutil.move(run_excel_input_path, excel_input_final_path)
        shutil.move(run_excel_output_path, excel_output_final_path)


def run_scenarios_from_folder_local(
    excel_folder_path: str,
    output_folder: str,
    sc_list: list[str] | None = None,
    add_costs: bool = False,
    in_place: bool = True,
) -> None:
    """
    Run the optimization with for each scenario (corresponding to a single optimization configuration) given in the list and located in a subfolder of the Excel folder path

    :param excel_folder_path: The folder path containing the input and output Excel files for every scenario in their respective subfolders
    :type excel_folder_path: str
    :param output_folder: The folder path where all files will be saved
    :type output_folder: str
    :param sc_list: The list of scenario names which will be computed, defaults to None
    :type sc_list: list[str], optional
    :param add_costs: If True, the detailed repartition of the optimization costs will be added, defaults to False
    :type add_costs: bool, optional
    :param in_place: If True, the output data Excel file is modified in place, otherwise the Excel files will be found in the optimization configuration parent folder
    :type in_place: bool
    """

    if sc_list == None:
        sc_list = [f.name for f in os.scandir(excel_folder_path) if f.is_dir()]

    first_sc = sc_list[0]
    list_dir = os.listdir(os.path.join(excel_folder_path, first_sc))
    for file in list_dir:
        if file.startswith("in_prob_"):
            excel_input_path = os.path.join(excel_folder_path, first_sc, file)
    excel_output_path = excel_input_path.replace("in_prob", "out_prob")

    output_optim_folder = output_folder
    if not os.path.exists(output_optim_folder):
        os.makedirs(output_optim_folder)

    # Create all files paths
    (
        model_path,
        run_dat_path,
        run_model_path,
        run_data_folder,
        dat_costs_extension_path,
        mod_costs_extension_path,
        _,
        _,
        _,
    ) = path.get_run_paths_and_param_excel(excel_input_path, output_optim_folder)

    data = dataframes.excel_to_dataframe(excel_input_path)

    # Create the input Excel file and update the .dat file
    optimization.prepare_optimization(
        data,
        model_path,
        run_model_path,
        excel_input_path=excel_input_path,
        dat_path=run_dat_path,
        excel_output_path=excel_output_path,
        add_costs=add_costs,
        mod_costs_extension_path=mod_costs_extension_path,
        dat_costs_extension_path=dat_costs_extension_path,
    )

    # Copy the empty output file for all scenarios
    for sc_name in sc_list[1:]:
        list_dir = os.listdir(os.path.join(excel_folder_path, sc_name))
        shutil.copy(excel_output_path, os.path.join(excel_folder_path, sc_name, os.path.basename(excel_output_path)))

    # Run scenarios that appear in the scenario list
    run_scenarios_local(
        run_model_path, run_dat_path, run_data_folder, excel_folder_path, sc_list=sc_list, in_place=in_place
    )


def display_scenarios(
    excel_folder_path: str, sc_list: list[str] | None = None, add_costs: bool = False, color_blind: bool = True
) -> None:
    """
    Display optimization results for every scenario folder contained in the Excel folder

    :param excel_folder_path: The folder path containing the input and output Excel files for every scenario in their respective subfolders
    :type excel_folder_path: str
    :param sc_list: The list of scenario names which will be computed, defaults to None
    :type sc_list: list[str], optional
    :param add_costs: If True, the detailed repartition of the optimization costs will be added, defaults to False
    :type add_costs: bool, optional
    :param color_blind: If True, the color blind palette will be used, defaults to True
    :type color_blind: bool, optional
    """

    # Display all scenarios in subfolders by default
    if sc_list == None:
        sc_list = [f.name for f in os.scandir(excel_folder_path) if f.is_dir()]

    for sc_name in sc_list:
        print(sc_name)

        list_dir = os.listdir(os.path.join(excel_folder_path, sc_name))
        excel_input_path = None
        excel_output_path = None
        for file in list_dir:
            if file.startswith("in_prob_"):
                excel_input_path = os.path.join(excel_folder_path, sc_name, file)
            if file.startswith("out_prob_"):
                excel_output_path = os.path.join(excel_folder_path, sc_name, file)

        # Validate found paths
        if excel_input_path is None:
            print(f"No input file found for scenario {sc_name}, skipping")
            continue

        if excel_output_path is None:
            # Try to infer output path from input filename
            excel_output_path = excel_input_path.replace("in_prob", "out_prob")
            if not os.path.exists(excel_output_path):
                print(f"No output file found for scenario {sc_name}, skipping")
                continue

        # Get all paths and plotting parameters
        (html_path, plot_param) = path.get_display_paths_and_param_scenario(
            excel_input_path, excel_folder_path, sc_name
        )

        # Display optimization results
        display.plot_from_excel(
            excel_input_path,
            excel_output_path,
            sc_name=sc_name,
            html_path=html_path,
            client_param=plot_param,
            add_costs=add_costs,
            color_blind=color_blind,
        )


def display_optimization_series(
    excel_folder_path: str, output_folder: str, add_costs: bool = False, color_blind: bool = True
) -> None:
    """
    Display series of optimizations

    :param excel_folder_path: The folder path containing the input and output Excel files for every scenario in their respective subfolders
    :type excel_folder_path: str
    :param output_folder: The folder path where all files will be saved
    :type output_folder: str
    :param add_costs: If True, the detailed repartition of the optimization costs will be added, defaults to False
    :type add_costs: bool, optional
    :param color_blind:If True, the color blind palette will be used, defaults to True
    :type color_blind: bool, optional
    """
    # Retrieves list of subfolders corresponding to the optimization iterations
    optim_list = [f.name for f in os.scandir(excel_folder_path) if f.is_dir() and f.name.startswith("Iteration")]

    for iteration in optim_list:
        iteration_folder_path = os.path.join(excel_folder_path, iteration)
        excel_input_path = os.path.join(
            iteration_folder_path,
            [f.name for f in os.scandir(iteration_folder_path) if f.name.endswith("input.xlsx")][0],
        )
        excel_output_path = os.path.join(
            iteration_folder_path,
            [f.name for f in os.scandir(iteration_folder_path) if f.name.endswith("output.xlsx")][0],
        )

        # Get all paths and plotting parameters
        (_, html_path_basic, plot_param) = path.get_display_paths_and_param_excel(excel_input_path, output_folder)
        html_basic_filename = os.path.splitext(os.path.basename(html_path_basic))[0]
        html_path_iteration = os.path.join(
            os.path.dirname(html_path_basic), html_basic_filename + "_" + iteration + ".html"
        )
        print(html_path_iteration)

        # Display optimization results
        display.plot_from_excel(
            excel_input_path,
            excel_output_path,
            sc_name=None,
            html_path=html_path_iteration,
            client_param=plot_param,
            add_costs=add_costs,
            color_blind=color_blind,
        )


def compare_from_excel(
    excel_input_init_path: str,
    excel_output_init_path: str,
    excel_input_forced_path: str,
    excel_output_forced_path: str,
    output_folder: str | None = None,
    color_blind: bool = False,
):
    """
    Compare an initial optimization from Excel files with a forced optimization from Excel files

    :param excel_input_init_path: The initial input data Excel file path
    :type excel_input_init_path: str
    :param excel_output_init_path: The initial output data Excel file path
    :type excel_output_init_path: str
    :param excel_input_forced_path: The forced input data Excel file path
    :type excel_input_forced_path: str
    :param excel_output_forced_path: The forced output data Excel file path
    :type excel_output_forced_path: str
    :param output_folder: The folder path where all files will be saved, defaults to None
    :type output_folder: str
    :param color_blind: If True, the color blind palette will be used, defaults to False
    :type color_blind: bool, optional
    """

    # Load initial optimization data
    data_in_i = dataframes.excel_to_dataframe(excel_input_init_path)
    data_out_i = dataframes.excel_to_dataframe(excel_output_init_path)

    # Load forced optimization data
    data_in_f = dataframes.excel_to_dataframe(excel_input_forced_path)
    data_out_f = dataframes.excel_to_dataframe(excel_output_forced_path)

    # Get paths and plotting parameters
    html_path, plot_param = path.get_compare_paths_excel(excel_input_init_path, output_folder=output_folder)

    # Compare the optimizations
    compare.compare_from_input_output_data(
        data_in_i,
        data_out_i,
        data_in_f,
        data_out_f,
        html_path=html_path,
        subplots_param=plot_param,
        color_blind=color_blind,
    )


def compare_from_json_excel(
    json_init_path: str,
    excel_input_forced_path: str,
    excel_output_forced_path: str,
    output_folder: str | None = None,
    color_blind: bool = False,
):
    """
    Compare an initial optimization from a .json file with a forced optimization from Excel files

    :param json_init_path: The optimization job path (can be a .json or a .txt)
    :type json_init_path: str
    :param excel_input_forced_path: The forced input data Excel file path
    :type excel_input_forced_path: str
    :param excel_output_forced_path: The forced output data Excel file path
    :type excel_output_forced_path: str
    :param output_folder: The folder path where all files will be saved, defaults to None
    :type output_folder: str
    :param color_blind: If True, the color blind palette will be used, defaults to False
    :type color_blind: bool, optional
    """

    # Load initial optimization data
    data_in_i, data_out_i = dataframes.json_to_input_output_dataframes(json_init_path)

    # Load forced optimization data
    data_in_f = dataframes.excel_to_dataframe(excel_input_forced_path)
    data_out_f = dataframes.excel_to_dataframe(excel_output_forced_path)

    # Get paths and optimization data
    html_path, plot_param = path.get_compare_paths_json(json_init_path, output_folder=output_folder)

    # Compare the optimizations
    compare.compare_from_input_output_data(
        data_in_i,
        data_out_i,
        data_in_f,
        data_out_f,
        html_path=html_path,
        subplots_param=plot_param,
        color_blind=color_blind,
    )


# DISTANT OPTIMIZATIONS (IBM CLOUD) ------------------------------------------------------------------------------------------


def run_from_excel_and_display_distant(
    excel_input_path: str, output_folder: str, add_costs: bool = True, color_blind: bool = False
) -> None:
    """
    Replay in the distant environment the optimization job from the Excel files and display the recomputed display

    :param excel_input_path: The input data Excel file path
    :type excel_input_path: str
    :param output_folder: The folder path where all files will be saved
    :type output_folder: str
    :param add_costs: If True, the detailed repartition of the optimization costs will be added, defaults to True
    :type add_costs: bool, optional
    :param color_blind: If True, the color blind palette will be used, defaults to False
    :type color_blind: bool, optional
    """

    config = load_config()
    ibm_watson_ml_properties = config.to_dict()

    data = dataframes.excel_to_dataframe(excel_input_path)
    input_data = dataframes.get_cloud_input_from_dataframe(data)

    # Create all files paths
    (
        model_path,
        run_dat_path,
        run_model_path,
        run_data_folder,
        dat_costs_extension_path,
        mod_costs_extension_path,
        html_path,
        excel_output_path,
        plot_param,
    ) = path.get_run_paths_and_param_excel(excel_input_path, output_folder)
    output_path = excel_output_path.removesuffix(".xlsx") + ".json"

    # Create the input Excel file and update the .dat file
    optimization.prepare_optimization(
        data,
        model_path,
        run_model_path,
        excel_input_path=excel_input_path,
        dat_path=run_dat_path,
        excel_output_path=excel_output_path,
        add_costs=add_costs,
        mod_costs_extension_path=mod_costs_extension_path,
        dat_costs_extension_path=dat_costs_extension_path,
    )
    print(f"All optimization files generated.\nPlease check the files at '{output_folder}'.\n")

    # Replay the optimisation
    model_id, deployment_id = optimizationIBM.create_model_and_deployment_distant(
        ibm_watson_ml_properties=ibm_watson_ml_properties, modelPath=run_model_path, modelName="OptimAnalyser"
    )
    optimizationIBM.run_optimization_distant(
        in_data=input_data,
        output_path=output_path,
        ibm_watson_ml_properties=ibm_watson_ml_properties,
        modelId=model_id,
        deploymentId=deployment_id,
    )

    # DELETE DEPLOYMENT AND MODEL
    optimizationIBM.delete_deployment_and_model_distant(
        ibm_watson_ml_properties=ibm_watson_ml_properties, model_id=model_id, deployment_id=deployment_id
    )

    # Save optimization results in Excel file
    dataframes.dataframe_to_excel(dataframes.json_to_dataframe(output_path), excel_output_path)
    data_recomputed = dataframes.json_to_dataframe(output_path)

    # Display results and save the graphs in a html file
    display.plot_from_data(
        all_data=data_recomputed,  # This should keep the data from the .json and replace the recomputed sheets
        sc_name=None,
        html_path=html_path,
        subplots_param=plot_param,
        color_blind=color_blind,
    )


def replay_from_json_and_display_distant(
    json_path: str, output_folder: str, add_costs: bool = True, color_blind: bool = False
) -> None:
    """
    Replay in the distant environment the optimization job from the .json and display the recomputed display

    :param json_path: The optimization job path (can be a .json or a .txt)
    :type json_path: str
    :param output_folder: The folder path where all files will be saved
    :type output_folder: str
    :param add_costs: If True, the detailed repartition of the optimization costs will be added, defaults to True
    :type add_costs: bool, optional
    :param color_blind: If True, the color blind palette will be used, defaults to False
    :type color_blind: bool, optional
    """

    config = load_config()
    ibm_watson_ml_properties = config.to_dict()

    # Load data from .json
    data = dataframes.json_to_dataframe(json_path)
    input_data = dataframes.get_cloud_input_from_dataframe(data)

    # Get all paths and plotting parameters
    (
        excel_init_path,
        excel_input_path,
        excel_output_path,
        model_path,
        run_dat_path,
        run_model_path,
        _,
        dat_costs_extension_path,
        mod_costs_extension_path,
        html_path,
        plot_param,
    ) = path.get_run_paths_and_param_json(json_path, output_folder)
    output_path = excel_output_path.removesuffix(".xlsx") + ".json"

    # Create the excel with all initial data contained in the optimisation job (.json)
    optimization.prepare_excel_initial_data(data, excel_init_path)

    # Create the input Excel file and update the .dat file
    optimization.prepare_optimization(
        data,
        model_path,
        run_model_path,
        excel_input_path=excel_input_path,
        dat_path=run_dat_path,
        excel_output_path=excel_output_path,
        add_costs=add_costs,
        mod_costs_extension_path=mod_costs_extension_path,
        dat_costs_extension_path=dat_costs_extension_path,
    )
    print(f"All optimization files generated.\nPlease check the files at '{output_folder}'.\n")

    # Replay the optimisation
    model_id, deployment_id = optimizationIBM.create_model_and_deployment_distant(
        ibm_watson_ml_properties=ibm_watson_ml_properties, modelPath=run_model_path, modelName="OptimAnalyser"
    )
    optimizationIBM.run_optimization_distant(
        in_data=input_data,
        output_path=output_path,
        ibm_watson_ml_properties=ibm_watson_ml_properties,
        modelId=model_id,
        deploymentId=deployment_id,
    )

    # DELETE DEPLOYMENT AND MODEL
    optimizationIBM.delete_deployment_and_model_distant(
        ibm_watson_ml_properties=ibm_watson_ml_properties, model_id=model_id, deployment_id=deployment_id
    )

    # Save optimization results in Excel file
    dataframes.dataframe_to_excel(dataframes.json_to_dataframe(output_path), excel_output_path)
    data_recomputed = dataframes.json_to_dataframe(output_path)

    # Display results and save the graphs in a html file
    display.plot_from_data(
        all_data=data_recomputed, sc_name=None, html_path=html_path, subplots_param=plot_param, color_blind=color_blind
    )


def run_scenarios_distant(model_id: str, deployment_id: str, excel_folder_path: str, sc_list: list[str]) -> None:
    """
    Run multiple times in the distant environment the given optimization configuration with for each scenario given in the list and located in a subfolder of the Excel folder path

    :param model_id: The ID of the WML model
    :type model_id: str
    :param deployment_id: The ID of the WML model deployment
    :type deployment_id: str
    :param excel_folder_path: The folder path containing the input and output Excel files for every scenario in their respective subfolders
    :type excel_folder_path: str
    :param sc_list: The scenario names list
    :type sc_list: list[str]
    """

    config = load_config()
    ibm_watson_ml_properties = config.to_dict()

    for sc_name in sc_list:
        print(sc_name)
        list_dir = os.listdir(os.path.join(excel_folder_path, sc_name))
        for file in list_dir:
            if file.startswith("in_prob_"):
                excel_input_path = os.path.join(excel_folder_path, sc_name, file)
        excel_output_path = excel_input_path.replace("in_prob", "out_prob")
        output_path = excel_output_path.removesuffix(".xlsx") + ".json"

        data = dataframes.excel_to_dataframe(excel_input_path)
        input_data = dataframes.get_cloud_input_from_dataframe(data)

        optimizationIBM.run_optimization_distant(
            in_data=input_data,
            output_path=output_path,
            ibm_watson_ml_properties=ibm_watson_ml_properties,
            modelId=model_id,
            deploymentId=deployment_id,
        )

        dataframes.dataframe_to_excel(dataframes.json_to_dataframe(output_path), excel_output_path)


def run_scenarios_from_folder_distant(
    excel_folder_path: str, output_folder: str, sc_list: list[str] | None = None, add_costs: bool = False
) -> None:
    """
    Run the optimization in the distant environment with for each scenario (corresponding to a single optimization configuration) given in the list and located in a subfolder of the Excel folder path

    :param excel_folder_path: The folder path containing the input and output Excel files for every scenario in their respective subfolders
    :type excel_folder_path: str
    :param output_folder: The folder path where all files will be saved
    :type output_folder: str
    :param sc_list: The list of scenario names which will be computed, defaults to None
    :type sc_list: list[str], optional
    :param add_costs: If True, the detailed repartition of the optimization costs will be added, defaults to False
    :type add_costs: bool, optional
    """

    config = load_config()
    ibm_watson_ml_properties = config.to_dict()

    if sc_list == None:
        sc_list = [f.name for f in os.scandir(excel_folder_path) if f.is_dir()]

    first_sc = sc_list[0]
    list_dir = os.listdir(os.path.join(excel_folder_path, first_sc))
    for file in list_dir:
        if file.startswith("in_prob_"):
            excel_input_path = os.path.join(excel_folder_path, first_sc, file)
    excel_output_path = excel_input_path.replace("in_prob", "out_prob")

    output_optim_folder = output_folder
    if not os.path.exists(output_optim_folder):
        os.makedirs(output_optim_folder)

    # Create all files paths
    (model_path, run_dat_path, run_model_path, _, dat_costs_extension_path, mod_costs_extension_path, _, _, _) = (
        path.get_run_paths_and_param_excel(excel_input_path, output_optim_folder)
    )

    data = dataframes.excel_to_dataframe(excel_input_path)

    # Create the input Excel file and update the .dat file
    optimization.prepare_optimization(
        data,
        model_path,
        run_model_path,
        excel_input_path=excel_input_path,
        dat_path=run_dat_path,
        excel_output_path=excel_output_path,
        add_costs=add_costs,
        mod_costs_extension_path=mod_costs_extension_path,
        dat_costs_extension_path=dat_costs_extension_path,
    )

    model_id, deployment_id = optimizationIBM.create_model_and_deployment_distant(
        ibm_watson_ml_properties=ibm_watson_ml_properties, modelPath=run_model_path, modelName="OptimAnalyser"
    )
    print("In main " + model_id)

    # Run scenarios that appear in the scenario list
    run_scenarios_distant(model_id, deployment_id, excel_folder_path, sc_list=sc_list)

    # DELETE DEPLOYMENT AND MODEL
    optimizationIBM.delete_deployment_and_model_distant(
        ibm_watson_ml_properties=ibm_watson_ml_properties, model_id=model_id, deployment_id=deployment_id
    )
