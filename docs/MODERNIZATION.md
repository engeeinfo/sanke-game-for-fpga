# Modernization record

## Baseline

Baseline captured on 2026-10-31 from the `main` branch.

| Area | Result | Notes |
| --- | --- | --- |
| Stack | Verilog | `game.v` plus one simulation testbench. |
| Dependency installation | Missing initially | Icarus Verilog was required for local simulation. |
| Build | Pass with warnings | Compilation succeeds; Icarus reports missing explicit time units. |
| Tests | Smoke test only | The testbench runs a scenario but has no assertions. |
| Lint | Not configured | No HDL lint or formatting configuration exists. |
| License | Missing | Added MIT license in this branch. |
| CI | Missing | Added build/lint/test workflow. |

## Audit findings

1. **Medium — weak verification:** the testbench does not assert state,
   coordinates, score, or game-over outputs.
2. **Low — timing clarity:** modules lack explicit time unit/precision
   declarations, producing simulator warnings.
3. **Low — missing project contract:** README, architecture, toolchain, and
   board-support expectations were undocumented.

No secrets, dependency manifests, or external dependency vulnerabilities were
found.

## Changes

- Added project documentation and architecture boundaries.
- Added Makefile targets and GitHub Actions CI using Icarus Verilog.
- Added standard ignore rules and MIT license.
- Preserved the existing HDL behavior; no unverified game-logic changes were
  made.

## Follow-up

Add assertions for reset, direction reversal prevention, wall collision,
apple consumption, score conversion, and game-over behavior. Add explicit
`` `timescale`` or SystemVerilog timeunit declarations after confirming the
target simulator and board clock contract.
