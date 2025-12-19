"""Pytest configuration and shared fixtures."""

import pytest
from pathlib import Path
from optim_analyser.config import Config, IBMConfig, PathConfig, AppConfig


@pytest.fixture
def sample_config():
    """Provide a sample configuration for testing."""
    ibm = IBMConfig(
        api_key="test_api_key",
        space_id="test_space_id",
        api_domain="https://test.ibm.com",
        iam_domain="https://test-iam.ibm.com",
    )
    
    paths = PathConfig(
        models_path=Path("tests/data/models"),
        config_path=Path("tests/data/config"),
        output_path=Path("tests/output"),
    )
    
    app = AppConfig(
        theme="Arc",
        log_level="DEBUG",
    )
    
    return Config(ibm=ibm, paths=paths, app=app)


@pytest.fixture
def temp_output_dir(tmp_path):
    """Provide a temporary output directory."""
    output_dir = tmp_path / "output"
    output_dir.mkdir()
    return output_dir


@pytest.fixture
def sample_json_data():
    """Provide sample optimization JSON data."""
    return {
        "decision_optimization": {
            "input_data": [
                {
                    "id": "OPERATION.csv",
                    "fields": ["param", "value"],
                    "values": [["test_param", "test_value"]]
                }
            ],
            "output_data": [
                {
                    "id": "RESULTS.csv",
                    "fields": ["time", "power"],
                    "values": [[0, 100], [1, 150]]
                }
            ],
            "solve_state": {
                "solve_status": "optimal_solution"
            }
        }
    }
