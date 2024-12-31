`ifdef RTL
	`define CYCLE_TIME_clk1 17.1
	`define CYCLE_TIME_clk2 10.1
`endif
`ifdef GATE
	`define CYCLE_TIME_clk1 47.1
	`define CYCLE_TIME_clk2 10.1
`endif

`define PATTERN_NUMBER 10

module PATTERN(
	clk1,
	clk2,
	rst_n,
	in_valid,
	in_row,
	in_kernel,
	out_valid,
	out_data
);

output reg clk1, clk2;
output reg rst_n;
output reg in_valid;
output reg [17:0] in_row;
output reg [11:0] in_kernel;

input out_valid;
input [7:0] out_data;


//================================================================
// parameters & integer
//================================================================
integer in_row_f;
integer in_kernel_f;
integer output_f;

integer pat;
integer set;
integer latency;
integer total_latency;
integer total_pattern = `PATTERN_NUMBER;
integer a;
integer cnt;

//================================================================
// wire & registers 
//================================================================
reg [7:0] out_data_golden;

//================================================================
// clock
//================================================================
real CYCLE_clk1 = `CYCLE_TIME_clk1;
real CYCLE_clk2 = `CYCLE_TIME_clk2;
always	#(CYCLE_clk1/2.0) clk1 = ~clk1;
initial	clk1 = 0;
always	#(CYCLE_clk2/2.0) clk2 = ~clk2;
initial	clk2 = 0;

//================================================================
// initial
//================================================================
initial begin
	// Open files
	in_row_f = $fopen("../00_TESTBED/lab7_pattern/in_row.txt", "r");
	in_kernel_f = $fopen("../00_TESTBED/lab7_pattern/in_kernel.txt", "r");
	output_f = $fopen("../00_TESTBED/lab7_pattern/output.txt", "r");

	reset_task;
    total_latency = 0;
	
	for (integer i_pat = 0; i_pat < total_pattern; i_pat = i_pat + 1) begin
		a = $fscanf(in_row_f, "%d", pat);
		a = $fscanf(in_kernel_f, "%d", pat);
		a = $fscanf(output_f, "%d", pat);
		$display("\033[0;34mPattern number %d\033[m", pat);
		input_task;
		latency = 1;
		check_ans_task;
		total_latency = total_latency + latency;
		$display("\033[0;32mPass pattern %d latency %d \033[m", pat, latency);
	end

	$finish;
end

//================================================================
// task
//================================================================

task reset_task; begin
	rst_n = 1'b1;
	in_valid = 1'b0;
	in_row = 18'bx;
	in_kernel = 12'bx;

	force clk1 = 1'b0;
	force clk2 = 1'b0;
	#(CYCLE_clk1/2); rst_n = 1'b0; // delay a small time and then pull down reset
	#(100); // check if the output is reset
	if ((out_valid !== 0) || (out_data !== 0)) begin
		$display("\033[0;31m************************************************************");
		$display("                    FAIL!                   ");
		$display("*  Output signals should be 0 after initial RESET at %8t *", $time);
        $display("************************************************************\033[m");
		$finish;
	end
	repeat(2) #(CYCLE_clk1);
	release clk1;
	release clk2;
	rst_n = 1'b1; // set reset to high
	#(2);
end
endtask

task input_task; begin
	in_valid = 1'b0;
	in_row = 18'bx;
	in_kernel = 12'bx;
    repeat ($urandom_range(2,4)) @(negedge clk1);
	for (integer i=0; i<6; i=i+1) begin
		in_valid = 1'b1;
		// in_row
		a = $fscanf(in_row_f, "%d", in_row[17:15]);
		a = $fscanf(in_row_f, "%d", in_row[14:12]);
		a = $fscanf(in_row_f, "%d", in_row[11:9]);
		a = $fscanf(in_row_f, "%d", in_row[8:6]);
		a = $fscanf(in_row_f, "%d", in_row[5:3]);
		a = $fscanf(in_row_f, "%d", in_row[2:0]);
		// in_kernel
		a = $fscanf(in_kernel_f, "%d", in_kernel[11:9]);
		a = $fscanf(in_kernel_f, "%d", in_kernel[8:6]);
		a = $fscanf(in_kernel_f, "%d", in_kernel[5:3]);
		a = $fscanf(in_kernel_f, "%d", in_kernel[2:0]);
    	@(negedge clk1);
    end
    in_valid = 1'b0;
    in_row = 18'bx;
	in_kernel = 12'bx;
end
endtask

task check_ans_task;
	cnt = 0;
	while (cnt < 150) begin
		latency = latency + 1;
		if (out_valid !== 1'b1) begin
			if (latency == 5000) begin
				$display("\033[0;31m********************************************************");
				$display("                          FAIL!                           ");
				$display("*  The execution latency is over 5000 cycles. *");
				$display("********************************************************\033[m");
				$finish;
			end
		end 
		else begin
			cnt = cnt + 1;
			$fscanf(output_f, "%d", out_data_golden);
			if (out_data_golden !== out_data) begin
				$display("\033[0;31m********************************************************");
				$display("                          FAIL!                           ");
				$display("*  The output is not correct at %8t *", $time);
				$display("The golden value is \n%d,  your output value is \n%d", out_data_golden, out_data);
				$display("********************************************************\033[m");
				$finish;
    		end
		end
		@(negedge clk1);
    end
	
    if (out_valid !== 1'b0 || out_data !== 1'b0) begin
        $display("\033[0;31m********************************************************");
        $display("                          FAIL!                           ");
        $display("*  The output should be zero at %8t *", $time);
        $display("The output should be high for 150 cycle");
        $display("********************************************************\033[m");
        $finish;
    end
    @(negedge clk1);
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
always @(negedge clk1) begin
    if (out_valid === 1'b0 && out_data !== 1'b0) begin
        $display("\033[0;31m************************************************************");  
        $display("                          FAIL!                           ");    
        $display("*  out should be low when out_valid is low.   *");
        $display("************************************************************\033[m");
        $finish;            
    end    
end

endmodule