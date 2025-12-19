# Architecture

## Overview

EMS Optim Analyser follows Domain-Driven Design principles with clean separation of concerns:

- **Domain Layer**: Core business models and errors
- **Service Layer**: Business logic orchestration
- **Infrastructure Layer**: External integrations (IBM Watson ML, CPLEX)
- **Presentation Layer**: GUI and CLI interfaces

## Project Structure

```
src/optim_analyser/
├── models.py              # Domain models (dataclasses)
├── errors.py              # Error hierarchy with context
├── config.py              # Configuration management
├── analysis/              # Analysis and visualization
│   ├── services/          # Business logic services
│   │   ├── display_service.py      # Visualization generation
│   │   ├── replay_service.py       # Optimization replay
│   │   └── comparison_service.py   # Multi-job comparison
│   ├── analyse.py         # Legacy functions (facade)
│   ├── display.py         # Plotly visualization
│   ├── compare.py         # Comparison logic
│   └── subplot.py         # Subplot layouts
├── ibm/                   # IBM Watson ML integration
│   ├── modelDeploymentWithRestClient.py  # Model deployment
│   ├── jobWMLRestClient.py               # Job execution
│   ├── optimizationIBM.py                # Orchestration
│   └── getJobsStatus.py                  # Job monitoring
├── optim/                 # CPLEX optimization
│   ├── dataframes.py      # Data transformation
│   ├── optimization.py    # Optimization preparation
│   ├── replay.py          # Local CPLEX execution
│   └── path.py            # Resource path resolution
├── app/                   # Tkinter GUI
│   ├── app.py             # Main window
│   ├── appMenu.py         # Menu bar
│   ├── appDisplayRun.py   # Display tab
│   ├── appCompare.py      # Comparison tab
│   └── appOptimJob.py     # Optimization tab
├── cli.py                 # Command-line interface
└── launchApp.py           # GUI entry point
```

## Domain Models

**File**: [models.py](../src/optim_analyser/models.py)

Type-safe dataclasses for all business entities:

**Core Models**:
- `OptimizationJob` - Complete optimization job
- `OptimizationData` - Time-series data
- `ModelInfo` - CPLEX model metadata

**Configuration**:
- `ReplayConfig` - Replay settings
- `DisplayConfig` - Visualization settings
- `ComparisonConfig` - Comparison settings
- `PlotParameters` - Plot customization

**IBM Integration**:
- `IBMDeployment` - Watson ML deployment
- `IBMJobSubmission` - Job submission

**Results**:
- `ComparisonResult` - Multi-job analysis
- `VisualizationResult` - Generated HTML info

**Enums**:
- `JobStatus` - Job state
- `OptimizationMode` - Local/remote execution

## Error Hierarchy

**File**: [errors.py](../src/optim_analyser/errors.py)

All exceptions inherit from `OptimAnalyserError` with error codes and context:

- `ConfigurationError` - Invalid settings
- `DataError` - Data loading failures
- `ModelReferenceError` - Missing CPLEX models
- `OptimizationFail` - CPLEX execution errors
- `IBMConnectionError` - Network/auth issues
- `IBMJobError` - Remote job failures
- `ValidationError` - Input validation
- `ResourceNotFoundError` - Missing files
- `VisualizationError` - Plot generation failures

## Service Layer

**Directory**: [analysis/services/](../src/optim_analyser/analysis/services/)

### DisplayService
Visualization generation:
- `display_from_json()` - Display from JSON file
- `display_from_excel()` - Display from Excel files

### ReplayService
Optimization replay:
- `replay_local()` - Local CPLEX replay
- `replay_remote()` - IBM Watson ML replay

### ComparisonService
Multi-job comparison:
- `compare_jobs_from_folder()` - Compare folder of jobs
- `compare_specific_jobs()` - Compare specific jobs

All services use domain models and raise specific exceptions.

## IBM Watson ML Integration

### WMLModelDeploymentClient
[modelDeploymentWithRestClient.py](../src/optim_analyser/ibm/modelDeploymentWithRestClient.py)
- Model upload
- Deployment creation
- Version management

### WMLJobClient
[jobWMLRestClient.py](../src/optim_analyser/ibm/jobWMLRestClient.py)
- Job submission
- Status monitoring
- Result retrieval

### optimizationIBM
[optimizationIBM.py](../src/optim_analyser/ibm/optimizationIBM.py)
- Orchestrates deployment + execution
- `replay_optimization_cloud()` - Full remote workflow
- `run_optimization_distant()` - Submit optimization

## CPLEX Integration

### dataframes.py
Data transformation: JSON ↔ pandas ↔ Excel

### optimization.py
- `.mod` and `.dat` file generation
- Cost extension injection
- Excel input preparation

### replay.py
- Local CPLEX execution
- Solution parsing
- Excel export

### path.py
- Resource path resolution
- Input/output path generation
- Parameter extraction

## User Interfaces

### GUI (Tkinter)
Tabbed interface with:
- Display tab - Visualize results
- Replay tab - Re-run optimizations
- Compare tab - Multi-job comparison
- Optimization tab - Submit new jobs

Launch: `python -m optim_analyser`

### CLI (argparse)
Commands:
- `display` - Generate visualizations
- `replay-local` - Local CPLEX replay
- `replay-remote` - IBM remote replay
- `compare` - Compare jobs

Launch: `python -m optim_analyser --help`

## Testing

- **Unit Tests**: Service layer, utilities
- **Integration Tests**: End-to-end workflows
- **CI/CD**: GitHub Actions on every push
