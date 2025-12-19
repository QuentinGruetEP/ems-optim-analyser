# EMS Optim Analyser

[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/)
[![CI](https://github.com/QuentinGruetEP/ems-optim-analyser/workflows/CI/badge.svg)](https://github.com/QuentinGruetEP/ems-optim-analyser/actions/workflows/ci.yml)
[![License: Proprietary](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)
[![codecov](https://codecov.io/gh/QuentinGruetEP/ems-optim-analyser/graph/badge.svg?token=s04F9n0lSW)](https://codecov.io/gh/QuentinGruetEP/ems-optim-analyser)

Analysis and visualization tool for EMS microgrid optimization results. Visualize, replay, and compare CPLEX optimization runs from IBM Watson Machine Learning.

**Key Features**: Interactive Plotly visualizations • Local/remote replay • Multi-job comparison • Color-blind palettes • Excel export • GUI + CLI

**For**: Optimization engineers debugging microgrid behavior • Data analysts visualizing energy flows

## Quick Start

**Prerequisites**: Python 3.10+ | IBM Watson ML account (optional) | CPLEX (optional)

```bash
# Clone and install
git clone https://github.com/energypool/ems-optim-analyser.git
cd ems-optim-analyser
python -m venv .venv
.venv\Scripts\activate  # or: source .venv/bin/activate (Linux/Mac)
pip install -e .

# Optional: Add IBM credentials to .env
echo "IBM_API_KEY=your_key" >> .env
echo "IBM_SPACE_ID=your_space" >> .env
```

## Usage

**GUI**: Launch with `python -m optim_analyser`

**CLI Commands**:
```bash
python -m optim_analyser display results.json                    # Visualize results
python -m optim_analyser replay-local input.json --output ./out  # Replay with CPLEX
python -m optim_analyser replay-remote input.json --output ./out # Replay on IBM Watson ML
python -m optim_analyser compare job1.json job2.json job3.json   # Compare multiple runs
python -m optim_analyser --help                                  # Show all commands
```

## Project Structure

```
ems-optim-analyser/
├── src/optim_analyser/      # Main package
│   ├── models.py            # Domain models (dataclasses)
│   ├── errors.py            # Error hierarchy
│   ├── config.py            # Configuration management
│   ├── analysis/            # Visualization and analysis
│   │   ├── services/        # Business logic (Display, Replay, Comparison)
│   │   ├── display.py       # Plotly visualization
│   │   └── compare.py       # Comparison logic
│   ├── ibm/                 # IBM Watson ML integration
│   │   ├── modelDeploymentWithRestClient.py
│   │   ├── jobWMLRestClient.py
│   │   └── optimizationIBM.py
│   ├── optim/               # CPLEX optimization
│   │   ├── dataframes.py    # Data transformation
│   │   ├── optimization.py  # Optimization prep
│   │   └── replay.py        # Local replay
│   ├── app/                 # GUI (Tkinter)
│   └── cli.py               # CLI
├── tests/                   # pytest suite
├── resources/               # CPLEX models, configs
├── docs/architecture.md     # Technical architecture
└── scripts/build_executable.py  # Build standalone .exe
```

See [docs/architecture.md](docs/architecture.md) for technical details.

## Development

```bash
# Setup
pip install -e ".[dev]"
pre-commit install

# Test
pytest                                          # All tests
pytest --cov=optim_analyser --cov-report=html  # With coverage

# Quality checks (runs on commit)
black src/ tests/                               # Format
mypy src/                                       # Type check
flake8 src/ tests/                              # Lint
bandit -r src/                                  # Security scan

# Build standalone .exe
python scripts/build_executable.py
```

## Troubleshooting

**GUI won't launch**: `python -c "import optim_analyser"` to verify installation

**Import errors**: Ensure `pip install -e .` and Python 3.10+

**IBM connection fails**: Check `.env` credentials and network

## Contributing

Fork → Create branch → Add tests → Run `pre-commit run --all-files` → Commit → Open PR

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License & Support

**License**: Copyright © 2025 Energy Pool. Proprietary and confidential.

**Support**: [GitHub Issues](https://github.com/energypool/ems-optim-analyser/issues) | [CHANGELOG.md](CHANGELOG.md)

**Built with**: IBM Watson Machine Learning • CPLEX • Plotly • Python 3.10+
