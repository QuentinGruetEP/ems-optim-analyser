import ttkthemes
import tkinter as tk
from tkinter import ttk
from tkinter import messagebox
from tkinter.filedialog import askdirectory, askopenfilename
import yaml
import sys
import threading

from optim_analyser.optim.path import resource_path
from optim_analyser.app.appCompare import Comparison
from optim_analyser.app.appMenu import Menu
from optim_analyser.app.appDisplayRun import DisplayRun
from optim_analyser.app.appForceBehavior import ForceBehavior
from optim_analyser.app import checkUpdates


class App(ttkthemes.ThemedTk):
    # App is the general frame, sets general gui behavior

    def __init__(self):
        # Window initialization
        super().__init__(theme="Arc")

        # Set the initial size of the window (width x height)
        self.geometry("")  # 750x500
        self.protocol("WM_DELETE_WINDOW", self.on_closing)
        self.iconphoto(False, tk.PhotoImage(file=resource_path(["icons", "ep_icon.png"])))

        # Container
        container = ttk.Frame(self)
        container.pack(side="top", fill="both", expand=True)
        container.grid_rowconfigure(0, weight=1)
        container.grid_columnconfigure(0, weight=1)
        self.container = container

        self.available_windows = dict(
            {
                Comparison: "Compare optimization results",
                DisplayRun: "Run and display optimization results",
                ForceBehavior: "Force optimization behavior",
                Menu: "Menu",
            }
        )
        # Dictionary of frames that can be displayed, class App acts as root window for all frames
        self.frames = {}
        # Frames objects are defined in their corresponding .py files
        for F in self.available_windows.keys():
            frame = F(container, self)  # Frame object created
            self.frames[F] = frame  # Frame stored in the dictionary
            frame.grid(row=0, column=0, sticky="nsew")

        # Initial frame shown
        self.show_frame(Menu)

        # Update management
        self.update_properties_path = resource_path(["config", "UpdateProperties.yml"])
        self.init_update_path()

        # Check for updates and update files if necessary
        threading.Thread(target=self.update(), daemon=True).start()

    def show_frame(self, F):
        # Raise the current frame to the top
        self.frames[F].tkraise()
        # Set container window title to the one corresponding to the current displayed frame
        self.title(self.available_windows[F])

    def on_closing(self):
        if messagebox.askokcancel("Quit", "Do you want to quit?"):
            self.destroy()

    def enable_returning_to_menu(self, F):
        F.frame_back_to_menu = ttk.Frame(F)
        F.button_menu = ttk.Button(F.frame_back_to_menu, text="Back to menu", command=lambda: self.show_frame(Menu))
        F.frame_back_to_menu.grid(column=0, row=0, padx=5, pady=5, sticky="ew")
        F.frame_back_to_menu.columnconfigure(0, weight=1)
        F.button_menu.grid(column=0, row=0, sticky="nw")

    def init_update_path(self):
        try:
            base_path = sys._MEIPASS
            # No exception thrown means the program has been launched with an executable : need to check if files are up-to-date
            with open(self.update_properties_path, "r") as file:
                self.update_properties = yaml.safe_load(file)

            if self.update_properties["SHORTCUT_SHAREPOINT_ZIP"] in ["/", ""]:
                self.update_properties["SHORTCUT_SHAREPOINT_ZIP"] = askopenfilename(
                    title="Select shortcut to the downloadable .zip"
                )
            if self.update_properties["LOCAL_ZIP"] in ["/", ""]:
                self.update_properties["LOCAL_ZIP"] = askopenfilename(title="Select your .zip")

            # Write the updated data back to the YAML file
            with open(self.update_properties_path, "w") as file:
                yaml.dump(self.update_properties, file)
        except AttributeError:
            # No need to initialize update path since the program has been launched with Python directly
            pass

    def update(self):
        try:
            base_path = sys._MEIPASS
            # No exception thrown means the program has been launched with an executable : need to check if files are up-to-date
            checkUpdates.update(self.update_properties, self.frames[Menu].label_txt_update_info)
        except AttributeError:
            # No need to update since the program has been launched with Python directly
            self.frames[Menu].label_txt_update_info.config(text="")
