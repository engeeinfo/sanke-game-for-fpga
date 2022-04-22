`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   01:00:25 04/25/2022
// Design Name:   game
// Module Name:   C:/Users/exam/Desktop/01fe19bec013/game12/game_tb.v
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
initial begin
forever #100 clk=~clk;
end

	initial begin
		
		clk = 1;
		movement = 1;
		start = 1;
		reset = 0;
		#100;
        
		

	end
      
endmodule

