/**************************************************************************/
// Copyright (c) 2024, OASIS Lab
// MODULE: TETRIS
// FILE NAME: TETRIS.v
// VERSRION: 1.0
// DATE: August 15, 2024
// AUTHOR: Yu-Hsuan Hsu, NYCU IEE
// DESCRIPTION: ICLAB2024FALL / LAB3 / TETRIS
// MODIFICATION HISTORY:
// Date                 Description
// 
/**************************************************************************/
 // 39966
module TETRIS (
	//INPUT
	rst_n,
	clk,
	in_valid,
	tetrominoes,
	position,
	//OUTPUT
	tetris_valid,
	score_valid,
	fail,
	score,
	tetris
);

//---------------------------------------------------------------------
//   PORT DECLARATION          
//---------------------------------------------------------------------
input				rst_n, clk, in_valid;
input		[2:0]	tetrominoes;
input		[2:0]	position;
output reg			tetris_valid, score_valid, fail;
output reg	[3:0]	score;
output reg 	[71:0]	tetris;


//---------------------------------------------------------------------
//   PARAMETER & INTEGER DECLARATION
//---------------------------------------------------------------------
parameter IDLE = 2'b00, PLACE = 2'b01, DETECT = 2'b10, OUTPUT = 2'b11;


//---------------------------------------------------------------------
//   REG & WIRE DECLARATION
//---------------------------------------------------------------------
reg [1:0] current_state, next_state;
reg tetris_map [0:13][0:5];
reg tetris_map_next [0:13][0:5];

reg [3:0] score_next;
reg [3:0] score_reg; // stupid TA wants this
reg tetris_valid_next, score_valid_next, fail_next;
reg tetris_valid_reg, score_valid_reg, fail_reg;

reg [2:0] tetrominoes_buf;
reg [2:0] position_buf;

reg [3:0] record_upper [0:5];
reg [3:0] record_upper_next [0:5];
reg [3:0] cnt, cnt_next;

reg [3:0] min_row;
reg record_full [11:0];


reg [3:0] record_upper_position, record_upper_position_1, record_upper_position_2, record_upper_position_3;
reg [3:0] data1_next, data2_next, data3_next, data4_next;
reg [3:0] data1, data2, data3, data4;


//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		tetris_map[13][0:5] <= '{6{1'b0}};
		tetris_map[12][0:5] <= '{6{1'b0}};
		tetris_map[11][0:5] <= '{6{1'b0}};
		tetris_map[10][0:5] <= '{6{1'b0}};
		tetris_map[9][0:5] <= '{6{1'b0}};
		tetris_map[8][0:5] <= '{6{1'b0}};
		tetris_map[7][0:5] <= '{6{1'b0}};
		tetris_map[6][0:5] <= '{6{1'b0}};
		tetris_map[5][0:5] <= '{6{1'b0}};
		tetris_map[4][0:5] <= '{6{1'b0}};
		tetris_map[3][0:5] <= '{6{1'b0}};
		tetris_map[2][0:5] <= '{6{1'b0}};
		tetris_map[1][0:5] <= '{6{1'b0}};
		tetris_map[0][0:5] <= '{6{1'b0}};

		score_reg <= 0;
		current_state <= IDLE;
		record_upper <= {0,0,0,0,0,0};
		cnt <= 0;
	end
	else begin
		tetris_map <= tetris_map_next;
		
		score_reg <= score_next;
		current_state <= next_state;
		record_upper <= record_upper_next;
		cnt <= cnt_next;
	end
end

always @(posedge clk) begin
	tetrominoes_buf <= tetrominoes;
	position_buf <= position;
	data1 <= data1_next;
	data2 <= data2_next;
	data3 <= data3_next;
	data4 <= data4_next;

end

