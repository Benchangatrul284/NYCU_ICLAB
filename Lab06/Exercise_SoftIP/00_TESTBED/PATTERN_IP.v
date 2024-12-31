`ifdef RTL
    `define CYCLE_TIME 20.0
`endif
`ifdef GATE
    `define CYCLE_TIME 20.0
`endif

`define SEED_NUMBER     28825252
`define PATTERN_NUMBER 1000

module PATTERN #(parameter IP_BIT = 5)(
    //Output Port
    IN_code,
    //Input Port
	OUT_code
);
// ========================================
// Input & Output
// ========================================

real CYCLE = `CYCLE_TIME;
reg clk;
initial clk = 0;
always #(CYCLE/2.0) clk = ~clk;



output reg [IP_BIT+4-1:0] IN_code;

input [IP_BIT-1:0] OUT_code;

reg [IP_BIT-1:0] OUT_code_golden;

integer input_f;
integer output_f;
integer pat;
integer total_pattern = `PATTERN_NUMBER;

initial begin
	// Open input and output files
	input_f = $fopen("../00_TESTBED/ip_pattern/input.txt", "r");
	output_f = $fopen("../00_TESTBED/ip_pattern/output.txt", "r");

	for (integer i_pat = 0; i_pat < total_pattern; i_pat = i_pat + 1) begin
		$fscanf(input_f, "%d", pat);
        $fscanf(output_f, "%d", pat);
        @(negedge clk);
		$fscanf(input_f, "%b", IN_code);
        @(negedge clk);
        check_ans_task;
        $display("Pass pattern %d", pat);
	end
	YOU_PASS_task;
	$finish;
end

task check_ans_task;
    $fscanf(output_f, "%b", OUT_code_golden);
    if (OUT_code !== OUT_code_golden) begin
        $display("********************************************************");
        $display("                          FAIL!                           ");
        $display("The golden value is %b,  your output value is %b", OUT_code_golden, OUT_code);
        $display("********************************************************");
        $finish;
    end
endtask


task YOU_PASS_task; begin
    $display("----------------------------------------------------------------------------------------------------------------------");
    $display("                                                  Congratulations!                                                    ");
    $display("                                           You have passed all patterns!                                               ");
    $display("----------------------------------------------------------------------------------------------------------------------");
    $finish;
end 
endtask

endmodule