from __future__ import annotations

import json
import os

import pandas as pd


def json_to_dataframe(json_file: str) -> dict[str, pd.DataFrame]:
    """
    Read the .json file and return the dictionnary containing the names
    of the sheets and their content in the associated pd.Dataframes

    :param json_file: The optimization job path (can be a .json or a .txt)
    :type json_file: str
    :return: The dictionnary containing the names of the datasheets and their content
    :rtype: dict[str,pd.DataFrame]
    """

    with open(json_file, "r") as f:
        json_data = json.load(f)

        if "entity" in json_data:
            json_data = json_data["entity"]

        data = dict()

        for sheet_data in json_data["decision_optimization"]["input_data"]:
            sheet_name = sheet_data["id"]
            # Remove '.csv' from the end of the sheet name if it exists
            if sheet_name.endswith(".csv"):
                sheet_name = sheet_name[:-4]
            columns = sheet_data["fields"]
            values = sheet_data["values"]

            sheet_df = pd.DataFrame(data=values, columns=columns)
            data[sheet_name] = sheet_df

        for sheet_data in json_data["decision_optimization"]["output_data"]:
            sheet_name = sheet_data["id"]
            # Remove '.csv' from the end of the sheet name if it exists
            if sheet_name.endswith(".csv"):
                sheet_name = sheet_name[:-4]
                if sheet_name in [
                    "OPERATION_OUTPUT",
                    "OPERATION_STEPS_OUTPUT",
                    "ASSETS_OUTPUT",
                    "ASSET_STEPS_OUTPUT",
                    "VIOLATIONS_OUTPUT",
                    "MARKET_BIDS_OUTPUT",
                    "ASSET_STEPS_COST",
                    "STEP_COSTS",
                    "COSTS",
                ]:
                    columns = sheet_data["fields"]
                    values = sheet_data["values"]
                    sheet_df = pd.DataFrame(data=values, columns=columns)
                    data[sheet_name] = sheet_df

    return data


def json_to_input_output_dataframes(json_file: str) -> tuple[dict[str, pd.DataFrame], dict[str, pd.DataFrame]]:
    """
    Read the .json file and return the dictionnary containing the names
    of the sheets and their content in the associated pd.Dataframes

    :param json_file: The optimization job path (can be a .json or a .txt)
    :type json_file: str
    :return: The dictionnaries containing the names of the input and output datasheets and their content
    :rtype: dict[str,pd.DataFrame],dict[str,pd.DataFrame]
    """

    with open(json_file, "r") as f:
        json_data = json.load(f)

        if "entity" in json_data:
            json_data = json_data["entity"]

        data_in = dict()
        data_out = dict()
        for sheet_data in json_data["decision_optimization"]["input_data"]:
            sheet_name = sheet_data["id"]
            # Remove '.csv' from the end of the sheet name if it exists
            if sheet_name.endswith(".csv"):
                sheet_name = sheet_name[:-4]
            columns = sheet_data["fields"]
            values = sheet_data["values"]

            sheet_df = pd.DataFrame(data=values, columns=columns)
            data_in[sheet_name] = sheet_df

        for sheet_data in json_data["decision_optimization"]["output_data"]:
            sheet_name = sheet_data["id"]
            # Remove '.csv' from the end of the sheet name if it exists
            if sheet_name.endswith(".csv"):
                sheet_name = sheet_name[:-4]
            columns = sheet_data["fields"]
            values = sheet_data["values"]

            sheet_df = pd.DataFrame(data=values, columns=columns)
            data_out[sheet_name] = sheet_df
            if sheet_name == "OPERATION_STEPS_OUTPUT":
                break

    return data_in, data_out


def dataframe_to_excel(dataframe: dict[str, pd.DataFrame], output_file: str) -> None:
    """
    Save the data as an Excel with multiple sheets in the output_file

    :param dataframe: The dictionnary containing the names of the datasheets and their content
    :type dataframe: dict[str,pd.DataFrame]
    :param output_file: The saved Excel file path
    :type output_file: str
    :rtype: None
    """
    # Create the output directory if it does not exist
    output_dir = os.path.dirname(output_file)
    if output_dir:  # Only create if a directory path is specified
        os.makedirs(output_dir, exist_ok=True)

    # Use ExcelWriter to save multiple sheets in one Excel file
    with pd.ExcelWriter(output_file, engine="openpyxl") as writer:
        for sheet_name, sheet_data in dataframe.items():
            # Write the DataFrame to the Excel file
            sheet_data.to_excel(writer, sheet_name=sheet_name, index=False)


def excel_to_dataframe(excel_file: str) -> dict[str, pd.DataFrame]:
    """
    Read an Excel file and return its data

    :param excel_file: The saved Excel file path
    :type excel_file: str
    :return: The dictionnary containing the names of the datasheets and their content
    :rtype: dict[str,pd.DataFrame]
    """
    # Use ExcelWriter to save multiple sheets in one Excel file
    return pd.read_excel(excel_file, sheet_name=None, engine="openpyxl")


def dataframe_to_csvs(dataframe: dict[str, pd.DataFrame], output_folder: str) -> None:
    """
    Save the given data as multiple csv files

    :param dataframe: The dictionnary containing the names of the datasheets and their content
    :type dataframe: dict[str,pd.DataFrame]
    :param output_folder: The path to save the multiple csv files
    :type output_folder: str
    :rtype: None
    """
    # Guarantee that the output folder exists, or create it
    os.makedirs(output_folder, exist_ok=True)

    for sheet_name, sheet_data in dataframe.items():
        # Build the path for the Excel file of this sheet
        csv_file_path = os.path.join(output_folder, f"{sheet_name}")
        # Write the datafile as a .csv
        sheet_data.to_csv(csv_file_path, index=False)


def get_cloud_input_from_dataframe(input_data: dict[str, pd.DataFrame]) -> list[dict]:
    """
    Get the formatted optimization input data that can be used to create a job on IBM cloud

    :param input_data: The dictionnary containing the names of the input datasheets and their content
    :type input_data: dict[str, pd.DataFrame]
    :return: The list containing the formatted input data required to run the job
    :rtype: list[dict]
    """
    json_list_of_dict = []
    for sheet_name in input_data.keys():
        # Convert excel to string
        # (define orientation of document in this case from up to down)
        values = (
            input_data[sheet_name]
            .to_json(orient="split", index=False)
            .replace('"columns":', '"fields":', 1)
            .replace('"data":', '"values":', 1)
        )
        values = values.replace("{", '{"id": "' + sheet_name + '.csv",\n')

        json_list_of_dict.append(json.loads(values))
    return json_list_of_dict


if __name__ == "__main__":
    json_filepath = r"C:\Users\n.conil\Downloads\104349_4ac1a0cc-19f0-4a2d-9b51-9f0e4d909a34_job.json"
    data = json_to_dataframe(json_filepath)