function [71:0] tetris_map_to_tetris;
	// assign value to tetris_map from register value
	input tetris_map [0:13][0:5];
	begin
		tetris_map_to_tetris = {tetris_map[11][5],tetris_map[11][4], tetris_map[11][3], tetris_map[11][2], tetris_map[11][1], tetris_map[11][0],
								tetris_map[10][5],tetris_map[10][4], tetris_map[10][3], tetris_map[10][2], tetris_map[10][1], tetris_map[10][0],
								tetris_map[9][5],tetris_map[9][4], tetris_map[9][3], tetris_map[9][2], tetris_map[9][1], tetris_map[9][0],
								tetris_map[8][5],tetris_map[8][4], tetris_map[8][3], tetris_map[8][2], tetris_map[8][1], tetris_map[8][0],
								tetris_map[7][5],tetris_map[7][4], tetris_map[7][3], tetris_map[7][2], tetris_map[7][1], tetris_map[7][0],
								tetris_map[6][5],tetris_map[6][4], tetris_map[6][3], tetris_map[6][2], tetris_map[6][1], tetris_map[6][0],
								tetris_map[5][5],tetris_map[5][4], tetris_map[5][3], tetris_map[5][2], tetris_map[5][1], tetris_map[5][0],
								tetris_map[4][5],tetris_map[4][4], tetris_map[4][3], tetris_map[4][2], tetris_map[4][1], tetris_map[4][0],
								tetris_map[3][5],tetris_map[3][4], tetris_map[3][3], tetris_map[3][2], tetris_map[3][1], tetris_map[3][0],
								tetris_map[2][5],tetris_map[2][4], tetris_map[2][3], tetris_map[2][2], tetris_map[2][1], tetris_map[2][0],
								tetris_map[1][5],tetris_map[1][4], tetris_map[1][3], tetris_map[1][2], tetris_map[1][1], tetris_map[1][0],
								tetris_map[0][5],tetris_map[0][4], tetris_map[0][3], tetris_map[0][2], tetris_map[0][1], tetris_map[0][0]};
								
	end
endfunction

function [3:0] get_first_one;
	// get the first one in the column_data
	input [12:0] column_data;
	reg [12:0] column_data_reversed;
	reg [12:0] column_data_reversed_complement;
	reg [12:0] and_result;
	begin
		// priority encoder may help
		// column_data_reversed = {column_data[0], column_data[1], column_data[2], column_data[3], column_data[4], column_data[5], column_data[6], column_data[7], column_data[8], column_data[9], column_data[10], column_data[11], column_data[12]};

		// column_data_reversed_complement = ~column_data_reversed + 1'b1;
		// and_result = column_data_reversed & column_data_reversed_complement;
		// $display("and_result: %b", and_result);
		// case (and_result)
		// 	13'b0000000000000: get_first_one = 0;
		// 	13'b1000000000000: get_first_one = 1;
		// 	13'b0100000000000: get_first_one = 2;
		// 	13'b0010000000000: get_first_one = 3;
		// 	13'b0001000000000: get_first_one = 4;
		// 	13'b0000100000000: get_first_one = 5;
		// 	13'b0000010000000: get_first_one = 6;
		// 	13'b0000001000000: get_first_one = 7;
		// 	13'b0000000100000: get_first_one = 8;
		// 	13'b0000000010000: get_first_one = 9;
		// 	13'b0000000001000: get_first_one = 10;
		// 	13'b0000000000100: get_first_one = 11;
		// 	13'b0000000000010: get_first_one = 12;
		// 	13'b0000000000001: get_first_one = 13;
		// 	default: get_first_one = 4'bx;
		// endcase

		// casez(column_data)
		// 	13'b1????????????: get_first_one = 13;
		// 	13'b01???????????: get_first_one = 12;
		// 	13'b001??????????: get_first_one = 11;
		// 	13'b0001?????????: get_first_one = 10;
		// 	13'b00001????????: get_first_one = 9;
		// 	13'b000001???????: get_first_one = 8;
		// 	13'b0000001??????: get_first_one = 7;
		// 	13'b00000001?????: get_first_one = 6;
		// 	13'b000000001????: get_first_one = 5;
		// 	13'b0000000001???: get_first_one = 4;
		// 	13'b00000000001??: get_first_one = 3;
		// 	13'b000000000001?: get_first_one = 2;
		// 	13'b0000000000001: get_first_one = 1;
		// 	13'b0000000000000: get_first_one = 0;
		// 	default: get_first_one = 4'bx;
		// endcase
		if (column_data[12])
			get_first_one = 13;
		else if (column_data[11])
			get_first_one = 12;
		else if (column_data[10])
			get_first_one = 11;
		else if (column_data[9])
			get_first_one = 10;
		else if (column_data[8])
			get_first_one = 9;
		else if (column_data[7])
			get_first_one = 8;
		else if (column_data[6])
			get_first_one = 7;
		else if (column_data[5])
			get_first_one = 6;
		else if (column_data[4])
			get_first_one = 5;
		else if (column_data[3])
			get_first_one = 4;
		else if (column_data[2])
			get_first_one = 3;
		else if (column_data[1])
			get_first_one = 2;
		else if (column_data[0])
			get_first_one = 1;
		else
			get_first_one = 0;
	end
