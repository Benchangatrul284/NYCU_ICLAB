//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Fall
//   Lab04 Exercise		: Convolution Neural Network 
//   Author     		: Yu-Chi Lin (a6121461214.st12@nycu.edu.tw)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : CNN.v
//   Module Name : CNN
//   Release version : V1.0 (Release Date: 2024-10)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`define CYCLE_TIME      50.0
`define SEED_NUMBER     28825252
`define PATTERN_NUMBER 3

module PATTERN(
    //Output Port
    clk,
    rst_n,
    in_valid,
    Img,
    Kernel_ch1,
    Kernel_ch2,
	Weight,
    Opt,
    //Input Port
    out_valid,
    out
    );

//---------------------------------------------------------------------
//   PORT DECLARATION          
//---------------------------------------------------------------------
output    reg      clk, rst_n, in_valid;
output  reg [31:0]  Img;
output  reg [31:0]  Kernel_ch1;
output  reg [31:0]  Kernel_ch2;
output  reg [31:0]  Weight;
output  reg    Opt;
input           out_valid;
input   [31:0]  out;

//---------------------------------------------------------------------
//   PARAMETER & INTEGER DECLARATION
//---------------------------------------------------------------------
real CYCLE = `CYCLE_TIME;
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch_type = 0;
parameter inst_arch = 0;


integer image_f;
integer kernel1_f;
integer kernel2_f;
integer opt_f;
integer weight_f;
integer out_f;

integer latency;
integer total_latency;
integer total_pattern = `PATTERN_NUMBER;
//---------------------------------------------------------------------
//   Reg & Wires
//---------------------------------------------------------------------
reg Kernel_ch1_flag;
reg Kernel_ch2_flag;
reg Weight_flag;
reg Opt_flag;
reg [31:0] out_golden;
integer pat;

//================================================================
// clock
//================================================================

always #(CYCLE/2.0) clk = ~clk;
initial	clk = 0;

//---------------------------------------------------------------------
//   Pattern_Design
//---------------------------------------------------------------------

initial begin
        // Open input and output files
        image_f  = $fopen("../00_TESTBED/pattern_txt/Img.txt", "r");
        kernel1_f = $fopen("../00_TESTBED/pattern_txt/Kernel_ch1.txt", "r");
        kernel2_f = $fopen("../00_TESTBED/pattern_txt/Kernel_ch2.txt", "r");
        opt_f = $fopen("../00_TESTBED/pattern_txt/Opt.txt", "r");
        weight_f = $fopen("../00_TESTBED/pattern_txt/Weight.txt", "r");
        out_f = $fopen("../00_TESTBED/pattern_txt/Out.txt", "r");
        // if (image_in == 0) begin
        //     $display("Failed to open input.txt");
        //     $finish;
        // end
        if (out_f == 0) begin
            $display("Failed to open output.txt");
            $finish;
        end
        
        // Initialize signals
        reset_task;
        total_latency = 0;
        // Iterate through each pattern
        for (integer i_pat = 0; i_pat < total_pattern; i_pat = i_pat + 1) begin
            $fscanf(image_f, "%d", pat);
            $fscanf(kernel1_f, "%d", pat);
            $fscanf(kernel2_f, "%d", pat);
            $fscanf(opt_f, "%d", pat);
            $fscanf(weight_f, "%d", pat);
            $fscanf(out_f, "%d", pat);
            $display("Start Pattern %d", pat);
            input_task;
            wait_and_check_out_valid_task;
            $display("Pass Pattern %d", i_pat);
        end
        YOU_PASS_task;
    end


task reset_task; begin
	rst_n = 1'b1;
	in_valid = 1'b0;
	Opt = 1'bx;
    Img = 32'bx;
    Kernel_ch1 = 32'bx;
    Kernel_ch2 = 32'bx;
    Weight = 32'bx;

	force clk = 1'b0;
	#(CYCLE/2); rst_n = 1'b0; // delay a small time and then pull down reset
	#(100); // check if the output is reset
	if ((out_valid !== 0) || (out !== 0)) begin
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


