"""Build a clean cross-platform plugin zip with forward-slash paths.

Per ZIP spec (PKZIP appnote 4.4.17.1), entry paths SHOULD use forward slashes.
Windows tools (PowerShell Compress-Archive, .NET ZipFile.CreateFromDirectory) often
produce backslash paths, which Linux-side unzippers reject.
"""
import os
import sys
import zipfile
from pathlib import Path

default_src = Path.home() / ".claude" / "plugins" / "study-companion"
default_dst = Path.home() / "study-companion-plugin.zip"
src = Path(os.environ.get("PLUGIN_SRC_DIR", str(default_src)))
dst = Path(os.environ.get("PLUGIN_ZIP_DST", str(default_dst)))

if dst.exists():
    dst.unlink()

EXCLUDE_DIRS = {"__pycache__", "node_modules", ".git", "tests"}
EXCLUDE_FILES = {"marketplace.json"}  # marketplace.json is for /plugin marketplace flow, not direct UI upload

count = 0
with zipfile.ZipFile(dst, "w", zipfile.ZIP_DEFLATED) as zf:
    for root, dirs, files in os.walk(src):
        dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]
        for fname in files:
            if fname in EXCLUDE_FILES:
                continue
            full = Path(root) / fname
            rel = full.relative_to(src)
            arcname = rel.as_posix()  # forward slashes per ZIP spec
            zf.write(full, arcname)
            count += 1

size_kb = dst.stat().st_size / 1024
print(f"Created {dst} ({size_kb:.1f} KB) with {count} entries (forward-slash paths)")
