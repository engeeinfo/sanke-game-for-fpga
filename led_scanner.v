module led_scanner(input clk, input [63:0] matrix, output reg [7:0] row = 8'd1, output reg [7:0] col, input [2:0] state);
    always @(posedge clk) begin
        case (row)
            8'd1: col = matrix[7:0];
            8'd2: col = matrix[15:8];
            8'd4: col = matrix[23:16];
            8'd8: col = matrix[31:24];
            8'd16: col = matrix[39:32];
            8'd32: col = matrix[47:40];
            8'd64: col = matrix[55:48];
            8'd128: col = matrix[63:56];
            default: col = 8'b0;
        endcase
        row = row << 1;
        if (row == 0)
            row = 8'd1;
    end
endmodule
