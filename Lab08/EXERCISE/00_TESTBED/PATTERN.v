/**************************************************************************/
// Copyright (c) 2024, OASIS Lab
// MODULE: SA
// FILE NAME: PATTERN.v
// VERSRION: 1.0
// DATE: Nov 06, 2024
// AUTHOR: Yen-Ning Tung, NYCU AIG
// CODE TYPE: RTL or Behavioral Level (Verilog)
// DESCRIPTION: 2024 Fall IC Lab / Exersise Lab08 / PATTERN
// MODIFICATION HISTORY:
// Date                 Description
// 
/**************************************************************************/
`ifdef RTL
	`define CYCLE_TIME 50
`endif
`ifdef GATE
	`define CYCLE_TIME 50
`endif

`define PATTERN_NUMBER 10


module PATTERN(
    // Output signals
    clk,
    rst_n,
    cg_en,
    in_valid,
    T,
    in_data,
    w_Q,
    w_K,
    w_V,

    // Input signals
    out_valid,
    out_data
);

output reg clk;
output reg rst_n;
output reg cg_en;
output reg in_valid;
output reg [3:0] T;
output reg signed [7:0] in_data;
output reg signed [7:0] w_Q;
output reg signed [7:0] w_K;
output reg signed [7:0] w_V;

input out_valid;
input signed [63:0] out_data;

//================================================================
// Clock
//================================================================
real CYCLE = `CYCLE_TIME;
always	#(CYCLE/2.0) clk = ~clk;
initial	clk = 0;


//================================================================
// parameters & integer
//================================================================
integer in_T_f;
integer in_data_f;
integer in_QKV_f;
integer output_f;

