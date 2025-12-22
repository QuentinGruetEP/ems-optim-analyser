"""Unit tests for configuration management."""

import os
from pathlib import Path

import pytest

from optim_analyser.config import Config, load_config, load_env_file


class TestConfig:
    """Test configuration loading and management."""

    def test_config_from_env(self, monkeypatch):
        """Test loading configuration from environment variables."""
        monkeypatch.setenv("IBM_API_KEY", "test_key")
        monkeypatch.setenv("IBM_SPACE_ID", "test_space")

        config = Config.from_env()

        assert config.ibm.api_key == "test_key"
        assert config.ibm.space_id == "test_space"

    def test_config_defaults(self):
        """Test default configuration values."""
        config = Config.from_env()

        assert config.ibm.api_domain == "https://us-south.ml.cloud.ibm.com"
        assert config.ibm.hardware_spec_name == "S"
        assert config.app.theme == "Arc"

    def test_config_to_dict(self, sample_config):
        """Test conversion to dictionary."""
        config_dict = sample_config.to_dict()

        assert "API_KEY" in config_dict
        assert "SPACE_ID" in config_dict
        assert config_dict["API_KEY"] == "test_api_key"

    def test_load_env_file(self, tmp_path):
        """Test loading from .env file."""
        env_file = tmp_path / ".env"
        env_file.write_text("TEST_VAR=test_value\n# Comment\nANOTHER_VAR=another_value")

        load_env_file(str(env_file))

        assert os.getenv("TEST_VAR") == "test_value"
        assert os.getenv("ANOTHER_VAR") == "another_value"

    def test_load_config_with_missing_credentials(self, monkeypatch):
        """Test that missing credentials produce a warning but don't fail."""
        # Clear IBM credentials from environment
        monkeypatch.delenv("IBM_API_KEY", raising=False)
        monkeypatch.delenv("IBM_SPACE_ID", raising=False)

        with pytest.warns(UserWarning, match="IBM Watson ML credentials not configured"):
            # Pass a non-existent file to prevent loading from actual .env
            config = load_config(env_file="nonexistent.env")
            assert config is not None
