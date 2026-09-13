---
name: opus5-guide
description: >-
  Overlay on implementation-discipline for Claude Opus 5. Use when Opus 5
  handles a non-trivial multi-surface or persistence-sensitive implementation,
  migration, or review; especially one-shot work. Do not use for small isolated
  edits.
---

# Opus 5 guide

Follow `implementation-discipline`. This file fills **Opus 5** evidence,
workaround, checkpoint, and stop-signal calibration.
Sources: observed Opus implementation and review failures. Not model folklore.

## First step

1. Load the parent, then pin-matched language, framework, and domain skills.
2. Snapshot the commit, worktree, approved plan, and stop condition.
3. Label load-bearing statements **verified**, inferred, or proposed.
4. Verify the first framework seam before implementing broadly.

## Pressure map

| Pressure | Risk | Correction |
| --- | --- | --- |
| Coherent explanation | prose sounds like proof | cite runtime path, artifact, or test |
| Detailed one-shot plan | breadth hides unfinished seams | gate one vertical slice at a time |
| New evidence | old design survives through momentum | revise the decision immediately |
| Centralization | every surface enters one service | share invariants; keep adapters native |
| Framework friction | workaround chain becomes architecture | stop when a second workaround supports the first |
| Concurrency language | mechanism gets a stronger claim | name anomaly and residual behavior |
| Friendly errors | unknown failure becomes expected conflict | prove it or re-raise |
| Completion momentum | focused green becomes done | run the parent closure sweep |
| User stop | implementation continues | stop writes and present the smallest revision |

## One-shot gate

One shot means complete without ceremonial pauses. It does not waive a stop
condition.

```text
Opus checkpoint:
- [ ] Slice matches approved scope
- [ ] Parent framework seam passes
- [ ] New evidence changed the plan where required
- [ ] No workaround supports another workaround
- [ ] Concurrency claim names residual behavior
- [ ] Focused gate passed
- [ ] Parent closure sweep passed before “done”
```

If a line is red, **stop**. Do not write more code to make the explanation true.

## LLM traps — never generate these

- “Best practice” without the pin and framework path
- One service forced through every lifecycle
- A private API preserving a disproved design
- Callback suppression followed by hand-built lifecycle recreation
- A pessimistic lock called optimistic concurrency
- Every persistence error translated into the expected conflict
- A completion claim before path, retry, and real-store closure
- Continued implementation after the user asks for review or stop

## Do not

- Repeat the parent catalogs.
- Turn one incident into model folklore or a universal ban.
- Add one framework's remedy to another stack.
- Revert, commit, push, or mutate data during a read-only review.
