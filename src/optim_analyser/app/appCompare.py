import tkinter as tk
from tkinter import ttk

from optim_analyser.optim.path import output_path
from optim_analyser.analysis import analyse
from optim_analyser.app.appOptimJob import OptimJob
from optim_analyser.app import appOptimJob

class Comparison(ttk.Frame):
    # Frame with all tools to compare already computed optimizations
    
    def __init__(self, parent, controller):
        ttk.Frame.__init__(self, parent)
        self.columnconfigure(0,weight=1)
        self.rowconfigure([2,3], weight=1)
        
        controller.enable_returning_to_menu(self)

        self.frame_options = ttk.Frame(self)
        self.frame_options.grid(column=0, row=1, padx=20, pady=5, sticky='ew')
        self.color_blind = True
        self.color_blind_var = tk.BooleanVar()
        self.color_blind_var.set(True)
        self.checkbutton_color_blind = ttk.Checkbutton(self.frame_options,
                                                 text='Color blind palette',
                                                 variable=self.color_blind_var,
                                                 command=self.update_color_blind,
                                                 onvalue=True,
                                                 offvalue=False)
        self.checkbutton_color_blind.grid(column=0, row=1)

        self.job_init = OptimJob()
        self.frame_optim_init = ttk.Labelframe(self, text="Initial optimization")
        self.frame_optim_init.grid(column=0, row=2, padx=10, pady=5, sticky='ew')
        self.frame_optim_init.columnconfigure(0,weight=1)

        # Import initial optimization as Excel files
        self.frame_optim_init_excel_json = ttk.Frame(self.frame_optim_init)
        self.frame_optim_init_excel_json.grid(column=0, row=0, padx=10, pady=5, sticky='ew')
        self.frame_optim_init_excel_json.columnconfigure([1],weight=1)
        self.label_txt_optim_init_input_excel = ttk.Label(self.frame_optim_init_excel_json, text="Import Excel files :")
        self.label_txt_optim_init_input_excel_in_selected = ttk.Label(self.frame_optim_init_excel_json, text=self.job_init.excel_input_path)
        self.label_txt_optim_init_input_excel_out_selected = ttk.Label(self.frame_optim_init_excel_json, text=self.job_init.excel_output_path)

        self.button_optim_init_excel_in = ttk.Button(self.frame_optim_init_excel_json, text="Select Excel input file",
                                            command=(lambda:[appOptimJob.click_choose_excel_in(self.job_init, self.label_txt_optim_init_input_excel_in_selected),
                                                                self.check_files(self.job_init, self.job_forced)]))
        self.button_optim_init_excel_out = ttk.Button(self.frame_optim_init_excel_json, text="Select Excel output file",
                                                command=(lambda:[appOptimJob.click_choose_excel_out(self.job_init, self.label_txt_optim_init_input_excel_out_selected),
                                                                self.check_files(self.job_init, self.job_forced)]))
        
        self.label_txt_optim_init_input_excel.grid(column=0, row=0, sticky='w')
        self.label_txt_optim_init_input_excel_in_selected.grid(column=1, row=1)
        self.button_optim_init_excel_in.grid(column=0, row=1, sticky='w')
        self.label_txt_optim_init_input_excel_out_selected.grid(column=1, row=2)
        self.button_optim_init_excel_out.grid(column=0, row=2, sticky='w')

        # Import initial optimization as json file
        self.label_txt_optim_init_or = ttk.Label(self.frame_optim_init_excel_json, text="OR")
        self.label_txt_optim_init_json = ttk.Label(self.frame_optim_init_excel_json, text="Import json file :")
        self.label_txt_optim_init_json_selected = ttk.Label(self.frame_optim_init_excel_json, text=self.job_init.json_path)
        self.button_optim_init_json = ttk.Button(self.frame_optim_init_excel_json, text="Select json file",
                                        command=(lambda:[appOptimJob.click_choose_json(self.job_init, self.label_txt_optim_init_json_selected),
                                                            self.check_files(self.job_init, self.job_forced)]))
        self.label_txt_optim_init_or.grid(column=0, row=3, sticky='w')
        self.label_txt_optim_init_json.grid(column=0, row=4, sticky='w')
        self.label_txt_optim_init_json_selected.grid(column=1, row=5)
        self.button_optim_init_json.grid(column=0, row=5, sticky='w')
        
        self.job_forced = OptimJob()
        self.frame_optim_forced = ttk.Labelframe(self, text="Forced optimization")
        self.frame_optim_forced.grid(column=0, row=3, padx=10, pady=5, sticky='ew')
        self.frame_optim_forced.columnconfigure(0,weight=1)
        
        self.frame_optim_forced_excel = ttk.Frame(self.frame_optim_forced)
        self.frame_optim_forced_excel.grid(column=0, row=0, padx=10, pady=5, sticky='ew')
        self.frame_optim_forced_excel.columnconfigure([1],weight=1)
        self.label_txt_optim_forced_input_excel = ttk.Label(self.frame_optim_forced_excel, text="Import Excel files :")
        self.label_txt_optim_forced_input_excel_in_selected = ttk.Label(self.frame_optim_forced_excel, text=self.job_forced.excel_input_path)
        self.label_txt_optim_forced_input_excel_out_selected = ttk.Label(self.frame_optim_forced_excel, text=self.job_forced.excel_output_path)

        self.button_optim_forced_excel_in = ttk.Button(self.frame_optim_forced_excel, text="Select Excel input file",
                                                command=(lambda:[appOptimJob.click_choose_excel_in(self.job_forced, self.label_txt_optim_forced_input_excel_in_selected),
                                                                self.check_files(self.job_init, self.job_forced)]))
        self.button_optim_forced_excel_out = ttk.Button(self.frame_optim_forced_excel, text="Select Excel output file",
                                                command=(lambda:[appOptimJob.click_choose_excel_out(self.job_forced, self.label_txt_optim_forced_input_excel_out_selected),
                                                                self.check_files(self.job_init, self.job_forced)]))
        
        self.label_txt_optim_forced_input_excel.grid(column=0, row=0, sticky='w')
        self.label_txt_optim_forced_input_excel_in_selected.grid(column=1, row=1)
        self.button_optim_forced_excel_in.grid(column=0, row=1, sticky='w')
        self.label_txt_optim_forced_input_excel_out_selected.grid(column=1, row=2)
        self.button_optim_forced_excel_out.grid(column=0, row=2, sticky='w')

        
        self.button_compare_excels = ttk.Button(self, text="Compare with initial Excel files",
                                        command=lambda:self.compare_excels(self.job_init.excel_input_path, self.job_init.excel_output_path, self.job_forced.excel_input_path, self.job_forced.excel_output_path, color_blind=self.color_blind))
        self.button_compare_json_excels = ttk.Button(self, text="Compare with initial json",
                                            command=lambda:self.compare_json_excel(self.job_init.json_path, self.job_forced.excel_input_path, self.job_forced.excel_output_path, color_blind=self.color_blind))

    def update_color_blind(self):
        self.color_blind = self.color_blind_var.get()

    def update_add_costs(self):
        self.add_costs = self.add_costs_var.get()
    
    def check_files(self, job_i:OptimJob, job_f:OptimJob):
        json_init_ready = job_i.json_path != None and (job_i.json_path.endswith(".json") or job_i.json_path.endswith(".txt"))
        excel_init_ready = (job_i.excel_input_path != None and job_i.excel_input_path.endswith(".xlsx") and
                            job_i.excel_output_path != None and job_i.excel_output_path.endswith(".xlsx"))
        excel_forced_ready = (job_f.excel_input_path != None and job_f.excel_input_path.endswith(".xlsx") and
                            job_f.excel_output_path != None and job_f.excel_output_path.endswith(".xlsx"))
        row=4
        if json_init_ready and excel_forced_ready:
            self.button_compare_json_excels.grid(column=0, row=row, pady=5)
        else :
            self.button_compare_json_excels.grid_forget()
        if excel_init_ready and excel_forced_ready:
            if json_init_ready and excel_forced_ready: # button_compare_json_excels is already displayed
                row+=1
            self.button_compare_excels.grid(column=0, row=row, pady=5)
        else :
            self.button_compare_excels.grid_forget()
    
    def compare_excels(self,
                       excel_input_init_path:str, excel_output_init_path:str,
                       excel_input_forced_path:str, excel_output_forced_path:str,
                       output_folder:str=output_path('./output/'), color_blind:bool=False):
        analyse.display_from_excel(excel_input_init_path, excel_output_init_path, output_folder, "Initial behavior", color_blind)
        analyse.display_from_excel(excel_input_forced_path, excel_output_forced_path, output_folder, "Forced behavior", color_blind)
        analyse.compare_from_excel(excel_input_init_path, excel_output_init_path,
                                excel_input_forced_path, excel_output_forced_path,
                                output_folder, color_blind)
    def compare_json_excel(self,
                           json_init_path:str,
                           excel_input_forced_path:str, excel_output_forced_path:str,
                           html_path:str=output_path('./output/comparison.html'), color_blind:bool=False):
        analyse.display_from_json(json_init_path, output_path('./output/'), color_blind=True)
        analyse.display_from_excel(excel_input_forced_path, excel_output_forced_path, output_path('./output/'), "Forced behavior", color_blind)
        analyse.compare_from_json_excel(json_init_path, excel_input_forced_path, excel_output_forced_path, html_path, color_blind)
