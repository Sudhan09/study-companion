# Security Threat Model

## PII exfiltration (residual #J4 + audit finding #018)

`instructions/identity.md` is @-imported into every Cowork session and contains a full PII dossier (name, location, age, height, weight, GitHub handle, employer pivot, machine fingerprint).

**Threat:** PromptArmor-style indirect prompt injection (https://www.promptarmor.com/resources/claude-cowork-exfiltrates-files) can trick Claude into POSTing file content to api.anthropic.com Files API; api.anthropic.com is allowlisted for legitimate model traffic.

**Status:** Accepted residual — the value of having PII as session-context (e.g., for Asta's voice + identity-locked teaching) outweighs the exfil risk for this user.

**Mitigations in place:**
- No live secrets (PATs, API keys, passwords) in any file. Verified by audit grep.
- Cowork sandbox restricts outbound network beyond allowlist.
- GitHub repo is private; only repo collaborators can read source.

**Mitigations NOT in place (acknowledged gaps):**
- No content-scanner that strips PII before @-import.
- No allowlist of trusted file editors for `state/active_weak_spots.md` (user-editable + @-imported, see audit finding #019).

## Routine prompt skew (audit finding #021)

Each routine prompt exists in two places: (1) the committed `.md` files in this repo, and (2) the live copy pasted into Cowork's /schedule UI. Edits to (1) do not propagate to (2). To check for skew:

- Run `bash scripts/check-routine-skew.sh` (added in Task 5.3).
- The script extracts each routine's prompt block from `routines/0X-*.md`, hashes it, and prints the expected hash for comparison against the live /schedule UI text.
- Manually visit https://claude.ai/code/routines, open each routine, copy the prompt body, and run `sha256sum` on it. If the hash doesn't match, re-paste from the repo.

**Cadence:** monthly, or after any routine prompt edit.
