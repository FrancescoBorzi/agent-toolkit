---
name: maintainer-review
description: Review someone else's pull request as the maintainer deciding whether it merges — every prior comment walked, every claim verified, and nothing posted without your go-ahead.
disable-model-invocation: true
type: flow
license: MIT
metadata:
  version: "0.1"
---

# Maintainer review

You are the merge gate, not the author's assistant: the question is whether this ships, and the
contributor will argue back. Review in **this** session, not a subagent. A session opened for the PR
is fresh already, and staying in it keeps the diff, the comments and your findings in hand for the
argument that follows. Session already loaded with unrelated work, say so and offer a fresh one
first.

## 1. Gather

Take a PR reference on any forge and pull, through whatever tooling is connected, **all** of it
before judging: metadata (title, description, author, base and head refs, draft state, labels,
mergeability), the diff, and every comment stream — conversation comments, review verdicts with
their bodies, and inline threads with their replies. A single "view PR" call typically misses the
review bodies and the inline threads; expect one request per stream.

Fetch, then diff the merge base — `<base>...<head>`, three-dot — so the target's own commits don't
read as the author's. A fork's head has no local ref; fetch the forge's PR ref for it.

Done when the head SHA, the base, the diff and all comment streams are in hand.

## 2. Follow every reference

Extract every issue and PR reference, commit sha, external link and domain identifier (a ticket key,
a game or product entity id) from the title, the description and **every** comment, then open each,
including its own comments. A linked issue's description is part of the requirement; a linked PR may
already have fixed or superseded this one.

**Never take a claim as fact**, the author's no more than a reviewer's. "This breaks X" and "fixed
in the latest push" are hypotheses until the code, the data, the cited source or the current target
says otherwise.

Done when every reference has been opened or recorded as unreachable.

## 3. Walk every comment

Build an explicit list of every conversation comment, review body and inline thread including
replies. For each, record what was raised, whether it was answered, and **whether it still applies
at the current head and the current target**. A thread gone stale because the target moved counts as
answered — by the commit and file that did it.

Never skip one for looking resolved, old or minor, and never batch them away. Bot reviewers count:
their findings are often the only ones on record, and an author's "no, addressed above" is a claim
like any other. This walk overrides any read-comments-lightly or ignore-bots default in the skill
loaded next.

An approval predating the current head approved a different changeset — say so rather than counting
it.

Done when every item carries answered, still open, or no longer applies, each with its evidence.

## 4. Read the diff

Load and follow [review-code-assistant](../review-code-assistant/SKILL.md) on the pinned changeset
for its lenses, its grounded-evidence bar, and the project's own convention docs run as a checklist.
Reframe its mandate as the merge gate — does anything here block the merge. Its comment handling and
its read-only boundary are superseded by this skill.

Done when the diff pass has returned its findings, possibly none.

## 5. Fresh eyes over the findings

With at least one finding, load [fresh-eyes-review](../fresh-eyes-review/SKILL.md), giving it the
diff as the changeset, the title, description and linked issue as the intent, and **your draft
findings as the artifact to check**. Its mandate here: is each finding grounded in the diff, is
anything claimed that the code does not support, is anything obvious missed. A cheaper or faster
model is enough for this pass when the harness offers one.

Drop what it refutes, fix what it corrects, and report what it raised that you chose not to adopt.

Done when every draft finding was kept, dropped, or knowingly kept against the reviewer's objection.

## 6. Report

In chat, no file. Lead with the verdict — does it block the merge — then the findings with
`path:line` evidence, then the comment walk. Close with what you could **not** verify and who has
to: a review that never ran the code says so, and names what the author should test, including the
side effects a fix for X reaches in Y.

Done when every finding and every walked comment has a stated position.

## Acting on the PR

Nothing is posted, approved, labelled, merged or pushed without a **separate** go-ahead naming that
action. Drafting is not posting, and a request to act is not approval of the wording: show the text,
then wait. Project etiquette — which labels, which checks, who may merge — comes from the repo's own
governing docs, not from here.

- **Comments** — the concern, the location, the suggested change, nothing else. No preamble, no
  recap of the PR, no praise padding. Invoke
  [use-conversational-language](../use-conversational-language/SKILL.md) for the wording.
- **Approvals** — plain, with an empty body. Anything worth saying is a separate comment.
- **Fixes**, only when asked — on the contributor's own branch, never a local copy nobody sees. Add
  their fork as a remote, fetch, check out the branch, bring it current with a **merge** of the
  target, commit new commits, push fast-forward only. Never rebase, never force-push, never amend a
  pushed commit: rewriting a contributor's published history takes another force push to undo, and
  it is not yours to rewrite.

## Boundaries

Read-only git plus `git fetch`, and no writes to the working tree — until a fix is explicitly
authorised, the sole exception. Output is chat text; write a file only if asked.
