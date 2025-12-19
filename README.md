# Optim Analyser

[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/)
[![License: Proprietary](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)

**A powerful analysis and visualization tool for EMS microgrid optimization results.**

Optim Analyser helps you visualize, analyze, and debug optimization runs from the [ems-optimizer](https://github.com/energypool/ems-optimizer) project. It provides both a GUI application and CLI tools for working with IBM Watson ML optimization jobs.

## 🎯 Features

- **📊 Visualization**: Interactive plotly-based visualizations of optimization results
- **🔄 Replay**: Re-run optimization jobs locally or on IBM Watson ML
- **📈 Comparison**: Compare multiple optimization runs side-by-side
- **🎨 Customization**: Color-blind friendly palettes and configurable plotting
- **💾 Export**: Convert IBM Watson ML JSON output to Excel format
- **🖥️ Dual Interface**: Both GUI (Tkinter) and CLI available
- **📦 Standalone**: Builds to Windows executable with PyInstaller

## 🚀 Quick Start

### Prerequisites

- Python 3.10 or higher
- (Optional) IBM Watson Machine Learning account for remote optimization

### Installation

#### For Users

```bash
# Install from source
git clone https://github.com/energypool/ems-optim-analyser.git
cd ems-optim-analyser
pip install .

# Or install in development mode
pip install -e ".[dev]"
```

#### For Developers

```bash
git clone https://github.com/energypool/ems-optim-analyser.git
cd ems-optim-analyser

# Create virtual environment
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install with dev dependencies
pip install -e ".[dev,build]"

# Set up pre-commit hooks
pre-commit install
```

### Configuration

1. Copy the example configuration:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your IBM Watson ML credentials (if needed):
   ```bash
   IBM_API_KEY=your_api_key_here
   IBM_SPACE_ID=your_space_id_here
   ```

### Running the Application

#### GUI Mode
```bash
# Using installed command
optim-analyser-gui

# Or directly with Python
python -m optim_analyser
```

#### CLI Mode
```bash
# Display results from JSON
optim-analyser display path/to/results.json

# Replay optimization
optim-analyser replay path/to/input.json --output results/

# Compare multiple runs
optim-analyser compare run1.json run2.json run3.json

# Convert JSON to Excel
optim-analyser convert path/to/results.json
```

## 📖 Documentation

Full documentation is available in the [docs/](docs/) directory:

- [User Guide](docs/user-guide.md) - How to use the application
- [Configuration](docs/configuration.md) - Configuration options explained
- [Development Guide](docs/development.md) - Contributing and development setup
- [Architecture](docs/architecture.md) - Technical architecture overview

## 🏗️ Project Structure

```
ems-optim-analyser/
├── src/optim_analyser/      # Main package
│   ├── app/                 # GUI components (Tkinter)
│   ├── ibm/                 # IBM Watson ML integration
│   ├── optim/               # Optimization logic and CPLEX integration
│   ├── analysis/            # Visualization and analysis
│   ├── config.py            # Configuration management
│   └── cli.py               # Command-line interface
├── tests/                   # Test suite
├── resources/               # Configuration files, models, icons
├── docs/                    # Documentation
└── scripts/                 # Utility scripts
```

## 🔧 Development

### Running Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=optim_analyser --cov-report=html

# Run specific test categories
pytest -m unit              # Unit tests only
pytest -m integration       # Integration tests only
pytest -m "not slow"        # Skip slow tests
```

### Code Quality

```bash
# Format code
black src/ tests/
isort src/ tests/

# Lint
flake8 src/ tests/
mypy src/

# Or use pre-commit for all checks
pre-commit run --all-files
```

### Building Executable

```bash
# Build standalone Windows executable
python scripts/build_executable.py

# Output will be in dist/OptimAnalyser/
```

## 🔗 Integration with ems-optimizer

This tool is designed to work with the [ems-optimizer](https://github.com/energypool/ems-optimizer) project. 

**Workflow:**
1. ems-optimizer deploys CPLEX models to IBM Watson ML
2. Models process microgrid optimization jobs
3. Optim Analyser visualizes and analyzes the results

See the [integration guide](docs/integration.md) for details.

## 📝 Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and release notes.

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📄 License

Copyright © 2025 Energy Pool. All rights reserved.

This software is proprietary and confidential. Unauthorized copying, distribution, or use is strictly prohibited.

## 👥 Authors

- **Energy Pool Development Team**
- Maintainer: Quentin Gruet

## 🆘 Support

For issues, questions, or feature requests:
- Open an issue on [GitHub Issues](https://github.com/energypool/ems-optim-analyser/issues)
- Contact the development team at dev@energypool.eu

## 🙏 Acknowledgments

- Built with IBM Watson Machine Learning
- Uses CPLEX optimization engine
- Visualization powered by Plotly
