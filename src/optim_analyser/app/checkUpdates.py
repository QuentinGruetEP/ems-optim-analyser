import os
import filecmp
import shutil
import zipfile
from tkinter import ttk


def extract_zip(zip_path: str, extract_to: str) -> None:
    with zipfile.ZipFile(zip_path, "r") as zip_ref:
        zip_ref.extractall(extract_to)


def merge_files_from_folders_rec(source: str, dest: str, label: ttk.Label):
    # List of files in both folders
    files_source = set([f.name for f in os.scandir(source) if f.is_file()])
    files_dest = set([f.name for f in os.scandir(dest) if f.is_file()])

    # List of files in both folders
    folders_source = set([d.name for d in os.scandir(source) if d.is_dir()])
    folders_dest = set([d.name for d in os.scandir(dest) if d.is_dir()])

    # New files or folders in the folder source
    files_unique_to_folder_source = files_source - files_dest
    folders_unique_to_folder_source = folders_source - folders_dest

    # Common files
    common_files = files_source.intersection(files_dest)

    # Copy unique files from source to dest
    for file in files_unique_to_folder_source:
        label.config(text="New version of OptimAnalyser released, please update yours by downloading zip on Sharepoint")
        shutil.copy(os.path.join(source, file), os.path.join(dest, file))

    # Creat new folders from source to dest
    for folder in folders_unique_to_folder_source:
        if not os.path.exists(os.path.join(dest, folder)):
            os.makedirs(os.path.join(dest, folder))

    # Merge common files
    for file in common_files:
        if not filecmp.cmp(os.path.join(source, file), os.path.join(dest, file), shallow=False):
            label.config(
                text="New version of OptimAnalyser released, please update yours by downloading zip on Sharepoint"
            )
            """
                # Merging logic here for files with differences
                if file in ["deployment_list.xlsx", "plot_param.xlsx"]:
                    # These Excels might have been customed by user : we renamed customed xlsx and copy the official versions
                    os.rename(os.path.join(dest, file), os.path.join(dest, file.replace('.xlsx', '_custom.xlsx')))
                    shutil.copy(os.path.join(source, file), os.path.join(dest, file))
                elif file != 'UpdateProperties.yml':
                    # For simplicity,  copy the version from source
                    shutil.copy(os.path.join(source, file), os.path.join(dest, file))
                """
    for folder in folders_source:
        merge_files_from_folders_rec(os.path.join(source, folder), os.path.join(dest, folder), label)


def compare_zip_to_folder_and_merge(
    zip_folder_source: str, folder_local: str, tool_name: str, label: ttk.Label
) -> None:
    temp_folder_unzip = os.path.join(folder_local, os.pardir, "tmpCheckUpdatesOptimAnalyser")
    if not os.path.exists(temp_folder_unzip):
        os.makedirs(temp_folder_unzip)
    extract_zip(zip_folder_source, temp_folder_unzip)
    temp_folder_source = os.path.join(temp_folder_unzip, tool_name)

    merge_files_from_folders_rec(temp_folder_source, folder_local, label)
    shutil.rmtree(temp_folder_unzip)


def compare_zip_to_zip(zip_source: str, zip_local: str, label: ttk.Label) -> None:
    # Create a style
    style = ttk.Style()
    style.configure("Custom.TLabel", foreground="red")
    if not filecmp.cmp(zip_source, zip_local, shallow=False):
        label.config(text="New version released, please update by downloading zip on Sharepoint", style="Custom.TLabel")
    else:
        label.config(text="Up-to-date version ", style="")


def update(update_properties: dict, label: ttk.Label) -> None:
    shortcut_sharepoint_folder_path = update_properties["SHORTCUT_SHAREPOINT_ZIP"]
    # Folder where the .zip downloaded by the user is located
    local_zip_folder = update_properties["LOCAL_ZIP"]
    compare_zip_to_zip(zip_source=shortcut_sharepoint_folder_path, zip_local=local_zip_folder, label=label)
