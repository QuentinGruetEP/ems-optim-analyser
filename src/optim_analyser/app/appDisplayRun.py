import tkinter as tk
from tkinter import ttk
import os
import sys
import threading

from optim_analyser.optim.path import output_path
from optim_analyser.analysis import analyse
from optim_analyser.app.appOptimJob import OptimJob
from optim_analyser.app import appOptimJob


class DisplayRun(ttk.Frame):
    # Frame with all tools to display, replay or run an optimization job or multiple scenarios

    def __init__(self, parent, controller):
        ttk.Frame.__init__(self, parent)
        controller.enable_returning_to_menu(self)
        self.columnconfigure([0, 1], weight=1)
        self.rowconfigure([1], weight=1)

        # Test folder
        self.output_folder = output_path(output_folder_name="output")
        if not os.path.exists(self.output_folder):
            os.makedirs(self.output_folder)

        # Frames to display control and console output
        self.frame_control = ttk.Frame(self)
        self.frame_control.grid(column=0, row=1, sticky="nw")
        self.frame_control.rowconfigure([1, 2, 3, 4], weight=1)
        self.frame_control.columnconfigure(0, weight=1)
        self.frame_console = ttk.Frame(self)
        self.frame_console.grid(column=1, row=1, padx=20, pady=20, sticky="nsew")
        self.frame_console.columnconfigure(0, weight=1)
        self.frame_console.rowconfigure(0, weight=1)

        # Frame with check boxes to select options
        self.frame_options = ttk.Labelframe(self.frame_control, text="Select options")
        self.frame_options.grid(column=0, row=1, padx=20, pady=5, sticky="w")
        self.color_blind = True
        self.color_blind_var = tk.BooleanVar()
        self.color_blind_var.set(self.color_blind)
        self.checkbutton_color_blind = ttk.Checkbutton(
            self.frame_options,
            text="Color blind palette",
            variable=self.color_blind_var,
            command=self.update_color_blind,
            onvalue=True,
            offvalue=False,
        )
        self.checkbutton_color_blind.grid(column=0, row=0, padx=20, sticky="w")

        self.run_local = True
        self.run_local_var = tk.BooleanVar()
        self.run_local_var.set(self.run_local)
        self.checkbutton_run_local = ttk.Checkbutton(
            self.frame_options,
            text="Run the optimization in the local environment\n(CPLEX must be installed on this device)",
            variable=self.run_local_var,
            command=self.update_run_local,
            onvalue=True,
            offvalue=False,
        )
        self.checkbutton_run_local.grid(column=0, row=1, padx=20, sticky="w")

        self.add_costs = False
        self.add_costs_var = tk.BooleanVar()
        self.add_costs_var.set(self.add_costs)
        self.checkbutton_add_costs = ttk.Checkbutton(
            self.frame_options,
            text="Add optimization costs details",
            variable=self.add_costs_var,
            command=self.update_add_costs,
            onvalue=True,
            offvalue=False,
        )
        self.checkbutton_add_costs.grid(column=0, row=2, padx=20, sticky="w")

        # Optimization selection
        self.job = OptimJob()

        self.frame_json = ttk.Labelframe(self.frame_control, text="Import json/txt file :")
        self.frame_json.grid(column=0, row=2, padx=20, pady=10, sticky="ew")
        self.frame_json.columnconfigure(0, weight=1)
        self.frame_json_select = ttk.Frame(self.frame_json)
        self.frame_json_select.grid(column=0, row=0, padx=5, pady=5, sticky="w")
        self.frame_json_button = ttk.Frame(self.frame_json)
        self.frame_json_button.grid(column=0, row=1, pady=5)
        self.label_txt_json_selected = ttk.Label(self.frame_json_select, text=self.job.json_path)
        self.button_json = ttk.Button(
            self.frame_json_select,
            text="Select json/txt",
            command=(
                lambda: [
                    appOptimJob.click_choose_json(self.job, self.label_txt_json_selected),
                    self.check_files(self.job),
                ]
            ),
        )
        self.label_txt_json_selected.grid(column=1, row=0)
        self.button_json.grid(column=0, row=0, sticky="w")

        self.frame_excel = ttk.Labelframe(self.frame_control, text="Import Excel files :")
        self.frame_excel.grid(column=0, row=3, padx=20, pady=10, sticky="ew")
        self.frame_excel.columnconfigure(0, weight=1)
        self.frame_excel_select = ttk.Frame(self.frame_excel)
        self.frame_excel_select.grid(column=0, row=0, padx=5, pady=5, sticky="w")
        self.frame_excel_button = ttk.Frame(self.frame_excel)
        self.frame_excel_button.grid(column=0, row=1, pady=5)
        self.label_txt_excel_input_selected = ttk.Label(self.frame_excel_select, text=self.job.excel_input_path)
        self.label_txt_excel_output_selected = ttk.Label(self.frame_excel_select, text=self.job.excel_output_path)
        self.button_excel_in = ttk.Button(
            self.frame_excel_select,
            text="Select Excel input file",
            command=(
                lambda: [
                    appOptimJob.click_choose_excel_in(self.job, self.label_txt_excel_input_selected),
                    self.check_files(self.job),
                ]
            ),
        )
        self.button_excel_out = ttk.Button(
            self.frame_excel_select,
            text="Select Excel output file",
            command=(
                lambda: [
                    appOptimJob.click_choose_excel_out(self.job, self.label_txt_excel_output_selected),
                    self.check_files(self.job),
                ]
            ),
        )
        self.label_txt_excel_input_selected.grid(column=1, row=0)
        self.button_excel_in.grid(column=0, row=0, sticky="w")
        self.label_txt_excel_output_selected.grid(column=1, row=1)
        self.button_excel_out.grid(column=0, row=1, sticky="w")

        self.frame_sc = ttk.Labelframe(self.frame_control, text="Import scenarios :")
        self.frame_sc.grid(column=0, row=4, padx=20, pady=10, sticky="ew")
        self.frame_sc.columnconfigure(0, weight=1)
        self.frame_sc_select = ttk.Frame(self.frame_sc)
        self.frame_sc_select.grid(column=0, row=0, padx=5, pady=5, sticky="w")
        self.frame_sc_button = ttk.Frame(self.frame_sc)
        self.frame_sc_button.grid(column=0, row=1, pady=5)
        self.label_txt_sc_selected = ttk.Label(self.frame_sc_select, text=self.job.sc_folder)
        self.button_sc = ttk.Button(
            self.frame_sc_select,
            text="Select folder",
            command=(
                lambda: [
                    appOptimJob.click_choose_sc_folder(self.job, self.label_txt_sc_selected),
                    self.check_files(self.job),
                ]
            ),
        )
        self.label_txt_sc_selected.grid(column=1, row=0)
        self.button_sc.grid(column=0, row=0, sticky="w")

        # Buttons to launch display or run/replay
        self.button_display_json = ttk.Button(
            self.frame_json_button,
            text="Display",
            command=lambda: self.display_json(self.job.json_path, self.color_blind),
        )
        self.button_display_excel = ttk.Button(
            self.frame_excel_button,
            text="Display",
            command=lambda: self.display_excel(self.job.excel_input_path, self.job.excel_output_path, self.color_blind),
        )
        self.button_display_sc = ttk.Button(
            self.frame_sc_button,
            text="Display",
            command=lambda: self.display_sc(self.job.sc_folder, self.add_costs, self.color_blind),
        )

        self.button_run_json = ttk.Button(
            self.frame_json_button,
            text="Replay",
            command=lambda: self.run_json(self.job.json_path, self.add_costs, self.color_blind, self.run_local),
        )
        self.button_run_excel = ttk.Button(
            self.frame_excel_button,
            text="Run",
            command=lambda: self.run_excel(self.job.excel_input_path, self.add_costs, self.color_blind, self.run_local),
        )
        self.button_run_sc = ttk.Button(
            self.frame_sc_button,
            text="Run",
            command=lambda: self.run_sc(self.job.sc_folder, self.add_costs, self.color_blind, self.run_local),
        )

        # Console redirected in frame
        self.console_text = tk.Text(
            self.frame_console,
            state="disabled",
        )
        self.console_text.grid(column=0, row=0, sticky="nsew")
        # create a Scrollbar and associate it with txt
        self.scrollbar = ttk.Scrollbar(self.frame_console, command=self.console_text.yview)
        self.scrollbar.grid(column=1, row=0, sticky="nsew")
        self.console_text["yscrollcommand"] = self.scrollbar.set

        # Redirect sys.stdout -> TextRedirector
        self.redirect_sysstd()

    def redirect_sysstd(self):
        # We specify that sys.stdout point to TextRedirector
        sys.stdout = TextRedirector(self.console_text, "stdout")
        sys.stderr = TextRedirector(self.console_text, "stderr")

    def update_color_blind(self):
        self.color_blind = self.color_blind_var.get()

    def update_run_local(self):
        self.run_local = self.run_local_var.get()

    def update_add_costs(self):
        self.add_costs = self.add_costs_var.get()

    def check_files(self, job: OptimJob):
        if job.json_path != None and (job.json_path.endswith(".json") or job.json_path.endswith(".txt")):
            self.button_display_json.grid(column=0, row=0, padx=2.5)
            self.button_run_json.grid(column=1, row=0, padx=2.5)
        else:
            self.button_display_json.grid_forget()
            self.button_run_json.grid_forget()
        if job.excel_input_path != None and job.excel_input_path.endswith(".xlsx"):
            self.button_run_excel.grid(column=1, row=0, padx=2.5)
            if job.excel_output_path != None and job.excel_output_path.endswith(".xlsx"):
                self.button_display_excel.grid(column=0, row=0, padx=2.5)
        else:
            self.button_display_excel.grid_forget()
            self.button_run_excel.grid_forget()
        if job.sc_folder != None:
            self.button_display_sc.grid(column=0, row=0, padx=2.5)
            self.button_run_sc.grid(column=1, row=0, padx=2.5)
        else:
            self.button_display_sc.grid_forget()
            self.button_run_sc.grid_forget()

    def display_json(self, json_path: str, color_blind: bool):
        analyse.display_from_json(json_path, self.output_folder, color_blind)

    def display_excel(self, excel_input_path: str, excel_output_path: str, color_blind: bool):
        analyse.display_from_excel(
            excel_input_path, excel_output_path, self.output_folder, sc_name=None, color_blind=color_blind
        )

    def display_sc(self, sc_folder: str, add_costs: bool, color_blind: bool):
        # In the scenario folder : directories with input and output excel files
        # in_prob_[site_name].xlsx & out_prob_[site_name].xlsx
        # All scenarios require the same model and .dat file (same number of step_id)
        analyse.display_scenarios(sc_folder, sc_list=None, add_costs=add_costs, color_blind=color_blind)

    def run_json(self, json_path: str, add_costs: bool, color_blind: bool, run_local: bool):
        if run_local:
            t = threading.Thread(
                target=analyse.replay_from_json_and_display_local(json_path, self.output_folder, add_costs, color_blind)
            )
            t.daemon = True  # close pipe if GUI process exits
            t.start()
        else:
            analyse.replay_from_json_and_display_distant(json_path, self.output_folder, add_costs, color_blind)

    def run_excel(self, excel_input_path: str, add_costs: bool, color_blind: bool, run_local: bool):
        if run_local:
            t = threading.Thread(
                target=analyse.run_from_excel_and_display_local(
                    excel_input_path, self.output_folder, self.console_text, add_costs, color_blind
                )
            )
            t.daemon = True  # close pipe if GUI process exits
            t.start()
        else:
            analyse.run_from_excel_and_display_distant(excel_input_path, self.output_folder, add_costs, color_blind)

    def run_sc(self, sc_folder: str, add_costs: bool, color_blind: bool, run_local: bool):
        # In the scenario folder : directories with input and output excel files
        # in_prob_[site_name].xlsx & out_prob_[site_name].xlsx
        # All scenarios require the same model and .dat file (same number of step_id)
        if run_local:
            t = threading.Thread(
                target=analyse.run_scenarios_from_folder_local(
                    sc_folder, output_folder=self.output_folder, sc_list=None, add_costs=add_costs, in_place=True
                )
            )
            t.daemon = True  # close pipe if GUI process exits
            t.start()

        else:
            analyse.run_scenarios_from_folder_distant(sc_folder, self.output_folder, sc_list=None, add_costs=add_costs)
        analyse.display_scenarios(sc_folder, sc_list=None, add_costs=add_costs, color_blind=color_blind)


class TextRedirector(object):
    def __init__(self, widget: tk.Text, tag: str):
        self.widget = widget
        self.tag = tag

    def write(self, text):
        self.widget.configure(state="normal")  # Edit mode
        self.widget.insert(tk.END, text, (self.tag,))  # insert new text at the end of the widget
        self.widget.configure(state="disabled")  # Static mode
        self.widget.see(tk.END)  # Scroll down
        self.widget.update_idletasks()  # Update the console

    def flush(self):
        pass
