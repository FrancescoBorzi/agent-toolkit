---
name: handover
description: Use when handing finished work over to code review — writing a PR description or packaging a change for review by a human, an agent, or both.
license: MIT
metadata:
  version: "0.1"
---

# Handover

Package a finished change so its reviewers never reconstruct intent from the diff. Write for a
reviewer holding the diff and nothing else — no planning docs, no session, no knowledge that
either exists.

## Gather

Start the project's checks (tests, lint, build — whatever it defines) first, unless this session
already ran them on this tree; read these while they run, skipping what doesn't exist:

1. **Decisions log** — a `*.DECISIONS.md` beside the task's plan.
2. **Planning docs** — the task's requirements, plan, and ticket in the project's planning
   directory.
3. **The session**, when it produced the change: decisions, pivots, constraints.
4. **The diff** against the target, plus commit subjects.

Each source once, no deeper than the artifact needs: skim the diff whole, deep-read only the files
you will name in the *Review guide*, and never rebuild history commit by commit — which commit
changed what is the diff's job, not yours.

Then match the plan's steps and acceptance criteria against the diff both ways — planned but
absent, present but unplanned. Done when every source is read or confirmed absent and every planned
item is matched.

## Never invent rationale

State a "why" only where a source gives it. A deviation nothing explains is asked of the author
once; unanswered or unaskable, it ships flagged in plain words ("nothing records why — worth
confirming"), since it may be an unintentional gap rather than a decision. Sourcing is your gate,
not the reviewer's reading: it decides what you may write, and never appears in the text. 
When not sure, always ask. Never guess.

## The artifact

`<slug>.HANDOVER.md` beside the task's plan; if no planning directory → present the content and ask
where to save it. Its body is paste-ready as the PR description, and stands alone:

- **Mention only what the reviewer can open** — a tracker URL, or a file you verified is committed
  on the branch. Everything else — planning docs, decisions log, session, commit hashes — is
  neither linked nor named: write what it says ("this was meant to …"), never where it says it.
- **Under a screen**, ~400 words; the caps below are limits, not targets.
- **Plain reviewer-facing wording**, never this skill's vocabulary. Before drafting, actually
  invoke use-conversational-language — reciting its rules from memory does not count.

Sections, skipped only when truly empty:

1. **What and why** — 2–3 lines.
2. **Decisions worth knowing** — at most 5 lines, each: what was chosen or what departs from the
   plan, its why or the missing-why flag, and where in the code to see it.
3. **Testing** — commands actually run with their real output, then what was **not** verified —
   untested paths, unmet or unchecked acceptance criteria, manual steps skipped. Describing what
   the tests cover is not evidence.
4. **Review guide** — the few files where judgment matters and why; the rest named as mechanical.
5. **Known gaps** — at most 3: shortcomings, assumptions, open questions.

Done when every section is filled or knowingly skipped, nothing reads as verified that wasn't, and
nothing in the text points at something the reviewer cannot open.

## Boundaries

- Modify no source files; the handover doc is the only file written.
- Never push, or open/comment on a PR — publishing is the user's explicit call.
- The project's own checks are in scope to run; anything beyond (deploys, migrations, data jobs)
  is not.
