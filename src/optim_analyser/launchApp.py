"""
DEPRECATED: This file is deprecated and will be removed in a future version.

Use the proper entry point instead:
    python -m optim_analyser
    
Or install the package and use:
    optim-analyser-gui
    
See README.md for details.
"""

import warnings

warnings.warn(
    "launchApp.py is deprecated. Use 'python -m optim_analyser' instead.",
    DeprecationWarning,
    stacklevel=2
)

if __name__ == "__main__":
    print("=" * 70)
    print("WARNING: This file is deprecated!")
    print("=" * 70)
    print()
    print("Please use one of these commands instead:")
    print()
    print("  python -m optim_analyser")
    print("  .\\run_gui.bat")
    print()
    print("Or after installation:")
    print("  optim-analyser-gui")
    print()
    print("=" * 70)
    
    # Still run the app for backwards compatibility
    from optim_analyser.app.app import App
    app = App()
    app.mainloop()
