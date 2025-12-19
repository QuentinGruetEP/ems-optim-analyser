import pandas as pd

from optim_analyser.errors import OptimizationFail
from optim_analyser.optim import dataframes, optimization


def replay_optimization(model_path: str, dat_path: str, data: dict[str, pd.DataFrame], excel_output_path: str) -> None:
    """
    Run the optimization configuration given by the OPL model file and the .dat file, and allow comparison of the initial and recomputed objective values

    :param model_path: The OPL model file (.mod) path
    :type model_path: str
    :param dat_path: The .dat file path
    :type dat_path: str
    :param data: The initial optimization input and output data
    :type data: dict[str,pd.DataFrame]
    :param excel_output_path: The path to the recomputed output data Excel file that will be created when running the optimization configuration
    :type excel_output_path: str
    """
    optimization.run_optimization(model_path=model_path, dat_path=dat_path)
    optimiser_objective_value_init = (
        data["OPERATION_OUTPUT"].set_index("param_id").transpose()["optimiser_objective_value"]["param_val"]
    )
    output_data = dataframes.excel_to_dataframe(excel_output_path)
    if any([output_data[sheet_name].columns.tolist() == [] for sheet_name in output_data.keys()]):
        raise OptimizationFail("No optimization output data")
    optimiser_objective_value_recomputed = (
        output_data["OPERATION_OUTPUT"].set_index("param_id").transpose()["optimiser_objective_value"]["param_val"]
    )
    print("Initial optimiser_objective_value : ", optimiser_objective_value_init)
    print("Recomputed optimiser_objective_value : ", optimiser_objective_value_recomputed)

    # assert(round(optimiser_objective_value_init,4) == round(optimiser_objective_value_recomputed,4))
