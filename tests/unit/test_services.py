"""Unit tests for service layer.

Tests the DisplayService, ReplayService, and ComparisonService classes.
"""

import pytest
from pathlib import Path
from unittest.mock import Mock, patch, MagicMock

from optim_analyser.analysis.services import DisplayService, ReplayService, ComparisonService
from optim_analyser.models import VisualizationResult, ComparisonResult, JobStatus
from optim_analyser.errors import DataError, OptimizationFail, IBMJobError, VisualizationError


class TestDisplayService:
    """Tests for DisplayService."""
    
    def test_display_service_instantiation(self):
        """DisplayService can be instantiated."""
        service = DisplayService()
        assert service is not None
    
    @patch('optim_analyser.analysis.services.display_service.dataframes')
    @patch('optim_analyser.analysis.services.display_service.path')
    @patch('optim_analyser.analysis.services.display_service.display')
    def test_display_from_json_success(self, mock_display, mock_path, mock_dataframes):
        """display_from_json returns VisualizationResult on success."""
        # Arrange
        mock_dataframes.json_to_dataframe.return_value = {"data": "test"}
        # Return 4 values: excel, json, html, param
        mock_path.get_display_paths_and_param_json.return_value = (
            "excel_path", "json_path", "html_path", {"param": "value"}
        )
        
        service = DisplayService()
        
        # Act
        result = service.display_from_json("test.json", "output/", color_blind=False)
        
        # Assert
        assert isinstance(result, VisualizationResult)
        assert result.html_path == Path("html_path")
        mock_display.plot_from_data.assert_called_once()
    
    @patch('optim_analyser.analysis.services.display_service.dataframes')
    def test_display_from_json_file_not_found(self, mock_dataframes):
        """display_from_json raises DataError when file not found."""
        # Arrange
        mock_dataframes.json_to_dataframe.side_effect = FileNotFoundError("Not found")
        service = DisplayService()
        
        # Act & Assert
        with pytest.raises(DataError) as exc_info:
            service.display_from_json("missing.json", "output/")
        
        assert "JSON file not found" in str(exc_info.value)
        assert exc_info.value.error_code == "JSON_NOT_FOUND"


class TestReplayService:
    """Tests for ReplayService."""
    
    def test_replay_service_instantiation(self):
        """ReplayService can be instantiated."""
        service = ReplayService()
        assert service is not None
    
    @patch('optim_analyser.analysis.services.replay_service.dataframes')
    @patch('optim_analyser.analysis.services.replay_service.path')
    @patch('optim_analyser.analysis.services.replay_service.optimization')
    @patch('optim_analyser.analysis.services.replay_service.replay')
    @patch('optim_analyser.analysis.services.replay_service.display')
    def test_replay_local_success(self, mock_display, mock_replay, mock_opt, mock_path, mock_df):
        """replay_local returns VisualizationResult on success."""
        # Arrange
        mock_df.json_to_dataframe.return_value = {"data": "test"}
        mock_path.get_run_paths_and_param_json.return_value = (
            "excel_init", "excel_input", "excel_output",
            "model", "run_dat", "run_model", None,
            "dat_costs", "mod_costs", "html", {"param": "value"}
        )
        
        service = ReplayService()
        
        # Act
        result = service.replay_local("test.json", "output/")
        
        # Assert
        assert isinstance(result, VisualizationResult)
        mock_opt.prepare_optimization.assert_called_once()
        mock_replay.replay_optimization.assert_called_once()
    
    @patch('optim_analyser.analysis.services.replay_service.dataframes')
    def test_replay_local_failure(self, mock_dataframes):
        """replay_local raises OptimizationFail on error."""
        # Arrange
        mock_dataframes.json_to_dataframe.side_effect = Exception("CPLEX error")
        service = ReplayService()
        
        # Act & Assert
        with pytest.raises(OptimizationFail) as exc_info:
            service.replay_local("test.json", "output/")
        
        assert "Local replay failed" in str(exc_info.value)
        assert exc_info.value.error_code == "REPLAY_LOCAL_FAILED"
    
    @patch('optim_analyser.analysis.services.replay_service.dataframes')
    def test_replay_remote_failure(self, mock_dataframes):
        """replay_remote raises IBMJobError on error."""
        # Arrange
        mock_dataframes.json_to_dataframe.side_effect = Exception("IBM error")
        service = ReplayService()
        ibm_props = {"SPACE_ID": "test-space"}
        
        # Act & Assert
        with pytest.raises(IBMJobError) as exc_info:
            service.replay_remote("test.json", "output/", ibm_props)
        
        assert "Remote replay failed" in str(exc_info.value)
        assert exc_info.value.error_code == "REPLAY_REMOTE_FAILED"


