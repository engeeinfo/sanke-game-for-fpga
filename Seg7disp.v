module Seg7disp(input [3:0] bcd_nums, output reg [7:0] display_num);
    always @(bcd_nums) begin
        case (bcd_nums)
            0: display_num = 8'b11000000;
            1: display_num = 8'b11111001;
            2: display_num = 8'b10100100;
            3: display_num = 8'b10110000;
            4: display_num = 8'b10011001;
            5: display_num = 8'b10010010;
            6: display_num = 8'b10000010;
            7: display_num = 8'b11111000;
            8: display_num = 8'b10000000;
            9: display_num = 8'b10010000;
            default: display_num = 8'b11111111;
        endcase
    end
endmodule
