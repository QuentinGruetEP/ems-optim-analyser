"""Helper script to migrate files from ems-optimizer to ems-optim-analyser.

This script automates the file copying and import fixing process.
Run from the ems-optim-analyser root directory.
"""

import shutil
import re
from pathlib import Path


def main():
    """Main migration script."""
    
    # Paths
    old_repo = Path(r"C:\Users\quentin.gruet\Code\ems-optimizer\optimAnalyser")
    new_repo = Path(r"C:\Users\quentin.gruet\Code\ems-optim-analyser")
    
    if not old_repo.exists():
        print(f"❌ Source directory not found: {old_repo}")
        return 1
    
    if not new_repo.exists():
        print(f"❌ Target directory not found: {new_repo}")
        return 1
    
    print("🚀 Starting migration from ems-optimizer to ems-optim-analyser\n")
    
    # Step 1: Copy source files
    print("📁 Copying source files...")
    src_source = old_repo / "src"
    src_target = new_repo / "src" / "optim_analyser"
    
    if src_source.exists():
        for item in src_source.iterdir():
            if item.name == "__pycache__":
                continue
            
            target = src_target / item.name
            if item.is_dir():
                if target.exists():
                    shutil.rmtree(target)
                shutil.copytree(item, target, ignore=shutil.ignore_patterns('__pycache__', '*.pyc'))
                print(f"  ✓ Copied directory: {item.name}")
                
                # Create __init__.py if it doesn't exist
                init_file = target / "__init__.py"
                if not init_file.exists():
                    init_file.write_text(f'"""Module: {item.name}."""\n')
            else:
                if item.suffix == '.py':
                    shutil.copy2(item, target)
                    print(f"  ✓ Copied file: {item.name}")
    
    # Step 2: Copy resources
    print("\n📚 Copying resources...")
    
    # Copy Excel configs
    data_cplex = old_repo / "data_cplex"
    if data_cplex.exists():
        for xlsx_file in ["deployment_list.xlsx", "plot_param.xlsx"]:
            src_file = data_cplex / xlsx_file
            if src_file.exists():
                dest_file = new_repo / "resources" / "config" / xlsx_file
                shutil.copy2(src_file, dest_file)
                print(f"  ✓ Copied: {xlsx_file}")
        
        # Copy models
        models_src = data_cplex / "models"
        if models_src.exists():
            models_dest = new_repo / "resources" / "models"
            if models_dest.exists():
                shutil.rmtree(models_dest)
            shutil.copytree(models_src, models_dest)
            print(f"  ✓ Copied models directory")
    
    # Copy icons
    icon_src = old_repo / "src" / "app" / "ep_icon.png"
    if icon_src.exists():
        icon_dest = new_repo / "resources" / "icons" / "ep_icon.png"
        shutil.copy2(icon_src, icon_dest)
        print(f"  ✓ Copied icon")
    
    # Step 3: Fix imports
    print("\n🔧 Fixing imports...")
    fix_imports_in_directory(src_target)
    
    # Step 4: Create __init__.py files
    print("\n📝 Creating __init__.py files...")
    ensure_init_files(src_target)
    
    print("\n✅ Migration complete!")
    print("\n📋 Next steps:")
    print("  1. Review the copied files in src/optim_analyser/")
    print("  2. Fix any remaining hardcoded paths")
    print("  3. Run tests: pytest")
    print("  4. Test GUI: python -m optim_analyser")
    print("  5. Test CLI: optim-analyser --help")
    
    return 0


def fix_imports_in_directory(directory: Path):
    """Fix imports in all Python files in directory."""
    for py_file in directory.rglob("*.py"):
        fix_imports_in_file(py_file)


def fix_imports_in_file(file_path: Path):
    """Fix imports in a single Python file."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # Replace relative imports with package imports
        replacements = [
            (r'^from ibm import ', 'from optim_analyser.ibm import '),
            (r'^from ibm\.', 'from optim_analyser.ibm.'),
            (r'^from app import ', 'from optim_analyser.app import '),
            (r'^from app\.', 'from optim_analyser.app.'),
            (r'^from optim import ', 'from optim_analyser.optim import '),
            (r'^from optim\.', 'from optim_analyser.optim.'),
            (r'^from analysis import ', 'from optim_analyser.analysis import '),
            (r'^from analysis\.', 'from optim_analyser.analysis.'),
            (r'^from errors import ', 'from optim_analyser.errors import '),
        ]
        
        for pattern, replacement in replacements:
            content = re.sub(pattern, replacement, content, flags=re.MULTILINE)
        
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"  ✓ Fixed imports in: {file_path.relative_to(file_path.parents[3])}")
    
    except Exception as e:
        print(f"  ⚠️  Error processing {file_path}: {e}")


def ensure_init_files(directory: Path):
    """Ensure all directories have __init__.py files."""
    for subdir in directory.rglob("*"):
        if subdir.is_dir() and not (subdir / "__init__.py").exists():
            if any(subdir.glob("*.py")):
                init_file = subdir / "__init__.py"
                module_name = subdir.name
                init_file.write_text(f'"""Module: {module_name}."""\n')
                print(f"  ✓ Created: {init_file.relative_to(directory.parent)}")


if __name__ == "__main__":
    import sys
    sys.exit(main())
