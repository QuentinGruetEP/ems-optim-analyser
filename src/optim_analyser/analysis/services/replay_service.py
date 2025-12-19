"""Replay service - handles replaying optimization jobs.

This service encapsulates replay logic for both local (CPLEX) and remote (IBM) execution.
"""

from pathlib import Path
from typing import Optional

from optim_analyser.analysis import display
from optim_analyser.errors import IBMJobError, OptimizationFail
from optim_analyser.ibm import optimizationIBM
from optim_analyser.models import OptimizationMode, ReplayConfig, VisualizationResult
from optim_analyser.optim import dataframes, optimization, path, replay


class ReplayService:
    """Service for replaying optimization jobs."""

    def replay_local(
        self, json_path: str, output_folder: str, add_costs: bool = True, color_blind: bool = False
    ) -> VisualizationResult:
        """Replay optimization locally using CPLEX.

        Args:
            json_path: Path to JSON optimization job file
            output_folder: Output directory
            add_costs: Include cost breakdown
            color_blind: Use color-blind friendly palette

        Returns:
            VisualizationResult with generated HTML

        Raises:
            OptimizationFail: If CPLEX execution fails
        """
        try:
            data = dataframes.json_to_dataframe(json_path)

            (
                excel_init_path,
                excel_input_path,
                excel_output_path,
                model_path,
                run_dat_path,
                run_model_path,
                _,
                dat_costs_extension_path,
                mod_costs_extension_path,
                html_path,
                plot_param,
            ) = path.get_run_paths_and_param_json(json_path, output_folder)

            optimization.prepare_excel_initial_data(data, excel_init_path)
            optimization.prepare_optimization(
                data,
                model_path,
                run_model_path,
                excel_input_path=excel_input_path,
                dat_path=run_dat_path,
                add_costs=add_costs,
                dat_costs_extension_path=dat_costs_extension_path,
                mod_costs_extension_path=mod_costs_extension_path,
            )

            replay.replay_optimization(run_model_path, run_dat_path, data, excel_output_path)

            display.plot_from_excel(
                excel_input_path,
                excel_output_path,
                sc_name=None,
                html_path=html_path,
                client_param=plot_param,
                add_costs=add_costs,
                color_blind=color_blind,
            )

            return VisualizationResult(html_path=Path(html_path), plot_count=1)

        except Exception as e:
            raise OptimizationFail(
                f"Local replay failed: {str(e)}", error_code="REPLAY_LOCAL_FAILED", context={"json_path": json_path}
            ) from e

    def replay_remote(
        self,
        json_path: str,
        output_folder: str,
        ibm_properties: dict,
        add_costs: bool = True,
        color_blind: bool = False,
    ) -> VisualizationResult:
        """Replay optimization remotely on IBM Watson ML.

        Args:
            json_path: Path to JSON optimization job file
            output_folder: Output directory
            ibm_properties: IBM Watson ML configuration
            add_costs: Include cost breakdown
            color_blind: Use color-blind friendly palette

        Returns:
            VisualizationResult with generated HTML

        Raises:
            IBMJobError: If remote execution fails
        """
        try:
            data = dataframes.json_to_dataframe(json_path)

            (
                excel_init_path,
                excel_input_path,
                excel_output_path,
                model_path,
                run_dat_path,
                run_model_path,
                json_output_path,
                dat_costs_extension_path,
                mod_costs_extension_path,
                html_path,
                plot_param,
            ) = path.get_run_paths_and_param_json(json_path, output_folder)

            optimization.prepare_excel_initial_data(data, excel_init_path)

            optimizationIBM.replay_optimization_cloud(
                all_data=data,
                space_id=ibm_properties["SPACE_ID"],
                model_path=model_path,
                output_json_path=json_output_path,
                ibm_watson_ml_properties=ibm_properties,
                add_costs=add_costs,
                dat_costs_extension_path=dat_costs_extension_path,
                mod_costs_extension_path=mod_costs_extension_path,
            )

            data_recomputed = dataframes.json_to_dataframe(json_output_path)
            display.plot_from_data(
                all_data=data_recomputed,
                sc_name=None,
                html_path=html_path,
                subplots_param=plot_param,
                color_blind=color_blind,
            )

            return VisualizationResult(html_path=Path(html_path), plot_count=1)

        except Exception as e:
            raise IBMJobError(
                f"Remote replay failed: {str(e)}", error_code="REPLAY_REMOTE_FAILED", context={"json_path": json_path}
            ) from e
