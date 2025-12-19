import tkinter as tk
from tkinter import ttk


from optim_analyser.app.appDisplayRun import DisplayRun
from optim_analyser.app.appCompare import Comparison
from optim_analyser.app.appForceBehavior import ForceBehavior

class Menu(tk.Frame):
    # Frame allowing naviguation between frames
    def __init__(self, parent, controller):
        controller.title("Menu")

        ttk.Frame.__init__(self, parent)
    
        self.columnconfigure(0, weight=1)
        self.rowconfigure([0,1,2], weight=1)

        self.label_txt = ttk.Label(self, text="Optimization Analyser")
        self.label_txt.grid(column=0, row=0, pady=15, padx=150, sticky='ns')

        # Button declaration
        self.frame_button = ttk.Frame(self)
        self.frame_button.grid(column=0, row=1, padx=20, pady=10, sticky='ns')
        self.button_display = ttk.Button(self.frame_button, text="Run optimization and display optimization results",
                                   command=lambda:controller.show_frame(DisplayRun))
        self.button_display.grid(column=0, row=0, pady=5)

        self.button_compare = ttk.Button(self.frame_button, text="Compare optimizations",
                                   command=lambda:controller.show_frame(Comparison))
        self.button_compare.grid(column=0, row=1, pady=5)

        self.button_force_behavior = ttk.Button(self.frame_button, text="Force bevahior",
                                          command=lambda:controller.show_frame(ForceBehavior))
        self.button_force_behavior.grid(column=0, row=2, pady=5)

        # Update info
        self.label_txt_update_info = ttk.Label(self, text="Checking for updates ...")
        self.label_txt_update_info.grid(column=0, row=2, pady=5, padx=0, sticky='s')