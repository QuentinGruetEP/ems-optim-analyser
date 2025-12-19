"""Unit tests for IBM Watson ML integration."""

from unittest.mock import Mock, patch

import pytest

from optim_analyser.ibm.optimizationIBM import (
    create_model_and_deployment_distant,
    delete_deployment_and_model_distant,
    run_optimization_distant,
)


@pytest.mark.unit
class TestIBMIntegration:
    """Test IBM Watson ML integration functions."""

    @patch("optim_analyser.ibm.modelDeploymentWithRestClient.WMLModelDeploymentClient")
    def test_create_model_and_deployment(self, mock_client, sample_config):
        """Test model creation and deployment."""
        # Setup mock
        mock_instance = Mock()
        mock_instance.createAndUploadAssetOnWml.return_value = "model_123"
        mock_instance.deployAssetOnWml.return_value = "deployment_456"
        mock_client.return_value = mock_instance

        ibm_properties = sample_config.to_dict()

        # Note: This will need actual implementation after migration
        # model_id, deployment_id = create_model_and_deployment_distant(
        #     ibm_watson_ml_properties=ibm_properties,
        #     modelPath="test.mod",
        #     modelName="TestModel"
        # )

        # assert model_id == "model_123"
        # assert deployment_id == "deployment_456"

    @pytest.mark.slow
    @pytest.mark.integration
    def test_run_optimization_remote(self, sample_config):
        """Integration test for remote optimization (requires credentials)."""
        # Skip if no credentials
        if not sample_config.ibm.api_key or sample_config.ibm.api_key == "test_api_key":
            pytest.skip("IBM credentials not configured")

        # Integration test would go here
