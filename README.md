# 🐍 Verilog Snake Game

> A classic Snake Game built with Verilog, designed to run on an 8x8 LED matrix and display score using 7-segment displays. Includes direction controls, apple generation, and adaptive speed.

---

![Snake Demo](https://media.giphy.com/media/3ohc1d5UrUd3lSUs0Y/giphy.gif)

## 📚 Table of Contents

- [Modules](#-modules)
- [Controls](#-controls)
- [Getting Started](#-getting-started)
- [Waveform Screenshots](#-waveform-screenshots)
- [Matrix Layout](#-matrix-layout)
- [Score Display](#-score-display)
- [Block Diagram](#-block-diagram)
- [Testing Logic](#-testing-logic)
- [Known Limitations](#-known-limitations)
- [Contributors](#-contributors)

---

## 📦 Modules

| Module         | Description                             |
| -------------- | --------------------------------------- |
| `game`         | Top-level module integrating all logic  |
| `move`         | Snake movement, apple logic, collision  |
| `led_scanner`  | Displays matrix row-by-row              |
| `freq_divider` | Controls game speed (faster as score ↑) |
| `bin2bcd`      | Converts binary score to BCD format     |
| `Seg7disp`     | Converts BCD to 7-segment encoding      |

---

## 🕹️ Controls

| Action | Movement Code |
| ------ | ------------- |
| Up     | `4'b0001`     |
| Down   | `4'b0010`     |
| Left   | `4'b0100`     |
| Right  | `4'b1000`     |

⚠️ Illegal reverse movements (like UP→DOWN) are blocked for safety.

---

## 🚀 Getting Started

### ✅ Simulate

```bash
iverilog -o game_tb game.v game_tb.v
vvp game_tb
```
