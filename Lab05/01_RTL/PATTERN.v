`ifdef RTL
    `define CYCLE_TIME 20.0
`endif
`ifdef GATE
    `define CYCLE_TIME 20.0
`endif
`ifdef POST
    `define CYCLE_TIME 20.0
`endif

`define SEED_NUMBER     28825252
`define PATTERN_NUMBER 10

module PATTERN(
    // Output signals
    clk,
	rst_n,
	
	in_valid,
	in_valid2,
	
    image,
	template,
	image_size,
	action,

    // Input signals
	out_valid,
	out_value
);

// ========================================
// I/O declaration
// ========================================
// Output
output reg       clk, rst_n;
output reg       in_valid;
output reg       in_valid2;

output reg [7:0] image;
output reg [7:0] template;
output reg [1:0] image_size;
output reg [2:0] action;

// Input
input out_valid;
input out_value;

// ========================================
// clock
// ========================================
real CYCLE = `CYCLE_TIME;
always	#(CYCLE/2.0) clk = ~clk; //clock
initial	clk = 0;

// ========================================
// integer & parameter
// ========================================
integer image_f;
integer image_size_f;
integer template_f;
integer action_f;
integer out_f;

integer pat;
integer set;
integer latency;
integer total_latency;
integer total_pattern = `PATTERN_NUMBER;

integer image_size_real;
integer number_of_action;
integer out_ans_size;
integer out_value_golden;

// ========================================
// wire & reg
// ========================================


//================================================================
// design
//================================================================
initial begin
	// Open input and output files
	image_f = $fopen("../00_TESTBED/lab5_pattern/image.txt", "r");
	image_size_f = $fopen("../00_TESTBED/lab5_pattern/image_size.txt", "r");;
	template_f = $fopen("../00_TESTBED/lab5_pattern/template.txt", "r");;
	action_f = $fopen("../00_TESTBED/lab5_pattern/action.txt", "r");;
	out_f = $fopen("../00_TESTBED/lab5_pattern/output.txt", "r");

	reset_task;
    total_latency = 0;
	
	for (integer i_pat = 0; i_pat < total_pattern; i_pat = i_pat + 1) begin
		// reset_task;
		$fscanf(image_f, "%d", pat);
		$fscanf(template_f, "%d", pat);
		$fscanf(action_f, "%d", pat);
		$fscanf(image_size_f, "%d", pat);
		$fscanf(out_f, "%d", pat);
		$display("pattern number %d", pat);
		input_image_template_task;
		for (integer i_set = 0; i_set < 8; i_set = i_set + 1) begin
			$fscanf(action_f, "%d", set);
			$fscanf(out_f, "%d", set);
			$display("set number %d", set);
			input_action_task;
			check_ans_task;
		end	
	end
	YOU_PASS_task;
	$finish;
end

task reset_task; begin
	rst_n = 1'b1;
	in_valid = 1'b0;
	image = 8'bx;
    template = 8'bx;
	image_size = 2'bx;
	in_valid2 = 1'b0;
	action = 3'bx;

	force clk = 1'b0;
	#(CYCLE/2); rst_n = 1'b0; // delay a small time and then pull down reset
	#(100); // check if the output is reset
	if ((out_valid !== 0) || (out_value !== 0)) begin
		$display("                    FAIL!                   ");
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

task input_image_template_task;
	// input the image, template and image_size
	in_valid = 1'b0;
	image = 8'bx;
    template = 8'bx;
	image_size = 2'bx;
	in_valid2 = 1'b0;
	action = 3'bx;
	repeat ($urandom_range(1,4)) @(negedge clk);
	// first cycle
	in_valid = 1'b1;
    $fscanf(image_size_f, "%d", image_size);
	$display("image_size = %d", image_size);
	$fscanf(image_f, "%d", image);
	$fscanf(template_f, "%d", template);
	@(negedge clk);

	// input the image and template
	if (image_size == 2'b00)
		image_size_real = 4;
	else if (image_size == 2'b01)
		image_size_real = 8;
	else if (image_size == 2'b10)
		image_size_real = 16;
	
	image_size = 2'bx;
	for (integer i_image = 1; i_image < image_size_real*image_size_real * 3 ; i_image = i_image + 1) begin
		$fscanf(image_f, "%d", image);
		if (i_image < 9) begin
			$fscanf(template_f, "%d", template);
		end
		if (i_image == 9)
			template = 8'bx;
		@(negedge clk);
	end
	in_valid = 1'b0;
	image = 8'bx;
	template = 8'bx;
endtask

task input_action_task;
	in_valid2 = 1'b0;
	action = 3'bx;
	repeat ($urandom_range(2,4)) @(negedge clk);
	in_valid2 = 1'b1;
	$fscanf(action_f, "%d", number_of_action);
	$display("number_of_action = %d", number_of_action);
	for (integer i_action = 0; i_action < number_of_action; i_action = i_action + 1) begin
		$fscanf(action_f, "%d", action);
		@(negedge clk);
	end
	in_valid2 = 1'b0;
	action = 3'bx;
endtask

task check_ans_task;
	latency = 1;
	while (out_valid !== 1'b1) begin
        latency = latency + 1;
        if (latency == 5000) begin
            $display("********************************************************");
            $display("                          FAIL!                           ");
            $display("*  The execution latency is over 5000 cycles. *");
            $display("********************************************************");
            $finish;
        end
        @(negedge clk);
    end
	// output is ready
	total_latency = total_latency + latency;
	$fscanf(out_f, "%d", out_ans_size);
	$display("out_ans_size= %d", out_ans_size);
	for (integer i_ans = 0; i_ans < out_ans_size*out_ans_size*20 ; i_ans = i_ans + 1) begin
		$fscanf(out_f, "%d", out_value_golden);
		if (out_value_golden !== out_value) begin
			$display("********************************************************");
			$display("                          FAIL!                           ");
			$display("*  The output is not correct at %8t *", $time);
			$display("The golden value is %d,  your output value is %d", out_value_golden, out_value);
			$display("********************************************************");
			$finish;
		end
		if (out_valid !== 1'b1) begin
			$display("********************************************************");
			$display("                          FAIL!                           ");
			$display("*  The output is not valid at %8t ", $time);
			$display("The output image size should be %d", out_ans_size);
			$display("********************************************************");
			$finish;
		end
		@(negedge clk);
	end
	if (out_valid !== 1'b0) begin
		$display("********************************************************");
		$display("                          FAIL!                           ");
		$display("*  The output is valid at %8t ", $time);
		$display("The output image size should be %d", out_ans_size);
		$display("********************************************************");
		$finish;
	end
endtask

/* Check for invalid overlap */
always @(*) begin
    if (in_valid && out_valid || in_valid2 && out_valid)  begin
        $display("************************************************************");  
        $display("                          FAIL!                           ");    
        $display("*  The out_valid signal cannot overlap with in_valid.   *");
        $display("************************************************************");
        $finish;            
    end    
end

// out should be reset when out_valid is low
always @(negedge clk) begin
    if (out_valid === 1'b0 && out_value !== 1'b0) begin
        $display("************************************************************");  
        $display("                          FAIL!                           ");    
        $display("*  out should be reset when out_valid is low.   *");
        $display("************************************************************");
        $finish;            
    end    
end


task YOU_PASS_task; begin
    $display("----------------------------------------------------------------------------------------------------------------------");
    $display("                                                  Congratulations!                                                    ");
    $display("                                           You have passed all patterns!                                               ");
    $display("                                           Your execution cycles = %5d cycles                                          ", total_latency);
    $display("                                           Your clock period = %.1f ns                                                 ", CYCLE);
    $display("                                           Total Latency = %.1f ns                                                    ", total_latency * CYCLE);
    $display("----------------------------------------------------------------------------------------------------------------------");
    repeat (2) @(negedge clk);
    $finish;
end 
endtask

endmodule