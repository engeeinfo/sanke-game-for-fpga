# Architecture

```text
game
├── move
├── freq_divider
├── bin2bcd
│   └── Seg7disp (two instances)
└── led_scanner
```

- `game` wires the game engine to display and timing helpers.
- `move` owns snake coordinates, board matrix, direction validation, score,
  apple placement, and game-over state.
- `freq_divider` generates the movement tick from the input clock and score.
- `bin2bcd` converts the binary score to decimal digits.
- `Seg7disp` maps a decimal digit to seven-segment outputs.
- `led_scanner` multiplexes the 8x8 matrix.

The current design is board-independent at the module boundary. A future
board adapter should provide clock and pin constraints without modifying
`move` or the display conversion modules.
