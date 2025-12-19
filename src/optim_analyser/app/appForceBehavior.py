from tkinter import ttk


class ForceBehavior(ttk.Frame):
    def __init__(self, parent, controller):
        ttk.Frame.__init__(self, parent)
        controller.enable_returning_to_menu(self)

        self.label = ttk.Label(self, text="Not implemented on models yet")
        self.label.grid(padx=20, pady=5, sticky="ew")
