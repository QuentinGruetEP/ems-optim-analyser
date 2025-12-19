"""Optim Analyser - EMS Microgrid Optimization Analysis Tool.

This package provides tools for analyzing, visualizing, and replaying
optimization results from IBM Watson ML CPLEX jobs.
"""

__version__ = "1.0.0"
__author__ = "Energy Pool"
__email__ = "dev@energypool.eu"

from optim_analyser.config import Config, load_config

__all__ = ["Config", "load_config", "__version__"]
