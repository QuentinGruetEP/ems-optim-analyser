# Optim Analyser Architecture

## Overview

Optim Analyser is a desktop application for analyzing and visualizing EMS microgrid optimization results. It provides both GUI and CLI interfaces for working with IBM Watson ML optimization jobs.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     User Interface Layer                     │
├──────────────────────────────┬──────────────────────────────┤
│         GUI (Tkinter)        │         CLI (argparse)        │
│   - App framework            │   - Command handlers          │
│   - Menu navigation          │   - Batch processing          │
│   - Interactive forms        │   - Script automation         │
└──────────────────────────────┴──────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                    Application Layer                         │
├──────────────────┬──────────────────┬─────────────────────┐│
│   Analysis       │   Optimization   │   Configuration     ││
│   - Visualization│   - Local exec   │   - Env management  ││
│   - Comparison   │   - Remote exec  │   - Path handling   ││
│   - Export       │   - Replay       │   - Validation      ││
└──────────────────┴──────────────────┴─────────────────────┘│
                        │                                      │
                        ▼                                      │
┌─────────────────────────────────────────────────────────────┘
│                    Integration Layer                         │
├──────────────────────────────┬──────────────────────────────┤
│   IBM Watson ML              │   CPLEX Optimizer            │
│   - Model deployment         │   - Local execution          │
│   - Job submission           │   - Model management         │
│   - Result retrieval         │   - Data conversion          │
└──────────────────────────────┴──────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                              │
├────────────────────┬────────────────────┬───────────────────┤
│  Input/Output      │  Configuration     │  Resources        │
│  - JSON files      │  - Excel configs   │  - CPLEX models   │
│  - Excel files     │  - Plot params     │  - Icons          │
│  - Visualizations  │  - Deployments     │  - Themes         │
└────────────────────┴────────────────────┴───────────────────┘
```

## Module Structure

### `optim_analyser.app`
**Purpose**: GUI components using Tkinter

**Components**:
- `app.py` - Main application framework
- `appMenu.py` - Menu navigation
- `appDisplayRun.py` - Display optimization results
- `appCompare.py` - Compare multiple runs
- `appOptimJob.py` - Job submission interface
- `appForceBehavior.py` - Override optimization parameters

**Dependencies**: tkinter, ttkthemes, PIL

### `optim_analyser.ibm`
**Purpose**: IBM Watson ML integration

**Components**:
- `optimizationIBM.py` - Main orchestration functions
- `modelDeploymentWithRestClient.py` - Model deployment
- `jobWMLRestClient.py` - Job submission and retrieval
- `getJobsStatus.py` - Job status polling

**Dependencies**: requests, ibm_watson_machine_learning (future)

### `optim_analyser.optim`
**Purpose**: Optimization logic and CPLEX integration

**Components**:
- `optimization.py` - Local CPLEX execution
- `replay.py` - Replay existing optimizations
- `path.py` - Resource path management
- `dataframes.py` - Data structure conversions

**Dependencies**: pandas, numpy

### `optim_analyser.analysis`
**Purpose**: Visualization and analysis

**Components**:
- `analyse.py` - Main analysis functions
- `display.py` - Visualization generation
- `compare.py` - Multi-run comparison
- `subplot.py` - Plot utilities
- `colors.py` - Color palette management

**Dependencies**: plotly, pandas, numpy

### `optim_analyser.config`
**Purpose**: Configuration management

**Responsibilities**:
- Load environment variables
- Parse .env files
- Validate configuration
- Provide typed config objects

## Design Principles

### 1. Separation of Concerns
- GUI and CLI are independent interfaces to the same core logic
- IBM integration is isolated from visualization logic
- Configuration is centralized and environment-agnostic

### 2. Dependency Injection
- Configuration is injected rather than globally accessed
- IBM clients are created with explicit credentials
- File paths are configurable

### 3. Testability
- Each module has a clear interface
- External dependencies are mockable
- Integration tests separate from unit tests

### 4. Extensibility
- New visualization types can be added to `analysis`
- New IBM features can be added to `ibm`
- New GUI screens can be added to `app`

## Data Flow

### Display Workflow
```
JSON File → load_json() → parse_data() → create_dataframes() 
    → generate_plots() → save_html() → Display
```

### Replay Workflow (Local)
```
Input JSON → extract_parameters() → run_cplex_local()
    → collect_results() → generate_output_json() → Display
```

### Replay Workflow (Remote)
```
Input JSON → create_deployment() → submit_job() 
    → poll_status() → retrieve_results() → Display
```

## Configuration Strategy

### Environment Variables
Primary configuration source. Loaded from:
1. System environment
2. `.env` file in current directory
3. `.env` file in parent directories

### Excel Configuration
Domain-specific configuration:
- `deployment_list.xlsx` - Model/microgrid mappings
- `plot_param.xlsx` - Visualization parameters

### Code Configuration
Hardcoded defaults in `config.py` for sane fallbacks

## Error Handling

### User-Facing Errors
- Clear error messages in GUI dialogs
- Helpful error messages in CLI
- Suggestions for resolution

### Developer Errors
- Detailed stack traces in logs
- Context information preserved
- Errors propagated with context

## Future Enhancements

### Planned Features
1. **Plugin System** - Allow custom visualization types
2. **Database Backend** - Store optimization history
3. **Web Interface** - Browser-based UI alternative
4. **Real-time Monitoring** - Live job status updates
5. **Batch Processing** - Parallel job submission

### Technical Debt
1. Refactor IBM client to use official SDK
2. Add comprehensive type hints
3. Improve error handling consistency
4. Add input validation layer
5. Create data model abstraction
