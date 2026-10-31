# Snake Game for FPGA

Verilog implementation of a simple FPGA snake game.

## Simulation

```bash
iverilog -o game_tb game.v game_tb.v
vvp game_tb
```

## Hardware use

Assign the clock, reset, display, and control inputs in `game.v` to the target
FPGA board using the board's constraints file. The repository does not include
a board-specific pin assignment or synthesis project.
