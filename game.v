module game(
    input clk,
    input start, reset,
    input [3:0] movement,
    output [7:0] row,
    output [7:0] col,
    output [2:0] head_row, head_col,
    output [63:0] matrix,
    output [2:0] state,
    output fout,
    output [7:0] ones, tens
);

    wire [7:0] out;
    wire [3:0] bcd_ones, bcd_tens;
    wire [5:0] score;

    freq_divider fd(clk, out, fout, score);
    move snake_move(movement, head_row, head_col, clk, matrix, state, start, reset, fout, score);
    bin2bcd b1(score, bcd_tens, bcd_ones);
    Seg7disp TEN(bcd_tens, tens);
    Seg7disp UNIT(bcd_ones, ones);
    led_scanner led(clk, matrix, row, col, state);
endmodule
