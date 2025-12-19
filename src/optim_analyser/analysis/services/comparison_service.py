"""Comparison service - handles comparing multiple optimization runs.

This service encapsulates comparison logic for analyzing multiple optimization results.
"""

import os
from pathlib import Path
from typing import List

from optim_analyser.optim import dataframes, path
from optim_analyser.analysis import compare
from optim_analyser.models import ComparisonResult, ComparisonConfig, OptimizationJob, JobStatus
from optim_analyser.errors import DataError, VisualizationError


class ComparisonService:
    """Service for comparing multiple optimization runs."""
    
    def compare_jobs_from_folder(
        self,
        jobs_folder: str,
        output_folder: str,
        color_blind: bool = False
    ) -> ComparisonResult:
        """Compare all JSON jobs in a folder.
        
        Args:
            jobs_folder: Directory containing JSON job files
            output_folder: Output directory for comparison
            color_blind: Use color-blind friendly palette
            
        Returns:
            ComparisonResult with analysis
            
        Raises:
            DataError: If no jobs found or loading fails
            VisualizationError: If comparison generation fails
        """
        try:
            json_list = [f for f in os.listdir(jobs_folder) if f.endswith('.json')]
            
            if not json_list:
                raise DataError(
                    "No JSON files found in folder",
                    error_code="NO_JOBS_FOUND",
                    context={"folder": jobs_folder}
                )
            
            (html_path, plot_param) = path.get_compare_paths_and_param_folder(
                jobs_folder, output_folder
            )
            
            compare.compare_jobs_from_folder(
                jobs_folder=jobs_folder,
                html_path=html_path,
                client_param=plot_param,
                color_blind=color_blind
            )
            
            # Create ComparisonResult (simplified - would need more info in real impl)
            jobs = [
                OptimizationJob(
                    job_id=json_file,
                    input_data=None,  # Would need to load
                    status=JobStatus.COMPLETED
                )
                for json_file in json_list
            ]
            
            return ComparisonResult(
                jobs=jobs,
                comparison_name=Path(jobs_folder).name,
                html_path=Path(html_path)
            )
            
        except Exception as e:
            raise VisualizationError(
                f"Comparison failed: {str(e)}",
                error_code="COMPARISON_FAILED",
                context={"jobs_folder": jobs_folder}
            ) from e
    
    def compare_specific_jobs(
        self,
        json_paths: List[str],
        output_folder: str,
        comparison_name: str = "comparison",
        color_blind: bool = False
    ) -> ComparisonResult:
        """Compare specific optimization jobs.
        
        Args:
            json_paths: List of JSON file paths to compare
            output_folder: Output directory
            comparison_name: Name for the comparison
            color_blind: Use color-blind friendly palette
            
        Returns:
            ComparisonResult with analysis
            
        Raises:
            DataError: If jobs cannot be loaded
            VisualizationError: If comparison generation fails
        """
        try:
            if not json_paths:
                raise DataError(
                    "No jobs provided for comparison",
                    error_code="EMPTY_COMPARISON"
                )
            
            html_path = os.path.join(output_folder, f"{comparison_name}.html")
            
            #Plot parameters from first job
            plot_param = path.get_display_paths_and_param_json(json_paths[0], output_folder)[3]
            
            compare.compare_jobs_from_list(
                json_paths=json_paths,
                html_path=html_path,
                client_param=plot_param,
                color_blind=color_blind
            )
            
            jobs = [
                OptimizationJob(
                    job_id=Path(jp).stem,
                    input_data=None,
                    status=JobStatus.COMPLETED
                )
                for jp in json_paths
            ]
            
            return ComparisonResult(
                jobs=jobs,
                comparison_name=comparison_name,
                html_path=Path(html_path)
            )
            
        except Exception as e:
            raise VisualizationError(
                f"Job comparison failed: {str(e)}",
                error_code="JOBS_COMPARISON_FAILED",
                context={"job_count": len(json_paths)}
            ) from e
