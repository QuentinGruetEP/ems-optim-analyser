# Migration Guide

## Phase 1: Setup New Repository ✓

1. **Create repository structure** ✓
2. **Initialize git** ✓
3. **Create configuration files** ✓
4. **Set up CI/CD** ✓

## Phase 2: Copy Files (Next Steps)

### Step 1: Copy Source Code

```powershell
# From the ems-optimizer directory
cd C:\Users\quentin.gruet\Code\ems-optimizer

# Copy Python source files
robocopy optimAnalyser\src ..\ems-optim-analyser\src\optim_analyser /E /XD __pycache__

# Rename directories to match package structure
# The script will preserve: app/, ibm/, optim/, analysis/
```

### Step 2: Copy Resources

```powershell
# Copy data files
robocopy optimAnalyser\data_cplex ..\ems-optim-analyser\resources\config deployment_list.xlsx plot_param.xlsx

# Copy models
robocopy optimAnalyser\data_cplex\models ..\ems-optim-analyser\resources\models /E

# Copy documentation
copy optimAnalyser\README.md ..\ems-optim-analyser\docs\user-guide.md
```

### Step 3: Update Imports

All imports need to be updated from relative to package imports:

**Before**:
```python
from ibm import optimizationIBM
from optim.path import resource_path
from analysis import display
```

**After**:
```python
from optim_analyser.ibm import optimizationIBM
from optim_analyser.optim.path import resource_path
from optim_analyser.analysis import display
```

**Automated script** (create as `scripts/fix_imports.py`):
```python
import re
from pathlib import Path

def fix_imports(file_path):
    """Fix imports in Python file."""
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Replace relative imports with package imports
    replacements = [
        (r'^from ibm import', 'from optim_analyser.ibm import'),
        (r'^from app\.', 'from optim_analyser.app.'),
        (r'^from optim\.', 'from optim_analyser.optim.'),
        (r'^from analysis\.', 'from optim_analyser.analysis.'),
        (r'^from errors import', 'from optim_analyser.errors import'),
    ]
    
    for pattern, replacement in replacements:
        content = re.sub(pattern, replacement, content, flags=re.MULTILINE)
    
    with open(file_path, 'w') as f:
        f.write(content)

# Run on all Python files
for py_file in Path('src/optim_analyser').rglob('*.py'):
    fix_imports(py_file)
```

### Step 4: Fix Hardcoded Paths

**Create migration script** (`scripts/fix_paths.py`):
```python
from pathlib import Path
import re

def fix_paths(file_path):
    """Replace hardcoded paths with config-based paths."""
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Look for hardcoded path patterns
    patterns = [
        (r'C:\\Users\\[^"]+', 'config.paths.output_path'),
        (r'"data_cplex/', '"resources/config/'),
        (r'data_cplex\\models', 'resources/models'),
    ]
    
    # Note patterns and suggest manual review
    for pattern, _ in patterns:
        if re.search(pattern, content):
            print(f"⚠️  Found hardcoded path in {file_path}: {pattern}")
```

## Phase 3: Update Code

### Critical Changes

1. **Add `__init__.py` files**:
```powershell
cd C:\Users\quentin.gruet\Code\ems-optim-analyser\src\optim_analyser
New-Item -ItemType File -Path "app\__init__.py"
New-Item -ItemType File -Path "ibm\__init__.py"
New-Item -ItemType File -Path "optim\__init__.py"
New-Item -ItemType File -Path "analysis\__init__.py"
```

2. **Create `errors.py`** in new location:
```python
# src/optim_analyser/errors.py
"""Custom exceptions for Optim Analyser."""

class OptimAnalyserError(Exception):
    """Base exception for Optim Analyser."""
    pass

class OptimizationError(OptimAnalyserError):
    """Optimization execution failed."""
    pass

class OptimizationFail(OptimAnalyserError):
    """Optimization completed but failed to find solution."""
    pass

class ConfigurationError(OptimAnalyserError):
    """Invalid configuration."""
    pass

class IBMConnectionError(OptimAnalyserError):
    """Failed to connect to IBM Watson ML."""
    pass
```

3. **Update resource loading**:
```python
# In optim/path.py
from pathlib import Path
from optim_analyser.config import load_config

def resource_path(path_parts):
    """Get absolute path to resource."""
    config = load_config()
    if "models" in path_parts:
        base = config.paths.models_path
    elif "config" in path_parts:
        base = config.paths.config_path
    else:
        base = Path(__file__).parent.parent.parent / "resources"
    
    return base.joinpath(*path_parts)
```

## Phase 4: Testing

### 1. Install in Development Mode

```powershell
cd C:\Users\quentin.gruet\Code\ems-optim-analyser
python -m venv .venv
.venv\Scripts\activate
pip install -e ".[dev]"
```

### 2. Run Tests

```powershell
# Run all tests
pytest

# Run with coverage
pytest --cov=optim_analyser --cov-report=html

# Open coverage report
start htmlcov\index.html
```

### 3. Manual Testing

```powershell
# Test CLI
optim-analyser --help

# Test GUI
optim-analyser-gui

# Test specific command
optim-analyser display tests/data/sample.json
```

## Phase 5: Clean Up Old Repository

### Update ems-optimizer

1. **Add submodule reference** (optional):
```powershell
cd C:\Users\quentin.gruet\Code\ems-optimizer
git submodule add https://github.com/energypool/ems-optim-analyser tools/optim-analyser
```

2. **Update README**:
```markdown
## Optimization Analysis

Optimization results can be analyzed using the separate
[Optim Analyser](https://github.com/energypool/ems-optim-analyser) tool.

### Installation
\`\`\`bash
pip install git+https://github.com/energypool/ems-optim-analyser.git
\`\`\`

### Usage
\`\`\`bash
optim-analyser display path/to/results.json
\`\`\`
```

3. **Remove optimAnalyser directory** (after confirming migration):
```powershell
# Create a backup first!
git mv optimAnalyser optimAnalyser.deprecated
git commit -m "chore: deprecate optimAnalyser (migrated to ems-optim-analyser)"

# Or delete entirely
git rm -r optimAnalyser
git commit -m "chore: remove optimAnalyser (migrated to separate repo)"
```

## Phase 6: Release

### Create First Release

```powershell
cd C:\Users\quentin.gruet\Code\ems-optim-analyser

# Commit all changes
git add .
git commit -m "feat: initial release of standalone optim-analyser"

# Create tag
git tag v1.0.0

# Push to GitHub
git remote add origin https://github.com/energypool/ems-optim-analyser.git
git push -u origin main
git push --tags
```

### Build and Test Executable

```powershell
python scripts/build_executable.py

# Test the executable
.\dist\OptimAnalyser\OptimAnalyser.exe
```

## Rollback Plan

If issues arise:

1. **Keep ems-optimizer unchanged** until migration is validated
2. **Test extensively** before removing old code
3. **Keep backup branch** in ems-optimizer:
```powershell
cd C:\Users\quentin.gruet\Code\ems-optimizer
git checkout -b backup/before-optim-analyser-split
git push origin backup/before-optim-analyser-split
```

## Success Criteria

- [ ] All source files copied and imports fixed
- [ ] All tests passing
- [ ] CLI commands working
- [ ] GUI launches successfully
- [ ] Executable builds without errors
- [ ] Documentation complete
- [ ] GitHub repository created
- [ ] CI/CD pipeline running
- [ ] First release published
- [ ] Old code removed from ems-optimizer
