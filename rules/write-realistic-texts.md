---
name: write-realistic-texts
description: Texts other people will read follow the use-conversational-language skill; private agent-user chat and official docs are exempt.
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
