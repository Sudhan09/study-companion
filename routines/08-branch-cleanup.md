<!-- Per audit finding #009 remediation. Cleans up merged claude/* branches older than 30 days. -->

# Routine 8: study-branch-cleanup

## Schedule
- **Cron (UTC):** `0 6 * * 0`
- **IST equivalent:** 11:30 Sunday (after drift-audit at 10:30)
- **Frequency:** Weekly, Sunday late-morning

## Repository config
- **Repo:** Sudhan09/study-companion (private)
- **Authentication:** Anthropic-managed proxy (Claude GitHub App).
- **Branch policy:** push to `claude/branch-cleanup-$(TZ=Asia/Kolkata date +%F)`. Default-deny on main per design §H Rule 9.

## Reads
- The local clone of `Sudhan09/study-companion` (already cloned by routine sandbox at run start; specifically `git branch -r --merged origin/main` to enumerate merged branches).

## Writes
- `logs/<YYYY-MM-DD>.md` — appends a `## Branch cleanup (<HH:MM> IST)` section listing deleted branch counts and names.

## Output target
- Commit + push to `claude/branch-cleanup-$(TZ=Asia/Kolkata date +%F)`. The committed log entry is the audit trail; no external notification.

## Routine prompt (paste this into Cowork /schedule UI)

```
You are the study-branch-cleanup routine. Your job is to delete merged claude/* branches older than 30 days from Sudhan09/study-companion. Never touches unmerged branches.

## Steps

Step 0: Pause check (Path A v3 universal preamble; added 2026-05-07).

- Read `state/current_day.md`. If the file does not exist, proceed to Step 1.
- Parse `mode`. If absent, treat as `bootcamp`. If `mode != paused`, proceed to Step 1.
- If `mode == paused`: read `state/vacation.md`. If absent, exit 1. Parse `suppress_routines`. By default, `study-branch-cleanup` is NOT suppressed (maintenance routine; runs through pause). Per GAP-06, branch-cleanup is also explicitly EXCLUDED from `missed_routines.md` carry-forward — even if user adds it to `suppress_routines`, the carry-forward replay path does not re-run it. Proceed to Step 1.
- If user has explicitly added `study-branch-cleanup` to `suppress_routines`: append `| <today-IST-date> | study-branch-cleanup | skipped-vacation | n/a |` to `state/missed_routines.md` for audit, commit `chore(branch-cleanup): skipped — mode=paused`, push, exit cleanly.

Step 1: List candidates.
- Run: `git fetch --all --prune`
- List remote branches: `git branch -r --merged origin/main | grep '^  origin/claude/' | sed 's|^  origin/||'`
- For each branch, get its tip-commit date: `git log -1 --format=%ci origin/<branch>`
- Filter to branches older than 30 days (use `TZ=Asia/Kolkata date -d "today -30 days" +%F` as the cutoff).

Step 2: Verify each candidate is fully merged.
- For each candidate, run: `git merge-base --is-ancestor origin/<branch> origin/main && echo "merged" || echo "unmerged"`
- Drop any reporting "unmerged" — never delete unmerged work.

Step 3: Delete merged candidates.
- For each: `git push origin --delete <branch>`
- Track count of deleted branches.

Step 4: Append audit log atomically.
- Compute target log: logs/$(TZ=Asia/Kolkata date +%F).md
- Read existing content (if file exists) into a tmpfile, then append the new section to the tmpfile, then rename via the helper:

```
date_iso=$(TZ=Asia/Kolkata date +%F)
log="logs/${date_iso}.md"
tmp="${log}.tmp"
cp -f "$log" "$tmp" 2>/dev/null || true   # tolerate first-time create
cat >> "$tmp" <<EOF

## Branch cleanup ($(TZ=Asia/Kolkata date +%H:%M) IST)
- **Deleted:** <N> branches older than 30 days, all merged to main.
- **Branches:** <list>
- **Skipped (unmerged):** <count>
EOF
bash scripts/atomic-write.sh "$tmp" "$log"
```

- This preserves the partial-write guarantee from `scripts/atomic-write.sh`.

Step 5: Commit + push.
- git add logs/<date>.md
- git commit -m "chore(branch-cleanup): deleted <N> merged claude/* branches older than 30d"
- git push origin claude/branch-cleanup-$(TZ=Asia/Kolkata date +%F)

## What you MUST NOT do
- DO NOT delete unmerged branches under any circumstances.
- DO NOT delete the main branch.
- DO NOT delete branches younger than 30 days.
- DO NOT push to main.
```

## Success criteria
- Old merged claude/* branches are gone from the remote.
- logs/<date>.md has a branch-cleanup section with counts.
- Unmerged branches and main are untouched.

## What this routine MUST NOT do
- MUST NOT delete unmerged branches under any circumstances.
- MUST NOT delete the `main` branch (or any branch outside the `claude/*` prefix).
- MUST NOT delete branches younger than 30 days.
- MUST NOT push to `main`. Only `claude/branch-cleanup-<date>`.
- MUST NOT skip the audit log on no-op runs (e.g., when N=0). The log entry confirms the routine ran even on quiet weeks.
