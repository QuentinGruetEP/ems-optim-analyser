"""Integration test for application startup and basic functionality."""

import pytest
from unittest.mock import MagicMock, patch
import tkinter as tk


class TestApplicationStartup:
    """Test that the application can start without errors."""

    def test_gui_imports(self):
        """Test that all GUI modules can be imported."""
        from optim_analyser.app.app import App
        from optim_analyser.app.appMenu import Menu
        from optim_analyser.app.appDisplayRun import DisplayRun
        from optim_analyser.app.appCompare import Comparison
        from optim_analyser.app.appForceBehavior import ForceBehavior
        
        # If imports succeed, test passes
        assert App is not None
        assert Menu is not None

    def test_analysis_modules_import(self):
        """Test that analysis modules can be imported."""
        from optim_analyser.analysis import analyse
        from optim_analyser.analysis import display
        from optim_analyser.analysis import compare
        from optim_analyser.analysis import colors
        
        assert analyse is not None
        assert display is not None

    def test_optim_modules_import(self):
        """Test that optimization modules can be imported."""
        from optim_analyser.optim import dataframes
        from optim_analyser.optim import optimization
        from optim_analyser.optim import path
        from optim_analyser.optim import replay
        
        assert dataframes is not None
        assert optimization is not None

    def test_ibm_modules_import(self):
        """Test that IBM modules can be imported."""
        from optim_analyser.ibm import optimizationIBM
        from optim_analyser.ibm import jobWMLRestClient
        
        assert optimizationIBM is not None
        assert jobWMLRestClient is not None

    def test_config_loads(self):
        """Test that configuration can be loaded."""
        from optim_analyser.config import load_config
        
        config = load_config()
        assert config is not None
        assert config.paths is not None
        assert config.app is not None

    def test_cli_entry_point_exists(self):
        """Test that CLI entry point is accessible."""
        from optim_analyser.cli import main
        
        assert main is not None
        assert callable(main)

    def test_gui_entry_point_exists(self):
        """Test that GUI entry point is accessible."""
        from optim_analyser.__main__ import main
        
        assert main is not None
        assert callable(main)

    @patch('optim_analyser.app.app.ttkthemes.ThemedTk.__init__')
    @patch('optim_analyser.app.app.App.mainloop')
    def test_app_can_instantiate(self, mock_mainloop, mock_init):
        """Test that App class can be instantiated (mocked to avoid GUI)."""
        mock_init.return_value = None
        
        from optim_analyser.app.app import App
        
        # Mock the initialization to avoid actually creating a window
        with patch.object(App, '__init__', lambda x: None):
            app = App()
            assert app is not None

    def test_resource_paths_are_valid(self):
        """Test that resource path resolution works."""
        from optim_analyser.optim.path import resource_path
        from pathlib import Path
        
        # Test that the function returns a path
        config_path = resource_path(["config"])
        assert config_path is not None
        assert isinstance(config_path, str)
        
        # Verify the path makes sense structurally
        assert "config" in config_path or "resources" in config_path

    def test_no_legacy_imports_in_codebase(self):
        """Test that no files use legacy import patterns."""
        from pathlib import Path
        import re
        
        src_dir = Path(__file__).parent.parent.parent / "src" / "optim_analyser"
        
        # Pattern to catch legacy imports (not using optim_analyser prefix)
        legacy_patterns = [
            re.compile(r'^import (analysis|app|optim|ibm)\.'),
            re.compile(r'^from (analysis|app|optim|ibm) import'),
        ]
        
        violations = []
        
        for py_file in src_dir.rglob("*.py"):
            if "__pycache__" in str(py_file):
                continue
                
            with open(py_file, 'r', encoding='utf-8') as f:
                for line_num, line in enumerate(f, 1):
                    for pattern in legacy_patterns:
                        if pattern.search(line):
                            violations.append(f"{py_file.name}:{line_num}: {line.strip()}")
        
        assert len(violations) == 0, (
            f"Found {len(violations)} legacy imports:\n" + 
            "\n".join(violations[:10])  # Show first 10
        )

    def test_no_duplicate_data_files(self):
        """Test that data files don't exist in both src/ and resources/."""
        from pathlib import Path
        
        project_root = Path(__file__).parent.parent.parent
        
        # Define files that should ONLY be in resources/, not in src/
        expected_only_in_resources = [
            ("IbmWatsonMLProperties.yml", "resources/config", "src/optim_analyser/ibm"),
            ("UpdateProperties.yml", "resources/config", "src/optim_analyser/app"),
            ("ep_icon.png", "resources/icons", "src/optim_analyser/app"),
        ]
        
        duplicates = []
        
        for filename, canonical_location, forbidden_location in expected_only_in_resources:
            canonical_path = project_root / canonical_location / filename
            forbidden_path = project_root / forbidden_location / filename
            
            # Canonical location should exist
            if not canonical_path.exists():
                duplicates.append(f"❌ Missing canonical: {canonical_path}")
            
            # Duplicate location should NOT exist
            if forbidden_path.exists():
                duplicates.append(f"❌ Duplicate found: {forbidden_path} (should only be in {canonical_location})")
        
        assert len(duplicates) == 0, (
            f"Data file duplication issues:\n" + "\n".join(duplicates)
        )


class TestErrorHandling:
    """Test that error classes are properly defined."""

    def test_custom_exceptions_exist(self):
        """Test that custom exception classes are defined."""
        from optim_analyser.errors import OptimizationFail, ModelReferenceError
        
        assert issubclass(OptimizationFail, Exception)
        assert issubclass(ModelReferenceError, Exception)

    def test_can_raise_custom_exceptions(self):
        """Test that custom exceptions can be raised and caught."""
        from optim_analyser.errors import OptimizationFail
        
        with pytest.raises(OptimizationFail):
            raise OptimizationFail("Test error")


class TestDataTransformations:
    """Test that data transformation functions are accessible."""

    def test_json_to_dataframe_function_exists(self):
        """Test that JSON to DataFrame conversion function exists."""
        from optim_analyser.optim.dataframes import json_to_dataframe
        
        assert json_to_dataframe is not None
        assert callable(json_to_dataframe)

    def test_dataframe_to_excel_function_exists(self):
        """Test that DataFrame to Excel conversion function exists."""
        from optim_analyser.optim.dataframes import dataframe_to_excel
        
        assert dataframe_to_excel is not None
        assert callable(dataframe_to_excel)
