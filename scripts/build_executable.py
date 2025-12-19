"""Build script for creating standalone executable."""

import sys
import shutil
from pathlib import Path
import PyInstaller.__main__

def build_executable():
    """Build standalone Windows executable using PyInstaller."""
    
    # Get project root
    project_root = Path(__file__).parent.parent
    
    # Define paths
    entry_point = project_root / "src" / "optim_analyser" / "__main__.py"
    icon_path = project_root / "resources" / "icons" / "ep_icon.png"
    dist_dir = project_root / "dist"
    build_dir = project_root / "build"
    
    # Clean previous builds
    if dist_dir.exists():
        shutil.rmtree(dist_dir)
    if build_dir.exists():
        shutil.rmtree(build_dir)
    
    print("Building OptimAnalyser executable...")
    
    # PyInstaller arguments
    args = [
        str(entry_point),
        "--name=OptimAnalyser",
        "--windowed",  # No console window
        "--onedir",  # One directory bundle
        f"--distpath={dist_dir}",
        f"--workpath={build_dir}",
        "--clean",
        "--noconfirm",
        # Add data files
        f"--add-data={project_root / 'resources' / 'config'};resources/config",
        f"--add-data={project_root / 'resources' / 'models'};resources/models",
        f"--add-data={project_root / 'resources' / 'icons'};resources/icons",
    ]
    
    # Add icon if it exists
    if icon_path.exists():
        args.append(f"--icon={icon_path}")
    
    # Run PyInstaller
    PyInstaller.__main__.run(args)
    
    print(f"\n✓ Build complete!")
    print(f"  Executable location: {dist_dir / 'OptimAnalyser'}")
    print(f"  Run: {dist_dir / 'OptimAnalyser' / 'OptimAnalyser.exe'}")

if __name__ == "__main__":
    build_executable()
