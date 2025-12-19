"""Display service - handles visualization of optimization results.

This service encapsulates all display-related logic, providing a clean
interface for rendering optimization data to HTML visualizations.
"""

from pathlib import Path
from typing import Optional

from optim_analyser.optim import dataframes, path
from optim_analyser.analysis import display
from optim_analyser.models import DisplayConfig, OptimizationData, VisualizationResult
from optim_analyser.errors import DataError, VisualizationError


class DisplayService:
    """Service for displaying optimization results."""
    
    def display_from_json(
        self, 
        json_path: str, 
        output_folder: str,
        color_blind: bool = False
    ) -> VisualizationResult:
        """Display optimization job from JSON file.
        
        Args:
            json_path: Path to JSON optimization job file
            output_folder: Output directory for visualizations
            color_blind: Use color-blind friendly palette
            
        Returns:
            VisualizationResult with path to generated HTML
            
        Raises:
            DataError: If JSON cannot be loaded
            VisualizationError: If visualization generation fails
        """
        try:
            # Load data from .json
            data = dataframes.json_to_dataframe(json_path)
            
            # Get corresponding paths and plotting parameters
            (_, _, html_path, plot_param) = path.get_display_paths_and_param_json(
                json_path, output_folder
            )
            
            # Display and save visuals in the .html
            display.plot_from_data(
                all_data=data,
                sc_name=None,
                html_path=html_path,
                subplots_param=plot_param,
                color_blind=color_blind
            )
            
            return VisualizationResult(
                html_path=Path(html_path),
                plot_count=len(data)  # Approximate
            )
            
        except FileNotFoundError as e:
            raise DataError(
                f"JSON file not found: {json_path}",
                error_code="JSON_NOT_FOUND",
                context={"path": json_path}
            ) from e
        except Exception as e:
            raise VisualizationError(
                f"Failed to generate visualization: {str(e)}",
                error_code="DISPLAY_FAILED",
                context={"json_path": json_path, "output": output_folder}
            ) from e
    
    def display_from_excel(
        self,
        excel_input_path: str,
        excel_output_path: str,
        output_folder: str,
        sc_name: Optional[str] = None,
        color_blind: bool = False
    ) -> VisualizationResult:
        """Display optimization job from Excel files.
        
        Args:
            excel_input_path: Path to input Excel file
            excel_output_path: Path to output Excel file
            output_folder: Output directory for visualizations
            sc_name: Scenario name
            color_blind: Use color-blind friendly palette
            
        Returns:
            VisualizationResult with path to generated HTML
            
        Raises:
            DataError: If Excel files cannot be loaded
            VisualizationError: If visualization generation fails
        """
        try:
            # Get corresponding paths and plotting parameters
            (_, html_path, plot_param) = path.get_display_paths_and_param_excel(
                excel_input_path, output_folder
            )
            
            # Display and save visuals in the .html
            display.plot_from_excel(
                excel_input_path,
                excel_output_path,
                sc_name=sc_name,
                html_path=html_path,
                client_param=plot_param,
                add_costs=False,
                color_blind=color_blind
            )
            
            return VisualizationResult(
                html_path=Path(html_path),
                plot_count=1  # Approximate
            )
            
        except FileNotFoundError as e:
            raise DataError(
                f"Excel file not found",
                error_code="EXCEL_NOT_FOUND",
                context={"input": excel_input_path, "output": excel_output_path}
            ) from e
        except Exception as e:
            raise VisualizationError(
                f"Failed to generate Excel visualization: {str(e)}",
                error_code="EXCEL_DISPLAY_FAILED",
                context={"input": excel_input_path}
            ) from e