endfunction

function [3:0] max_2;
	// get the max value of two input
	input [3:0] a, b;
	reg [4:0] inter1;
	begin
		inter1 = a-b;
		max_2 = (inter1[4])? b: a;
	end
endfunction

function [3:0] max_3;
	// get the max value of three input
	input [3:0] a, b, c;
	reg [3:0] inter1;
	begin
		inter1 = max_2(a, b);
		max_3 = max_2(inter1, c);
	end
endfunction


function [3:0] max_4;
	// get the max value of four input
	input [3:0] a, b, c, d;
	reg [3:0] inter1, inter2;
	begin
		inter1 = max_2(a, b);
		inter2 = max_2(c, d);
		max_4 = max_2(inter1, inter2);
	end
endfunction

function [1:0] add_2;
	input a, b;
	begin
		case({a,b})
		2'b00: add_2 = 2'b00;
		2'b01: add_2 = 2'b01;
		2'b10: add_2 = 2'b01;
		2'b11: add_2 = 2'b10;
		endcase
	end
endfunction

function [4:0] sum_12;
	// get the sum of 12 input
	input a [11:0];
	begin
		sum_12 = (a[0] + a[1]) + (a[2] + a[3]) + (a[4] + a[5]) + (a[6] + a[7]) + (a[8] + a[9]) + (a[10] + a[11]);
		// sum_12 = add_2(a[0], a[1]) + add_2(a[2], a[3]) + add_2(a[4], a[5]) + add_2(a[6], a[7]) + add_2(a[8], a[9]) + add_2(a[10], a[11]);
	end
endfunction

function is_smaller;
	// return 1 if a < b
	input [3:0] a, b;
	reg [4:0] diff;
	begin
		diff = a - b;
		is_smaller = diff[4];
	end
endfunction

