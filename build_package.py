#!/usr/bin/env python3
import os
import shutil
import zipfile
from pathlib import Path

# Paths
base_dir = Path("/Users/ricwall/Library/CloudStorage/GoogleDrive-dgatewizzydizzy@gmail.com/.shortcut-targets-by-id/1lU7Zgb6V8CUyG788Ih9xaHfCYvDnYYMQ/dragons_gate/EMCO_temp")
src_dir = base_dir / "src"
temp_dir = base_dir / "temp_extract"
output_file = base_dir / "EMCOChat.mpackage"

# Clean temp directory except for base files
print("Cleaning temp directory...")
if temp_dir.exists():
    # Remove old aliases, scripts, resources directories
    for item in ["aliases", "scripts", "resources"]:
        item_path = temp_dir / item
        if item_path.exists():
            shutil.rmtree(item_path)

# Copy files from src to temp_extract
print("Copying source files...")
for item in src_dir.iterdir():
    if item.is_dir():
        dest = temp_dir / item.name
        if dest.exists():
            shutil.rmtree(dest)
        shutil.copytree(item, dest)
        print(f"  Copied {item.name}/")

# Create the mpackage (zip file)
print("\nCreating EMCOChat.mpackage...")
with zipfile.ZipFile(output_file, 'w', zipfile.ZIP_DEFLATED) as zipf:
    for root, dirs, files in os.walk(temp_dir):
        for file in files:
            file_path = Path(root) / file
            arcname = file_path.relative_to(temp_dir)
            zipf.write(file_path, arcname)
            print(f"  Added {arcname}")

print(f"\n✓ Package built successfully: {output_file}")
print(f"  Size: {output_file.stat().st_size:,} bytes")
