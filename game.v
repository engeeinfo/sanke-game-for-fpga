module game(clk,movement,row,col,state,start,reset,matrix,head_row,head_col,fout,ones,tens);
input clk;
input start,reset;
input [3:0]movement;// up,down,left,right
output  [7:0]row ;
output  [7:0]col ;

output [2:0] head_row,head_col;
wire [2:0]center_row,center_col;
wire [2:0]tail_row,tail_col;

wire [2:0]apple_row,apple_col;
reg [3:0]old_movement;
output [63:0]matrix;
output [2:0]state;
wire [7:0]out;
output fout;
parameter UP = 1, DOWN = 2, LEFT = 4, RIGHT = 8;

output [7:0]ones,tens;
wire [3:0] bcd_ones,bcd_tens;
wire [5:0]score;

freq_divider fd(clk,out,fout,score);
move snake_move(movement,head_row,head_col,clk,matrix,state,start,reset,fout,score);

bin2bcd b1(score,bcd_tens,bcd_ones); // from binary change to bcd
Seg7disp TEN(bcd_tens,tens);
Seg7disp UNIT(bcd_ones,ones);

led_scanner led(clk,matrix,row,col,state);


endmodule 

module led_scanner(clk,matrix,row,col,state);
input clk;
input [63:0]matrix; // 0:63 (64bit) O10000,01000,00100.....
output reg [7:0]row=8'd1 ;
output reg [7:0]col;
input [2:0]state;
always@(posedge clk) // led_scanner 
begin
    case(row)
    8'd1: 
    begin
        col = matrix[7:0];
    end
    8'd2:
    begin
        col = matrix[15:8];
    end
    8'd4:
    begin
        col = matrix[23:16];
    end
    8'd8: 
    begin
        col = matrix[31:24];
    end
    8'd16:
    begin
        col = matrix[39:32];
    end
    8'd32: 
    begin
        col = matrix[47:40];
    end
    8'd64: 
    begin
        col = matrix[55:48];
    end
    8'd128: 
    begin
        col = matrix[63:56];
	end
