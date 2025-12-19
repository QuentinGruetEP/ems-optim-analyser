"""Domain models for Optim Analyser.

This module defines typed domain objects that represent core business concepts.
Using dataclasses provides type safety and reduces dict-passing anti-patterns.
"""

from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
from pathlib import Path
from typing import Dict, List, Optional

import pandas as pd


class JobStatus(Enum):
    """Optimization job status."""

    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"


class OptimizationMode(Enum):
    """Type of optimization execution."""

    LOCAL = "local"
    REMOTE = "remote"


@dataclass
class OptimizationData:
    """Structured optimization data from JSON/Excel.

    Replaces dict[str, pd.DataFrame] with a typed object.
    """

    dataframes: Dict[str, pd.DataFrame]
    metadata: Dict[str, any] = field(default_factory=dict)

    def get_table(self, name: str) -> Optional[pd.DataFrame]:
        """Get a specific dataframe by name."""
        return self.dataframes.get(name)

    def table_names(self) -> List[str]:
        """Get list of all table names."""
        return list(self.dataframes.keys())


@dataclass
class PlotParameters:
    """Visualization configuration."""

    microgrid_ref: int
    microgrid_name: str
    color_blind: bool = False
    add_costs: bool = True
    plot_variables: List[str] = field(default_factory=list)


@dataclass
class OptimizationJob:
    """Represents an optimization job with metadata."""

    job_id: str
    input_data: OptimizationData
    status: JobStatus = JobStatus.PENDING
    mode: OptimizationMode = OptimizationMode.LOCAL
    created_at: datetime = field(default_factory=datetime.now)
    completed_at: Optional[datetime] = None
    error_message: Optional[str] = None

    # Paths
    input_path: Optional[Path] = None
    output_path: Optional[Path] = None
    model_path: Optional[Path] = None

    # Results
    output_data: Optional[OptimizationData] = None

    def is_complete(self) -> bool:
        """Check if job completed successfully."""
        return self.status == JobStatus.COMPLETED

    def is_failed(self) -> bool:
        """Check if job failed."""
        return self.status == JobStatus.FAILED

    def mark_completed(self, output_data: OptimizationData):
        """Mark job as completed with results."""
        self.status = JobStatus.COMPLETED
        self.completed_at = datetime.now()
        self.output_data = output_data

    def mark_failed(self, error: str):
        """Mark job as failed with error message."""
        self.status = JobStatus.FAILED
        self.completed_at = datetime.now()
        self.error_message = error


@dataclass
class ReplayConfig:
    """Configuration for replaying an optimization."""

    json_path: Path
    output_folder: Path
    mode: OptimizationMode = OptimizationMode.LOCAL
    add_costs: bool = True
    color_blind: bool = False

    # IBM-specific
    space_id: Optional[str] = None
    hardware_spec: str = "M"
    num_nodes: int = 1


@dataclass
class ComparisonConfig:
    """Configuration for comparing multiple runs."""

    job_paths: List[Path]
    output_folder: Path
    comparison_name: str
    color_blind: bool = False


@dataclass
class ComparisonResult:
    """Results from comparing multiple optimization runs."""

    jobs: List[OptimizationJob]
    comparison_name: str
    html_path: Path
    created_at: datetime = field(default_factory=datetime.now)

    def job_count(self) -> int:
        """Number of jobs in comparison."""
        return len(self.jobs)


@dataclass
class DisplayConfig:
    """Configuration for displaying optimization results."""

    input_path: Path
    output_folder: Path
    color_blind: bool = False
    exclude_costs: bool = False
    plot_params: Optional[PlotParameters] = None


@dataclass
class ModelInfo:
    """Information about a CPLEX model."""

    model_path: Path
    model_name: str
    input_fields: List[str] = field(default_factory=list)
    output_fields: List[str] = field(default_factory=list)

    def has_costs_extension(self) -> bool:
        """Check if model supports cost extraction."""
        return "costs" in self.model_name.lower()


@dataclass
class IBMDeployment:
    """IBM Watson ML deployment information."""

    deployment_id: str
    model_id: str
    space_id: str
    deployment_name: str
    status: str
    created_at: datetime = field(default_factory=datetime.now)

    def is_ready(self) -> bool:
        """Check if deployment is ready to accept jobs."""
        return self.status.lower() in ["ready", "online"]


@dataclass
class IBMJobSubmission:
    """Information about an IBM job submission."""

    job_id: str
    deployment_id: str
    space_id: str
    input_data: Dict
    submitted_at: datetime = field(default_factory=datetime.now)
    status: JobStatus = JobStatus.PENDING
    result_url: Optional[str] = None


@dataclass
class VisualizationResult:
    """Result of generating visualizations."""

    html_path: Path
    plot_count: int
    created_at: datetime = field(default_factory=datetime.now)
    thumbnail_path: Optional[Path] = None

    def exists(self) -> bool:
        """Check if the HTML file was created."""
        return self.html_path.exists()
