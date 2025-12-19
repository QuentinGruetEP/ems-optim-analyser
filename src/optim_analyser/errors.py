"""Custom exceptions for Optim Analyser.

All application-specific errors inherit from OptimAnalyserError.
Errors include context and error codes for better debugging and user feedback.
"""

from typing import Optional, Dict, Any


class OptimAnalyserError(Exception):
    """Base exception for all Optim Analyser errors.
    
    Args:
        message: Human-readable error description
        error_code: Unique error code for categorization
        context: Additional context information (paths, values, etc.)
    """
    
    def __init__(
        self, 
        message: str, 
        error_code: Optional[str] = None,
        context: Optional[Dict[str, Any]] = None
    ):
        self.message = message
        self.error_code = error_code or self.__class__.__name__.upper()
        self.context = context or {}
        super().__init__(self.format_message())
    
    def format_message(self) -> str:
        """Format error with code and context."""
        msg = f"[{self.error_code}] {self.message}"
        if self.context:
            context_str = ", ".join(f"{k}={v}" for k, v in self.context.items())
            msg += f" (Context: {context_str})"
        return msg


class ConfigurationError(OptimAnalyserError):
    """Configuration-related errors (missing files, invalid values)."""
    pass


class DataError(OptimAnalyserError):
    """Data loading, parsing, or validation errors."""
    pass


class ModelReferenceError(OptimAnalyserError):
    """Error referencing or loading CPLEX models."""
    pass


class OptimizationFail(OptimAnalyserError):
    """Optimization execution failed."""
    pass


class IBMConnectionError(OptimAnalyserError):
    """IBM Watson ML connection or authentication failed."""
    pass


class IBMJobError(OptimAnalyserError):
    """IBM job submission or retrieval failed."""
    pass


class ValidationError(OptimAnalyserError):
    """Input validation failed."""
    pass


class ResourceNotFoundError(OptimAnalyserError):
    """Required resource (file, model, deployment) not found."""
    pass


class VisualizationError(OptimAnalyserError):
    """Error generating visualizations."""
    pass


# Backward compatibility aliases (deprecated)
# TODO: Remove in next major version
class OptimizationFail_Legacy(OptimizationFail):
    """Legacy alias. Use OptimizationFail instead."""
    def __init__(self, message: str = ""):
        import warnings
        warnings.warn(
            "Using legacy OptimizationFail without context. "
            "Update to: raise OptimizationFail(message, error_code, context)",
            DeprecationWarning,
            stacklevel=2
        )
        super().__init__(message or "Optimization failed")


class ModelReferenceError_Legacy(ModelReferenceError):
    """Legacy alias. Use ModelReferenceError instead."""
    def __init__(self, message: str = ""):
        import warnings
        warnings.warn(
            "Using legacy ModelReferenceError without context. "
            "Update to: raise ModelReferenceError(message, error_code, context)",
            DeprecationWarning,
            stacklevel=2
        )
        super().__init__(message or "Model reference error")