class TestComparisonService:
    """Tests for ComparisonService."""
    
    def test_comparison_service_instantiation(self):
        """ComparisonService can be instantiated."""
        service = ComparisonService()
        assert service is not None
    
    @patch('optim_analyser.analysis.services.comparison_service.os.listdir')
    @patch('optim_analyser.analysis.services.comparison_service.path')
    @patch('optim_analyser.analysis.services.comparison_service.compare')
    def test_compare_jobs_from_folder_success(self, mock_compare, mock_path, mock_listdir):
        """compare_jobs_from_folder returns ComparisonResult."""
        # Arrange
        mock_listdir.return_value = ["job1.json", "job2.json", "readme.txt"]
        mock_path.get_compare_paths_and_param_folder.return_value = (
            "compare.html", {"param": "value"}
        )
        
        service = ComparisonService()
        
        # Act
        result = service.compare_jobs_from_folder("jobs/", "output/")
        
        # Assert
        assert isinstance(result, ComparisonResult)
        assert len(result.jobs) == 2  # Only .json files
        assert result.html_path == Path("compare.html")
        mock_compare.compare_jobs_from_folder.assert_called_once()
    
    @patch('optim_analyser.analysis.services.comparison_service.os.listdir')
    def test_compare_jobs_from_folder_no_jobs(self, mock_listdir):
        """compare_jobs_from_folder raises VisualizationError (wraps DataError) when no JSON files found."""
        # Arrange
        mock_listdir.return_value = ["readme.txt", "data.csv"]
        service = ComparisonService()
        
        # Act & Assert
        with pytest.raises(VisualizationError) as exc_info:
            service.compare_jobs_from_folder("jobs/", "output/")
        
        assert "Comparison failed" in str(exc_info.value)
        assert exc_info.value.error_code == "COMPARISON_FAILED"
    
    def test_compare_specific_jobs_empty_list(self):
        """compare_specific_jobs raises VisualizationError (wraps DataError) when list is empty."""
        service = ComparisonService()
        
        with pytest.raises(VisualizationError) as exc_info:
            service.compare_specific_jobs([], "output/")
        
        assert "Job comparison failed" in str(exc_info.value)
        assert exc_info.value.error_code == "JOBS_COMPARISON_FAILED"
    
    @patch('optim_analyser.analysis.services.comparison_service.path')
    @patch('optim_analyser.analysis.services.comparison_service.compare')
    def test_compare_specific_jobs_success(self, mock_compare, mock_path):
        """compare_specific_jobs returns ComparisonResult."""
        # Arrange
        mock_path.get_display_paths_and_param_json.return_value = (
            None, None, None, {"param": "value"}
        )
        
        service = ComparisonService()
        json_paths = ["job1.json", "job2.json"]
        
        # Act
        result = service.compare_specific_jobs(json_paths, "output/", "test_comparison")
        
        # Assert
        assert isinstance(result, ComparisonResult)
        assert len(result.jobs) == 2
        assert result.comparison_name == "test_comparison"
        mock_compare.compare_jobs_from_list.assert_called_once()
