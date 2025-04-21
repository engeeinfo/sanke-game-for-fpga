module game(clk, movement, row, col, state, start, reset, matrix, head_row, head_col, fout, ones, tens);
    input clk;
    input start, reset;
    input [3:0] movement; // up, down, left, right
    output [7:0] row;
    output [7:0] col;
    output [2:0] head_row, head_col;
    wire [2:0] center_row, center_col;
    wire [2:0] tail_row, tail_col;
    wire [2:0] apple_row, apple_col;
    reg [3:0] old_movement;
    output [63:0] matrix;
    output [2:0] state;
    wire [7:0] out;
    output fout;
    parameter UP = 1, DOWN = 2, LEFT = 4, RIGHT = 8;
    output [7:0] ones, tens;
    wire [3:0] bcd_ones, bcd_tens;
    wire [5:0] score;

    freq_divider fd(clk, out, fout, score);
    move snake_move(movement, head_row, head_col, clk, matrix, state, start, reset, fout, score);
    bin2bcd b1(score, bcd_tens, bcd_ones); // from binary change to bcd
    Seg7disp TEN(bcd_tens, tens);
    Seg7disp UNIT(bcd_ones, ones);
    led_scanner led(clk, matrix, row, col, state);
endmodule 

module led_scanner(clk, matrix, row, col, state);
    input clk;
    input [63:0] matrix; // 64-bit matrix
    output reg [7:0] row = 8'd1;
    output reg [7:0] col;
    input [2:0] state;

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
        endcase
        row = row >> 1;
        if (row < 8'b0000_0001) begin
            row = 8'b1000_0000;
        end
    end
endmodule

module move(movement, head_row, head_col, clk, matrix, state, start, reset, fout, score);
    input [3:0] movement;
    input clk, fout;
    input start, reset;
    reg [2:0] apple_row = 3; // initial apple position
    reg [2:0] apple_col = 6;
    output reg [2:0] state;
    reg [2:0] next_state;
    reg [3:0] old_movement;
    reg over = 0;
    reg state_start = 1;
    output reg [63:0] matrix;

    output reg [2:0] head_row = 3, head_col = 3;
    reg [2:0] center_row = 3, center_col = 2;
    reg [2:0] tail_row = 3, tail_col = 1;

    reg [2:0] min_row[30:0]; // snake's real tail
    reg [2:0] min_col[30:0]; // tail storage
    output reg [5:0] score = 0;

    parameter UP = 1, DOWN = 2, LEFT = 4, RIGHT = 8;
    integer k = 234; // for random generation
    integer i, j, m; // loop variables

    always @(posedge clk) begin
        if (state_start == 1) begin
            // Game start; happy face
            matrix[7:0] = 8'b00000000;
            matrix[15:8] = 8'b01100110;
            matrix[23:16] = 8'b01100110;
            matrix[31:24] = 8'b00000000;
            matrix[39:32] = 8'b01000010;
            matrix[47:40] = 8'b00100100;
            matrix[55:48] = 8'b00011000;
            matrix[63:56] = 8'b00000000;
        end
        else if (over == 1) begin
            // Game over; sad face
            score = 0;
            old_movement = 0;
            matrix[7:0] = 8'b00000000;
            matrix[15:8] = 8'b01100110;
            matrix[23:16] = 8'b01100110;
            matrix[31:24] = 8'b00000000;
            matrix[39:32] = 8'b00011000;
            matrix[47:40] = 8'b00100100;
            matrix[55:48] = 8'b01000010;
            matrix[63:56] = 8'b00000000;
        end
        else begin
            if (movement == 0)
                old_movement = old_movement;
            else begin
                // Illegal moves
                if ((old_movement == UP && movement == DOWN) ||
                    (old_movement == DOWN && movement == UP) ||
                    (old_movement == LEFT && movement == RIGHT) ||
                    (old_movement == RIGHT && movement == LEFT)) begin
                    old_movement = old_movement; // Don't change direction
                end else begin
                    old_movement = movement;
                end
            end

            matrix = 0; // Clear the matrix
            matrix[head_row*8 + head_col] = 1;
            matrix[center_row*8 + center_col] = 1;
            matrix[tail_row*8 + tail_col] = 1;
            matrix[apple_row*8 + apple_col] = 1;

            // Print the snake's tail (real part)
            if (score > 0) begin
                for (i = 0; i < 30; i = i + 1) begin
                    if (i < score)
                        matrix[min_row[i]*8 + min_col[i]] = 1;
                end
            end

            // When eating the apple
            if ((head_row == apple_row) && (head_col == apple_col)) begin
                apple_row <= (123 * k) % 7;
                apple_col <= (123 * (k + 1)) % 7;
                k = k + 1;
                score <= score + 1;
            end else begin
                apple_row <= apple_row;
                apple_col <= apple_col;
            end
        end
    end

    always @(posedge fout) begin
        if (state_start == 1) begin
            if (start == 1) begin
                state_start = 0;
                head_row <= 3;
                head_col <= 3;
                center_row <= 3;
                center_col <= 2;
                tail_row <= 3;
                tail_col <= 1;
                min_row[0] <= 3;
                min_col[0] <= 0;
            end else begin
                state_start = 1;
            end
        end else if (over == 1) begin
            if (start == 1) begin
                over = 0;
                head_row <= 3;
                head_col <= 3;
                center_row <= 3;
                center_col <= 2;
                tail_row <= 3;
                tail_col <= 1;
                min_row[0] <= 3;
                min_col[0] <= 0;
            end else begin
                over = 1;
            end
        end else begin
            // Movement logic for each direction
            case (old_movement)
                UP: begin
                    if (head_row > 0) begin
                        head_row <= head_row - 3'd1;
                        center_row <= head_row;
                        center_col <= head_col;
                        tail_row <= center_row;
                        tail_col <= center_col;
                        min_row[0] <= tail_row;
                        min_col[0] <= tail_col;
                        for (j = 1; j < 30; j = j + 1) begin
                            if (j < score) begin
                                min_row[j] <= min_row[j-1];
                                min_col[j] <= min_col[j-1];
                            end
                        end
                    end else begin
                        over = 1;
                    end
                end
                DOWN: begin
                    if (head_row < 7) begin
                        head_row <= head_row + 3'd1;
                        center_row <= head_row;
                        center_col <= head_col;
                        tail_row <= center_row;
                        tail_col <= center_col;
                        min_row[0] <= tail_row;
                        min_col[0] <= tail_col;
                        for (j = 1; j < 30; j = j + 1) begin
                            if (j < score) begin
                                min_row[j] <= min_row[j-1];
                                min_col[j] <= min_col[j-1];
                            end
                        end
                    end else begin
                        over = 1;
                    end
                end
                LEFT: begin
                    if (head_col > 0) begin
                        head_col <= head_col - 3'd1;
                        center_row <= head_row;
                        center_col <= head_col;
                        tail_row <= center_row;
                        tail_col <= center_col;
                        min_row[0] <= tail_row;
                        min_col[0] <= tail_col;
                        for (j = 1; j < 30; j = j + 1) begin
                            if (j < score) begin
                                min_row[j] <= min_row[j-1];
                                min_col[j] <= min_col[j-1];
                            end
                        end
                    end else begin
                        over = 1;
                    end
                end
                RIGHT: begin
                    if (head_col < 7) begin
                        head_col <= head_col + 3'd1;
                        center_row <= head_row;
                        center_col <= head_col;
                        tail_row <= center_row;
                        tail_col <= center_col;
                        min_row[0] <= tail_row;
                        min_col[0] <= tail_col;
                        for (j = 1; j < 30; j = j + 1) begin
                            if (j < score) begin
                                min_row[j] <= min_row[j-1];
                                min_col[j] <= min_col[j-1];
                            end
                        end
                    end else begin
                        over = 1;
                    end
                end
                default: begin
                    head_row <= head_row;
                    head_col <= head_col;
                    center_row <= center_row;
                    center_col <= center_col;
                    tail_row <= tail_row;
                    tail_col <= tail_col;
                end
            endcase
        end
    end
endmodule

module freq_divider(clk, out, fout, score);
    input clk;
    input [5:0] score;
    output reg fout;
    output reg [7:0] out;

    always @(posedge clk) begin
        if (out == 8'd1) begin
            fout = !fout;
            out = 8'b1000_0000 - (score * 5);
        end else
            out = out - 8'd1;
    end
endmodule

module bin2bcd(in, tens, units);
    input [5:0] in;
    output reg [3:0] tens, units;
    reg [5:0] value;

    always @(in) begin
        value = in;
        units = value % 10;
        value = value / 10;
        tens = value % 10;
        value = value / 10;
    end
endmodule

module Seg7disp(bcd_nums, display_num);
    input [3:0] bcd_nums;
    output reg [7:0] display_num;

    parameter BLANK = 8'b11111111;
    parameter ZERO  = 8'b11000000;
    parameter ONE   = 8'b11111001;
    parameter TWO   = 8'b10100100;
    parameter THREE = 8'b10110000;
    parameter FOUR  = 8'b10011001;
    parameter FIVE  = 8'b10010010;
    parameter SIX   = 8'b10000010;
    parameter SEVEN = 8'b11111000;
    parameter EIGHT = 8'b10000000;
    parameter NINE  = 8'b10010000;

    always @(bcd_nums) begin
        case (bcd_nums)
            0: display_num = ZERO;
            1: display_num = ONE;
            2: display_num = TWO;
            3: display_num = THREE;
            4: display_num = FOUR;
            5: display_num = FIVE;
            6: display_num = SIX;
            7: display_num = SEVEN;
            8: display_num = EIGHT;
            9: display_num = NINE;
            default: display_num = BLANK;
        endcase
    end
endmodule
