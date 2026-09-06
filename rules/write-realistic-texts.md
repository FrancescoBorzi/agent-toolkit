---
name: write-realistic-texts
description: Texts other people will read follow the use-conversational-language skill and need the user's go-ahead on the wording before publishing; private agent-user chat and official docs are exempt.
---

Whenever writing text that other people will read as if the user wrote it — commit messages,
PR descriptions, review comments, code comments, chat messages or questions for colleagues, and
similar — you must actually invoke the `use-conversational-language` skill and follow its rules
— reciting them from memory does not count.

Replies to the user in the current session are private agent-user communication, out of scope
however conversational they sound.

Documentation (README and similar) is out of scope: written prose conventions apply there, not
conversational voice.

Agent-facing texts (plans, analyses, specs, skills, rules) are exempt; there, completeness and
unambiguity beat brevity.

Publishing one needs an EXPLICIT go-ahead on the concrete wording first: PR and issue comments,
review bodies, release notes, chat messages, commit trailers crediting other people, anything sent
to an external service. Code comments and plain commit messages are out of scope, they land in the
change the user already reviews.

Naming the action does not approve the wording: "approve and add the label", "comment and close",
"open the PR" authorize those actions and nothing more. Draft it, show it, wait. Other named
actions proceed meanwhile only when reversible and not ordered after the text, so "comment, then
approve and merge" holds the whole chain at the comment.

A go-ahead is one-off: approval of one comment, commit or file is never approval of the next.
Never write opinions, verdicts, or a review in the user's voice that the user did not ask for.
