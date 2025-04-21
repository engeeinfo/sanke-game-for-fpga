`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   01:00:25 04/25/2022
// Design Name:   game
// Module Name:   game_tb
// Project Name:  game12
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: game
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module game_tb;

	// Inputs
	reg clk;
	reg [3:0] movement;
	reg start;
	reg reset;

	// Outputs
	wire [7:0] row;
	wire [7:0] col;
	wire [2:0] state;
	wire [63:0] matrix;
	wire [2:0] head_row;
	wire [2:0] head_col;
	wire fout;
	wire [7:0] ones;
	wire [7:0] tens;

	// Instantiate the Unit Under Test (UUT)
	game uut (
		.clk(clk), 
		.movement(movement), 
		.row(row), 
		.col(col), 
		.state(state), 
		.start(start), 
		.reset(reset), 
		.matrix(matrix), 
		.head_row(head_row), 
		.head_col(head_col), 
		.fout(fout), 
		.ones(ones), 
		.tens(tens)
	);

	// Clock Generation
	initial begin
		clk = 1;
		forever #5 clk = ~clk;  // 100MHz Clock, adjust delay if needed
	end

	// Test Sequence
	initial begin
		// Initial Conditions
		reset = 0;
		start = 0;
		movement = 4'b0000; // No movement at first
		#10; // Wait for some time

		// Test Reset and Start Signal
		reset = 1;  // Apply Reset
		#10;
		reset = 0;  // Remove Reset
		start = 1;  // Start the Game
		#10;
		start = 0;  // Game should start now
		#10;

		// Test Movement (Up)
		movement = 4'b0001;  // Move Up
		#20;

		// Test Movement (Right)
		movement = 4'b1000;  // Move Right
		#20;

		// Test Movement (Down)
		movement = 4'b0010;  // Move Down
		#20;

		// Test Movement (Left)
		movement = 4'b0100;  // Move Left
		#20;

		// Test when hitting wall
		movement = 4'b0001;  // Move Up at boundary
		#20;
		movement = 4'b0010;  // Move Down at boundary
		#20;
		movement = 4'b0100;  // Move Left at boundary
		#20;
		movement = 4'b1000;  // Move Right at boundary
		#20;

		// Test Apple Eating Scenario (e.g., Head moves to Apple position)
		movement = 4'b1000;  // Move Right (Apple should be at this position)
		#20;

		// Test Game Over (Head collides with tail)
		movement = 4'b0001;  // Moving into own tail should trigger game over
		#20;

		// Test Reset after Game Over
		reset = 1;  // Reset Game
		#10;
		reset = 0;  // Clear Reset
		#10;
		start = 1;  // Start New Game
		#10;
		start = 0;

		// End Simulation
		$finish;
	end
      
endmodule
