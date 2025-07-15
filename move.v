module move(
    input [3:0] movement,
    output reg [2:0] head_row = 3, head_col = 3,
    input clk, fout,
    output reg [63:0] matrix = 64'd0,
    output reg [2:0] state = 0,
    input start, reset,
    output reg [5:0] score = 0
);
    parameter UP = 1, DOWN = 2, LEFT = 4, RIGHT = 8;

    reg [3:0] old_movement = RIGHT;
    reg over = 0;
    reg state_start = 1;

    reg [2:0] apple_row = 3, apple_col = 5;
    reg [2:0] center_row = 3, center_col = 2;
    reg [2:0] tail_row = 3, tail_col = 1;
    reg [2:0] min_row[0:29], min_col[0:29];
    integer k = 1;
    integer i;

    always @(posedge clk) begin
        if (state_start) begin
            // Happy face
            matrix <= 64'b0000000001100110011001100000000001000010001001000001100000000000;
        end else if (over) begin
            // Sad face
            score <= 0;
            old_movement <= RIGHT;
            matrix <= 64'b0000000001100110011001100000000000011000001001000100001000000000;
        end else begin
            if (movement != 0 && !(
                (old_movement == UP && movement == DOWN) ||
                (old_movement == DOWN && movement == UP) ||
                (old_movement == LEFT && movement == RIGHT) ||
                (old_movement == RIGHT && movement == LEFT)))
            begin
                old_movement <= movement;
            end

            matrix <= 0;
            matrix <= matrix | (64'h1 << (head_row * 8 + head_col));
            matrix <= matrix | (64'h1 << (center_row * 8 + center_col));
            matrix <= matrix | (64'h1 << (tail_row * 8 + tail_col));
            matrix <= matrix | (64'h1 << (apple_row * 8 + apple_col));

            for (i = 0; i < score; i = i + 1)
                matrix <= matrix | (64'h1 << (min_row[i] * 8 + min_col[i]));

            if ((head_row == apple_row) && (head_col == apple_col)) begin
                k = k + 1;
                apple_row <= (3 * k) % 8;
                apple_col <= (5 * k) % 8;
                score <= score + 1;
            end
        end
    end

    always @(posedge fout) begin
        if (state_start && start) begin
            state_start <= 0;
            head_row <= 3; head_col <= 3;
            center_row <= 3; center_col <= 2;
            tail_row <= 3; tail_col <= 1;
            min_row[0] <= 3; min_col[0] <= 0;
        end else if (over && start) begin
            over <= 0;
            score <= 0;
        end else if (!over) begin
            case (old_movement)
                UP: if (head_row > 0) head_row <= head_row - 1; else over <= 1;
                DOWN: if (head_row < 7) head_row <= head_row + 1; else over <= 1;
                LEFT: if (head_col > 0) head_col <= head_col - 1; else over <= 1;
                RIGHT: if (head_col < 7) head_col <= head_col + 1; else over <= 1;
            endcase

            center_row <= head_row;
            center_col <= head_col;
            tail_row <= center_row;
            tail_col <= center_col;
            min_row[0] <= tail_row;
            min_col[0] <= tail_col;

            for (i = 1; i < score; i = i + 1) begin
                min_row[i] <= min_row[i - 1];
                min_col[i] <= min_col[i - 1];
            end
        end
    end
endmodule
