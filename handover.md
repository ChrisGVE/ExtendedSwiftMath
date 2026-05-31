# Handover — latex-extensions COMPLETE (2026-05-31)

## Status: SHIPPED — only an unpushed main (2 commits) is pending

The `latex-extensions` feature set is finished, audited to convergence,
released as **2.1.1**. Two later commits on local `main` (test cleanup +
a real SIGABRT fix) are not yet pushed to `origin/main` — see below.

## What shipped

Five LaTeX command groups + supporting commands, all with parse + render +
round-trip serialization + tests:
- `\overset` / `\underset` / `\stackrel`
- `\cancel` / `\bcancel` / `\xcancel`
- `\mathllap` / `\mathrlap` / `\mathclap`
- `\xrightarrow` / `\xleftarrow` (with `^`/`_` scripts)
- `\genfrac` (self-mapping single-char delimiters only)
- `\middle`, `\bmod`, `\:`

## Final state (verified)

- `swift build`: 0 errors. `swift test`: **416 cases pass, 0 failures,
  exit 0.**
- The earlier "exit 1 SIGABRT font-cleanup quirk" was a MISDIAGNOSIS. It was
  a real crash: `makeLeftRight` typeset `inner.innerList` twice on the same
  (non-finalized) atoms; pass 1's `.table` case mutates the table atom's type
  to `.inner`, so pass 2 force-cast a `MTMathTable` via `as! MTInner` and
  trapped (e.g. a pmatrix in `\left...\right` under a narrow maxWidth). The
  abort killed the process mid-run, so ~140 tests never executed and the old
  "277 pass" count was a partial run. Fixed in `b322f7f` (typeset once, reuse).
- Codex audit **CONVERGED** at Round 9 (`code_audit.md`). Round-7 `<`/`>`
  finding was DISPUTED and the dispute ACCEPTED (self-mapping delimiter scope).
- `dev` branch DELETED (local + remote) — it was byte-identical to main.
- Two new commits on local `main` not yet on `origin/main`: `10d8781`
  (test: positive guard assertions) and `b322f7f` (SIGABRT fix). PUSH PENDING.
- Pre-fix refs at commit `fffa967`: `origin/main`,
  `origin/feat/latex-extensions`, and tag `2.1.1`.
- GitHub release **2.1.1** published (target `main`), body verified clean of
  AI attribution: https://github.com/ChrisGVE/ExtendedSwiftMath/releases/tag/2.1.1

## How the branch tangle was resolved

- Local `main` had 17 commits; `origin/main` had 2 independent Apache-2.0
  commits. Rebased local `main` onto `origin/main` (`-X theirs`), then a
  reconciliation commit set the three divergent files per Chris's choice:
  **LICENSE = local, NOTICE = origin/main, README + DocC = local**.
- `dev` and `feat/latex-extensions` were reset to `main` and force-pushed
  (`--force-with-lease`) since the rebase rewrote shas. All three branches are
  now identical — the accidental split is gone.

## Open question for later (NOT blocking)

CLAUDE.md §4 says `dev`/feature branches should carry Package.swift
`name: "SwiftMath"` for upstream-PR compatibility, but all branches currently
use `name: "ExtendedSwiftMath"` (was already the case before this work). If a
new upstream PR to `mgriebling/SwiftMath` is planned, the dev-branch package
name needs reverting first. No upstream PR is currently open (PR #2 was closed).

## Key gotchas (still true)

- New atom subclasses must be in `MTMathAtom.copy()` and deep-copied in
  `init`/`finalized`, else they degrade to the base class. All four
  (MTOverUnder, MTCancel, MTOverlap, MTExtensibleArrow) are correctly wired.
- `\genfrac` rejecting `<`/`>`/`\langle` is a deliberate, documented scope
  decision (genfrac re-renders the stored delimiter literally via
  `findGlyphForBoundary`; only self-mapping chars render right AND round-trip).
  Do not "fix" this without a render path.
- `img/*.png` churn in `git status` is pre-existing; leave it alone.