integer pat;
integer latency;
integer total_latency;
integer total_pattern = `PATTERN_NUMBER;

integer a;
integer T_buf;

//================================================================
// Wire & Reg Declaration
//================================================================
reg signed [47:0] out_data_golden;


initial begin
	// Open files
	in_T_f = $fopen("../00_TESTBED/lab8_pattern/T.txt", "r");
    in_data_f = $fopen("../00_TESTBED/lab8_pattern/data.txt", "r");
    in_QKV_f = $fopen("../00_TESTBED/lab8_pattern/QKV.txt", "r");
    output_f = $fopen("../00_TESTBED/lab8_pattern/output.txt", "r");

	reset_task;
    total_latency = 0;
	for (integer i_pat = 0; i_pat < total_pattern; i_pat = i_pat + 1) begin
		a = $fscanf(in_T_f, "%d", pat);
		a = $fscanf(in_data_f, "%d", pat);
        a = $fscanf(in_QKV_f, "%d", pat);
		a = $fscanf(output_f, "%d", pat);
		$display("\033[0;34mPattern number %d\033[m", pat);
		input_task;
		latency = 0;
		check_ans_task;
		total_latency = total_latency + latency;
		$display("\033[0;32mPass pattern %d latency %d \033[m", pat, latency);
	end
    YOU_PASS_task;
	$finish;
end

task reset_task; begin
	rst_n = 1'b1;
	in_valid = 1'b0;
    cg_en = 1'b0;
	T = 4'bx;
    in_data = 8'bx;
    w_Q = 8'bx;
    w_K = 8'bx;
    w_V = 8'bx;

	force clk = 1'b0;
	#(CYCLE/2); rst_n = 1'b0; // delay a small time and then pull down reset
	#(100); // check if the output is reset
	if ((out_valid !== 0) || (out_data !== 0)) begin
		$display("\033[0;31m************************************************************");
		$display("                    FAIL!                   ");
		$display("*  Output signals should be 0 after initial RESET at %8t *", $time);
        $display("************************************************************\033[m");
		$finish;
	end
	repeat(2) #(CYCLE);
	release clk;
	rst_n = 1'b1; // set reset to high
	#(2);
end
endtask

task input_task; begin
    in_valid = 1'b0;
	T = 4'bx;
    in_data = 8'bx;
    w_Q = 8'bx;
    w_K = 8'bx;
    w_V = 8'bx;

    repeat ($urandom_range(2,4)) @(negedge clk);
    in_valid = 1'b1;
    // ######################### //
	cg_en = 1'b1;

	a = $fscanf(in_T_f, "%d", T);
    a = $fscanf(in_data_f, "%d", in_data);
    a = $fscanf(in_QKV_f, "%d", w_Q);
    T_buf = T;
    @(negedge clk);
    T = 1'bx;

    for (integer i = 1; i < T_buf*8; i = i + 1) begin
        a = $fscanf(in_data_f, "%d", in_data);
        a = $fscanf(in_QKV_f, "%d", w_Q);
        @(negedge clk);
    end
    in_data = 8'bx;
    
    // in case T != 8
    for (integer i = T_buf*8; i < 64; i = i + 1) begin
        a = $fscanf(in_QKV_f, "%d", w_Q);
        @(negedge clk);
    end
    w_Q = 8'bx;

    for (integer i = 0; i < 64; i = i + 1) begin
        a = $fscanf(in_QKV_f, "%d", w_K);
        @(negedge clk);
    end
    w_K = 8'bx;

    for (integer i = 0; i < 64; i = i + 1) begin
        a = $fscanf(in_QKV_f, "%d", w_V);
        @(negedge clk);
    end

    in_valid = 1'b0;
    T = 4'bx;
    in_data = 8'bx;
    w_Q = 8'bx;
    w_K = 8'bx;
    w_V = 8'bx;
end
endtask


task check_ans_task;
	while (out_valid !== 1'b1) begin
        latency = latency + 1;
        if (latency == 2000) begin
            $display("\033[0;31m********************************************************");
            $display("                          FAIL!                           ");
            $display("*  The execution latency is over 2000 cycles. *");
            $display("********************************************************\033[m");
            $finish;
        end
        @(negedge clk);
    end

	// output is ready
    for (integer i = 0; i < 8*T_buf; i = i + 1) begin
        if (out_valid !== 1'b1) begin
            $display("\033[0;31m********************************************************");
            $display("                          FAIL!                           ");
            $display("*  The output should be high for %d cycles at %8t *", 8*T_buf, $time);
            $display("*  You only pull up for %d cycles", i);
            $display("********************************************************\033[m");
            $finish;
        end
        else begin
            a = $fscanf(output_f, "%d", out_data_golden);
            if (out_data_golden !== out_data) begin
                $display("\033[0;31m********************************************************");
                $display("                          FAIL!                           ");
                $display("*  The output is not correct at %8t *", $time);
                $display("The golden value is %d,  your output value is %d", out_data_golden, out_data);
                $display("********************************************************\033[m");
                $finish;
            end
        end
        @(negedge clk);
    end

    if (out_valid !== 1'b0 || out_data !== 1'b0) begin
        $display("\033[0;31m********************************************************");
        $display("                          FAIL!                           ");
        $display("*  The output should be high for %d cycles at %8t *", 8*T_buf, $time);
        $display("********************************************************\033[m");
        $finish;
    end
    @(negedge clk);
endtask

task YOU_PASS_task; begin
    $display("\033[0;33m----------------------------------------------------------------------------------------------------------------------");
    $display("                                                  Congratulations!                                                    ");
    $display("                                           You have passed all patterns!                                               ");
    $display("                                           Your execution cycles = %5d cycles                                          ", total_latency);
    $display("                                           Your clock period = %.1f ns                                                 ", CYCLE);
    $display("                                           Total Latency = %.1f ns                                                    ", total_latency * CYCLE);
    $display("---------------------------------------------------------------------------------------------------------------------- \033[m");
    repeat (2) @(negedge clk);
    $finish;
end 
endtask

/* Check for invalid overlap */
always @(*) begin
    if (in_valid && out_valid)  begin
        $display("\033[0;31m************************************************************");  
        $display("                          FAIL!                           ");    
        $display("*  The out_valid signal cannot overlap with in_valid.   *");
        $display("************************************************************\033[m");
        $finish;            
    end    
end

// out should be reset when out_valid is low
always @(negedge clk) begin
    if (out_valid === 1'b0 && out_data !== 32'b0) begin
        $display("\033[0;31m************************************************************");  
        $display("                          FAIL!                           ");    
        $display("*  out should be low when out_valid is low.   *");
        $display("************************************************************\033[m");
        $finish;            
    end    
end
endmodule