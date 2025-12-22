# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- **BREAKING**: Consolidated IBM Watson ML configuration - removed `IbmWatsonMLProperties.yml` in favor of `.env` file
- All IBM credentials now loaded from environment variables via unified `Config` class
- Simplified configuration management with single source of truth

### Removed
- `IbmWatsonMLProperties.yml` - replaced by `.env` configuration
- `get_ibm_watson_ml_properties()` function - replaced by `load_config()`

### Migration Guide
- Copy all values from `IbmWatsonMLProperties.yml` to your `.env` file if not already present
- Update any custom code using `get_ibm_watson_ml_properties()` to use `load_config().ibm.to_dict()`

## [1.0.0] - 2025-12-19

### Added
- GUI application for optimization analysis
- CLI interface for automation
- IBM Watson ML integration
- JSON to Excel conversion
- Interactive visualizations with Plotly
- Optimization replay functionality
- Multi-run comparison features
- Color-blind friendly palettes
- PyInstaller executable builds

### Changed
- Migrated from ems-optimizer repository
- Restructured to modern Python package layout
- Added comprehensive testing infrastructure
- Improved configuration management
- Enhanced error handling

### Infrastructure
- GitHub Actions CI/CD pipeline
- Automated testing and linting
- Pre-commit hooks for code quality
- Automated release workflows

[Unreleased]: https://github.com/energypool/ems-optim-analyser/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/energypool/ems-optim-analyser/releases/tag/v1.0.0
