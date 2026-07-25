---
name: handover
description: Use when handing finished work over to code review — writing a PR description, opening a PR, or packaging a change for review by a human, an agent, or both.
license: MIT
metadata:
  author: Stefanos Lignos
  version: "0.1"
---

# Handover

Package a finished change for its reviewers so they never reconstruct intent from the diff. The
handover is **claims to verify, not advocacy** — every statement points at something the reviewer
can check.

## Sources

Collect before writing, in order, skipping what doesn't exist:

1. **Decisions log** — a `*.DECISIONS.md` beside the task's plan.
2. **Planning docs** — the task's requirements, plan, and ticket in the project's planning
   directory.
3. **The session** — when this session produced the change: decisions, pivots, and constraints
   from the conversation itself.
4. **Git history and the diff** — the branch's commits and its full diff against the target.

Match the diff against plan and requirements both ways — planned but absent, present but
unplanned — and every divergence joins the delta section. Done when every source was read or
confirmed absent and every planned item is matched against the diff.

## The source rule

Every reported decision or deviation names its source — log, doc, session, or the author's
answer. Never invent rationale. A deviation no source explains is asked of the author once;
unanswered or unaskable, it appears as "unexplained — confirm before merge", since it may be an
unintentional gap, not a decision.

## Evidence

Run the project's own checks (tests, lint, build — whatever it defines) and capture the real
output; describing what the tests cover is not evidence. State just as plainly what was **not**
verified — untested paths, unmet or unchecked acceptance criteria, manual steps not performed.

## The artifact

`<slug>.HANDOVER.md` beside the task's plan; no planning directory → present the content and ask
where to save it. The body is paste-ready as the PR description — before drafting it, actually
invoke use-conversational-language; reciting its rules from memory does not count. Sections, in
order, skipped only when truly empty:

1. **Intent** — what the change is for and why, a few lines; link the ticket/requirements rather
   than restate them.
2. **Decisions & delta** — review-relevant decisions and every plan divergence, one line each:
   claim, source, where to verify. Review-relevant means a competent reviewer given diff and docs
   would otherwise flag it as wrong or waste time re-deriving it; everything else stays out.
3. **Evidence** — commands actually run with real results, then what was not verified.
4. **Review guide** — the few files where human judgment matters and why, the mechanical rest,
   and a reading order.
5. **Prior review** — reviews already performed (agent or human), each finding's fate; "none" is
   written out, never omitted.
6. **Limitations & assumptions** — known shortcomings, assumptions, open questions.

Done when every section is filled or knowingly skipped, every claim names its source, and nothing
reads as verified that wasn't.

## Boundaries

- Modify no source files; the handover doc is the only file written.
- Never push, or open/comment on a PR — publishing is the user's explicit call.
- The project's own checks are in scope to run; anything beyond (deploys, migrations, data jobs)
  is not.
