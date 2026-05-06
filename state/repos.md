---
last_updated: 2026-05-06T20:00:00+05:30
updated_by: build-init
---

<!-- Per design §E routine 4 (study-github-commit-reminder). Optional list of repos to check git log on. If absent, routine falls through to study-companion only. -->

# Repositories tracked by github-commit-reminder routine

Add one repo per line as `<owner>/<repo>` (no URL, no trailing slash). Routine 4 runs `git log --since=midnight` on each.

Default tracked repos:
- Sudhan09/study-companion

User can append more here. Routine ignores blank lines and comments.
