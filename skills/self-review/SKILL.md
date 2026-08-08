---
name: self-review
description: Self-review a changeset until merge-ready — a fresh-context reviewer checks it as a maintainer would, the author answers every finding, and a compact report for the PR proves the review happened.
disable-model-invocation: true
type: flow
license: MIT
metadata:
  version: "0.1"
---

# Self-review

Make a changeset merge-ready before submission — no regressions, sound code, the project's
conventions respected — and prove it was scrutinized: a fresh-context reviewer hunts for what
would block the merge, the author answers every finding, and a compact report — scannable by a
maintainer in seconds — records the outcome. The report is the review record only; the change's
what/why belongs to the PR description (e.g. via /handover), never here.

## Pin the changeset

1. Resolve source and target. No input → current branch against the auto-detected target: the
   default branch of the `upstream` remote when one exists (fork workflow), else of `origin`
   (`git symbolic-ref refs/remotes/<remote>/HEAD`), else the sole existing candidate among
   `main`, `master`, `develop`/`development` (remote-tracking ref first, else the local branch) —
   failure or ambiguity → ask. Explicit branches in the invocation win. State the chosen target.
2. `git fetch` the target's remote (local-only target → nothing to fetch; a failed fetch → say
   so and ask rather than diff stale refs), then diff `<target>...HEAD` (merge-base three-dot;
   two-dot only without a common ancestor). Empty diff → probably a wrong target (typical: a
   fork's default branch already holding the commits) — say so and ask for the true one.
3. Modified tracked files block the run — commit or stash first, no override: the diff covers
   commits only, so uncommitted work would ship unreviewed under a clean report. Untracked files
   don't block: they can't ship unless committed. This skill's own artifacts (report,
   planning-home files) don't count as dirty.

Done when source branch, target, and reviewed SHA are recorded and the diff is non-empty.

## Project rules file

`.agents/docs/self-review-rules.md`, when the project carries one, adds project-specific rules or
overrides to the review mandate and process (extra focus areas, report handling) — never to the
Boundaries below. Absent → skip silently. Either way, the report states whether it was found and
applied.

## Review

Load and follow [fresh-eyes-review](../fresh-eyes-review/SKILL.md) on the pinned changeset —
inputs all explicit, so it runs without its confirmation step — with:

- an intent statement — the task's ticket or requirements when the planning home holds them, else
  derived from the branch name and commit subjects;
- excluded paths: the planning home and the report — author rationale and past dispositions must
  never reach the reviewer. Planning files the changeset itself touches ship in the PR, so they
  are reviewed like any other change; the report stays excluded always;
- the mandate framed as a maintainer's merge gate — would anything here block the merge? — and
  extended by: the project's own governing docs (contributing, agent instructions, codestyle) run
  as a checklist against every changed file, not as background reading; and leftovers — debug
  prints, commented-out code, stray TODOs, accidentally committed files;
- the grounded bar: a finding exists only with a nameable concrete failure, violated rule, or
  redundancy — hedged speculation is out, zero findings is a valid outcome;
- an instruction to the reviewer to report back the harness and model it ran on, and whether it
  covered every changed file.

Done when the reviewer has returned its findings — possibly none — its provenance, and its
coverage.

## Disposition walk

One finding at a time, recommending a disposition with a one-line why — the author decides:

- **fix** — apply it to the working tree now; committing stays the author's move.
- **dismiss** — record the author's reason, pushing once toward one a maintainer can evaluate
  ("mirrors the existing pattern in this file", not "disagree"); if the author insists, their
  words go in verbatim.

Never drop or soften a finding: every one appears in the report with its disposition. When
anything was fixed, offer one re-review round on the new SHA once the author has committed —
offered, never forced, no loop; declined or left uncommitted, the report carries a "fixes not
re-reviewed" caveat. A re-review carries dispositions forward: a re-raised finding matching a
dismissed one keeps its dismissal, only new findings are walked, and the report lists each
finding once. Close the walk by reminding the author to run the project's usual checks (build,
lint, tests) before pushing — this skill never runs them.

Done when every finding is dispositioned.

## Report

`<slug>.SELF-REVIEW.md` in the task's planning home, per the project's planning-directory
convention (e.g. `.agents/plans/<slug>/`); reuse the slug of the task's existing artifacts
(ticket, requirements, plan) — none → derive it from context (branch name, the changes); no
planning home resolvable → ask where to save it. Re-runs and later rounds update the file in
place — one file per task, never versioned copies: its destination is a single upload. It is for
pasting into the PR description or a comment, not for committing, unless the project rules file
says otherwise — either way committing is the author's move, never the agent's.

Compact above all: one line per finding, fusing location and concrete failure; the full prose
stays in the session. Provenance exactly as the environment reports it, `unknown` when it
doesn't — never guessed or recalled; the reviewer's model, when it differs from the session's,
appended to the **By** line as `review by <model>`; skill version from this file's frontmatter,
date = today. Caveats (fixes not re-reviewed, a same-context fallback review, incomplete
coverage) are visible header lines.

```markdown
# Self-review — my-feature → main

> **Outcome** 3 findings — 2 fixed, 1 dismissed — final round clean
> **Reviewed** `abc1234` (`my-feature` vs `main`, merge-base diff — 12 files, +340 −120)
> **By** <harness>, <model> — self-review v<version>, <date>
> **Project rules** `.agents/docs/self-review-rules.md` not present

## Round 1 — `abc1234`, 3 findings

1. `src/foo.c:142` — null deref when the timer expires mid-update → **fixed**
2. `db/updates/xyz.sql:3` — DELETE misses linked_id rows, orphans on re-run → **fixed**
3. `src/foo.c:97` — guard duplicates the check 4 lines up → **dismissed**: mirrors the existing
   pattern in this file, refactor out of scope

## Round 2 — `def5678`, clean
```

Done when the report holds the outcome line, changeset refs with diffstat, provenance with skill
version and date, rules-file status, and every round with its SHA and dispositioned findings.

## Wrap up

Print the report's project-relative path and the instruction to paste its content into the PR
description or a comment. Done when both are printed.

## Boundaries

- Files written: the report, and the fixes the author approved during the walk — nothing else.
- Read-only git plus `git fetch`; no commit, push, or PR operation — publishing is the author's.
