`timescale 1ns / 1ps

module game_tb;

    reg clk = 0;
    reg start = 0;
    reg reset = 0;
    reg [3:0] movement = 0;

    wire [7:0] row, col;
    wire [2:0] head_row, head_col;
    wire [63:0] matrix;
    wire [2:0] state;
    wire fout;
    wire [7:0] ones, tens;

    // Instantiate game module
    game uut (
        .clk(clk),
        .start(start),
        .reset(reset),
        .movement(movement),
        .row(row),
        .col(col),
        .head_row(head_row),
        .head_col(head_col),
        .matrix(matrix),
        .state(state),
        .fout(fout),
        .ones(ones),
        .tens(tens)
    );

    // Clock generation: 50MHz -> 20ns period
    always #10 clk = ~clk;

    // Direction encoding
    parameter UP = 4'b0001, DOWN = 4'b0010, LEFT = 4'b0100, RIGHT = 4'b1000;

    // Test sequence
    initial begin
        $display("Starting Snake Game Simulation...");
        $dumpfile("game_tb.vcd");  // For GTKWave
        $dumpvars(0, game_tb);

        #50;

        // Trigger reset and start
        reset = 1;
        #50;
        reset = 0;
        start = 1;
        #50;
        start = 0;

        // Initial movement - wait for start screen
        #500;

        // Move right
        movement = RIGHT;
        #2000;

        // Move down
        movement = DOWN;
        #2000;

        // Move left
        movement = LEFT;
        #2000;

        // Move up (illegal, should not be accepted)
        movement = UP;
        #1000;

        // Move down again (legal)
        movement = DOWN;
        #2000;

        // Wait for auto apple collision simulation
        #5000;

        // End test
        $display("Simulation ended.");
        $finish;
    end

endmodule
