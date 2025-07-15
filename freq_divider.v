module freq_divider(input clk, output reg [7:0] out = 8'd100, output reg fout = 0, input [5:0] score);
    always @(posedge clk) begin
        if (out == 8'd1) begin
            fout <= ~fout;
            out <= 8'd100 - (score * 2);  // speed increases with score
        end else begin
            out <= out - 1;
        end
    end
endmodule
