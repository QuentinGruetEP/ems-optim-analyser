from tkinter import ttk
from tkinter.filedialog import askopenfilename, askdirectory


class OptimJob:
    # Class to store optimization input and output paths
    def __init__(self):
        self.json_path = None
        self.excel_input_path = None
        self.excel_output_path = None
        self.sc_folder = None


# Commands to select a file and display the selected file path
def click_choose_json(job: OptimJob, label_txt_file_selected: ttk.Label):
    job.json_path = askopenfilename()
    label_txt_file_selected.config(text=job.json_path.split("/")[-1])


def click_choose_excel_in(job: OptimJob, label_txt_file_selected: ttk.Label):
    job.excel_input_path = askopenfilename()
    label_txt_file_selected.config(text=job.excel_input_path.split("/")[-1])


def click_choose_excel_out(job: OptimJob, label_txt_file_selected: ttk.Label):
    job.excel_output_path = askopenfilename()
    label_txt_file_selected.config(text=job.excel_output_path.split("/")[-1])


def click_choose_sc_folder(job: OptimJob, label_txt_file_selected: ttk.Label):
    job.sc_folder = askdirectory() + "/"
    label_txt_file_selected.config(text=job.sc_folder)
