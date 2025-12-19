# Contributing to Optim Analyser

First off, thank you for considering contributing to Optim Analyser! 

## Code of Conduct

This project is internal to Energy Pool. All contributors are expected to maintain professional standards.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce**
- **Expected vs actual behavior**
- **Screenshots** (if applicable)
- **Environment details** (OS, Python version, etc.)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. Include:

- **Clear use case**
- **Current limitations**
- **Proposed solution**
- **Alternative solutions considered**

### Pull Requests

1. **Fork and create a branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

2. **Make your changes**
   - Follow the code style (black, isort)
   - Add tests for new features
   - Update documentation
   - Ensure all tests pass

3. **Commit your changes**
   ```bash
   git commit -m "Add amazing feature"
   ```
   Follow [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat:` New feature
   - `fix:` Bug fix
   - `docs:` Documentation changes
   - `refactor:` Code refactoring
   - `test:` Adding tests
   - `chore:` Maintenance tasks

4. **Push and create PR**
   ```bash
   git push origin feature/amazing-feature
   ```

## Development Setup

### Prerequisites

- Python 3.10+
- Git
- Virtual environment tool

### Setup Steps

```bash
# Clone repository
git clone https://github.com/energypool/ems-optim-analyser.git
cd ems-optim-analyser

# Create virtual environment
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate

# Install development dependencies
pip install -e ".[dev,build]"

# Install pre-commit hooks
pre-commit install
```

### Running Tests

```bash
# All tests
pytest

# With coverage
pytest --cov=optim_analyser --cov-report=html

# Specific markers
pytest -m unit
pytest -m integration
```

### Code Style

We use automated formatters and linters:

```bash
# Format code
black src/ tests/
isort src/ tests/

# Lint
flake8 src/ tests/
mypy src/

# Run all checks
pre-commit run --all-files
```

## Style Guidelines

### Python Code Style

- Follow **PEP 8** (enforced by flake8)
- Use **black** for formatting (120 char line length)
- Use **type hints** where appropriate
- Write **docstrings** for public functions

Example:
```python
def analyze_optimization(
    input_path: str,
    output_path: str,
    *,
    add_costs: bool = True,
    color_blind: bool = False
) -> None:
    """Analyze optimization results and generate visualizations.
    
    Args:
        input_path: Path to input JSON file
        output_path: Path for output files
        add_costs: Include cost breakdown analysis
        color_blind: Use color-blind friendly palette
        
    Raises:
        FileNotFoundError: If input file doesn't exist
        OptimizationError: If analysis fails
    """
    pass
```

### Git Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters
- Reference issues and pull requests

### Documentation

- Keep README.md up to date
- Document new configuration options
- Add examples for new features
- Update CHANGELOG.md

## Project Structure

```
src/optim_analyser/
├── __init__.py          # Package initialization
├── __main__.py          # GUI entry point
├── cli.py               # CLI commands
├── config.py            # Configuration management
├── app/                 # GUI components
├── ibm/                 # IBM Watson ML integration
├── optim/               # Optimization logic
└── analysis/            # Visualization & analysis
```

## Testing Guidelines

### Test Organization

```
tests/
├── conftest.py          # Shared fixtures
├── unit/                # Unit tests
│   ├── test_config.py
│   ├── test_ibm.py
│   └── test_analysis.py
└── integration/         # Integration tests
    └── test_workflows.py
```

### Writing Tests

```python
import pytest
from optim_analyser.config import load_config

def test_load_config_success():
    """Test successful configuration loading."""
    config = load_config(".env.example")
    assert config is not None
    assert "IBM_API_KEY" in config

@pytest.mark.integration
def test_ibm_connection():
    """Test IBM Watson ML connection."""
    # Integration test code
    pass
```

## Release Process

1. Update version in `pyproject.toml`
2. Update `CHANGELOG.md`
3. Create release branch: `release/vX.Y.Z`
4. Open PR to main
5. After merge, tag release: `git tag vX.Y.Z`
6. Push tag: `git push origin vX.Y.Z`
7. GitHub Actions will build and publish

## Questions?

Contact the development team:
- Email: dev@energypool.eu
- GitHub Issues: [Report an issue](https://github.com/energypool/ems-optim-analyser/issues)

## License

By contributing, you agree that your contributions will be licensed under the same proprietary license as the project.