//  r: col = matrix[8*(r+1)-1:8*r];
    endcase
    row = row >> 1;
    if (row < 8'b0000_0001)
    begin
        row = 8'b1000_0000;
    end
end
endmodule

module move(movement,head_row,head_col,clk,matrix,state,start,reset,fout,score);
input [3:0]movement;
input clk,fout;
input start,reset;
reg [2:0]apple_row=3;//initial apple position
reg [2:0]apple_col=6;
output reg [2:0]state;
reg [2:0]next_state;
reg [3:0]old_movement;
reg over=0;
reg state_start=1;
output reg [63:0] matrix;

output reg [2:0]head_row=3,head_col=3;
reg [2:0]center_row=3,center_col=2;
reg [2:0]tail_row=3,tail_col=1;

reg [2:0]min_row[30:0]; // snake's real tail
reg [2:0]min_col[30:0]; // it means that every row and col's max is 30, because you or even me will never get the score over 30
output reg [5:0]score=0; 

parameter UP = 1, DOWN = 2, LEFT = 4, RIGHT = 8;
integer k=234;// for random
integer i=0;// for "for"
integer j=0;// same as above
integer m=0;// same as above
always@(posedge clk)
begin
	if (state_start == 1)// game start; happy face
	begin
		matrix[7:0]  =8'b00000000; 
		matrix[15:8] =8'b01100110; 
		matrix[23:16]=8'b01100110; 
		matrix[31:24]=8'b00000000; 
		matrix[39:32]=8'b01000010; 
		matrix[47:40]=8'b00100100; 
		matrix[55:48]=8'b00011000;
		matrix[63:56]=8'b00000000; 
	end
	else if(over == 1) // game over; sad face
	begin
		score = 0;
		old_movement = 0;
		matrix[7:0]  =8'b00000000; 
		matrix[15:8] =8'b01100110; 
		matrix[23:16]=8'b01100110; 
		matrix[31:24]=8'b00000000; 
		matrix[39:32]=8'b00011000; 
		matrix[47:40]=8'b00100100; 
		matrix[55:48]=8'b01000010; 
		matrix[63:56]=8'b00000000; 
		
		//matrix =0;
	end
	
	else
	begin
		if(movement == 0)
			old_movement = old_movement;
		
		else
        begin// illegal moves
            if(old_movement == UP && movement == DOWN) 
            begin
                old_movement = UP;
            end
            else if (old_movement == DOWN && movement == UP)// if snake moves old m=down; we press up it can't move up 
            begin
                old_movement = DOWN;
            end
            else if (old_movement == LEFT && movement == RIGHT)
            begin
                old_movement = LEFT;
            end
            else if (old_movement == RIGHT && movement == LEFT)
            begin
                old_movement = RIGHT;
            end
            else
            begin
                old_movement = movement;
            end
        end

		matrix=0; // clear the matrix
        matrix[head_row*8+head_col]=1;
        matrix[center_row*8+center_col]=1;
        matrix[tail_row*8+tail_col]=1;
		matrix[apple_row*8+apple_col] =  1;

		// print the min part(real tail)
		if(score>0)
		begin
			for(i=0; i < 30; i=i+1) // let 30 be max length
			begin
				if(i < score)
					matrix[min_row[i]*8+min_col[i]]=1;
			end	
		end	
		// when eating the apple	
		if((head_row == apple_row)&&(head_col == apple_col))
		begin
		// 	generate new_apple
			apple_row <= (123*k)%7;
			apple_col <= (123*(k+1))%7;
	//		matrix[apple_row*8+apple_col] =  1;
			k = k + 1;
			score <= score+1;
		end
		
		else
		begin// if we cannot eat apple its in same positionxx
		//	matrix[apple_row*8+apple_col] = 1;
			apple_row <= apple_row;
			apple_col <= apple_col;
		end
	end
end

always@(posedge fout)
begin// game start; and snake movement leftside matrix
		if (state_start == 1)
		begin
			if(start == 1)
			begin
				state_start = 0;
				head_row <= 3;
				head_col <= 3;
                center_row <= 3;
                center_col <= 2;
                tail_row <= 3;
                tail_col <= 1;
				min_row[0] <= 3;
				min_col[0] <= 0;
			end
			else
			begin
				state_start = 1;
			end
		end
		else if(over == 1) // game over 
		begin
			if(start == 1) // wait for start signal
			begin
				over = 0;
				head_row <= 3;
				head_col <= 3;
                center_row <= 3;
                center_col <= 2;
                tail_row <= 3;
                tail_col <= 1;
				min_row[0] <= 3;
				min_col[0] <= 0;
			end
			else
			begin
				over = 1;
			end
		end
		else
		begin
			case(old_movement)
			UP: // upward
			begin
				if(head_row > 0)
                begin
					head_row <= head_row - 3'd1;
					center_row <= head_row;
					center_col <= head_col;
					tail_row <= center_row;
					tail_col <= center_col;
					min_row[0] <= tail_row;
					min_col[0] <= tail_col;
					for (j=1;j<30;j=j+1)//overflow;
					begin
						if(j<score)
						begin
							min_row[j] <= min_row[j-1];
							min_col[j] <= min_col[j-1];
						end
					end
                end
				else
					begin
						head_row <= head_row;
						center_row <= center_row;
						tail_row <= tail_row;
						over = 1;
					end
			end
			DOWN:// downward
			begin
				if(head_row < 7)
                begin
                    head_row <= head_row + 3'd1; // down
					center_row <= head_row;
					center_col <= head_col;
					tail_row <= center_row;
					tail_col <= center_col;
					min_row[0] <= tail_row;
					min_col[0] <= tail_col;
					for (j=1;j<30;j=j+1)
					begin
						if(j<score)
						begin
							min_row[j] <= min_row[j-1];
							min_col[j] <= min_col[j-1];
						end
					end
                end
				else
				begin
					head_row <= head_row;
					center_row <= center_row;
					tail_row <= tail_row;
					over = 1;
				end
			end    
			LEFT:  // left 
			begin
				if(head_col > 0)
				begin
					head_col <= head_col - 3'd1;
					center_row <= head_row;
					center_col <= head_col;
					tail_row <= center_row;
					tail_col <= center_col;
					min_row[0] <= tail_row;
					min_col[0] <= tail_col;
					for (j=1;j<30;j=j+1)
					begin
						if(j<score)
						begin
							min_row[j] <= min_row[j-1];
							min_col[j] <= min_col[j-1];
						end
					end
                end
				else
				begin
					head_col <= head_col;
					center_col <= center_col;
					tail_col <= tail_col;
					over = 1;
				end
			end		
			RIGHT: // right
			begin
				if(head_col <  7)
                begin
					head_col <= head_col + 3'd1; 
					center_row <= head_row;
					center_col <= head_col;
					tail_row <= center_row;
					tail_col <= center_col;
					min_row[0] <= tail_row;
					min_col[0] <= tail_col;
					for (j=1;j<30;j=j+1)
					begin
						if(j<score)
						begin
							min_row[j] <= min_row[j-1];
							min_col[j] <= min_col[j-1];
						end
					end
                end
				else
				begin
					head_col <= head_col;
					center_col <= center_col;
					tail_col <= tail_col;
					over = 1;
				end
			end
			default: 
			begin
				head_row <= head_row;
				head_col <= head_col;
				center_row <= center_row;
				center_col <= center_col;
				tail_row <= tail_row;
				tail_col <= tail_col;
			end
			endcase
			
			for (m=1; m<30;m=m+1) // detect head hit the body
			begin
				if((head_row == min_row[m]) &&( head_col == min_col[m])&& (m<score))
				begin
					over = 1;
				end
			end
			
		end
end

endmodule

module freq_divider(clk,out,fout,score);
input clk;
input [5:0]score;
output reg fout;
output reg [7:0]out;
always@(posedge clk)
begin
	if(out == 8'd1)
	begin
		fout = !fout;
		out = 8'b1000_0000-(score*5);
	end
	else
		out = out - 8'd1;
end
endmodule


module bin2bcd(in,tens,units);

input [5:0]in;
output reg [3:0]tens,units;
reg [5:0]value ;

always@(in)
begin
    if(in >= 0)
    begin
        value = in;

        units = value % 10;
        value = value / 10;
        
        tens = value % 10;
        value = value / 10;
        
    end
end

endmodule

module Seg7disp(bcd_nums,display_num);
input [3:0]  bcd_nums; // print one side, every time
output reg [7:0] display_num;

parameter BLANK =   8'b1111_1111;
parameter ZERO  =   8'b1100_0000;//gfedcba
parameter ONE   =   8'b1111_1001;
parameter TWO   =   8'b1010_0100;
parameter THREE =   8'b1011_0000;
parameter FOUR  =   8'b1001_1001;
parameter FIVE  =   8'b1001_0010;
parameter SIX   =   8'b1000_0010;
parameter SEVEN =   8'b1111_1000;
parameter EIGHT =   8'b1000_0000;
parameter NINE  =   8'b1001_0000;

always@(bcd_nums)
begin
    
    case(bcd_nums)
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
    default:  display_num = BLANK;

    endcase

end

endmodule