always @(*) begin
	next_state = current_state;
	tetris_map_next = tetris_map;

	score_next = score_reg;

	record_upper_next = record_upper;

	cnt_next = cnt;

	// the output should be 0 normally
	score = 0;
	fail = 0;
	tetris_valid = 0;
	score_valid = 0;
	tetris = 72'b0;
	
	min_row = 0;
	data1_next = 0;
	data2_next = 0;
	data3_next = 0;
	data4_next = 0;

	case (current_state)
		IDLE: begin
			if (in_valid) begin
				next_state = PLACE;
				// get the height of the tetris
				record_upper_position = record_upper[position];
				record_upper_position_1 = record_upper[position+1];
				record_upper_position_2 = record_upper[position+2];
				record_upper_position_3 = record_upper[position+3];

				case (tetrominoes)
					3'b000: begin
						data1_next = record_upper_position;
						data2_next = record_upper_position_1;
					end
					3'b001: begin
						data1_next = record_upper_position;
					end
					3'b010: begin
						data1_next = record_upper_position;
						data2_next = record_upper_position_1;
						data3_next = record_upper_position_2;
						data4_next = record_upper_position_3;
					end
					3'b011: begin
						data1_next = record_upper_position;
						data2_next = record_upper_position_1+2;
					end
					3'b100: begin
						data1_next = record_upper_position+1;
						data2_next = record_upper_position_1;
						data3_next = record_upper_position_2;
					end
					3'b101: begin
						data1_next = record_upper_position;
						data2_next = record_upper_position_1;
					end
					3'b110: begin
						data1_next = record_upper_position;
						data2_next = record_upper_position_1+1;
					end
					3'b111: begin
						data1_next = record_upper_position+1;
						data2_next = record_upper_position_1+1;
						data3_next = record_upper_position_2;
					end
				endcase
			end
		end
		
		PLACE: begin
			min_row = max_4(data1,data4,data2,data3); // shuffle may be better ???		
			case (tetrominoes_buf)
				3'b000: begin
					// update the tetris
					tetris_map_next[min_row][position_buf] = 1'b1;
					tetris_map_next[min_row][position_buf+1] = 1'b1;
					tetris_map_next[min_row+1][position_buf] = 1'b1;
					tetris_map_next[min_row+1][position_buf+1] = 1'b1;
				end
				3'b001: begin
					// update the tetris
					tetris_map_next[min_row][position_buf] = 1'b1;
					tetris_map_next[min_row+1][position_buf] = 1'b1;
					tetris_map_next[min_row+2][position_buf] = 1'b1;
					tetris_map_next[min_row+3][position_buf] = 1'b1;
				end
				3'b010: begin
					// update the tetris
					tetris_map_next[min_row][position_buf] = 1'b1;
					tetris_map_next[min_row][position_buf+1] = 1'b1;
					tetris_map_next[min_row][position_buf+2] = 1'b1;
					tetris_map_next[min_row][position_buf+3] = 1'b1;
				end
				3'b011: begin
					// update the tetris
					tetris_map_next[min_row][position_buf] = 1'b1;
					tetris_map_next[min_row][position_buf+1] = 1'b1;
					tetris_map_next[min_row-1][position_buf+1] = 1'b1;
					tetris_map_next[min_row-2][position_buf+1] = 1'b1;
				end
				3'b100: begin
					// update the tetris
					tetris_map_next[min_row][position_buf] = 1'b1;
					tetris_map_next[min_row-1][position_buf] = 1'b1;
					tetris_map_next[min_row][position_buf+1] = 1'b1;
					tetris_map_next[min_row][position_buf+2] = 1'b1;
				end
				3'b101: begin
					// update the tetris
					tetris_map_next[min_row][position_buf] = 1'b1;
					tetris_map_next[min_row][position_buf+1] = 1'b1;
					tetris_map_next[min_row+1][position_buf] = 1'b1;
					tetris_map_next[min_row+2][position_buf] = 1'b1;
				end
				3'b110: begin
					// update the tetris
					tetris_map_next[min_row][position_buf] = 1'b1;
					tetris_map_next[min_row][position_buf+1] = 1'b1;
					tetris_map_next[min_row-1][position_buf+1] = 1'b1;
					tetris_map_next[min_row+1][position_buf] = 1'b1;
				end
				3'b111: begin
					// update the tetris
					tetris_map_next[min_row-1][position_buf] = 1'b1;
					tetris_map_next[min_row-1][position_buf + 1] = 1'b1;
					tetris_map_next[min_row][position_buf + 1] = 1'b1;
					tetris_map_next[min_row][position_buf + 2] = 1'b1;
				end
				endcase
				next_state = DETECT;
		end
		DETECT: begin
			// detect the row is full of 1
			record_full[11] = &{tetris_map[11][0], tetris_map[11][1], tetris_map[11][2], tetris_map[11][3], tetris_map[11][4], tetris_map[11][5]};
			record_full[10] = &{tetris_map[10][0], tetris_map[10][1], tetris_map[10][2], tetris_map[10][3], tetris_map[10][4], tetris_map[10][5]};
			record_full[9] = &{tetris_map[9][0], tetris_map[9][1], tetris_map[9][2], tetris_map[9][3], tetris_map[9][4], tetris_map[9][5]};
			record_full[8] = &{tetris_map[8][0], tetris_map[8][1], tetris_map[8][2], tetris_map[8][3], tetris_map[8][4], tetris_map[8][5]};
			record_full[7] = &{tetris_map[7][0], tetris_map[7][1], tetris_map[7][2], tetris_map[7][3], tetris_map[7][4], tetris_map[7][5]};
			record_full[6] = &{tetris_map[6][0], tetris_map[6][1], tetris_map[6][2], tetris_map[6][3], tetris_map[6][4], tetris_map[6][5]};
			record_full[5] = &{tetris_map[5][0], tetris_map[5][1], tetris_map[5][2], tetris_map[5][3], tetris_map[5][4], tetris_map[5][5]};
			record_full[4] = &{tetris_map[4][0], tetris_map[4][1], tetris_map[4][2], tetris_map[4][3], tetris_map[4][4], tetris_map[4][5]};
			record_full[3] = &{tetris_map[3][0], tetris_map[3][1], tetris_map[3][2], tetris_map[3][3], tetris_map[3][4], tetris_map[3][5]};
			record_full[2] = &{tetris_map[2][0], tetris_map[2][1], tetris_map[2][2], tetris_map[2][3], tetris_map[2][4], tetris_map[2][5]};
			record_full[1] = &{tetris_map[1][0], tetris_map[1][1], tetris_map[1][2], tetris_map[1][3], tetris_map[1][4], tetris_map[1][5]};
			record_full[0] = &{tetris_map[0][0], tetris_map[0][1], tetris_map[0][2], tetris_map[0][3], tetris_map[0][4], tetris_map[0][5]};


			// remove the row which is full
			if (record_full[11]) begin
				tetris_map_next[11][0:5] = tetris_map[12][0:5];
				tetris_map_next[12][0:5] = tetris_map[13][0:5];
				tetris_map_next[13][0:5] = {0,0,0,0,0,0};
			end
			if (record_full[10]) begin
				tetris_map_next[10][0:5] = tetris_map_next[11][0:5];
				tetris_map_next[11][0:5] = tetris_map_next[12][0:5];
				tetris_map_next[12][0:5] = tetris_map_next[13][0:5];
				tetris_map_next[13][0:5] = {0,0,0,0,0,0};
			end
			if (record_full[9]) begin
				tetris_map_next[9][0:5] = tetris_map_next[10][0:5];
				tetris_map_next[10][0:5] = tetris_map_next[11][0:5];
				tetris_map_next[11][0:5] = tetris_map_next[12][0:5];
				tetris_map_next[12][0:5] = tetris_map_next[13][0:5];
				tetris_map_next[13][0:5] = {0,0,0,0,0,0};
			end
			if (record_full[8]) begin
				tetris_map_next[8][0:5] = tetris_map_next[9][0:5];
				tetris_map_next[9][0:5] = tetris_map_next[10][0:5];
				tetris_map_next[10][0:5] = tetris_map_next[11][0:5];
				tetris_map_next[11][0:5] = tetris_map_next[12][0:5];
				tetris_map_next[12][0:5] = tetris_map_next[13][0:5];
				tetris_map_next[13][0:5] = {0,0,0,0,0,0};
			end
			if (record_full[7]) begin
				tetris_map_next[7][0:5] = tetris_map_next[8][0:5];
				tetris_map_next[8][0:5] = tetris_map_next[9][0:5];
				tetris_map_next[9][0:5] = tetris_map_next[10][0:5];
				tetris_map_next[10][0:5] = tetris_map_next[11][0:5];
				tetris_map_next[11][0:5] = tetris_map_next[12][0:5];
				tetris_map_next[12][0:5] = tetris_map_next[13][0:5];
				tetris_map_next[13][0:5] = {0,0,0,0,0,0};
			end
			if (record_full[6]) begin
				tetris_map_next[6][0:5] = tetris_map_next[7][0:5];
				tetris_map_next[7][0:5] = tetris_map_next[8][0:5];
				tetris_map_next[8][0:5] = tetris_map_next[9][0:5];
				tetris_map_next[9][0:5] = tetris_map_next[10][0:5];
				tetris_map_next[10][0:5] = tetris_map_next[11][0:5];
				tetris_map_next[11][0:5] = tetris_map_next[12][0:5];
				tetris_map_next[12][0:5] = tetris_map_next[13][0:5];
				tetris_map_next[13][0:5] = {0,0,0,0,0,0};
			end
			if (record_full[5]) begin
				tetris_map_next[5][0:5] = tetris_map_next[6][0:5];
				tetris_map_next[6][0:5] = tetris_map_next[7][0:5];
				tetris_map_next[7][0:5] = tetris_map_next[8][0:5];
				tetris_map_next[8][0:5] = tetris_map_next[9][0:5];
				tetris_map_next[9][0:5] = tetris_map_next[10][0:5];
				tetris_map_next[10][0:5] = tetris_map_next[11][0:5];
				tetris_map_next[11][0:5] = tetris_map_next[12][0:5];
				tetris_map_next[12][0:5] = tetris_map_next[13][0:5];
				tetris_map_next[13][0:5] = {0,0,0,0,0,0};
			end
			if (record_full[4]) begin
				tetris_map_next[4][0:5] = tetris_map_next[5][0:5];
				tetris_map_next[5][0:5] = tetris_map_next[6][0:5];
				tetris_map_next[6][0:5] = tetris_map_next[7][0:5];
				tetris_map_next[7][0:5] = tetris_map_next[8][0:5];
				tetris_map_next[8][0:5] = tetris_map_next[9][0:5];
				tetris_map_next[9][0:5] = tetris_map_next[10][0:5];
				tetris_map_next[10][0:5] = tetris_map_next[11][0:5];
				tetris_map_next[11][0:5] = tetris_map_next[12][0:5];
				tetris_map_next[12][0:5] = tetris_map_next[13][0:5];
				tetris_map_next[13][0:5] = {0,0,0,0,0,0};
			end
			if (record_full[3]) begin
				tetris_map_next[3][0:5] = tetris_map_next[4][0:5];
				tetris_map_next[4][0:5] = tetris_map_next[5][0:5];
				tetris_map_next[5][0:5] = tetris_map_next[6][0:5];
				tetris_map_next[6][0:5] = tetris_map_next[7][0:5];
				tetris_map_next[7][0:5] = tetris_map_next[8][0:5];
				tetris_map_next[8][0:5] = tetris_map_next[9][0:5];
				tetris_map_next[9][0:5] = tetris_map_next[10][0:5];
				tetris_map_next[10][0:5] = tetris_map_next[11][0:5];
				tetris_map_next[11][0:5] = tetris_map_next[12][0:5];
				tetris_map_next[12][0:5] = tetris_map_next[13][0:5];
				tetris_map_next[13][0:5] = {0,0,0,0,0,0};
			end
			if (record_full[2]) begin
				tetris_map_next[2][0:5] = tetris_map_next[3][0:5];
				tetris_map_next[3][0:5] = tetris_map_next[4][0:5];
				tetris_map_next[4][0:5] = tetris_map_next[5][0:5];
				tetris_map_next[5][0:5] = tetris_map_next[6][0:5];
				tetris_map_next[6][0:5] = tetris_map_next[7][0:5];
				tetris_map_next[7][0:5] = tetris_map_next[8][0:5];
				tetris_map_next[8][0:5] = tetris_map_next[9][0:5];
				tetris_map_next[9][0:5] = tetris_map_next[10][0:5];
				tetris_map_next[10][0:5] = tetris_map_next[11][0:5];
				tetris_map_next[11][0:5] = tetris_map_next[12][0:5];
				tetris_map_next[12][0:5] = tetris_map_next[13][0:5];
				tetris_map_next[13][0:5] = {0,0,0,0,0,0};
			end
			if (record_full[1]) begin
				tetris_map_next[1][0:5] = tetris_map_next[2][0:5];
				tetris_map_next[2][0:5] = tetris_map_next[3][0:5];
				tetris_map_next[3][0:5] = tetris_map_next[4][0:5];
				tetris_map_next[4][0:5] = tetris_map_next[5][0:5];
				tetris_map_next[5][0:5] = tetris_map_next[6][0:5];
				tetris_map_next[6][0:5] = tetris_map_next[7][0:5];
				tetris_map_next[7][0:5] = tetris_map_next[8][0:5];
				tetris_map_next[8][0:5] = tetris_map_next[9][0:5];
				tetris_map_next[9][0:5] = tetris_map_next[10][0:5];
				tetris_map_next[10][0:5] = tetris_map_next[11][0:5];
				tetris_map_next[11][0:5] = tetris_map_next[12][0:5];
				tetris_map_next[12][0:5] = tetris_map_next[13][0:5];
				tetris_map_next[13][0:5] = {0,0,0,0,0,0};
			end
			if (record_full[0]) begin
				tetris_map_next[0][0:5] = tetris_map_next[1][0:5];
				tetris_map_next[1][0:5] = tetris_map_next[2][0:5];
				tetris_map_next[2][0:5] = tetris_map_next[3][0:5];
				tetris_map_next[3][0:5] = tetris_map_next[4][0:5];
				tetris_map_next[4][0:5] = tetris_map_next[5][0:5];
				tetris_map_next[5][0:5] = tetris_map_next[6][0:5];
				tetris_map_next[6][0:5] = tetris_map_next[7][0:5];
				tetris_map_next[7][0:5] = tetris_map_next[8][0:5];
				tetris_map_next[8][0:5] = tetris_map_next[9][0:5];
				tetris_map_next[9][0:5] = tetris_map_next[10][0:5];
				tetris_map_next[10][0:5] = tetris_map_next[11][0:5];
				tetris_map_next[11][0:5] = tetris_map_next[12][0:5];
				tetris_map_next[12][0:5] = tetris_map_next[13][0:5];
				tetris_map_next[13] = {0,0,0,0,0,0};
			end
			// compute the score
			$display("record_full: %d %d %d %d %d %d %d %d %d %d %d %d", record_full[0], record_full[1], record_full[2], record_full[3], record_full[4], record_full[5], record_full[6], record_full[7], record_full[8], record_full[9], record_full[10], record_full[11]);
			score_next = score_reg + sum_12(record_full);
			$display("score_next: %d", score_next);
			next_state = OUTPUT;
		end
		OUTPUT: begin
			// this stage may be too long???
			// find the leading one in the column
			record_upper_next = {get_first_one({tetris_map[13][0], tetris_map[12][0],
												tetris_map[11][0], tetris_map[10][0], 
												tetris_map[9][0], tetris_map[8][0], 
												tetris_map[7][0], tetris_map[6][0], 
												tetris_map[5][0], tetris_map[4][0], 
												tetris_map[3][0], tetris_map[2][0], 
												tetris_map[1][0], tetris_map[0][0]}),

								get_first_one({tetris_map[13][1], tetris_map[12][1],
												tetris_map[11][1], tetris_map[10][1], 
												tetris_map[9][1], tetris_map[8][1], 
												tetris_map[7][1], tetris_map[6][1], 
												tetris_map[5][1], tetris_map[4][1], 
												tetris_map[3][1], tetris_map[2][1], 
												tetris_map[1][1], tetris_map[0][1]}),

								get_first_one({tetris_map[13][2], tetris_map[12][2],
											tetris_map[11][2], tetris_map[10][2], 
											tetris_map[9][2], tetris_map[8][2], 
											tetris_map[7][2], tetris_map[6][2], 
											tetris_map[5][2], tetris_map[4][2], 
											tetris_map[3][2], tetris_map[2][2], 
											tetris_map[1][2], tetris_map[0][2]}),

								get_first_one({tetris_map[13][3], tetris_map[12][3],
											tetris_map[11][3], tetris_map[10][3], 
											tetris_map[9][3], tetris_map[8][3], 
											tetris_map[7][3], tetris_map[6][3], 
											tetris_map[5][3], tetris_map[4][3], 
											tetris_map[3][3], tetris_map[2][3], 
											tetris_map[1][3], tetris_map[0][3]}),

								get_first_one({tetris_map[13][4], tetris_map[12][4],
											tetris_map[11][4], tetris_map[10][4], 
											tetris_map[9][4], tetris_map[8][4], 
											tetris_map[7][4], tetris_map[6][4], 
											tetris_map[5][4], tetris_map[4][4], 
											tetris_map[3][4], tetris_map[2][4], 
											tetris_map[1][4], tetris_map[0][4]}),
								
								get_first_one({tetris_map[13][5], tetris_map[12][5],
											tetris_map[11][5], tetris_map[10][5], 
											tetris_map[9][5], tetris_map[8][5], 
											tetris_map[7][5], tetris_map[6][5], 
											tetris_map[5][5], tetris_map[4][5], 
											tetris_map[3][5], tetris_map[2][5], 
											tetris_map[1][5], tetris_map[0][5]})
								};
			// check if the game is over
			fail = 	is_smaller(12,record_upper_next[0])||
					is_smaller(12,record_upper_next[1])||
					is_smaller(12,record_upper_next[2])||
					is_smaller(12,record_upper_next[3])||
					is_smaller(12,record_upper_next[4])||
					is_smaller(12,record_upper_next[5]);
					

			next_state = IDLE;
			score = score_reg;

			if (fail || cnt == 15) begin
				tetris_valid = 1'b1;
				tetris = tetris_map_to_tetris(tetris_map);
				score = score_reg;
				score_valid = 1'b1;
				score_next = 0;
				cnt_next = 0;
				record_upper_next = {0,0,0,0,0,0};
				tetris_map_next[13][0:5] = '{6{1'b0}};
				tetris_map_next[12][0:5] = '{6{1'b0}};
				tetris_map_next[11][0:5] = '{6{1'b0}};
				tetris_map_next[10][0:5] = '{6{1'b0}};
				tetris_map_next[9][0:5] = '{6{1'b0}};
				tetris_map_next[8][0:5] = '{6{1'b0}};
				tetris_map_next[7][0:5] = '{6{1'b0}};
				tetris_map_next[6][0:5] = '{6{1'b0}};
				tetris_map_next[5][0:5] = '{6{1'b0}};
				tetris_map_next[4][0:5] = '{6{1'b0}};
				tetris_map_next[3][0:5] = '{6{1'b0}};
				tetris_map_next[2][0:5] = '{6{1'b0}};
				tetris_map_next[1][0:5] = '{6{1'b0}};
				tetris_map_next[0][0:5] = '{6{1'b0}};
			end
			else begin
				// output the score
				// tetris = tetris_map_to_tetris(tetris_map);
				cnt_next = cnt + 1;
				score_valid = 1'b1;
				score = score_reg;
			end				
		end
	endcase
end

endmodule