task input_task; begin
	// input start
    // when flag is one, it means the input has been read
    Kernel_ch1_flag = 1'b0;
    Kernel_ch2_flag = 1'b0;
    Weight_flag = 1'b0;
    Opt_flag = 1'b0;
    Img = 32'bx;
    Kernel_ch1 = 32'bx;
    Kernel_ch2 = 32'bx;
    Weight = 32'bx;
    Opt = 1'bx;
	repeat ($urandom_range(1,4)) @(negedge clk);
    in_valid = 1'b1;
    $fscanf(opt_f, "%d", Opt);
    $fscanf(image_f, "%8h", Img);
    $fscanf(kernel1_f, "%8h", Kernel_ch1);
    $fscanf(kernel2_f, "%8h", Kernel_ch2);
    $fscanf(weight_f, "%8h", Weight);
    @(negedge clk);
	for (integer i = 1; i < 12; i = i+1) begin
        $fscanf(image_f, "%8h", Img);
        $fscanf(kernel1_f, "%8h", Kernel_ch1);
        $fscanf(kernel2_f, "%8h", Kernel_ch2);
        $fscanf(weight_f, "%8h", Weight);
        Opt = 1'bx;
        in_valid = 1'b1;
        @(negedge clk);
    end
    for (integer i = 12; i < 24; i = i + 1) begin
        $fscanf(image_f, "%8h", Img);
        $fscanf(weight_f, "%8h", Weight);
        Opt = 1'bx;
        Kernel_ch1 = 32'bx;
        Kernel_ch2 = 32'bx;
        in_valid = 1'b1;
        @(negedge clk);
    end
    for (integer i = 24; i < 75; i = i + 1) begin
        $fscanf(image_f, "%8h", Img);
        Opt = 1'bx;
        Kernel_ch1 = 32'bx;
        Kernel_ch2 = 32'bx;
        Weight = 32'bx;
        in_valid = 1'b1;
        @(negedge clk);
    end
	// $display("=====================================================");
	in_valid = 1'b0;
    Img = 32'bx;
    Kernel_ch1 = 32'bx;
    Kernel_ch2 = 32'bx;
    Weight = 32'bx;
    Opt = 1'bx; 
end
endtask

task wait_and_check_out_valid_task; begin
    latency = 1;
    while (out_valid !== 1'b1) begin
        latency = latency + 1;
        if (latency == 200) begin
            $display("********************************************************");
            $display("                          FAIL!                           ");
            $display("*  The execution latency is over 200 cycles. *");
            $display("********************************************************");
            $finish;
        end
        @(negedge clk);
    end
    total_latency = total_latency + latency;
    check_ans_task; // check the first answer

    @(negedge clk);
    if (out_valid !== 1'b1) begin
        $display("********************************************************");
        $display("                          FAIL!                           ");
        $display("*  Out_valid should be high for 3 cycles, one is given*");
        $display("********************************************************");
        $finish;
    end
    check_ans_task; // check the second answer

    @(negedge clk);
    if (out_valid !== 1'b1) begin
        $display("********************************************************");
        $display("                          FAIL!                           ");
        $display("*  Out_valid should be high for 3 cycles, two is given*");
        $display("********************************************************");
        $finish;
    end
    check_ans_task; // check the third answer

    @(negedge clk);
    if (out_valid !== 1'b0) begin
        $display("********************************************************");
        $display("                          FAIL!                           ");
        $display("*  Out_valid should be high for exactly 3 cycles, four is given*");
        $display("********************************************************");
        $finish;
    end
end
endtask



task check_ans_task; begin
    $fscanf(out_f, "%8h", out_golden);
    if (out === 32'bx) begin
        $display("********************************************************");
        $display("                          FAIL!                           ");
        $display("*  Your output is unknown at %8t *", $time);
        $display("********************************************************");
        $finish;
    end

    if ($bitstoshortreal(out) - $bitstoshortreal(out_golden) > 1e-5 || $bitstoshortreal(out_golden) - $bitstoshortreal(out) > 1e-5) begin
        $display("********************************************************");
        $display("                          FAIL!                           ");
        $display("*  The output is not correct at %8t *", $time);
        $display("* your output is %f, the correct output is %f *", $bitstoshortreal(out), $bitstoshortreal(out_golden));
        $display("********************************************************");
        $finish;
    end
end
endtask

/* Check for invalid overlap */
always @(*) begin
    if (in_valid && out_valid) begin
        $display("************************************************************");  
        $display("                          FAIL!                           ");    
        $display("*  The out_valid signal cannot overlap with in_valid.   *");
        $display("************************************************************");
        $finish;            
    end    
end

// out should be reset when out_valid is low
always @(negedge clk) begin
    if (out_valid === 1'b0 && out !== 1'b0) begin
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
end endtask

endmodule