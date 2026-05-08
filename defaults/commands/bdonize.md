---
version: 1.0.0
description: |
  Voice and style guide. Apply inline before saving any planning artifact (design doc, slice, brief). Single source for voice patterns; replaces duplicated blocks in slice/spec/plan-project.
allowed-tools: []
---

# Bdonize — voice and style

Apply these patterns inline to any draft before saving. Do not invoke the bdonizer Skill tool — it loads instructions but does not produce revised output in this context. Two passes:

---

## Phase 1 — Strip AI patterns

Remove:

- **Significance inflation:** "crucial", "vital", "essential", "key" used as filler.
- **AI vocabulary:** "highlight", "landscape", "underscore", "vibrant", "bustling", "embark", "delve", "tapestry".
- **Em dash overuse.** Use sparingly; sentences with three or more em dashes need rewriting.
- **Inline-header lists.** Bold lead-ins followed by colons that turn prose into a list of one-line claims.
- **Filler phrases:** "in order to", "it is important to note", "it goes without saying", "needless to say".
- **Excessive hedging:** "perhaps", "potentially", "might possibly", "could conceivably".
- **Sycophantic tone:** "great question", "wonderful idea".
- **Chatbot artifacts:** "Sure!", "I'd be happy to", "Let me know if".

---

## Phase 2 — Tune to voice

Apply:

- **No warmup sentence.** Open with the substance.
- **Short declarative payoffs.** Don't bury the result.
- **Deadpan over dramatic.** Practical framing, not emotional.
- **Stop when done.** No summary sentence at the end.
- **Sentence case headings.** Not Title Case, not ALL CAPS.
- **Terse fragments are fine.** Not every sentence needs a verb.
- **Direct over indirect.** "Cut X" not "We should consider cutting X".

---

## When to apply

- Final pass before saving any planning artifact: design docs, slice files, briefs, task files.
- Always inline (don't invoke the bdonizer Skill — it doesn't return revised output here).
- The pass runs after all content is drafted, before the file is written.

---

## Behavior rules

- Don't compress unnaturally. If something needs space to be clear, give it space. Density is the goal, not minimum word count.
- Don't substitute AI patterns with different AI patterns. The whole list is the floor.
- Voice should feel terse, deadpan, practical. If a draft reads as warm or salesy after the pass, run the pass again.
