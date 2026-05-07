# Windows handoff — Audit 2026-05-06 + Plugin Remediation

> **What this is:** detailed step-by-step for resuming on Windows after the audit + remediation work done on Linux 2026-05-06. Read this top-to-bottom before doing anything.
>
> **Audience:** Sudhan, on Windows 11, in a NEW Claude Code session (the Linux session that produced this is gone — context doesn't carry over).
>
> **Where to read this:** in any clone of `Sudhan09/study-companion`, file `docs/2026-05-06-windows-handoff.md` on the `main` branch.

---

## 1. Three repos, one system — know which is which

You now own **three GitHub repos** that work together:

| Repo | Role | Where it lives on your machine | Status |
|---|---|---|---|
| **`Sudhan09/study-companion`** | Granted folder. Holds state files, instructions/, wins/, routines/, drills/, RTI tracker. Loaded via CLAUDE.md @-imports in every Cowork session AND read by the plugin's hooks on claude.ai/code. | `C:\Users\sudha\study-companion\` | ✅ Merged 2026-05-06 (commit `f1afc3a`). 41 audit-fix commits on `main`. **Phase 6 user-actions pending.** |
| **`Sudhan09/study-companion-plugin`** *(new)* | The Claude Code plugin. Ships 12 skills, 2 sub-agents, 3 hook handlers (SessionStart, UserPromptSubmit, Stop), `_lib.js` shared code. Installed in Cowork via "Upload custom plugin file"; auto-discovered on claude.ai/code if cloned to `~/.claude/plugins/` | `C:\Users\sudha\.claude\plugins\study-companion\` | ✅ Pushed 2026-05-06. 41 plugin-audit-fix commits on `main`. **Local install pending.** |
| **`Sudhan09/python_bootcamp_claude_code`** | Bootcamp pipeline (curriculum XMLs). Read by routine 01 to sync into `instructions/curriculum/` in the granted folder. | (cloned by the cron routine, not your local machine — but the Claude GitHub App needs read access) | Pre-existing, unchanged. **Verify GitHub App access.** |

The audit + remediation on 2026-05-06 produced:
- **38 findings** in the granted folder (`Sudhan09/study-companion`) — all closed, merged via PR #1
- **36 findings** in the plugin (`Sudhan09/study-companion-plugin`) — 32 closed (4 deferred per plan), pushed to a fresh repo

There are NO open issues left in either repo's audit. The remaining work is purely operational: install the new plugin on your Windows machine, paste 8 routine prompts into Cowork's /schedule UI, and a few one-time setup items.

---

## 2. State summary (what's done vs what's left)

> **🟢 MAJOR STATUS UPDATE — 2026-05-06 evening (Linux session)**
>
> Most of what was originally listed here as "pending on Windows" got done on Linux because `claude.ai/code/routines` and `github.com` are just web pages — no Cowork-the-desktop-app required. The remaining Windows-side work shrunk from ~75 min to ~25 min.
>
> **Detail sections §3-§11 below describe the original full handoff.** They're preserved as reference for the historical record + Track 1 Cowork-side install instructions you'll still need. Read them only for steps marked still pending in the table below.

### Done on Linux (2026-05-06, day + evening)
- ✅ Granted-folder audit (38 findings, all closed in PR #1, merged to `main` at `f1afc3a`)
- ✅ Plugin audit (36 findings, 32 closed + 4 deferred, pushed to `Sudhan09/study-companion-plugin`)
- ✅ Hardening fix-pass on plugin (caught 2 critical issues code review almost let slip — fixed before push)
- ✅ 53 unit-test assertions added to plugin; all green
- ✅ Plugin cloned to `/home/sudhan/study-companion-plugin/`; all 4 hook handlers verified working end-to-end (Track 1 Linux side)
- ✅ U6 — README "Branch merge cadence" section pushed at `f3fc601`
- ✅ U4 — Claude GitHub App verified covering `Sudhan09/study-companion` + `Sudhan09/python_bootcamp_claude_code`
- ✅ U2 — pipeline repo `python_bootcamp_claude_code` added as secondary in routine 01 (folded into create)
- ✅ U1 — All 8 cron routines created at `claude.ai/code/routines`:
  - `study-curriculum-sync` (Daily 08:30 IST) — manual smoke test PASSED, produced clean `claude/curriculum-sync-2026-05-06` branch with `"status": "OK"` + 6 XML files synced from pipeline
  - `study-morning-briefing` (Daily 09:00 IST)
  - `study-spaced-rep-reminder` (Daily 19:00 IST — accepts Sunday-noise; tighten to Mon-Sat via CLI later if desired)
  - `study-github-commit-reminder` (Daily 20:30 IST — same Sunday-noise note)
  - `study-weekly-review` (Weekly Sun 10:00 IST)
  - `study-monday-distillation` (Weekly Mon 09:00 IST)
  - `study-drift-audit` (Weekly Sun 10:30 IST)
  - `study-branch-cleanup` (Weekly Sun 11:30 IST — brand-new routine, will be no-op for ~5 weeks until claude/* branches age past 30 days)
- ✅ `/web-setup` complete — gh token synced to claude.ai for cloud-session repo cloning

### Still pending on Windows
- **Track 1 Cowork-side** — replace the OLD plugin in `C:\Users\sudha\.claude\plugins\study-companion\` with the audited version (~5-10 min)
- **U5** — paste full design + build plan content from your private Windows-side plans into `docs/{design,build}-plan-snapshot.md`, commit + push (~10 min)

### Optional / observation
- **Track 3** — observe natural cron fires over the next 1-2 weeks; verify branches accumulate
- **Track 4** — publish marketplace repo for paths #2/#3/#5 (skip unless you want to share the plugin or auto-load it in `claude.ai/code` web sessions)
- **Tighten routines 3 + 4 to Mon-Sat** — via `/schedule update` in any `claude` CLI session if Sunday-noise bothers you

### What you have at the time this update was written
- 8 routines listed at https://claude.ai/code/routines, all marked **Active**
- Plugin at `Sudhan09/study-companion-plugin` HEAD = `9d7aa15` (tag `audit-2026-05-06-plugin-remediated`)
- Granted folder at `Sudhan09/study-companion` HEAD = `f3fc601` (tag `audit-2026-05-06-remediated` is at the earlier `f1afc3a`)
- 1 manual run already on the books: `claude/curriculum-sync-2026-05-06` branch, success

---

## 3. Pre-flight on Windows (5 min, before any tracks)

### 3.1 Pull the latest granted folder (which contains this doc)

In PowerShell, Git Bash, or WSL:
```bash
cd C:/Users/sudha/study-companion
git checkout main
git pull
git log -1 --oneline    # should show "docs: update Windows handoff..." (or newer)
```

### 3.2 Verify tools you'll need

```bash
node --version          # any LTS ≥ 18 — needed for plugin tests + validators
python --version        # 3.x — needed for YAML round-trip checks
gh auth status          # must be logged in as Sudhan09 with `repo` scope
git config user.name    # should be set
git config user.email   # should be set
```

If `gh` is not installed: https://cli.github.com/ → install → `gh auth login`.

### 3.3 Verify the audit work is in place

```bash
# Granted folder validators (should all exit 0)
node scripts/validate-imports.js
node scripts/validate-state-schemas.js
node scripts/validate-wins-schemas.js
bash scripts/check-routine-skew.sh    # produces 8 hash lines
```

If any of these fails, STOP and report back here — the granted folder shouldn't be regressing.

### 3.4 Get the plugin repo locally

```bash
cd C:/Users/sudha
git clone https://github.com/Sudhan09/study-companion-plugin.git
# This clones into C:/Users/sudha/study-companion-plugin/ (a separate folder from the granted folder)
cd study-companion-plugin
git log -1 --oneline    # should show "feat(tests): cover STALE emission..." or similar
node tests/run-all.js   # should print "All tests + validators passed."
```

If `node tests/run-all.js` doesn't pass, STOP — the plugin isn't ready for install.

---

## 4. Track 1 — Replace the local plugin (~15 min)

This is the FIRST track to do. Plugin install affects Cowork's behavior on every subsequent session, so you want it correct before re-pasting routines or running smoke tests.

### 4.1 What's currently installed (the OLD plugin)

The plugin you already have at `C:\Users\sudha\.claude\plugins\study-companion\` is the **pre-audit version** with the 36 known bugs (critical: stop.js reads non-existent `assistant_response` field; UserPromptSubmit regex omits `:lock`/`:companion`/`:wrap` deterministic tokens; etc.). You don't want to keep using it.

### 4.2 Replacement — Pick ONE of three options

#### Option A — git clone (easiest if you'll ever modify the plugin yourself)

```bash
# Backup the old plugin (you can delete after verifying the new one works)
cd C:/Users/sudha/.claude/plugins/
mv study-companion study-companion.OLD-pre-audit-2026-05-06

# Clone the new one
git clone https://github.com/Sudhan09/study-companion-plugin.git study-companion

# Verify
cd study-companion
node tests/run-all.js   # 53 assertions + 2 validators pass
ls .claude-plugin/plugin.json    # exists
ls hooks/                # 4 files: _lib.js, hooks.json, session-start.js, stop.js, user-prompt-submit.js (NO pre-compact.js — correctly absent)
```

This makes future updates `git pull` away.

#### Option B — symlink (advanced; useful if you want to develop in `C:/Users/sudha/study-companion-plugin/`)

```bash
cd C:/Users/sudha/.claude/plugins/
mv study-companion study-companion.OLD-pre-audit-2026-05-06
# PowerShell mklink (run as Administrator) OR:
cmd /c mklink /D study-companion C:/Users/sudha/study-companion-plugin
```

Edits in `C:/Users/sudha/study-companion-plugin/` flow through to the symlinked install. Run `node tests/run-all.js` from either path.

#### Option C — zip + Cowork "Upload custom plugin file" UI (no command line)

```bash
cd C:/Users/sudha/study-companion-plugin
# In Git Bash:
zip -r ../study-companion-plugin.zip . -x ".git/*" "tests/*"
# OR in PowerShell:
Compress-Archive -Path .\* -DestinationPath ..\study-companion-plugin.zip -Force
```

Then in Claude Desktop:
1. Open Cowork.
2. Customize menu (left sidebar) → "Upload custom plugin file".
3. Pick `C:/Users/sudha/study-companion-plugin.zip`.
4. Confirm install.

Note: if the OLD version is still listed under installed plugins, uninstall it first (Customize → installed plugins → remove `study-companion` → restart Cowork → upload new one).

### 4.3 Reload Claude Code so the new plugin takes effect

In whatever surface you're using:
- **Claude Desktop / Cowork**: quit + relaunch the app.
- **Claude Code CLI / VS Code**: run `/reload-plugins` in any active session, OR start a fresh session.

### 4.4 Smoke test the new plugin

Open a session in the **claude.ai/code** surface (NOT Cowork — Cowork hooks are dormant per known Anthropic bug #40495). The simplest way: `cd C:/Users/sudha/study-companion && claude` in the terminal.

In that session, try the deterministic tokens that were the most-broken before the fix:

```
:lock
```
Expected: a system message acknowledging the lock-decision skill should fire OR an automatic invocation of `/lock-decision` (depending on Anthropic harness behavior). Before fix: nothing — the regex didn't match `:lock`.

```
I don't get it
```
Expected: re-angle directive (the model says something like "Let me re-angle that with a different analogy/visualization"). Try with both straight `'` and curly `'` apostrophes — both should work after fix #003.

Type a teaching response and end with `Hope this helps!`. Then submit. Open `state/drift_log.md` in the granted folder — should now have a new entry like `... | failure=#10 severity=hard | detail="filler phrase detected: Hope this helps!"`. Before fix: drift_log was never written to from claude.ai/code because `stop.js` read the wrong field.

### 4.5 (Optional) Make the plugin repo public

If you want to share the plugin or use the `--plugin-dir` install path more easily:
```bash
gh repo edit Sudhan09/study-companion-plugin --visibility public
```

---

## 5. Track 2 — Granted-folder Phase 6 user actions (~60 min)

These were already pending from the granted-folder merge. Do them AFTER Track 1 so the new plugin is loaded when you test.

### 5.1 (U4) Verify Claude GitHub App access on the pipeline repo (~2 min)

1. Visit https://github.com/apps/claude/installations
2. Find your account; click "Configure"
3. Confirm BOTH of these repos appear under "Repository access":
   - `Sudhan09/study-companion`
   - `Sudhan09/python_bootcamp_claude_code`
4. If `python_bootcamp_claude_code` is missing: select "Only select repositories" → add it → save

You may also want to verify access to `Sudhan09/study-companion-plugin` if you plan to use it from cloud sessions.

### 5.2 (U2) Add pipeline repo to routine 01's /schedule UI repo list (~3 min)

**Depends on U4** — App must be installed first.

1. Open https://claude.ai/code/routines
2. Find `study-curriculum-sync` (routine 01)
3. Click into its settings — look for "Connect repository" or "Repositories"
4. Add `Sudhan09/python_bootcamp_claude_code` as a secondary repo (in addition to the existing `study-companion` primary)
5. Save

### 5.3 (U1) Re-paste each updated routine prompt into Cowork /schedule UI (~30-45 min)

The routine prompts in `routines/0X-*.md` have been heavily revised but the LIVE COPIES in claude.ai/code/routines are the OLD ones. Anthropic doesn't auto-sync; you have to re-paste.

**8 routines to update.** Do them in this order — independent ones first, then the dependents:

| Order | Routine | File | Action |
|---|---|---|---|
| 1 | `study-spaced-rep-reminder` | `routines/03-spaced-rep-reminder.md` | Re-paste prompt body (cron unchanged: `30 13 * * 1-6`) |
| 2 | `study-github-commit-reminder` | `routines/04-github-commit-reminder.md` | Re-paste (cron unchanged: `0 15 * * 1-6`) |
| 3 | `study-weekly-review` | `routines/05-weekly-review.md` | Re-paste (cron unchanged: `30 4 * * 0`) |
| 4 | `study-monday-distillation` | `routines/06-monday-distillation.md` | Re-paste (cron unchanged: `30 3 * * 1`) |
| 5 | `study-drift-audit` | `routines/07-drift-audit.md` | Re-paste (cron unchanged: `0 5 * * 0`) |
| 6 | `study-curriculum-sync` | `routines/01-curriculum-sync.md` | Re-paste, AFTER U2 (cron unchanged: `0 3 * * *`) |
| 7 | `study-morning-briefing` | `routines/02-morning-briefing.md` | Re-paste **AND CHANGE THE CRON** from `15 3 * * *` to `30 3 * * *` (08:45 IST → 09:00 IST). Also bump the Frequency description. |
| 8 | `study-branch-cleanup` | `routines/08-branch-cleanup.md` | **NEW ROUTINE — create from scratch.** Click "+ Create routine", name `study-branch-cleanup`, cron `0 6 * * 0` (Sun 11:30 IST), repo `Sudhan09/study-companion`, paste prompt body. |

**Per-routine procedure:**

1. Open the granted-folder file in your editor: `routines/0X-*.md`
2. Find the section that begins `## Routine prompt (paste this into Cowork /schedule UI)`
3. The prompt body is between the FIRST opening triple-backtick after that header and the closing triple-backtick. Copy ONLY the content between the backticks (not the backticks themselves).
4. In claude.ai/code/routines, edit the routine, paste into the prompt field, save.
5. Verify the paste with the skew check:
   ```bash
   cd C:/Users/sudha/study-companion
   bash scripts/check-routine-skew.sh
   ```
   Note the hash for the routine you just pasted (e.g., `02-morning-briefing: b471a13870693d76`).
6. In claude.ai/code/routines, copy the prompt body BACK out of the UI and into a clipboard / temp file:
   ```bash
   echo -n '<paste the prompt body here>' | sha256sum | cut -c1-16
   ```
7. The two 16-char hashes must match. If not, re-paste — the UI may have introduced whitespace differences (smart quotes, trailing whitespace, line-ending normalization).

**For routine 08 (the new branch-cleanup):**
- It's brand new. There's no existing /schedule UI entry to overwrite.
- Click "+ Create routine" (or whatever the new-routine flow is in claude.ai/code/routines).
- Name: `study-branch-cleanup`
- Cron: `0 6 * * 0`
- Repo: `Sudhan09/study-companion`
- Prompt body: copy from `routines/08-branch-cleanup.md`'s `## Routine prompt` block.
- Save.

### 5.4 (U5) Paste design + build plan content into the snapshot stubs (~10 min)

Two files exist as stubs in the granted folder:
- `docs/design-plan-snapshot.md` (19 lines stub)
- `docs/build-plan-snapshot.md` (stub)

The actual design + build plans live in your private docs at:
- `C:\Users\sudha\docs\superpowers\plans\2026-05-06-cowork-study-companion.md`
- `C:\Users\sudha\docs\superpowers\plans\2026-05-06-cowork-study-companion-build.md`

Open each stub, paste the corresponding plan content below the placeholder line. Then:
```bash
cd C:/Users/sudha/study-companion
git add docs/design-plan-snapshot.md docs/build-plan-snapshot.md
git commit -m "docs: paste full design + build plan content into snapshot stubs

Closes audit finding #017 (full closure). Repo-local snapshots
mirror the private plans so 'Per design §X' references in HTML
comments throughout the repo can be verified without leaving the repo."
git push
```

### 5.5 (U6) Document branch-merge cadence in README (~5 min)

The 7 cron routines push to `claude/<routine>-<YYYY-MM-DD>` branches. Routine 08 prunes merged ones older than 30 days. Without a documented merge cadence, output stays on isolated branches forever.

Append a section to `README.md`:

```markdown
## Branch merge cadence

Routine output lands on dated `claude/<routine>-<YYYY-MM-DD>` branches per Anthropic's web-scheduled-tasks default-deny policy. Merge cadence:

- **Daily (or as practical):** merge `claude/morning-briefing-*` and `claude/curriculum-sync-*` into `main` so today's session sees today's plan + curriculum scope. Quick pattern: from main, `git fetch origin && for b in $(git branch -r | grep "origin/claude/morning-briefing\|origin/claude/curriculum-sync"); do git merge --no-ff "$b"; done && git push`. Or use the GitHub web UI.
- **Weekly (Monday morning):** merge the prior week's `claude/spaced-rep-*`, `claude/commit-reminder-*`, `claude/weekly-review-*`, `claude/monday-distillation-*`, `claude/drift-audit-*`. The drift-audit and weekly-review entries are the highest-value records; the rest are nudge artifacts.
- **Monthly:** review unmerged `claude/*` branches; if any are still unmerged, decide keep-or-discard. The `study-branch-cleanup` routine (Sun 11:30 IST) auto-deletes only branches that ARE merged AND >30d old, so unmerged branches accumulate until you act on them.
```

Commit:
```bash
cd C:/Users/sudha/study-companion
git add README.md
git commit -m "docs(readme): document branch-merge cadence

Closes audit finding #009 user-action portion."
git push
```

---

## 6. Track 3 — Smoke test (manual + observe)

Run AFTER Tracks 1 and 2 complete.

### 6.1 Manual triggers (~15 min — gives you immediate feedback)

In claude.ai/code/routines, find each routine that has a "Run now" / "Trigger" button.

**Trigger routine 01 first:**
- Wait 5-10 min for completion.
- In a new shell: `cd C:/Users/sudha/study-companion && git fetch && git log --all --oneline -5`
- Expected: a new commit on `claude/curriculum-sync-<today's-IST-date>` with 6 XML files in `instructions/curriculum/` plus `.last-sync-status` containing `"status": "OK"`.
- **If `"status": "STALE"`:** routine 01's pipeline clone failed. Most likely cause: U2 not done (pipeline repo not added as secondary in /schedule UI), OR U4 not done (Claude GitHub App not installed on pipeline repo). Re-do those steps.

**Trigger routine 02 second:**
- Wait 3-5 min for completion.
- `git log --all --oneline -5` → expect a new commit on `claude/morning-briefing-<today's-IST-date>` with `state/schedule.md` (today's plan) + `logs/<today>.md` header.
- The committed `state/schedule.md` should NOT have a `[STALE-CURRICULUM]` flag at the top. If it does, routine 01's `.last-sync-status` was older than today — investigate timing.
- The branch suffix should be **today's IST date**, not yesterday's. If it shows yesterday's date, the routine ran during the IST-vs-UTC midnight window — re-run it later.

**Smoke test the plugin's UserPromptSubmit hook on claude.ai/code:**
1. `cd C:/Users/sudha/study-companion && claude` (starts a claude.ai/code session in the granted folder)
2. Type `:lock` → routes to `/lock-decision` skill
3. Type `I don't get it` (with curly apostrophe ', not straight ') → routes to confusion directive
4. Type `:wrap` → routes to `/day-wrap` skill

Before the plugin replacement: tokens 1, 3 fell through to model-judgment routing. After: deterministic.

### 6.2 Natural cron observation (over the next 1-2 weeks)

Cron schedules to watch:

| Day | Time | Routine | Branch produced |
|---|---|---|---|
| Daily | 08:30 IST | study-curriculum-sync | `claude/curriculum-sync-<date>` |
| Daily | 09:00 IST (post-fix) | study-morning-briefing | `claude/morning-briefing-<date>` |
| Mon-Sat | 19:00 IST | study-spaced-rep-reminder | `claude/spaced-rep-<date>` |
| Mon-Sat | 20:30 IST | study-github-commit-reminder | `claude/commit-reminder-<date>` |
| Sun | 10:00 IST | study-weekly-review | `claude/weekly-review-<date>` |
| Sun | 10:30 IST | study-drift-audit | `claude/drift-audit-<date>` |
| Sun | 11:30 IST | study-branch-cleanup | `claude/branch-cleanup-<date>` |
| Mon | 09:00 IST | study-monday-distillation | `claude/monday-distillation-<date>` |

Watch the GitHub branches list (`gh repo view Sudhan09/study-companion --web`) over the first week. By Monday 9:30 AM IST you should have ~6 branches (depending on day of week). By the second Monday: ~12.

**Plugin-side observation:** if you do RTI drill sessions on **claude.ai/code** (NOT Cowork — hooks dormant there), `state/drift_log.md` should accumulate entries every time the model uses a banned phrase, stacks analogies, misses a pulse-check, etc. After a week of drill sessions you should see 5-20 entries.

---

## 7. Troubleshooting matrix

| Symptom | Likely cause | Fix |
|---|---|---|
| Routine 01 commits with `"status": "STALE"` | Pipeline repo not in /schedule UI repo list, OR Claude GitHub App not installed on pipeline | Re-do U4 + U2 |
| Routine 02 commits `[STALE-CURRICULUM]` flag at top of schedule.md | Routine 01 didn't complete in time before routine 02 fired, OR `.last-sync-status` timestamp not from today | Wait 30 min + re-trigger routine 02 manually |
| Branch named with yesterday's IST date | Routine ran during IST-vs-UTC midnight window (00:00-05:30 IST) | Cosmetic; will self-correct on next run. If it persists, routine prompt's date computation may be wrong — check it uses `TZ=Asia/Kolkata date +%F` |
| `:lock` / `:companion` / `:wrap` tokens don't route to skill | OLD plugin still installed (hooks regex doesn't match these), OR you're testing on Cowork (hooks dormant) | Re-run Track 1 (replace plugin); test on claude.ai/code |
| `state/drift_log.md` empty after a week of drill sessions | All sessions ran on Cowork (hooks dormant); OR plugin not installed | Run drill sessions on claude.ai/code (`cd <granted folder> && claude`); verify plugin is at `~/.claude/plugins/study-companion/` |
| `node tests/run-all.js` fails on the plugin clone | The plugin's working tree is corrupt or partial | `cd C:/Users/sudha/study-companion-plugin && git fetch && git reset --hard origin/main` |
| `validate-state-schemas.js` fails on `repos.md` | Granted folder is on an old commit | `cd C:/Users/sudha/study-companion && git pull` |
| Routine 4 dispatches a "no commits today" alert despite commits | Commit author email doesn't match what routine 4 filters; OR `--invert-grep --grep="commit-reminder"` excluded a legitimate commit whose subject contained "commit-reminder" | Cosmetic; document on a future audit |
| Routine 02 fires AT same time as routine 01 (08:30 collision) | Routine 02 cron not updated to `30 3 * * *` (09:00 IST); still at the original 08:45 | Re-do U1 step 7: edit routine 02 in /schedule UI, change cron field |
| Routine 01 cloned `pipeline/` directory got committed by mistake | Should not happen — routine 01's prompt forbids it. If it does, the routine prompt regressed | Delete the `pipeline/` from main; re-paste routine 01's prompt to ensure latest version |

---

## 8. When to come back here (the Linux-side debugging)

You don't strictly need to. Most issues self-resolve via re-pasting or re-triggering. But if you hit any of these, ping back and I'll pick up:

- A routine produces unexpected output (corrupted YAML, missing fields, fabricated data)
- The plugin crashes or produces stderr Claude can't ignore
- A validator turns red after a routine writes a state file
- Cowork's UI rejects a routine prompt (length cap, syntax, etc.)
- After 1-2 weeks of natural firing, you want a status pass on what landed vs failed silently. Send me:
  - `git log --all --oneline -50` from the granted folder
  - Contents of `state/drift_log.md`
  - List of `claude/*` branches with their commit dates
  - Any routine output that looks weird

I'll diagnose and propose fixes.

---

## 9. Optional Track 4 — Marketplace repo (~10 min, only if you want all 5 install paths)

Right now, the plugin works via 2 of the 5 access paths described in `docs/2026-05-06-plugin-surface-comparison.md` (only available in the LINUX clone of `study-companion`, not pushed yet — read it via `gh repo view Sudhan09/study-companion --web` once I push that doc).

Working: `--plugin-dir` (CLI dev flag), Cowork "Upload custom plugin file".

Blocked: `/plugin install` from a marketplace, Cowork "Browse plugins", web auto-install via `.claude/settings.json`.

To unlock the blocked paths:

```bash
mkdir -p study-companion-marketplace/.claude-plugin
cd study-companion-marketplace
cat > .claude-plugin/marketplace.json <<'EOF'
{
  "name": "Sudhan's plugins",
  "owner": { "name": "Sudhan", "url": "https://github.com/Sudhan09" },
  "plugins": [
    {
      "name": "study-companion",
      "source": {
        "source": "github",
        "repo": "Sudhan09/study-companion-plugin"
      },
      "description": "Sudhan's bootcamp study companion. Enforces locked teaching method, tracks RTI pattern-failure state, logs drift across sessions."
    }
  ]
}
EOF
git init -b main
git add .
git commit -m "feat: marketplace listing for study-companion plugin"
gh repo create Sudhan09/study-companion-marketplace --private --source . --remote origin --push
```

Then to install via marketplace:
```
/plugin marketplace add Sudhan09/study-companion-marketplace
/plugin install study-companion
```

Or for web auto-install, in your project's `.claude/settings.json`:
```json
{ "enabledPlugins": { "study-companion": true } }
```

---

## 10. Quick reference

### Useful URLs
- **Granted folder repo:** https://github.com/Sudhan09/study-companion
- **Plugin repo:** https://github.com/Sudhan09/study-companion-plugin
- **Pipeline (bootcamp):** https://github.com/Sudhan09/python_bootcamp_claude_code
- **Cowork /schedule UI:** https://claude.ai/code/routines
- **Claude GitHub App installation:** https://github.com/apps/claude/installations
- **Plugin audit report:** local file `2026-05-06-plugin-audit-report.md` (Linux only — ask me to push if you want it in a repo)
- **Plugin remediation plan:** local file `2026-05-06-plugin-remediation-plan.md` (same)
- **Granted-folder audit report:** local file `2026-05-06-bug-audit-report.md` (same)

### Useful commands

```bash
# Pull latest granted folder
cd C:/Users/sudha/study-companion && git pull

# Pull latest plugin
cd C:/Users/sudha/study-companion-plugin && git pull

# Run all granted-folder validators
cd C:/Users/sudha/study-companion
node scripts/validate-imports.js
node scripts/validate-state-schemas.js
node scripts/validate-wins-schemas.js

# Run all plugin tests + validators
cd C:/Users/sudha/study-companion-plugin
node tests/run-all.js

# Skew-check routine prompts
cd C:/Users/sudha/study-companion
bash scripts/check-routine-skew.sh

# Hash a string from clipboard (for skew comparison)
echo -n '<paste prompt body here>' | sha256sum | cut -c1-16

# Watch for new claude/* branches
gh repo view Sudhan09/study-companion --web
git ls-remote --heads origin 'refs/heads/claude/*'

# Sweep granted folder for any regression
grep -rn "08:45" state/ routines/ --include='*.md' && echo "FAIL" || echo "OK"
grep -rn "Dispatch" routines/ | grep -v "Dispatch removed" | grep -v "<!--" || echo "OK"
grep -rn "C:\\\\Users\\\\sudha" . --include='*.md' --include='*.py' --include='*.js' --exclude-dir=.git
```

---

## 11. Final acceptance checklist

You're operationally complete when ALL of these hold:

### Plugin track (Track 1)
- [x] `study-companion-plugin` cloned at `/home/sudhan/study-companion-plugin/` (Linux dev install) ✅
- [x] `node tests/run-all.js` from the plugin → "All tests + validators passed." ✅ (53 assertions)
- [x] All 4 hooks verified end-to-end via fixture inputs on Linux ✅
- [ ] **Cowork-side install on Windows**: replace `C:/Users/sudha/.claude/plugins/study-companion/` with this audited version (zip-upload via Cowork OR git clone to that path)
- [ ] On claude.ai/code: `:lock` token routes deterministically; curly-apostrophe `I don't get it` triggers re-angle
- [ ] After a teaching session ending with `Hope this helps!` on claude.ai/code: `state/drift_log.md` has a new `failure=#10` entry

### Granted-folder track (Track 2)
- [x] U4: Both repos visible in github.com/apps/claude/installations ✅
- [x] U2: Routine 01's /schedule UI repo list contains both repos (folded into create) ✅
- [x] U1: All 8 routines in /schedule UI ✅
- [x] U1 step 7: Routine 02's cron is `30 3 * * *` (09:00 IST) ✅
- [x] U1 step 8: Routine 08 (study-branch-cleanup) exists in /schedule UI with cron `0 6 * * 0` ✅
- [ ] **U5**: `docs/{design,build}-plan-snapshot.md` contains the actual plan content (not stubs) — needs your private Windows-side plans
- [x] U6: `README.md` has "Branch merge cadence" section ✅

### Smoke test (Track 3)
- [x] Manual trigger of routine 01 produced `claude/curriculum-sync-2026-05-06` with `"status": "OK"` ✅
- [ ] Verify routine 02 produces a clean `claude/morning-briefing-<today>` branch (run manually OR wait for cron tomorrow 09:00 IST)
- [ ] After 1 week: confirm 4-7 days of `claude/morning-briefing-*` + `claude/curriculum-sync-*` branches naturally accumulated

### Optional (Track 4)
- [ ] Marketplace repo created (skip unless you want to share the plugin)

After Cowork-side plugin replace + U5 paste: the audit-2026-05-06 remediation is OPERATIONALLY COMPLETE on both the granted folder and the plugin. Tag `audit-2026-05-06-remediated` is already at HEAD on both repos; subsequent work is normal feature development.

---

*This handoff doc supersedes the version that landed in commit `caf48d0`. The earlier version covered only the granted-folder audit; this one adds the plugin remediation track and additional smoke tests.*
