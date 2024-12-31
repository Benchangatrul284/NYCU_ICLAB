`ifdef RTL
    `define CYCLE_TIME 7
`endif
`ifdef GATE
    `define CYCLE_TIME 7
`endif

`define SEED_NUMBER     28825252
`define PATTERN_NUMBER 20000

module PATTERN(
    // Output signals
    clk,
	rst_n,
	in_valid,
    in_data, 
	in_mode,
    // Input signals
    out_valid, 
	out_data
);


// ========================================
// clock
// ========================================

real CYCLE = `CYCLE_TIME;
always	#(CYCLE/2.0) clk = ~clk; //clock
initial	clk = 0;

// ========================================
// Input & Output
// ========================================
output reg clk, rst_n, in_valid;
output reg [8:0] in_mode;
output reg [14:0] in_data;

input out_valid;
input [206:0] out_data;

integer input_f;
integer mode_f;
integer output_f;

integer a;

integer pat;
integer latency;
integer total_latency;
integer total_pattern = `PATTERN_NUMBER;

reg [206:0] out_data_golden;

initial begin
	// Open input and output files
	input_f = $fopen("../00_TESTBED/lab6_pattern/input.txt", "r");
	mode_f = $fopen("../00_TESTBED/lab6_pattern/mode.txt", "r");
    output_f = $fopen("../00_TESTBED/lab6_pattern/output.txt", "r");

	reset_task;
    total_latency = 0;
	
	for (integer i_pat = 0; i_pat < total_pattern; i_pat = i_pat + 1) begin
		a = $fscanf(input_f, "%d", pat);
		a = $fscanf(mode_f, "%d", pat);
		a = $fscanf(output_f, "%d", pat);
		$display("\033[0;34mPattern number %d\033[m", pat);
		input_task;
        latency = 1;
		check_ans_task;
        $display("\033[0;32mPass pattern %d latency %d \033[m", pat, latency);
	end
	YOU_PASS_task;
	$finish;
end


task reset_task; begin
	rst_n = 1'b1;
	in_valid = 1'b0;
	in_data = 15'bx;
	in_mode = 9'bx;

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
	rst_n = 1'b1; // set reset to high
	#(2);
	release clk;
end
endtask

task input_task; begin
    in_valid = 1'b0;
    in_data = 15'bx;
    in_mode = 9'bx;
    repeat ($urandom_range(2,4)) @(negedge clk);
    // first cycle
	in_valid = 1'b1;
    a = $fscanf(mode_f, "%b", in_mode);
    a = $fscanf(input_f, "%b", in_data);
    @(negedge clk);
    in_mode = 9'bx;
    for (integer i = 1; i < 16; i = i + 1) begin
        a = $fscanf(input_f, "%b", in_data);
        @(negedge clk);
    end
    in_valid = 1'b0;
    in_data = 15'bx;
    in_mode = 9'bx;
end
endtask

task check_ans_task;
	while (out_valid !== 1'b1) begin
        latency = latency + 1;
        if (latency == 1000) begin
            $display("\033[0;31m********************************************************");
            $display("                          FAIL!                           ");
            $display("*  The execution latency is over 1000 cycles. *");
            $display("********************************************************\033[m");
            $finish;
        end
        @(negedge clk);
    end
	// output is ready
	total_latency = total_latency + latency;
	$fscanf(output_f, "%b", out_data_golden);
	
    if (out_data_golden !== out_data) begin
        $display("\033[0;31m********************************************************");
        $display("                          FAIL!                           ");
        $display("*  The output is not correct at %8t *", $time);
        $display("The golden value is \n%b,  your output value is \n%b", out_data_golden, out_data);
        $display("********************************************************\033[m");
        $finish;
    end
	@(negedge clk);
    if (out_valid !== 1'b0 || out_data !== 1'b0) begin
        $display("\033[0;31m********************************************************");
        $display("                          FAIL!                           ");
        $display("*  The output should be zero at %8t *", $time);
        $display("The output should only be high for one cycle");
        $display("********************************************************\033[m");
        $finish;
    end
    @(negedge clk);
endtask

// out should be reset when out_valid is low
always @(negedge clk) begin
    if (out_valid === 1'b0 && out_data !== 1'b0) begin
        $display("\033[0;31m************************************************************");  
        $display("                          FAIL!                           ");    
        $display("*  out should be low when out_valid is low.   *");
        $display("************************************************************\033[m");
        $finish;            
    end    
end


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
endmodule