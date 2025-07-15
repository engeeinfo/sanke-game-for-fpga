module bin2bcd(input [5:0] in, output reg [3:0] tens, units);
    reg [5:0] value;
    always @(in) begin
        value = in;
        units = value % 10;
        value = value / 10;
        tens = value % 10;
    end
endmodule
