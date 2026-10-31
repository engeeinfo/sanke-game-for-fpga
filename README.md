# Snake Game for FPGA

Synthesizable Verilog for an 8x8 LED-matrix snake game with a seven-segment
score display.

## Requirements

- Icarus Verilog 11 or newer for simulation
- `make`

The repository does not include a board constraint file or vendor-specific
project, so pin assignment and clock configuration must be supplied by the
target FPGA project.

## Run the simulation

```sh
make test
```

The existing testbench exercises reset, start, movement, wall handling,
direction changes, apple movement, game-over, and restart. It currently
provides a smoke test rather than exhaustive assertions.

## Structure

- `game.v` contains the `game` top-level module, movement/state logic, LED
  scanner, clock divider, binary-to-BCD conversion, and seven-segment decoder.
- `game_tb.v` is the simulation testbench.
- `docs/ARCHITECTURE.md` documents module responsibilities.
- `docs/MODERNIZATION.md` records the baseline and known gaps.

## Interface

The `game` module accepts `clk`, `movement[3:0]`, `start`, and `reset`.
Movement values are `1` up, `2` down, `4` left, and `8` right. It exposes the
8x8 matrix scan signals, snake state, head coordinates, game tick, and score
digits.

## Contributing

Keep board-independent game logic in `game.v`, add a self-checking regression
before changing behavior, and run `make test` before submitting changes.
