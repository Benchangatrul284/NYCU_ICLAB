/**************************************************************************/
// Copyright (c) 2024, OASIS Lab
// MODULE: PATTERN
// FILE NAME: PATTERN.v
// VERSRION: 1.0
// DATE: August 15, 2024
// AUTHOR: Yu-Hsuan Hsu, NYCU IEE
// DESCRIPTION: ICLAB2024FALL / LAB3 / PATTERN
// MODIFICATION HISTORY:
// Date                 Description
// 
/**************************************************************************/

`ifdef RTL
    `define CYCLE_TIME 40.0
`endif
`ifdef GATE
    `define CYCLE_TIME 40.0
`endif

module PATTERN(
	//OUTPUT
	rst_n,
	clk,
	in_valid,
	tetrominoes,
	position,
	//INPUT
	tetris_valid,
	score_valid,
	fail,
	score,
	tetris
);

//---------------------------------------------------------------------
//   PORT DECLARATION          
//---------------------------------------------------------------------
output reg			rst_n, clk, in_valid;
output reg	[2:0]	tetrominoes;
output reg  [2:0]	position;
input 				tetris_valid, score_valid, fail;
input 		[3:0]	score;
input		[71:0]	tetris;

//---------------------------------------------------------------------
//   PARAMETER & INTEGER DECLARATION
//---------------------------------------------------------------------
integer total_latency;
real CYCLE = `CYCLE_TIME;
parameter PATNUM = 1000;	
parameter pat_per_round = 16;
integer i_pat;
// file
integer in_read;
integer i_round;
integer pattern_number;
integer latency;
integer total_pattern;
//---------------------------------------------------------------------
//   REG & WIRE DECLARATION
//---------------------------------------------------------------------

reg [89:0] tetris_golden;
reg fail_golden;
reg [3:0] score_golden;
reg tetris_valid_golden;
reg score_valid_golden;

reg [3:0] record_upper [0:5];
reg [3:0] min_row;
reg [11:0] record_full;

reg [2:0] tetrominoes_golden, position_golden;
reg [12:0] tetris_golden_col [0:5];

//---------------------------------------------------------------------
//  CLOCK
//---------------------------------------------------------------------

initial clk = 0;
always #(CYCLE/2) clk = ~clk;
//---------------------------------------------------------------------
//  SIMULATION
//---------------------------------------------------------------------
initial begin
	in_read = $fopen("../00_TESTBED/input.txt", "r");
	reset_signal_task;
	total_latency = 0;
	
	// start to read pattern
	$fscanf(in_read, "%d", total_pattern);
	for (i_pat = 0; i_pat < PATNUM; i_pat = i_pat + 1) begin
		$fscanf(in_read, "%d", pattern_number);
		tetris_golden = 89'b0;
		fail_golden = 1'b0;
		score_golden = 4'b0;
		record_upper = {0,0,0,0,0,0};
		// tetris_valid_golden = 1'b0;
		// score_valid_golden = 1'b0;
		for (i_round = 0; i_round < pat_per_round; i_round = i_round + 1) begin
			tetris_valid_golden = 1'b0;
			score_valid_golden = 1'b0;
			input_task;
			wait_out_valid_task;
			cal_golden_task;
			check_ans_task;
			if (fail_golden == 1'b1) begin
				$display("%d pattern has terminated early", i_pat);
				for (integer i = i_round + 1; i < pat_per_round; i = i + 1) begin
					$fscanf(in_read, "%d %d", tetrominoes, position);
				end
				break;
			end
		end
		$display("PASS PATTERN NO.%4d", pattern_number);
	end
	$display("                  Congratulations!               ");
	$display("              execution cycles = %7d", total_latency);
	$display("              clock period = %4fns", CYCLE);
	$finish;
end


task reset_signal_task; begin
	rst_n = 1'b1;
	in_valid = 1'b0;
	tetrominoes = 3'b000;
	position = 3'b000;

	force clk = 1'b0;
	#(CYCLE/2); rst_n = 1'b0; // delay a small time and then pull down reset
	#(100); // check if the output is reset
	if ((tetris_valid !== 0) || (score_valid !== 0) || (fail !== 0) || (score !== 0) !== (tetris !== 0)) begin
		$display("                    SPEC-4 FAIL                   ");
		$display("************************************************************");
		$display("*  Output signals should be 0 after initial RESET at %8t *", $time);
        $display("************************************************************");
		$finish;
	end
	repeat(2) #(CYCLE);
	rst_n = 1'b1; // set reset to high
	#(2);
	release clk;
end
endtask

task input_task; begin
	// input start
	repeat ($urandom_range(1,4)) @(negedge clk);
	// check SPEC-8
	$fscanf(in_read, "%d %d", tetrominoes, position);
	tetrominoes_golden = tetrominoes;
	position_golden = position;
	// $display("=====================================================");
	// $display("tetrominoes = %d, position = %d", tetrominoes, position);
	in_valid = 1'b1;
	@(negedge clk);
	in_valid = 1'b0;
	tetrominoes = 3'bx;
	position = 3'bx;
end
endtask

task wait_out_valid_task; begin
	// recordend, wait for output
	latency = 1;
	while (score_valid !== 1'b1) begin
		if (latency > 1000) begin
			$display("************************************************************");
			$display("                    SPEC-6 FAIL                   ");
			$display("*  The execution latency exceeded 100 cycles at %8t   *", $time);
			$display("************************************************************");
			$finish;
		end
		if (score !== 0 || fail !== 0 || tetris_valid !== 0 || tetris !== 0) begin
			$display("************************************************************");
			$display("                    SPEC-5 FAIL                   ");
			$display("*  The signals score, fail, tetris_valid should be LOW when score_valid is low at %8t   *", $time);
			$display("Your score = %d, fail = %d, tetris_valid = %d", score, fail, tetris_valid);
			display_tetris;
			$display("************************************************************");
			$finish;
		end
		if (tetris_valid === 1'b0 && tetris !== 1'b0) begin
			$display("************************************************************");
			$display("                    SPEC-5 FAIL                   ");
			$display("*  The tetris should be LOW when tetris_valid is low at %8t   *", $time);
			$display("************************************************************");
			$finish;
		end
		latency = latency + 1;
		@(negedge clk);
	end
	total_latency = total_latency + latency;
	if (tetris_valid === 1'b0 && tetris !== 1'b0) begin
		$display("************************************************************");
		$display("                    SPEC-5 FAIL                   ");
		$display("*  The tetris should be LOW when tetris_valid is low at %8t   *", $time);
		$display("************************************************************");
		$finish;
	end
end
endtask

function [3:0] count_number_of_ones;
	input [11:0] record_full;
	begin
		count_number_of_ones = record_full[0] + record_full[1] + record_full[2] + record_full[3] + record_full[4] + record_full[5] + record_full[6] + record_full[7] + record_full[8] + record_full[9] + record_full[10] + record_full[11];
	end
endfunction

task display_record_upper; begin
	$display("input record_upper = %d %d %d %d %d %d", record_upper[0], record_upper[1], record_upper[2], record_upper[3], record_upper[4], record_upper[5]);
end
endtask

function [3:0] get_first_one;
	// get the first one in the column_data
	input [12:0] column_data;
	begin
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


task cal_golden_task; begin
	// record_upper records the lowest position the tetris can be placed in each row
	begin
		// display_record_upper;
		case (tetrominoes_golden)
			3'b000: begin
				// choose the upper one
				min_row = (record_upper[position_golden] > record_upper[position_golden+1])? record_upper[position_golden] : record_upper[position_golden+1];
				// update the record_upper of the column
				record_upper[position_golden] = min_row + 2;
				record_upper[position_golden+1] = min_row + 2;
				// update the tetris
				tetris_golden[min_row*6 + position_golden] = 1'b1;
				tetris_golden[min_row*6 + position_golden+1] = 1'b1;
				tetris_golden[(min_row+1)*6 + position_golden] = 1'b1;
				tetris_golden[(min_row+1)*6 + position_golden + 1] = 1'b1;
			end
			3'b001: begin
				// no need to choose the upper one
				min_row = record_upper[position_golden];
				// update the record_upper of the column
				record_upper[position_golden] = min_row + 4;
				// update the tetris
				tetris_golden[(min_row)*6 + position_golden] = 1'b1;
				tetris_golden[(min_row+1)*6 + position_golden] = 1'b1;
				tetris_golden[(min_row+2)*6 + position_golden] = 1'b1;
				tetris_golden[(min_row+3)*6 + position_golden] = 1'b1;
			end
			3'b010: begin
				// choose the upper one
				min_row = (record_upper[position_golden] > record_upper[position_golden+1])? record_upper[position_golden]: record_upper[position_golden+1];
				min_row = (min_row > record_upper[position_golden+2])? min_row: record_upper[position_golden+2];
				min_row = (min_row > record_upper[position_golden+3])? min_row: record_upper[position_golden+3];
				// update the record_upper of the column
				record_upper[position_golden] = min_row + 1;
				record_upper[position_golden+1] = min_row + 1;
				record_upper[position_golden+2] = min_row + 1;
				record_upper[position_golden+3] = min_row + 1;
				// update the tetris
				tetris_golden[min_row*6 + position_golden] = 1'b1;
				tetris_golden[min_row*6 + position_golden+1] = 1'b1;
				tetris_golden[min_row*6 + position_golden+2] = 1'b1;
				tetris_golden[min_row*6 + position_golden+3] = 1'b1;
			end
			3'b011: begin
				// choose the upper one
				min_row = (record_upper[position_golden] > record_upper[position_golden+1] + 2)? record_upper[position_golden]: record_upper[position_golden+1] + 2;
				// update the record_upper of the column
				record_upper[position_golden] = min_row + 1;
				record_upper[position_golden+1] = min_row + 1;
				// update the tetris
				tetris_golden[min_row*6 + position_golden] = 1'b1;
				tetris_golden[min_row*6 + position_golden+1] = 1'b1;
				tetris_golden[(min_row-1)*6 + position_golden+1] = 1'b1;
				tetris_golden[(min_row-2)*6 + position_golden+1] = 1'b1;
			end
			3'b100: begin
				// choose the upper one
				min_row = (record_upper[position_golden] + 1 > record_upper[position_golden+1])? record_upper[position_golden] + 1: record_upper[position_golden+1];
				min_row = (min_row > record_upper[position_golden+2])? min_row: record_upper[position_golden+2];
				// update the record_upper of the column
				record_upper[position_golden] = min_row + 1;
				record_upper[position_golden+1] = min_row + 1;
				record_upper[position_golden+2] = min_row + 1;
				// update the tetris
				tetris_golden[min_row*6 + position_golden] = 1'b1;
				tetris_golden[(min_row-1)*6 + position_golden] = 1'b1;
				tetris_golden[min_row*6 + position_golden+1] = 1'b1;
				tetris_golden[min_row*6 + position_golden+2] = 1'b1;
			end
			3'b101: begin
				// choose the upper one
				min_row = (record_upper[position_golden] > record_upper[position_golden+1])? record_upper[position_golden]: record_upper[position_golden+1];
				// update the record_upper of the column
				record_upper[position_golden] = min_row + 3;
				record_upper[position_golden+1] = min_row + 1;
				// update the tetris
				tetris_golden[min_row*6 + position_golden] = 1'b1;
				tetris_golden[min_row*6 + position_golden+1] = 1'b1;
				tetris_golden[(min_row+1)*6 + position_golden] = 1'b1;
				tetris_golden[(min_row+2)*6 + position_golden] = 1'b1;
			end
			3'b110: begin
				// choose the upper one
				min_row = (record_upper[position_golden] > record_upper[position_golden+1] + 1)? record_upper[position_golden]: record_upper[position_golden+1] + 1;
				// update the record_upper of the column
				record_upper[position_golden] = min_row + 2;
				record_upper[position_golden+1] = min_row + 1;
				// update the tetris
				tetris_golden[min_row*6 + position_golden] = 1'b1;
				tetris_golden[min_row*6 + position_golden+1] = 1'b1;
				tetris_golden[(min_row-1)*6 + position_golden+1] = 1'b1;
				tetris_golden[(min_row+1)*6 + position_golden] = 1'b1;
			end
			3'b111: begin
				// choose the upper one
				min_row = (record_upper[position_golden] + 1 > record_upper[position_golden+1] + 1)? record_upper[position_golden] + 1: record_upper[position_golden+1] + 1;
				min_row = (min_row > record_upper[position_golden+2])? min_row: record_upper[position_golden+2];
				// update the record_upper of the column
				record_upper[position_golden] = min_row;
				record_upper[position_golden+1] = min_row + 1;
				record_upper[position_golden+2] = min_row + 1;
				// update the tetris
				tetris_golden[(min_row-1)*6 + position_golden] = 1'b1;
				tetris_golden[(min_row-1)*6 + position_golden + 1] = 1'b1;
				tetris_golden[min_row*6 + position_golden + 1] = 1'b1;
				tetris_golden[min_row*6 + position_golden + 2] = 1'b1;
			end
		endcase
		// check if any row is full
		record_full = {&tetris_golden[71:66], &tetris_golden[65:60], 
               		&tetris_golden[59:54], &tetris_golden[53:48], 
               		&tetris_golden[47:42], &tetris_golden[41:36], 
               		&tetris_golden[35:30], &tetris_golden[29:24], 
               		&tetris_golden[23:18], &tetris_golden[17:12], 
               		&tetris_golden[11:6],  &tetris_golden[5:0]};

		// update the score
		score_golden = score_golden + count_number_of_ones(record_full);
		
		// if record_full gets two 1, stop the stimilation
		// if (count_number_of_ones(record_full) >= 2) begin
		// 	$display("count_number_of_ones(record_full) is %d", count_number_of_ones(record_full));
		// 	$finish
		// end
		
		// update the tetris (edge case not tested, may need to be modified)
		if (record_full[11]) begin
			// 12 -> 11
			tetris_golden[71:66] = tetris_golden[77:72];
			// 13 -> 12
			tetris_golden[77:72] = tetris_golden[83:78];
			// 6'b0 -> 13
			tetris_golden[83:78] = 6'b0;
		end
		if (record_full[10]) begin
			// 11 -> 10
			tetris_golden[65:60] = tetris_golden[71:66];
			// 12 -> 11
			tetris_golden[71:66] = tetris_golden[77:72];
			// 13 -> 12
			tetris_golden[77:72] = tetris_golden[83:78];
			// 6'b0 -> 13
			tetris_golden[83:78] = 6'b0;
		end
		if (record_full[9]) begin
			// 10 -> 9
			tetris_golden[59:54] = tetris_golden[65:60];
			// 11 -> 10
			tetris_golden[65:60] = tetris_golden[71:66];
			// 12 -> 11
			tetris_golden[71:66] = tetris_golden[77:72];
			// 6'b0 -> 12
			tetris_golden[77:72] = 6'b0;
		end
		if (record_full[8]) begin
			// 9 -> 8
			tetris_golden[53:48] = tetris_golden[59:54];
			// 10 -> 9
			tetris_golden[59:54] = tetris_golden[65:60];
			// 11 -> 10
			tetris_golden[65:60] = tetris_golden[71:66];
			// 12 -> 11
			tetris_golden[71:66] = tetris_golden[77:72];
			// 6'b0 -> 12
			tetris_golden[77:72] = 6'b0;
		end
		if (record_full[7]) begin
			// 8 -> 7
			tetris_golden[47:42] = tetris_golden[53:48];
			// 9 -> 8
			tetris_golden[53:48] = tetris_golden[59:54];
			// 10 -> 9
			tetris_golden[59:54] = tetris_golden[65:60];
			// 11 -> 10
			tetris_golden[65:60] = tetris_golden[71:66];
			// 12 -> 11
			tetris_golden[71:66] = tetris_golden[77:72];
			// 6'b0 -> 12
			tetris_golden[77:72] = 6'b0;
		end
		if (record_full[6]) begin
			// 7 -> 6
			tetris_golden[41:36] = tetris_golden[47:42];
			// 8 -> 7
			tetris_golden[47:42] = tetris_golden[53:48];
			// 9 -> 8
			tetris_golden[53:48] = tetris_golden[59:54];
			// 10 -> 9
			tetris_golden[59:54] = tetris_golden[65:60];
			// 11 -> 10
			tetris_golden[65:60] = tetris_golden[71:66];
			// 12 -> 11
			tetris_golden[71:66] = tetris_golden[77:72];
			// 6'b0 -> 12
			tetris_golden[77:72] = 6'b0;
		end
		if (record_full[5]) begin
			// 6 -> 5
			tetris_golden[35:30] = tetris_golden[41:36];
			// 7 -> 6
			tetris_golden[41:36] = tetris_golden[47:42];
			// 8 -> 7
			tetris_golden[47:42] = tetris_golden[53:48];
			// 9 -> 8
			tetris_golden[53:48] = tetris_golden[59:54];
			// 10 -> 9
			tetris_golden[59:54] = tetris_golden[65:60];
			// 11 -> 10
			tetris_golden[65:60] = tetris_golden[71:66];
			// 12 -> 11
			tetris_golden[71:66] = tetris_golden[77:72];
			// 6'b0 -> 12
			tetris_golden[77:72] = 6'b0;
		end
		if (record_full[4]) begin
			// 5 -> 4
			tetris_golden[29:24] = tetris_golden[35:30];
			// 6 -> 5
			tetris_golden[35:30] = tetris_golden[41:36];
			// 7 -> 6
			tetris_golden[41:36] = tetris_golden[47:42];
			// 8 -> 7
			tetris_golden[47:42] = tetris_golden[53:48];
			// 9 -> 8
			tetris_golden[53:48] = tetris_golden[59:54];
			// 10 -> 9
			tetris_golden[59:54] = tetris_golden[65:60];
			// 11 -> 10
			tetris_golden[65:60] = tetris_golden[71:66];
			// 12 -> 11
			tetris_golden[71:66] = tetris_golden[77:72];
			// 6'b0 -> 12
			tetris_golden[77:72] = 6'b0;
		end
		if (record_full[3]) begin
			// 4 -> 3
			tetris_golden[23:18] = tetris_golden[29:24];
			// 5 -> 4
			tetris_golden[29:24] = tetris_golden[35:30];
			// 6 -> 5
			tetris_golden[35:30] = tetris_golden[41:36];
			// 7 -> 6
			tetris_golden[41:36] = tetris_golden[47:42];
			// 8 -> 7
			tetris_golden[47:42] = tetris_golden[53:48];
			// 9 -> 8
			tetris_golden[53:48] = tetris_golden[59:54];
			// 10 -> 9
			tetris_golden[59:54] = tetris_golden[65:60];
			// 11 -> 10
			tetris_golden[65:60] = tetris_golden[71:66];
			// 12 -> 11
			tetris_golden[71:66] = tetris_golden[77:72];
			// 6'b0 -> 12
			tetris_golden[77:72] = 6'b0;
		end
		if (record_full[2]) begin
			// 3 -> 2
			tetris_golden[17:12] = tetris_golden[23:18];
			// 4 -> 3
			tetris_golden[23:18] = tetris_golden[29:24];
			// 5 -> 4
			tetris_golden[29:24] = tetris_golden[35:30];
			// 6 -> 5
			tetris_golden[35:30] = tetris_golden[41:36];
			// 7 -> 6
			tetris_golden[41:36] = tetris_golden[47:42];
			// 8 -> 7
			tetris_golden[47:42] = tetris_golden[53:48];
			// 9 -> 8
			tetris_golden[53:48] = tetris_golden[59:54];
			// 10 -> 9
			tetris_golden[59:54] = tetris_golden[65:60];
			// 11 -> 10
			tetris_golden[65:60] = tetris_golden[71:66];
			// 12 -> 11
			tetris_golden[71:66] = tetris_golden[77:72];
			// 6'b0 -> 12
			tetris_golden[77:72] = 6'b0;
		end
		if (record_full[1]) begin
			// 2 -> 1
			tetris_golden[11:6] = tetris_golden[17:12];
			// 3 -> 2
			tetris_golden[17:12] = tetris_golden[23:18];
			// 4 -> 3
			tetris_golden[23:18] = tetris_golden[29:24];
			// 5 -> 4
			tetris_golden[29:24] = tetris_golden[35:30];
			// 6 -> 5
			tetris_golden[35:30] = tetris_golden[41:36];
			// 7 -> 6
			tetris_golden[41:36] = tetris_golden[47:42];
			// 8 -> 7
			tetris_golden[47:42] = tetris_golden[53:48];
			// 9 -> 8
			tetris_golden[53:48] = tetris_golden[59:54];
			// 10 -> 9
			tetris_golden[59:54] = tetris_golden[65:60];
			// 11 -> 10
			tetris_golden[65:60] = tetris_golden[71:66];
			// 12 -> 11
			tetris_golden[71:66] = tetris_golden[77:72];
			// 6'b0 -> 12
			tetris_golden[77:72] = 6'b0;
		end
		if (record_full[0]) begin
			// 1 -> 0
			tetris_golden[5:0] = tetris_golden[11:6];
			// 2 -> 1
			tetris_golden[11:6] = tetris_golden[17:12];
			// 3 -> 2
			tetris_golden[17:12] = tetris_golden[23:18];
			// 4 -> 3
			tetris_golden[23:18] = tetris_golden[29:24];
			// 5 -> 4
			tetris_golden[29:24] = tetris_golden[35:30];
			// 6 -> 5
			tetris_golden[35:30] = tetris_golden[41:36];
			// 7 -> 6
			tetris_golden[41:36] = tetris_golden[47:42];
			// 8 -> 7
			tetris_golden[47:42] = tetris_golden[53:48];
			// 9 -> 8
			tetris_golden[53:48] = tetris_golden[59:54];
			// 10 -> 9
			tetris_golden[59:54] = tetris_golden[65:60];
			// 11 -> 10
			tetris_golden[65:60] = tetris_golden[71:66];
			/// 12 -> 11
			tetris_golden[71:66] = tetris_golden[77:72];
			// 6'b0 -> 12
			tetris_golden[77:72] = 6'b0;
		end

		// update the record_upper of the column
		// $display(tetris_golden[77]);
		tetris_golden_col[0] = {tetris_golden[72], tetris_golden[66], tetris_golden[60], tetris_golden[54], tetris_golden[48], tetris_golden[42], tetris_golden[36], tetris_golden[30], tetris_golden[24], tetris_golden[18], tetris_golden[12], tetris_golden[6], tetris_golden[0]};
		tetris_golden_col[1] = {tetris_golden[73], tetris_golden[67], tetris_golden[61], tetris_golden[55], tetris_golden[49], tetris_golden[43], tetris_golden[37], tetris_golden[31], tetris_golden[25], tetris_golden[19], tetris_golden[13], tetris_golden[7], tetris_golden[1]};
		tetris_golden_col[2] = {tetris_golden[74], tetris_golden[68], tetris_golden[62], tetris_golden[56], tetris_golden[50], tetris_golden[44], tetris_golden[38], tetris_golden[32], tetris_golden[26], tetris_golden[20], tetris_golden[14], tetris_golden[8], tetris_golden[2]};
		tetris_golden_col[3] = {tetris_golden[75], tetris_golden[69], tetris_golden[63], tetris_golden[57], tetris_golden[51], tetris_golden[45], tetris_golden[39], tetris_golden[33], tetris_golden[27], tetris_golden[21], tetris_golden[15], tetris_golden[9], tetris_golden[3]};
		tetris_golden_col[4] = {tetris_golden[76], tetris_golden[70], tetris_golden[64], tetris_golden[58], tetris_golden[52], tetris_golden[46], tetris_golden[40], tetris_golden[34], tetris_golden[28], tetris_golden[22], tetris_golden[16], tetris_golden[10], tetris_golden[4]};
		tetris_golden_col[5] = {tetris_golden[77], tetris_golden[71], tetris_golden[65], tetris_golden[59], tetris_golden[53], tetris_golden[47], tetris_golden[41], tetris_golden[35], tetris_golden[29], tetris_golden[23], tetris_golden[17], tetris_golden[11], tetris_golden[5]};

		record_upper[0] = get_first_one(tetris_golden_col[0]);
		record_upper[1] = get_first_one(tetris_golden_col[1]);
		record_upper[2] = get_first_one(tetris_golden_col[2]);
		record_upper[3] = get_first_one(tetris_golden_col[3]);
		record_upper[4] = get_first_one(tetris_golden_col[4]);
		record_upper[5] = get_first_one(tetris_golden_col[5]);

		// check if the game is over
		fail_golden = (record_upper[0] > 12)||(record_upper[1] > 12)||(record_upper[2] > 12)||(record_upper[3] > 12)||(record_upper[4] > 12)||(record_upper[5] > 12);
		// if the round is 15 or fail condition is met
		if (i_round === 15 || fail_golden === 1'b1) begin
			tetris_valid_golden = 1'b1;
		end
		score_valid_golden = 1'b1;
	end
end
endtask

task display_tetris; begin
	$display("tetris = %b%b%b%b%b%b", tetris[66], tetris[67], tetris[68], tetris[69], tetris[70], tetris[71]);
	$display("tetris = %b%b%b%b%b%b", tetris[60], tetris[61], tetris[62], tetris[63], tetris[64], tetris[65]);
	$display("tetris = %b%b%b%b%b%b", tetris[54], tetris[55], tetris[56], tetris[57], tetris[58], tetris[59]);
	$display("tetris = %b%b%b%b%b%b", tetris[48], tetris[49], tetris[50], tetris[51], tetris[52], tetris[53]);
	$display("tetris = %b%b%b%b%b%b", tetris[42], tetris[43], tetris[44], tetris[45], tetris[46], tetris[47]);
	$display("tetris = %b%b%b%b%b%b", tetris[36], tetris[37], tetris[38], tetris[39], tetris[40], tetris[41]);
	$display("tetris = %b%b%b%b%b%b", tetris[30], tetris[31], tetris[32], tetris[33], tetris[34], tetris[35]);
	$display("tetris = %b%b%b%b%b%b", tetris[24], tetris[25], tetris[26], tetris[27], tetris[28], tetris[29]);
	$display("tetris = %b%b%b%b%b%b", tetris[18], tetris[19], tetris[20], tetris[21], tetris[22], tetris[23]);
	$display("tetris = %b%b%b%b%b%b", tetris[12], tetris[13], tetris[14], tetris[15], tetris[16], tetris[17]);
	$display("tetris = %b%b%b%b%b%b", tetris[6], tetris[7], tetris[8], tetris[9], tetris[10], tetris[11]);
	$display("tetris = %b%b%b%b%b%b", tetris[0], tetris[1], tetris[2], tetris[3], tetris[4], tetris[5]);

end
endtask

task display_tetris_golden; begin
	$display("tetris_golden = %b%b%b%b%b%b", tetris_golden[66], tetris_golden[67], tetris_golden[68], tetris_golden[69], tetris_golden[70], tetris_golden[71]);
	$display("tetris_golden = %b%b%b%b%b%b", tetris_golden[60], tetris_golden[61], tetris_golden[62], tetris_golden[63], tetris_golden[64], tetris_golden[65]);
	$display("tetris_golden = %b%b%b%b%b%b", tetris_golden[54], tetris_golden[55], tetris_golden[56], tetris_golden[57], tetris_golden[58], tetris_golden[59]);
	$display("tetris_golden = %b%b%b%b%b%b", tetris_golden[48], tetris_golden[49], tetris_golden[50], tetris_golden[51], tetris_golden[52], tetris_golden[53]);
	$display("tetris_golden = %b%b%b%b%b%b", tetris_golden[42], tetris_golden[43], tetris_golden[44], tetris_golden[45], tetris_golden[46], tetris_golden[47]);
	$display("tetris_golden = %b%b%b%b%b%b", tetris_golden[36], tetris_golden[37], tetris_golden[38], tetris_golden[39], tetris_golden[40], tetris_golden[41]);
	$display("tetris_golden = %b%b%b%b%b%b", tetris_golden[30], tetris_golden[31], tetris_golden[32], tetris_golden[33], tetris_golden[34], tetris_golden[35]);
	$display("tetris_golden = %b%b%b%b%b%b", tetris_golden[24], tetris_golden[25], tetris_golden[26], tetris_golden[27], tetris_golden[28], tetris_golden[29]);
	$display("tetris_golden = %b%b%b%b%b%b", tetris_golden[18], tetris_golden[19], tetris_golden[20], tetris_golden[21], tetris_golden[22], tetris_golden[23]);
	$display("tetris_golden = %b%b%b%b%b%b", tetris_golden[12], tetris_golden[13], tetris_golden[14], tetris_golden[15], tetris_golden[16], tetris_golden[17]);
	$display("tetris_golden = %b%b%b%b%b%b", tetris_golden[6], tetris_golden[7], tetris_golden[8], tetris_golden[9], tetris_golden[10], tetris_golden[11]);
	$display("tetris_golden = %b%b%b%b%b%b", tetris_golden[0], tetris_golden[1], tetris_golden[2], tetris_golden[3], tetris_golden[4], tetris_golden[5]);
end
endtask

// this task will be executed after the score_valid is high
task check_ans_task; begin
	if (score_valid_golden === 1'b1) begin
		// check the score golden answer and fail golden answer
		if (score !== score_golden || fail !== fail_golden || score_valid !== score_valid_golden) begin
			$display("************************************************************");
			$display("score = %d, score_golden = %d", score, score_golden);
			$display("fail = %d, fail_golden = %d", fail, fail_golden);
			$display("                    SPEC-7 FAIL                   ");
			// display_tetris;
			// display_tetris_golden;
			$display("************************************************************");
			$finish;
		end
	end
	if (tetris_valid_golden === 1'b1) begin
		// check the tetris golden answer
		if (tetris !== tetris_golden[71:0] || tetris_valid !== tetris_valid_golden) begin
			$display("************************************************************");
			$display("tetris_valid = %d, tetris_valid_golden = %d", tetris_valid, tetris_valid_golden);
			display_tetris;
			display_tetris_golden;
			$display("                    SPEC-7 FAIL                   ");
			$display("************************************************************");
			$finish;
		end
	end
	@(negedge clk);
	if (score_valid !== 1'b0 || tetris_valid !== 1'b0) begin
		$display("************************************************************");
		$display("                    SPEC-8 FAIL                   ");
		$display("The score_valid or tetris_valid should be high for exactly one cycle");
		$display("************************************************************");
		$finish;
	end
end
endtask

endmodule

// for spec check
// $display("                    SPEC-4 FAIL                   ");
// $display("                    SPEC-5 FAIL                   ");
// $display("                    SPEC-6 FAIL                   ");
// $display("                    SPEC-7 FAIL                   ");
// $display("                    SPEC-8 FAIL                   ");
// for successful design
// $display("                  Congratulations!               ");
// $display("              execution cycles = %7d", total_latency);
// $display("              clock period = %4fns", CYCLE);