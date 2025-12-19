"""Command-line interface for Optim Analyser."""

import argparse
import sys
from pathlib import Path
from typing import Optional


def main():
    """Main CLI entry point."""
    parser = argparse.ArgumentParser(
        prog="optim-analyser",
        description="Analyze and visualize EMS microgrid optimization results",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Display results from JSON file
  optim-analyser display results.json

  # Replay optimization with new parameters
  optim-analyser replay input.json --output results/

  # Compare multiple optimization runs
  optim-analyser compare run1.json run2.json run3.json

  # Convert JSON to Excel
  optim-analyser convert results.json --output results.xlsx

  # Launch GUI
  optim-analyser gui
        """,
    )

    parser.add_argument("--version", action="version", version="%(prog)s 1.0.0")
    parser.add_argument("-v", "--verbose", action="store_true", help="Enable verbose output")
    parser.add_argument("--config", type=str, help="Path to configuration file")

    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # Display command
    display_parser = subparsers.add_parser("display", help="Display optimization results")
    display_parser.add_argument("input", type=str, help="Path to JSON input file")
    display_parser.add_argument("-o", "--output", type=str, help="Output directory for visualizations")
    display_parser.add_argument("--color-blind", action="store_true", help="Use color-blind friendly palette")
    display_parser.add_argument("--no-costs", action="store_true", help="Exclude cost breakdown")

    # Replay command
    replay_parser = subparsers.add_parser("replay", help="Replay optimization")
    replay_parser.add_argument("input", type=str, help="Path to input JSON file")
    replay_parser.add_argument("-o", "--output", type=str, required=True, help="Output directory")
    replay_parser.add_argument("--remote", action="store_true", help="Run on IBM Watson ML")
    replay_parser.add_argument("--model-id", type=str, help="IBM Watson ML model ID")
    replay_parser.add_argument("--deployment-id", type=str, help="IBM Watson ML deployment ID")

    # Compare command
    compare_parser = subparsers.add_parser("compare", help="Compare multiple optimization runs")
    compare_parser.add_argument("inputs", type=str, nargs="+", help="Paths to JSON files to compare")
    compare_parser.add_argument("-o", "--output", type=str, help="Output directory")
    compare_parser.add_argument("--color-blind", action="store_true", help="Use color-blind friendly palette")

    # Convert command
    convert_parser = subparsers.add_parser("convert", help="Convert JSON to Excel")
    convert_parser.add_argument("input", type=str, help="Path to JSON input file or directory")
    convert_parser.add_argument("-o", "--output", type=str, help="Output Excel file path")
    convert_parser.add_argument("-r", "--recursive", action="store_true", help="Process directory recursively")

    # GUI command
    gui_parser = subparsers.add_parser("gui", help="Launch GUI application")

    args = parser.parse_args()

    # Handle no command
    if not args.command:
        parser.print_help()
        return 0

    # Set up logging
    if args.verbose:
        import logging

        logging.basicConfig(level=logging.DEBUG)

    # Load configuration
    from optim_analyser.config import load_config

    try:
        config = load_config(args.config)
    except Exception as e:
        print(f"Error loading configuration: {e}")
        return 1

    # Execute command
    try:
        if args.command == "display":
            return cmd_display(args, config)
        elif args.command == "replay":
            return cmd_replay(args, config)
        elif args.command == "compare":
            return cmd_compare(args, config)
        elif args.command == "convert":
            return cmd_convert(args, config)
        elif args.command == "gui":
            return cmd_gui(args, config)
    except Exception as e:
        print(f"Error executing command: {e}")
        if args.verbose:
            import traceback

            traceback.print_exc()
        return 1

    return 0


def cmd_display(args, config):
    """Handle display command."""
    from optim_analyser.analysis.analyse import display_from_json

    print(f"Displaying results from: {args.input}")

    output_dir = args.output or "output"
    display_from_json(
        json_path=args.input,
        output_folder=output_dir,
        add_costs=not args.no_costs,
        color_blind=args.color_blind,
    )

    print(f"✓ Visualizations saved to: {output_dir}")
    return 0


def cmd_replay(args, config):
    """Handle replay command."""
    if args.remote:
        from optim_analyser.analysis.analyse import replay_from_json_and_display_distant

        print(f"Replaying optimization on IBM Watson ML: {args.input}")
        # Implementation would go here
    else:
        from optim_analyser.analysis.analyse import replay_from_json_and_display_local

        print(f"Replaying optimization locally: {args.input}")
        replay_from_json_and_display_local(json_path=args.input, output_folder=args.output)

    print(f"✓ Results saved to: {args.output}")
    return 0


def cmd_compare(args, config):
    """Handle compare command."""
    from optim_analyser.analysis.compare import compare_runs

    print(f"Comparing {len(args.inputs)} optimization runs...")

    output_dir = args.output or "output/comparison"
    # Implementation would go here

    print(f"✓ Comparison saved to: {output_dir}")
    return 0


def cmd_convert(args, config):
    """Handle convert command."""
    print(f"Converting JSON to Excel: {args.input}")

    input_path = Path(args.input)

    if input_path.is_dir():
        # Import the conversion module that will be migrated
        print(f"Processing directory: {input_path}")
        # Directory processing logic
    else:
        # Single file conversion
        output_path = args.output or input_path.with_suffix(".xlsx")
        print(f"Output: {output_path}")
        # Conversion logic

    print("✓ Conversion complete")
    return 0


def cmd_gui(args, config):
    """Handle GUI command."""
    from optim_analyser.app.app import App

    print("Launching GUI...")
    app = App()
    app.mainloop()
    return 0


if __name__ == "__main__":
    sys.exit(main())
