"""Configuration management for Optim Analyser.

Handles loading configuration from environment variables and .env files.
"""

import os
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

import yaml


@dataclass
class IBMConfig:
    """IBM Watson ML configuration."""

    api_key: str
    space_id: str
    api_domain: str = "https://us-south.ml.cloud.ibm.com"
    iam_domain: str = "https://iam.cloud.ibm.com"
    hardware_spec_name: str = "S"
    hardware_spec_num_nodes: int = 1
    run_time_version: str = "20.1"


@dataclass
class PathConfig:
    """Path configuration."""

    models_path: Path = field(default_factory=lambda: Path("resources/models"))
    config_path: Path = field(default_factory=lambda: Path("resources/config"))
    output_path: Path = field(default_factory=lambda: Path("output"))


@dataclass
class AppConfig:
    """Application configuration."""

    theme: str = "Arc"
    log_level: str = "INFO"
    color_blind_mode: bool = False


@dataclass
class Config:
    """Main configuration object."""

    ibm: IBMConfig
    paths: PathConfig
    app: AppConfig

    @classmethod
    def from_env(cls, env_file: Optional[str] = None) -> "Config":
        """Load configuration from environment variables.

        Args:
            env_file: Path to .env file (optional)

        Returns:
            Config object
        """
        if env_file and Path(env_file).exists():
            load_env_file(env_file)

        ibm = IBMConfig(
            api_key=os.getenv("IBM_API_KEY", ""),
            space_id=os.getenv("IBM_SPACE_ID", ""),
            api_domain=os.getenv("IBM_API_DOMAIN", "https://us-south.ml.cloud.ibm.com"),
            iam_domain=os.getenv("IBM_IAM_DOMAIN", "https://iam.cloud.ibm.com"),
            hardware_spec_name=os.getenv("IBM_HARDWARE_SPEC_NAME", "S"),
            hardware_spec_num_nodes=int(os.getenv("IBM_HARDWARE_SPEC_NUM_NODES", "1")),
            run_time_version=os.getenv("IBM_RUN_TIME_VERSION", "20.1"),
        )

        paths = PathConfig(
            models_path=Path(os.getenv("MODELS_PATH", "resources/models")),
            config_path=Path(os.getenv("CONFIG_PATH", "resources/config")),
            output_path=Path(os.getenv("OUTPUT_PATH", "output")),
        )

        app = AppConfig(
            theme=os.getenv("APP_THEME", "Arc"),
            log_level=os.getenv("LOG_LEVEL", "INFO"),
            color_blind_mode=os.getenv("COLOR_BLIND_MODE", "false").lower() == "true",
        )

        return cls(ibm=ibm, paths=paths, app=app)

    def to_dict(self) -> dict:
        """Convert config to dictionary for IBM Watson ML."""
        return {
            "API_KEY": self.ibm.api_key,
            "SPACE_ID": self.ibm.space_id,
            "API_DOMAIN": self.ibm.api_domain,
            "IAM_DOMAIN": self.ibm.iam_domain,
            "HARDWARE_SPEC_NAME": self.ibm.hardware_spec_name,
            "HARDWARE_SPEC_NUM_NODES": self.ibm.hardware_spec_num_nodes,
            "RUN_TIME_VERSION": self.ibm.run_time_version,
        }


def load_env_file(env_file: str) -> None:
    """Load environment variables from .env file.

    Args:
        env_file: Path to .env file
    """
    with open(env_file, "r") as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                key, value = line.split("=", 1)
                os.environ[key.strip()] = value.strip()


def load_config(env_file: Optional[str] = None) -> Config:
    """Load configuration from environment or .env file.

    Args:
        env_file: Optional path to .env file

    Returns:
        Config object

    Raises:
        ValueError: If required configuration is missing
    """
    # Try to find .env file if not specified
    if env_file is None:
        for possible_path in [".env", "../.env", "../../.env"]:
            if Path(possible_path).exists():
                env_file = possible_path
                break

    config = Config.from_env(env_file)

    # Validate required fields
    if not config.ibm.api_key and not config.ibm.space_id:
        # Only warn if both are missing (local-only mode is OK)
        import warnings

        warnings.warn(
            "IBM Watson ML credentials not configured. Remote optimization features will be unavailable.",
            UserWarning,
        )

    return config
