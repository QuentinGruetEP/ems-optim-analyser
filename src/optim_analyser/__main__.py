"""GUI entry point for Optim Analyser."""

import sys
from pathlib import Path

# Add src to path for development mode
if __name__ == "__main__":
    src_path = Path(__file__).parent.parent
    if str(src_path) not in sys.path:
        sys.path.insert(0, str(src_path))


def main():
    """Launch the GUI application."""
    try:
        from optim_analyser.app.app import App
        from optim_analyser.config import load_config

        # Load configuration
        config = load_config()

        # Launch GUI
        app = App()
        app.mainloop()

    except ImportError as e:
        print(f"Error importing required modules: {e}")
        print("Please ensure all dependencies are installed:")
        print("  pip install -e '.[dev]'")
        sys.exit(1)
    except Exception as e:
        print(f"Error launching application: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
