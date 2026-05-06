# Windows handoff — Audit 2026-05-06 remediation testing

> **Where to read this:** `docs/2026-05-06-windows-handoff.md` on `main` (PR #1 merged 2026-05-06 at commit `f1afc3a`).
>
> **Audience:** Sudhan, on Windows 11, after switching from the Linux session that produced this branch.

---

## 1. What's already done

- **PR #1 merged to main 2026-05-06** at commit `f1afc3a`. Branch `fix/audit-2026-05-06-remediation` deleted.
- 41 audit-fix commits + 1 doc commit close 35 of the 38 audit findings (the other 3 are deferred / accepted as no-op per the plan's self-review table).
- All three validators (`scripts/validate-imports.js`, `scripts/validate-state-schemas.js`, `scripts/validate-wins-schemas.js`) green on `main`.
- New artifacts: `SECURITY.md`, `scripts/atomic-write.sh`, `scripts/check-routine-skew.sh`, `scripts/validate-wins-schemas.js`, `routines/08-branch-cleanup.md`, `docs/design-plan-snapshot.md` + `docs/build-plan-snapshot.md` stubs.
- Tag `audit-2026-05-06-remediated` on the pre-merge HEAD.

## 2. What this doc covers

The 6 Phase-6 user-action items the harness could not automate, plus how to verify each one worked. Everything below requires Cowork (claude.ai/schedule UI) which is why it waits for Windows.

**It does NOT cover:**
- The plugin at `C:\Users\sudha\.claude\plugins\study-companion\` — that's a separate artifact, not in this PR. If you want to apply audit-style fixes to the plugin (hooks, skills, agents), that's a follow-up project.
- The 3 deferred audit findings (#024 drift_log placeholder syntax, #034 lazy-create distilled.md, #035 plugin-separate, #037 cosmetic Sunday cron). Background only — no action.
- Cowork hooks dormant per #40495 — known external bug, no action.

---

## 3. Pre-flight (5 min, before any Phase-6 work)

### 3.1 Pull the merged main on Windows

In Git Bash / WSL / PowerShell:
```bash
cd C:/Users/sudha/study-companion
git checkout main
git pull
```
Verify HEAD: `git log -1 --oneline` should show `f1afc3a Merge pull request #1 from Sudhan09/fix/audit-2026-05-06-remediation` (or whatever the merge commit ended up as if you did the merge differently). `git log --oneline | head -5` should show the audit work + merge commit at the top.

### 3.2 Verify tools
```bash
node --version          # any LTS (≥18) is fine
python --version        # 3.x for the YAML round-trip checks
gh auth status          # must be logged in as Sudhan09 with repo scope
```

### 3.3 Run the validators locally to confirm the branch is healthy
```bash
node scripts/validate-imports.js                         # OK 13 imports
node scripts/validate-state-schemas.js                   # OK 7 state files
node scripts/validate-wins-schemas.js                    # OK 6 wins
bash scripts/check-routine-skew.sh                       # 8 hash lines
```
If any of these fail, stop and ping back here — the branch shouldn't be regressing.

---

## 4. Phase-6 actions (in dependency order)

### Action U4 — Install Claude GitHub App on pipeline repo (~2 min)
**Why first:** routine 01's `git clone` of the pipeline can't authenticate without this.

1. Visit https://github.com/apps/claude/installations
2. Confirm BOTH repos appear in the access list:
   - `Sudhan09/study-companion`
   - `Sudhan09/python_bootcamp_claude_code`
3. If `python_bootcamp_claude_code` is missing: click "Configure" on the Claude installation, scroll to "Repository access", select "Only select repositories", add `python_bootcamp_claude_code`, save.

**Verify:** in the install page, both repos visible. No further test possible without Cowork; verifying U2 below will confirm end-to-end.

### Action U2 — Add pipeline repo to routine 01's /schedule UI repo list (~3 min)
**Depends on:** U4.

1. Open https://claude.ai/schedule.
2. Click `study-curriculum-sync` (routine 01).
3. Look for "Connect repository" or "Repository access" in the routine's settings.
4. Add `Sudhan09/python_bootcamp_claude_code` as a secondary repo (in addition to the existing primary `study-companion`).
5. Save.

**Verify:** the routine's repo list now shows both repos. Run a manual test in U1b below.

### Action U1 — Re-paste each routine's prompt block into /schedule UI (~30-45 min)
**Depends on:** U2 (for routine 01 specifically).

The 8 routines you need to update, in safe order:

| Order | Routine | File | Notes |
|---|---|---|---|
| 1 | `study-spaced-rep-reminder` | `routines/03-spaced-rep-reminder.md` | Independent. Cron unchanged (`30 13 * * 1-6`). |
| 2 | `study-github-commit-reminder` | `routines/04-github-commit-reminder.md` | Independent. Cron unchanged (`0 15 * * 1-6`). |
| 3 | `study-weekly-review` | `routines/05-weekly-review.md` | Independent. Cron unchanged (`30 4 * * 0`). |
| 4 | `study-monday-distillation` | `routines/06-monday-distillation.md` | Independent. Cron unchanged (`30 3 * * 1`). |
| 5 | `study-drift-audit` | `routines/07-drift-audit.md` | Independent. Cron unchanged (`0 5 * * 0`). |
| 6 | `study-curriculum-sync` | `routines/01-curriculum-sync.md` | After U2. Cron unchanged (`0 3 * * *`). |
| 7 | `study-morning-briefing` | `routines/02-morning-briefing.md` | **CRON CHANGED** from `15 3 * * *` to `30 3 * * *` (08:45 → 09:00 IST). Update the cron field too, not just the prompt. |
| 8 | `study-branch-cleanup` | `routines/08-branch-cleanup.md` | **NEW ROUTINE** — create from scratch. Cron `0 6 * * 0`. Sun 11:30 IST. |

**Per-routine procedure:**
1. Open the file in your editor: `routines/0X-*.md`
2. Find the fenced block under `## Routine prompt (paste this into Cowork /schedule UI)` — that's the entire prompt body.
3. Copy from the opening triple-backticks (exclusive) to the closing triple-backticks (exclusive).
4. In claude.ai/schedule, edit the routine, paste into the prompt field, save.
5. **Verify the paste with the skew check:**

   ```bash
   bash scripts/check-routine-skew.sh
   ```

   Note the hash for the routine you just pasted (e.g., `02-morning-briefing: b471a13870693d76`). Then in claude.ai/schedule, copy the prompt body back out and run:

   ```bash
   echo -n '<paste prompt body here>' | sha256sum | cut -c1-16
   ```

   The two 16-char hashes must match. If not, the paste introduced whitespace differences — re-paste.

**For routine 08 (new):** there's no existing /schedule UI entry. Click "+ Create routine" (or whatever the new-routine flow is), name it `study-branch-cleanup`, set cron `0 6 * * 0`, repo `Sudhan09/study-companion`, paste the prompt block from `routines/08-branch-cleanup.md`, save.

### Action U5 — Paste design + build plan content into stubs (~10 min)
**Independent, no Cowork needed.**

The audit referenced design plan §A-§J and build plan phases extensively via `<!-- Per design §X -->` HTML comments. Currently those references point at private Windows paths (`C:\Users\sudha\docs\superpowers\plans\2026-05-06-cowork-study-companion(-build).md`) that aren't in the repo. Two stub files exist for repo-local snapshots:

```bash
# Open these and replace the placeholder text below the H2 list with the actual content from your private docs/superpowers/plans/ files
docs/design-plan-snapshot.md
docs/build-plan-snapshot.md
```

After pasting:
```bash
git add docs/design-plan-snapshot.md docs/build-plan-snapshot.md
git commit -m "docs: paste design + build plan content into snapshot stubs

Closes audit finding #017 (full closure). Repo-local snapshots
mirror the private plans so 'Per design §X' references in HTML
comments throughout the repo can be verified without leaving the repo."
git push
```

### Action U6 — Document branch-merge cadence in README (~5 min)
**Independent, no Cowork needed.**

The 7 cron routines push to `claude/<routine>-<YYYY-MM-DD>` branches; routine 08 prunes merged ones older than 30 days. Without a documented merge cadence, routine output stays on isolated branches forever and the branch-cleanup routine has nothing to delete.

Append a section to `README.md`:
```markdown
## Branch merge cadence

Routine output lands on dated `claude/<routine>-<YYYY-MM-DD>` branches per Anthropic's web-scheduled-tasks default-deny policy. Merge cadence:

- **Daily** (or as frequently as practical): merge `claude/morning-briefing-*` and `claude/curriculum-sync-*` into `main` so today's session sees today's plan + curriculum scope. A simple loop: `for b in $(git branch -r --merged ... | grep claude/); do git merge --no-ff $b; done`. Or via GitHub web UI.
- **Weekly (Monday)**: merge the prior week's `claude/spaced-rep-*`, `claude/commit-reminder-*`, `claude/weekly-review-*`, `claude/monday-distillation-*`, `claude/drift-audit-*`. The drift-audit and weekly-review entries are the highest-value audit-trail records; the rest are nudge artifacts.
- **Monthly**: review unmerged `claude/*` branches; if any are still unmerged, decide keep-or-discard. The `study-branch-cleanup` routine (Sun 11:30 IST) auto-deletes only branches that ARE merged AND >30d old, so unmerged branches accumulate until you act on them.
```

Commit:
```bash
git add README.md
git commit -m "docs(readme): document branch-merge cadence

Closes audit finding #009 user-action portion. Without a documented
cadence, routine output stays on isolated branches and the new
branch-cleanup routine (#5b599e8) has nothing to delete."
git push
```

---

## 5. End-to-end smoke test (~24 hours observation, no active work)

After all 8 routines are pasted and U2 + U4 are confirmed:

### 5.1 Trigger routine 01 manually
In claude.ai/schedule, find `study-curriculum-sync` and click "Run now" (or equivalent).

**Expected:** within 5-10 min, a new commit on `claude/curriculum-sync-<today's-IST-date>` containing 6 XML files in `instructions/curriculum/` plus `.last-sync-status` with `"status": "OK"`.

**Failure modes:**
- Clone fails 401 → U2 not done correctly. Re-check repo list.
- Clone fails 404 → U4 not done. Verify GitHub App on pipeline repo.
- `.last-sync-status` shows `"status": "STALE"` with a missing-file list → pipeline repo content has changed shape since the audit. Investigate the pipeline repo's `config/` directory.

### 5.2 Trigger routine 02 manually (after 5.1 succeeds)
Click "Run now" on `study-morning-briefing`.

**Expected:** within 3-5 min, a new commit on `claude/morning-briefing-<today's-IST-date>` containing `state/schedule.md` (today's plan) + `logs/<today>.md` (header). NO `[STALE-CURRICULUM]` flag at the top of `state/schedule.md`.

**Failure modes:**
- `[STALE-CURRICULUM]` flag present → routine 01 didn't complete in time, or `.last-sync-status` timestamp doesn't match today's IST date. Check timing.
- Branch named with yesterday's date → IST-vs-UTC date confusion. Should NOT happen now (IST branch suffix is explicit), but verify.

### 5.3 Wait for natural cron fire (next morning)
Routine 01 fires at 08:30 IST, routine 02 at 09:00 IST. Watch the GitHub repo branches list around 09:05 IST. Both branches should appear with today's date.

### 5.4 Wait for evening routines (Mon-Sat)
- 19:00 IST: routine 03 (`study-spaced-rep-reminder`) — commits `state/spaced-rep-<date>.md`. (No phone notification per D1=A — file is the polling surface.)
- 20:30 IST: routine 04 (`study-github-commit-reminder`) — appends to `logs/<date>.md` with commit count.

### 5.5 Wait for Sunday routines
- 10:00 IST: routine 05 (`study-weekly-review`) — commits `state/weekly-review-<date>.md`.
- 10:30 IST: routine 07 (`study-drift-audit`) — commits `state/drift-audit-<date>.md`. Will likely be no-data the first week.
- 11:30 IST: routine 08 (`study-branch-cleanup`) — appends to `logs/<date>.md` with branch deletion count (likely 0 the first ~5 weeks).

### 5.6 Wait for Monday-09:00 routine
- 09:00 IST: routine 06 (`study-monday-distillation`) — moves logs older than 7 days to `archive/completed_days/`. Will be no-op until logs/ accumulates >7 days of files.

---

## 6. Scope boundaries

**In scope (this handoff):**
- Phase 6 user actions (U1, U2, U4, U5, U6).
- Routine functional verification.
- Validator regression check.

**Out of scope (separate work):**
- Plugin updates (`C:\Users\sudha\.claude\plugins\study-companion\`). The plugin's hooks, skills, agents, and tests are NOT in this PR. If you want them audited and remediated, that's a follow-up project requiring access to the plugin filesystem.
- Routine prompt content changes beyond what landed in the PR. If you want to tweak any routine's behavior, edit the file in this repo, commit, push, then re-paste into /schedule UI (and the skew-check hash will tell you when re-paste is needed).
- Cowork bug #40495 (hooks dormant). External Anthropic issue; will resolve when they ship a fix.
- The 3 deferred audit findings (#024, #034 / #035 accepted as no-op, #037 cosmetic). Documented in audit report; no work needed.

---

## 7. When to come back here (the Linux session)

You don't strictly need to return — every step above is doable from Windows alone. But if you hit any of these, ping back and I'll pick up:

- Validator turns red after a routine writes a state file (means writer-name drift or unexpected schema). I can extend `ALLOWED_WRITERS` or the schema check to absorb it, OR re-spec the routine to write conformant frontmatter.
- A routine's prompt rejects in /schedule UI (length cap, syntax, etc.) — I can split or shorten.
- Cowork itself behaves differently than the audit assumed (e.g., a tool the routine calls doesn't exist, an env var isn't set, a branch policy differs). I'll re-think that routine.
- After 1 week of natural firing, you want a summary of what landed vs what failed silently. Send me the contents of `logs/`, `state/drift-audit-<date>.md`, and the `claude/*` branch list and I'll do a status pass.
- You want to start the plugin remediation project (separate from this audit's scope).

---

## 8. Quick command reference (Windows-side)

```bash
# Pull the latest audit branch
cd C:/Users/sudha/study-companion
git fetch origin
git checkout fix/audit-2026-05-06-remediation
git pull

# Run all validators
node scripts/validate-imports.js
node scripts/validate-state-schemas.js
node scripts/validate-wins-schemas.js

# Get baseline hashes for /schedule UI comparison
bash scripts/check-routine-skew.sh

# Hash a string from clipboard (paste between quotes)
echo -n '<paste here>' | sha256sum | cut -c1-16

# Smoke-test atomic-write helper
echo "test" > /tmp/aw.tmp && bash scripts/atomic-write.sh /tmp/aw.tmp /tmp/aw.dst && cat /tmp/aw.dst && rm /tmp/aw.dst

# Sweep for residual issues (should all return "OK")
grep -rn "Dispatch" routines/ | grep -v "Dispatch removed" | grep -v "<!--" || echo "OK: no live Dispatch"
grep -rn "08:45" state/ routines/ --include='*.md' && echo "FAIL" || echo "OK: no stale 08:45"
grep -rn "Atomic-write: tmpfile" routines/ && echo "FAIL: stale text" || echo "OK"
grep -rni 'C:\\Users\\sudha\|C:/Users/sudha' . --include='*.md' --include='*.py' --include='*.js' --exclude-dir=.git 2>/dev/null || echo "OK: no Windows paths"

# After all routines re-pasted, watch for branch creation
git ls-remote origin 'refs/heads/claude/*' | head
```

---

## 9. The final acceptance check

PR merge already done (✅ pre-merged on Linux side). You're done with Phase 6 when ALL of these hold:

1. ☐ Both repos visible in https://github.com/apps/claude/installations.
2. ☐ Routine 01's /schedule UI repo list contains both repos.
3. ☐ All 8 routines paste-verified (skew-check hashes match UI text).
4. ☐ Routine 01 + routine 02 manual test produces a green run with no STALE flags.
5. ☐ `docs/design-plan-snapshot.md` and `docs/build-plan-snapshot.md` contain the actual plan content (not just stubs).
6. ☐ README.md has the "Branch merge cadence" section.
7. ✅ PR #1 merged to main (commit `f1afc3a`, 2026-05-06).

After that, the audit-2026-05-06 remediation is OPERATIONALLY complete. The branch tag `audit-2026-05-06-remediated` marks the state. Any further work (plugin audit, follow-up findings, etc.) is a new project.
