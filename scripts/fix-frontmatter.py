"""Move leading HTML provenance comments from before YAML frontmatter to after it.

Bug: Subagent B wrote SKILL.md and agent files like:
    <!-- Per design §B ... -->
    ---
    name: foo
    ...

YAML frontmatter must start at line 1. The leading HTML comment breaks parsing.
This script moves the comment to after the closing --- (or removes if user prefers).
"""
import re
from pathlib import Path

PLUGIN_DIR = Path(r"C:\Users\sudha\.claude\plugins\study-companion")
PATTERN = re.compile(
    r"^(<!--[^\n]*-->)\n+(---\n.*?\n---\n)(.*)$",
    re.DOTALL,
)

targets = list(PLUGIN_DIR.glob("skills/*/SKILL.md")) + list(PLUGIN_DIR.glob("agents/*.md"))
fixed = []
skipped = []
for f in targets:
    content = f.read_text(encoding="utf-8")
    m = PATTERN.match(content)
    if not m:
        skipped.append(f"{f}: no leading-comment-before-frontmatter pattern")
        continue
    comment, frontmatter, body = m.groups()
    # Reorder: frontmatter first, then comment, then body
    new_content = frontmatter + comment + "\n" + body
    # Force LF line endings — Cowork's Linux-side parser is strict, and the local
    # skill validator regex `^---\n` doesn't match `\r\n`.
    new_content = new_content.replace("\r\n", "\n").replace("\r", "\n")
    f.write_bytes(new_content.encode("utf-8"))
    fixed.append(str(f.relative_to(PLUGIN_DIR)))

print(f"Fixed {len(fixed)} files:")
for p in fixed:
    print(f"  {p}")
if skipped:
    print(f"\nSkipped {len(skipped)}:")
    for s in skipped:
        print(f"  {s}")
