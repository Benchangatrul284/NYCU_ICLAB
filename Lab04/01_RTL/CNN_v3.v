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

module CNN(
    //Input Port
    clk,
    rst_n,
    in_valid,
    Img,
    Kernel_ch1,
    Kernel_ch2,
	Weight,
    Opt,

    //Output Port
    out_valid,
    out
    );


//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------

// IEEE floating point parameter
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch_type = 0;
parameter inst_arch = 0;
parameter inst_faithful_round = 0;

parameter IDLE = 1'b0;
parameter CONV = 1'b1;


input rst_n, clk, in_valid;
input [inst_sig_width+inst_exp_width:0] Img, Kernel_ch1, Kernel_ch2, Weight;
input Opt;

output reg	out_valid;
output reg [inst_sig_width+inst_exp_width:0] out;

parameter FLOATONE = 32'h3F800000;
//---------------------------------------------------------------------
//   Reg & Wires
//---------------------------------------------------------------------
reg [6:0] cnt, cnt_next;
reg  current_state, next_state;
reg [31:0] idata0, idata1, idata2, idata3;

// kernel (C,H,W) = (3,2,2)
reg [31:0] kernel1_ch1 [0:3];
reg [31:0] kernel1_ch2 [0:3];
reg [31:0] kernel1_ch3 [0:3];
reg [31:0] kernel2_ch1 [0:3];
reg [31:0] kernel2_ch2 [0:3];
reg [31:0] kernel2_ch3 [0:3];

// weight (C,H) = (3,8)
reg [31:0] weight_array [0:23];

reg Opt_reg, Opt_next;
reg out_valid_next;
reg [31:0] out_next;

reg [31:0] multiplier_output;

// convolution output (C,H,W) = (2,6,6)
reg [31:0] conv_output_ch1 [0:5][0:5];
reg [31:0] conv_output_ch2 [0:5][0:5];
reg [31:0] conv_output_ch1_next [0:5][0:5];
reg [31:0] conv_output_ch2_next [0:5][0:5];


// multiplication intermediate value
reg [31:0] m0,m0_next;
reg [31:0] m1,m1_next;
reg [31:0] m2,m2_next;
reg [31:0] m3,m3_next;
reg [31:0] m4,m4_next;
reg [31:0] m5,m5_next;
reg [31:0] m6,m6_next;
reg [31:0] m7,m7_next;

// maxpooling intermediate value
reg [31:0] maxpool_output_ch1 [0:1][0:1];
reg [31:0] maxpool_output_ch2 [0:1][0:1];
reg [31:0] maxpool_output_ch1_next [0:1][0:1];
reg [31:0] maxpool_output_ch2_next [0:1][0:1];

// activation function intermediate value
reg [31:0] act1_ch1 [0:1][0:1];
reg [31:0] act2_ch1 [0:1][0:1];
reg [31:0] act1_ch2 [0:1][0:1];
reg [31:0] act2_ch2 [0:1][0:1];
reg [31:0] act1_ch1_next [0:1][0:1];
reg [31:0] act2_ch1_next [0:1][0:1];
reg [31:0] act1_ch2_next [0:1][0:1];
reg [31:0] act2_ch2_next [0:1][0:1];

// mlp intermediate value
reg [31:0] mlp_output [0:2];
reg [31:0] mlp_output_next [0:2];

// softmax intermediate value
reg [31:0] softmax_inter1, softmax_inter2, softmax_inter3, softmax_inter4;
reg [31:0] softmax_inter1_next, softmax_inter2_next, softmax_inter3_next, softmax_inter4_next;
//---------------------------------------------------------------------
// IPs
//---------------------------------------------------------------------

// DW_fp_mult
reg [31:0] mul1_a, mul1_b;
reg [31:0] mul2_a, mul2_b;
reg [31:0] mul3_a, mul3_b;
reg [31:0] mul4_a, mul4_b;
reg [31:0] mul5_a, mul5_b;
reg [31:0] mul6_a, mul6_b;
reg [31:0] mul7_a, mul7_b;
reg [31:0] mul8_a, mul8_b;

// multiplication output
wire [31:0] mul1_out;
wire [31:0] mul2_out;
wire [31:0] mul3_out;
wire [31:0] mul4_out;
wire [31:0] mul5_out;
wire [31:0] mul6_out;
wire [31:0] mul7_out;
wire [31:0] mul8_out;

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
 MUL1 ( .a(mul1_a), .b(mul1_b), .rnd(3'b000), .z(mul1_out), .status());

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    MUL2 ( .a(mul2_a), .b(mul2_b), .rnd(3'b000), .z(mul2_out), .status());

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    MUL3 ( .a(mul3_a), .b(mul3_b), .rnd(3'b000), .z(mul3_out), .status());

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    MUL4 ( .a(mul4_a), .b(mul4_b), .rnd(3'b000), .z(mul4_out), .status());

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    MUL5 ( .a(mul5_a), .b(mul5_b), .rnd(3'b000), .z(mul5_out), .status());

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    MUL6 ( .a(mul6_a), .b(mul6_b), .rnd(3'b000), .z(mul6_out), .status());

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    MUL7 ( .a(mul7_a), .b(mul7_b), .rnd(3'b000), .z(mul7_out), .status());

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    MUL8 ( .a(mul8_a), .b(mul8_b), .rnd(3'b000), .z(mul8_out), .status());


// DW_fp_add
reg [31:0] add21_a, add21_b, add22_a, add22_b;
wire [31:0] add21_out, add22_out;

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type)
    ADD2_1 ( .a(add21_a), .b(add21_b), .rnd(3'b000), .z(add21_out), .status());

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type)
    ADD2_2 ( .a(add22_a), .b(add22_b), .rnd(3'b000), .z(add22_out), .status());

// DW_fp_sum3
reg [31:0] add31_a, add31_b, add31_c;
reg [31:0] add32_a, add32_b, add32_c;
reg [31:0] add33_a, add33_b, add33_c;
reg [31:0] add34_a, add34_b, add34_c;
reg [31:0] add35_a, add35_b, add35_c;
reg [31:0] add36_a, add36_b, add36_c;
reg [31:0] add37_a, add37_b, add37_c;
reg [31:0] add38_a, add38_b, add38_c;

wire [31:0] add31_out, add32_out, add33_out, add34_out;
wire [31:0] add35_out, add36_out, add37_out, add38_out;

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type) 
    ADD3_1 ( .a(add31_a), .b(add31_b), .c(add31_c), .rnd(3'b000), .z(add31_out), .status());

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type) 
    ADD3_2 ( .a(add32_a), .b(add32_b), .c(add32_c), .rnd(3'b000), .z(add32_out), .status());

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type) 
    ADD3_3 ( .a(add33_a), .b(add33_b), .c(add33_c), .rnd(3'b000), .z(add33_out), .status());

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type) 
    ADD3_4 ( .a(add34_a), .b(add34_b), .c(add34_c), .rnd(3'b000), .z(add34_out), .status());

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type)
    ADD3_5 ( .a(add35_a), .b(add35_b), .c(add35_c), .rnd(3'b000), .z(add35_out), .status());

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type)
    ADD3_6 ( .a(add36_a), .b(add36_b), .c(add36_c), .rnd(3'b000), .z(add36_out), .status());

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type)
    ADD3_7 ( .a(add37_a), .b(add37_b), .c(add37_c), .rnd(3'b000), .z(add37_out), .status());

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type)
    ADD3_8 ( .a(add38_a), .b(add38_b), .c(add38_c), .rnd(3'b000), .z(add38_out), .status());



// DW_fp_cmp
reg [31:0] cmp1_a, cmp1_b, cmp2_a, cmp2_b, cmp3_a, cmp3_b, cmp4_a, cmp4_b;
wire [31:0] cmp1_out, cmp2_out, cmp3_out, cmp4_out;
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    CMP_1 ( .a(cmp1_a), .b(cmp1_b), .zctr(1'b0), .aeqb(),.altb(altb_inst), .agtb(), .unordered(),.z0(), .z1(cmp1_out), .status0(),.status1());
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    CMP_2 ( .a(cmp2_a), .b(cmp2_b), .zctr(1'b0), .aeqb(),.altb(altb_inst), .agtb(), .unordered(),.z0(), .z1(cmp2_out), .status0(),.status1());
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    CMP_3 ( .a(cmp3_a), .b(cmp3_b), .zctr(1'b0), .aeqb(),.altb(altb_inst), .agtb(), .unordered(),.z0(), .z1(cmp3_out), .status0(),.status1());
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    CMP_4 ( .a(cmp4_a), .b(cmp4_b), .zctr(1'b0), .aeqb(),.altb(altb_inst), .agtb(), .unordered(),.z0(), .z1(cmp4_out), .status0(),.status1());

// DW_fp_exp
reg [31:0] exp1_a, exp2_a;
wire [31:0] exp1_out, exp2_out;

DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch)
    EXP_1 (.a(exp1_a),.z(exp1_out),.status());

DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch)
    EXP_2 (.a(exp2_a),.z(exp2_out),.status());

// DW_fp_recip
reg [31:0] rec1_a, rec2_a;
wire [31:0] rec1_out, rec2_out;
DW_fp_recip #(inst_sig_width, inst_exp_width, inst_ieee_compliance,inst_faithful_round) 
    REC_1 (.a(rec1_a),.rnd(3'b000),.z(rec1_out),.status());

DW_fp_recip #(inst_sig_width, inst_exp_width, inst_ieee_compliance,inst_faithful_round) 
    REC_2 (.a(rec2_a),.rnd(3'b000),.z(rec2_out),.status());

//---------------------------------------------------------------------
// Design
//---------------------------------------------------------------------

task pixel_dot_kernel;
    // the pixel is broadcasted to 8 pixels, and then multiplied by the kernel
    // kernel is only a channel with shape (2,2)
    input [31:0] pixel;
    input [31:0] kernel_channel1 [0:3];
    input [31:0] kernel_channel2 [0:3];
    // output [31:0] out0, out1, out2, out3, out4, out5, out6, out7;
    begin
        // $display("pixel_dot_kernel evoked at %d", cnt);
        mul1_a = kernel_channel1[0];
        mul2_a = kernel_channel1[1];
        mul3_a = kernel_channel1[2];
        mul4_a = kernel_channel1[3];
        mul5_a = kernel_channel2[0];
        mul6_a = kernel_channel2[1];
        mul7_a = kernel_channel2[2];
        mul8_a = kernel_channel2[3];

        mul1_b = pixel;
        mul2_b = pixel;
        mul3_b = pixel;
        mul4_b = pixel;
        mul5_b = pixel;
        mul6_b = pixel;
        mul7_b = pixel;
        mul8_b = pixel;

        // // a little bit strange here
        // out0 = mul1_out;
        // out1 = mul2_out;
        // out2 = mul3_out;
        // out3 = mul4_out;
        // out4 = mul5_out;
        // out5 = mul6_out;
        // out6 = mul7_out;
        // out7 = mul8_out;
    end
endtask

task mult8_task;
    input [31:0] mult8_task_input_ch1 [0:1][0:1];
    input [31:0] mult8_task_input_ch2 [0:1][0:1];
    input [31:0] mult8_task_weight [0:7];
    begin
        mul1_a = mult8_task_input_ch1[0][0];
        mul2_a = mult8_task_input_ch1[0][1];
        mul3_a = mult8_task_input_ch1[1][0];
        mul4_a = mult8_task_input_ch1[1][1];
        mul5_a = mult8_task_input_ch2[0][0];
        mul6_a = mult8_task_input_ch2[0][1];
        mul7_a = mult8_task_input_ch2[1][0];
        mul8_a = mult8_task_input_ch2[1][1];

        mul1_b = mult8_task_weight[0];
        mul2_b = mult8_task_weight[1];
        mul3_b = mult8_task_weight[2];
        mul4_b = mult8_task_weight[3];
        mul5_b = mult8_task_weight[4];
        mul6_b = mult8_task_weight[5];
        mul7_b = mult8_task_weight[6];
        mul8_b = mult8_task_weight[7];
    end
endtask

task exp1_nega_task;
    /* calculate the e^(-a) by using EXP_1 */
    input [31:0] exp1_nega_task_input;
    begin
        exp1_a = {!exp1_nega_task_input[31], exp1_nega_task_input[30:0]};
    end
endtask

task exp2_nega_task;
    /* calculate the e^(-a) by using EXP_2 */
    input [31:0] exp2_nega_task_input;
    begin
        exp2_a = {!exp2_nega_task_input[31], exp2_nega_task_input[30:0]};
    end
endtask

task exp1_neg2a_task;
    /* calculate the e^(-2a) by using EXP_1 */
    input [31:0] exp1_neg2a_task_input;
    begin
        exp1_a[31] = !exp1_neg2a_task_input[31];
        exp1_a[30:23] = exp1_neg2a_task_input[30:23] + 1;
        exp1_a[22:0] = exp1_neg2a_task_input[22:0];
    end
endtask

task exp2_neg2a_task;
    /* calculate the e^(-2a) by using EXP_2 */
    input [31:0] exp2_neg2a_task_input;
    begin
        exp2_a[31] = !exp2_neg2a_task_input[31];
        exp2_a[30:23] = exp2_neg2a_task_input[30:23] + 1;
        exp2_a[22:0] = exp2_neg2a_task_input[22:0];
    end
endtask

task exp1_2a_task;
    /* calculate the e^(-2a) by using EXP_1 */
    input [31:0] exp1_neg2a_task_input;
    begin
        exp1_a[31] = exp1_neg2a_task_input[31];
        exp1_a[30:23] = exp1_neg2a_task_input[30:23] + 1;
        exp1_a[22:0] = exp1_neg2a_task_input[22:0];
    end
endtask

task exp2_2a_task;
    /* calculate the e^(-2a) by using EXP_2 */
    input [31:0] exp2_neg2a_task_input;
    begin
        exp2_a[31] = exp2_neg2a_task_input[31];
        exp2_a[30:23] = exp2_neg2a_task_input[30:23] + 1;
        exp2_a[22:0] = exp2_neg2a_task_input[22:0];
    end
endtask


task cmp1_task;
    /* compare 2 numbers by using CMP_1 */
    input [31:0] cmp1_task_input1, cmp1_task_input2;
    begin
        cmp1_a = cmp1_task_input1;
        cmp1_b = cmp1_task_input2;
    end
endtask

task cmp2_task;
    /* compare 2 numbers by using CMP_2 */
    input [31:0] cmp2_task_input1, cmp2_task_input2;
    begin
        cmp2_a = cmp2_task_input1;
        cmp2_b = cmp2_task_input2;
    end
endtask

task cmp3_task;
    /* compare 2 numbers by using CMP_3 */
    input [31:0] cmp3_task_input1, cmp3_task_input2;
    begin
        cmp3_a = cmp3_task_input1;
        cmp3_b = cmp3_task_input2;
    end
endtask

task cmp4_task;
    /* compare 2 numbers by using CMP_4 */
    input [31:0] cmp4_task_input1, cmp4_task_input2;
    begin
        cmp4_a = cmp4_task_input1;
        cmp4_b = cmp4_task_input2;
    end
endtask

task cmp31_task;
    /* compare 3 numbers by using CMP_1 and CMP_2 -> output: cmp2_out*/
    input [31:0] cmp31_task_input1, cmp31_task_input2, cmp31_task_input3;
    begin
        cmp1_a = cmp31_task_input1;
        cmp1_b = cmp31_task_input2;
        cmp2_a = cmp1_out;
        cmp2_b = cmp31_task_input3;
    end
endtask

task cmp32_task;
    /* compare 3 numbers by using CMP_3 and CMP_4 -> output: cmp4_out*/
    input [31:0] cmp32_task_input1, cmp32_task_input2, cmp32_task_input3;
    begin
        cmp3_a = cmp32_task_input1;
        cmp3_b = cmp32_task_input2;
        cmp4_a = cmp3_out;
        cmp4_b = cmp32_task_input3;
    end
endtask


task add21_task;
    /* adds 2 numbers by using ADD2_1 */
    input [31:0] add21_task_input1, add21_task_input2;
    begin
        // $display("add21_task evoked at time %d", cnt);
        add21_a = add21_task_input1;
        add21_b = add21_task_input2;
    end
endtask

task add22_task;
    /* adds 2 numbers by using ADD2_2 */
    input [31:0] add22_task_input1, add22_task_input2;
    begin
        add22_a = add22_task_input1;
        add22_b = add22_task_input2;
    end
endtask



task add31_task;
    /* adds 3 numbers by using ADD3_1 */
    input [31:0] add31_task_input1, add31_task_input2, add31_task_input3;
    begin
        add31_a = add31_task_input1;
        add31_b = add31_task_input2;
        add31_c = add31_task_input3;
    end
endtask

task add32_task;
    /* adds 3 numbers by using ADD3_2 */
    input [31:0] add32_task_input1, add32_task_input2, add32_task_input3;
    begin
        add32_a = add32_task_input1;
        add32_b = add32_task_input2;
        add32_c = add32_task_input3;
    end
endtask

task add33_task;
    /* adds 3 numbers by using ADD3_3 */
    input [31:0] add33_task_input1, add33_task_input2, add33_task_input3;
    begin
        add33_a = add33_task_input1;
        add33_b = add33_task_input2;
        add33_c = add33_task_input3;
    end
endtask

task add34_task;
    /* adds 3 numbers by using ADD3_4 */
    input [31:0] add34_task_input1, add34_task_input2, add34_task_input3;
    begin
        add34_a = add34_task_input1;
        add34_b = add34_task_input2;
        add34_c = add34_task_input3;
    end
endtask

task add35_task;
    /* adds 3 numbers by using ADD3_5 */
    input [31:0] add35_task_input1, add35_task_input2, add35_task_input3;
    begin
        add35_a = add35_task_input1;
        add35_b = add35_task_input2;
        add35_c = add35_task_input3;
    end
endtask

task add36_task;
    /* adds 3 numbers by using ADD3_6 */
    input [31:0] add36_task_input1, add36_task_input2, add36_task_input3;
    begin
        add36_a = add36_task_input1;
        add36_b = add36_task_input2;
        add36_c = add36_task_input3;
    end
endtask

task add37_task;
    /* adds 3 numbers by using ADD3_7 */
    input [31:0] add37_task_input1, add37_task_input2, add37_task_input3;
    begin
        add37_a = add37_task_input1;
        add37_b = add37_task_input2;
        add37_c = add37_task_input3;
    end
endtask

task add38_task;
    /* adds 3 numbers by using ADD3_8 */
    input [31:0] add38_task_input1, add38_task_input2, add38_task_input3;
    begin
        add38_a = add38_task_input1;
        add38_b = add38_task_input2;
        add38_c = add38_task_input3;
    end
endtask

task sub37_task;
    /* subtracts 2 numbers by using ADD3_7 */
    input [31:0] sub37_task_input1, sub37_task_input2, sub37_task_input3;
    begin
        add37_a = sub37_task_input1;
        add37_b[31] = !sub37_task_input2[31];
        add37_b[30:0] = sub37_task_input2[30:0];
        add37_c = sub37_task_input3;
    end
endtask

task sub38_task;
    /* subtracts 2 numbers by using ADD3_8 */
    input [31:0] sub38_task_input1, sub38_task_input2, sub38_task_input3;
    begin
        add38_a = sub38_task_input1;
        add38_b[31] = !sub38_task_input2[31];
        add38_b[30:0] = sub38_task_input2[30:0];
        add38_c = sub38_task_input3;
    end
endtask

task sub21_task;
    /* subtracts 2 numbers by using ADD2_1 */
    input [31:0] sub21_task_input1, sub21_task_input2;
    begin
        add21_a = sub21_task_input1;
        add21_b[31] = !sub21_task_input2[31];
        add21_b[30:0] = sub21_task_input2[30:0];
    end
endtask

task sub22_task;
    /* subtracts 2 numbers by using ADD2_2 */
    input [31:0] sub22_task_input1, sub22_task_input2;
    begin
        add22_a = sub22_task_input1;
        add22_b[31] = !sub22_task_input2[31];
        add22_b[30:0] = sub22_task_input2[30:0];
    end
endtask

task sub36_task;
    /* subtracts 3 numbers by using ADD3_6 */
    input [31:0] sub36_task_input1, sub36_task_input2, sub36_task_input3;
    begin
        add36_a = sub36_task_input1;
        add36_b[31] = !sub36_task_input2[31];
        add36_b[30:0] = sub36_task_input2[30:0];
        add36_c[31] = !sub36_task_input3[31];
        add36_c[30:0] = sub36_task_input3[30:0];
        add36_c = sub36_task_input3;
    end
endtask

task add51_task;
    /* adds 5 numbers by using ADD3_5 and ADD3_6 */
    input [31:0] add51_task_input1, add51_task_input2, add51_task_input3, add51_task_input4, add51_task_input5;
    // output [31:0] add_output;
    begin
        // $display("add51_task evoked at time %d", cnt);
        add35_a = add51_task_input1;
        add35_b = add51_task_input2;
        add35_c = add51_task_input3;

        add36_a = add35_out;
        add36_b = add51_task_input4;
        add36_c = add51_task_input5;
        // add_output = add36_out;
    end
endtask

task add52_task;
    /* adds 5 numbers by using ADD3_7 and ADD3_8 */
    input [31:0] add52_task_input1, add52_task_input2, add52_task_input3, add52_task_input4, add52_task_input5;
    begin
        // $display("add52_task evoked at time %d", cnt);
        add37_a = add52_task_input1;
        add37_b = add52_task_input2;
        add37_c = add52_task_input3;

        add38_a = add37_out;
        add38_b = add52_task_input4;
        add38_c = add52_task_input5;

        // add_output = add38_out;
    end
endtask

task sum8_task;
    /* adds 8 numbers by using ADD3_1, ADD3_2, ADD3_3, ADD2_1 -> add33_out */
    input [31:0] sum8_task_input1, sum8_task_input2, sum8_task_input3, sum8_task_input4,
                 sum8_task_input5, sum8_task_input6, sum8_task_input7, sum8_task_input8;
    begin
        add31_a = sum8_task_input1;
        add31_b = sum8_task_input2;
        add31_c = sum8_task_input3;

        add32_a = sum8_task_input4;
        add32_b = sum8_task_input5;
        add32_c = sum8_task_input6;

        add21_a = sum8_task_input7;
        add21_b = sum8_task_input8;

        add33_a = add31_out;
        add33_b = add32_out;
        add33_c = add21_out;
    end
endtask

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        current_state <= IDLE;
        cnt <= 0;
        out_valid <= 1'b0;
        out <= 0;

        conv_output_ch1[0] <= {0,0,0,0,0,0}; 
        conv_output_ch1[1] <= {0,0,0,0,0,0};
        conv_output_ch1[2] <= {0,0,0,0,0,0};
        conv_output_ch1[3] <= {0,0,0,0,0,0};
        conv_output_ch1[4] <= {0,0,0,0,0,0};
        conv_output_ch1[5] <= {0,0,0,0,0,0};

        conv_output_ch2[0] <= {0,0,0,0,0,0}; 
        conv_output_ch2[1] <= {0,0,0,0,0,0};
        conv_output_ch2[2] <= {0,0,0,0,0,0};
        conv_output_ch2[3] <= {0,0,0,0,0,0};
        conv_output_ch2[4] <= {0,0,0,0,0,0};
        conv_output_ch2[5] <= {0,0,0,0,0,0};

    end
    else begin
        current_state <= next_state;
        cnt <= cnt_next;
        out_valid <= out_valid_next;
        out <= out_next;

        conv_output_ch1 <= conv_output_ch1_next;
        conv_output_ch2 <= conv_output_ch2_next;
    end
end

// shift register for Image
always @(posedge clk) begin
    idata0 <= Img;
    idata1 <= idata0;
    idata2 <= idata1;
    idata3 <= idata2;
end

// input register
always @(posedge clk) begin
    Opt_reg <= Opt_next;
end

// intermediate value
always @(posedge clk) begin
    m0 <= m0_next;
    m1 <= m1_next;
    m2 <= m2_next;
    m3 <= m3_next;
    m4 <= m4_next;
    m5 <= m5_next;
    m6 <= m6_next;
    m7 <= m7_next;
    maxpool_output_ch1 <= maxpool_output_ch1_next;
    maxpool_output_ch2 <= maxpool_output_ch2_next;
    act1_ch1 <= act1_ch1_next;
    act2_ch1 <= act2_ch1_next;
    act1_ch2 <= act1_ch2_next;
    act2_ch2 <= act2_ch2_next;
    mlp_output <= mlp_output_next;
    softmax_inter1 <= softmax_inter1_next;
    softmax_inter2 <= softmax_inter2_next;
    softmax_inter3 <= softmax_inter3_next;
    softmax_inter4 <= softmax_inter4_next;
end

// read weight
always @(posedge clk) begin
    if (cnt < 24) begin
        weight_array[23] <= Weight;
        weight_array[0:22] <= weight_array[1:23];
    end
end

// read kernel and push kernel
always @(posedge clk) begin
    case (cnt)
    0,1,2,3: begin
        kernel1_ch1[3] <= Kernel_ch1;
        kernel1_ch1[0:2] <= kernel1_ch1[1:3];
        kernel2_ch1[3] <= Kernel_ch2;
        kernel2_ch1[0:2] <= kernel2_ch1[1:3];
    end
    4,5,6,7: begin
        kernel1_ch2[3] <= Kernel_ch1;
        kernel1_ch2[0:2] <= kernel1_ch2[1:3];
        kernel2_ch2[3] <= Kernel_ch2;
        kernel2_ch2[0:2] <= kernel2_ch2[1:3];
    end
    8,9,10,11: begin
        kernel1_ch3[3] <= Kernel_ch1;
        kernel1_ch3[0:2] <= kernel1_ch3[1:3];
        kernel2_ch3[3] <= Kernel_ch2;
        kernel2_ch3[0:2] <= kernel2_ch3[1:3];
    end
    28: begin
        kernel1_ch1 <= kernel1_ch2;
        kernel2_ch1 <= kernel2_ch2;
    end
    53: begin
        kernel1_ch1 <= kernel1_ch3;
        kernel2_ch1 <= kernel2_ch3;
    end
    endcase
end



always @(*) begin
    // input
    Opt_next = Opt_reg;

    // intermediate
    conv_output_ch1_next = conv_output_ch1;
    conv_output_ch2_next = conv_output_ch2;

    maxpool_output_ch1_next = maxpool_output_ch1;
    maxpool_output_ch2_next = maxpool_output_ch2;

    act1_ch1_next = act1_ch1;
    act2_ch1_next = act2_ch1;
    act1_ch2_next = act1_ch2;
    act2_ch2_next = act2_ch2;

    mlp_output_next = mlp_output;

    softmax_inter1_next = softmax_inter1;
    softmax_inter2_next = softmax_inter2;
    softmax_inter3_next = softmax_inter3;
    softmax_inter4_next = softmax_inter4;

    // m0_next = m0;
    // m1_next = m1;
    // m2_next = m2;
    // m3_next = m3;
    // m4_next = m4;
    // m5_next = m5;
    // m6_next = m6;
    // m7_next = m7;

    m0_next = mul1_out;
    m1_next = mul2_out;
    m2_next = mul3_out;
    m3_next = mul4_out;
    m4_next = mul5_out;
    m5_next = mul6_out;
    m6_next = mul7_out;
    m7_next = mul8_out;

    mul1_a = 0; mul1_b = 0;
    mul2_a = 0; mul2_b = 0;
    mul3_a = 0; mul3_b = 0;
    mul4_a = 0; mul4_b = 0;
    mul5_a = 0; mul5_b = 0;
    mul6_a = 0; mul6_b = 0;
    mul7_a = 0; mul7_b = 0;
    mul8_a = 0; mul8_b = 0;

    add31_a = 0; add31_b = 0; add31_c = 0;
    add32_a = 0; add32_b = 0; add32_c = 0;
    add33_a = 0; add33_b = 0; add33_c = 0;
    add34_a = 0; add34_b = 0; add34_c = 0;
    add35_a = 0; add35_b = 0; add35_c = 0;
    add36_a = 0; add36_b = 0; add36_c = 0;
    add37_a = 0; add37_b = 0; add37_c = 0;
    add38_a = 0; add38_b = 0; add38_c = 0;

    add21_a = 0; add21_b = 0; add22_a = 0; add22_b = 0;

    cmp1_a = 0; cmp1_b = 0; cmp2_a = 0; cmp2_b = 0;
    cmp3_a = 0; cmp3_b = 0; cmp4_a = 0; cmp4_b = 0;

    exp1_a = 0; exp2_a = 0; rec1_a = 0; rec2_a = 0;
    out_next = 0;
    out_valid_next = 0;
    cnt_next = 0;
    next_state = current_state;

    case (current_state)
    IDLE: begin
        if (in_valid) begin
            cnt_next = 1;
            next_state = CONV;
            Opt_next = Opt;
        end
    end
    CONV: begin
        cnt_next = cnt + 1;
        pixel_dot_kernel(idata3, kernel1_ch1, kernel2_ch1);
        case (cnt)
        5,30,55: begin // top-left corner of first channel
            if (Opt_reg == 1'b0) begin
                add51_task(32'b0,32'b0,32'b0,m3,conv_output_ch1[0][0]);
                conv_output_ch1_next[0][0] = add36_out;
                add52_task(32'b0,32'b0,32'b0,m7,conv_output_ch2[0][0]);
                conv_output_ch2_next[0][0] = add38_out;
                add31_task(32'b0,m2,conv_output_ch1[0][1]);
                conv_output_ch1_next[0][1] = add31_out;
                add32_task(32'b0,m6,conv_output_ch2[0][1]);
                conv_output_ch2_next[0][1] = add32_out;
                add33_task(32'b0,m1,conv_output_ch1[1][0]);
                conv_output_ch1_next[1][0] = add33_out;
                add34_task(32'b0,m5,conv_output_ch2[1][0]);
                conv_output_ch2_next[1][0] = add34_out;
                add21_task(m0, conv_output_ch1[1][1]);
                conv_output_ch1_next[1][1] = add21_out;
                add22_task(m4, conv_output_ch2[1][1]);
                conv_output_ch2_next[1][1] = add22_out;
            end 
            else begin
                add51_task(m0,m1,m2,m3,conv_output_ch1[0][0]);
                conv_output_ch1_next[0][0] = add36_out;
                add52_task(m4,m5,m6,m7,conv_output_ch2[0][0]);
                conv_output_ch2_next[0][0] = add38_out;
                add31_task(m0,m2,conv_output_ch1[0][1]);
                conv_output_ch1_next[0][1] = add31_out;
                add32_task(m4,m6,conv_output_ch2[0][1]);
                conv_output_ch2_next[0][1] = add32_out;
                add33_task(m0,m1,conv_output_ch1[1][0]);
                conv_output_ch1_next[1][0] = add33_out;
                add34_task(m4,m5,conv_output_ch2[1][0]);
                conv_output_ch2_next[1][0] = add34_out;
                add21_task(m0, conv_output_ch1[1][1]);
                conv_output_ch1_next[1][1] = add21_out;
                add22_task(m4, conv_output_ch2[1][1]);
                conv_output_ch2_next[1][1] = add22_out;
            end
        end
        6,31,56: begin
            // print_maxpool_task;
            maxpool_output_ch1_next[0][0] = conv_output_ch1[0][0];
            maxpool_output_ch2_next[0][0] = conv_output_ch2[0][0];
            if (Opt_reg == 0) begin
                add31_task(32'b0,m3,conv_output_ch1[0][1]);
                conv_output_ch1_next[0][1] = add31_out;
                add32_task(32'b0,m7,conv_output_ch2[0][1]);
                conv_output_ch2_next[0][1] = add32_out;
                add33_task(32'b0,m2,conv_output_ch1[0][2]);
                conv_output_ch1_next[0][2] = add33_out;
                add34_task(32'b0,m6,conv_output_ch2[0][2]);
                conv_output_ch2_next[0][2] = add34_out;
                add21_task(m1, conv_output_ch1[1][1]);
                conv_output_ch1_next[1][1] = add21_out;
                add22_task(m5, conv_output_ch2[1][1]);
                conv_output_ch2_next[1][1] = add22_out;
                add35_task(m0, conv_output_ch1[1][2], 32'b0);
                conv_output_ch1_next[1][2] = add35_out;
                add36_task(m4, conv_output_ch2[1][2], 32'b0);
                conv_output_ch2_next[1][2] = add36_out;
            end 
            else begin
                add31_task(m1,m3,conv_output_ch1[0][1]);
                conv_output_ch1_next[0][1] = add31_out;
                add32_task(m5,m7,conv_output_ch2[0][1]);
                conv_output_ch2_next[0][1] = add32_out;
                add33_task(m0,m2,conv_output_ch1[0][2]);
                conv_output_ch1_next[0][2] = add33_out;
                add34_task(m4,m6,conv_output_ch2[0][2]);
                conv_output_ch2_next[0][2] = add34_out;
                add21_task(m1, conv_output_ch1[1][1]);
                conv_output_ch1_next[1][1] = add21_out;
                add22_task(m5, conv_output_ch2[1][1]);
                conv_output_ch2_next[1][1] = add22_out;
                add35_task(m0, conv_output_ch1[1][2],32'b0);
                conv_output_ch1_next[1][2] = add35_out;
                add36_task(m4, conv_output_ch2[1][2],32'b0);
                conv_output_ch2_next[1][2] = add36_out;
            end
        end
        7,32,57: begin
            // print_maxpool_task;
            cmp1_task(maxpool_output_ch1[0][0], conv_output_ch1[0][1]);
            maxpool_output_ch1_next[0][0] = cmp1_out;
            cmp2_task(maxpool_output_ch2[0][0], conv_output_ch2[0][1]);
            maxpool_output_ch2_next[0][0] = cmp2_out;
            if (Opt_reg == 0) begin
                add31_task(32'b0,m3,conv_output_ch1[0][2]);
                conv_output_ch1_next[0][2] = add31_out;
                add32_task(32'b0,m7,conv_output_ch2[0][2]);
                conv_output_ch2_next[0][2] = add32_out;
                add33_task(32'b0,m2,conv_output_ch1[0][3]);
                conv_output_ch1_next[0][3] = add33_out;
                add34_task(32'b0,m6,conv_output_ch2[0][3]);
                conv_output_ch2_next[0][3] = add34_out;
                add21_task(m1, conv_output_ch1[1][2]);
                conv_output_ch1_next[1][2] = add21_out;
                add22_task(m5, conv_output_ch2[1][2]);
                conv_output_ch2_next[1][2] = add22_out;
                add35_task(m0, conv_output_ch1[1][3],32'b0);
                conv_output_ch1_next[1][3] = add35_out;
                add36_task(m4, conv_output_ch2[1][3],32'b0);
                conv_output_ch2_next[1][3] = add36_out;
            end 
            else begin
                add31_task(m1,m3,conv_output_ch1[0][2]);
                conv_output_ch1_next[0][2] = add31_out;
                add32_task(m5,m7,conv_output_ch2[0][2]);
                conv_output_ch2_next[0][2] = add32_out;
                add33_task(m0,m2,conv_output_ch1[0][3]);
                conv_output_ch1_next[0][3] = add33_out;
                add34_task(m4,m6,conv_output_ch2[0][3]);
                conv_output_ch2_next[0][3] = add34_out;
                add21_task(m1, conv_output_ch1[1][2]);
                conv_output_ch1_next[1][2] = add21_out;
                add22_task(m5, conv_output_ch2[1][2]);
                conv_output_ch2_next[1][2] = add22_out;
                add35_task(m0, conv_output_ch1[1][3],32'b0);
                conv_output_ch1_next[1][3] = add35_out;
                add36_task(m4, conv_output_ch2[1][3],32'b0);
                conv_output_ch2_next[1][3] = add36_out;
            end
        end
        8,33,58: begin
            // print_maxpool_task;
            cmp1_task(maxpool_output_ch1[0][0], conv_output_ch1[0][2]);
            maxpool_output_ch1_next[0][0] = cmp1_out;
            cmp2_task(maxpool_output_ch2[0][0], conv_output_ch2[0][2]);
            maxpool_output_ch2_next[0][0] = cmp2_out;
            if (Opt_reg == 0) begin
                add31_task(32'b0,m3,conv_output_ch1[0][3]);
                conv_output_ch1_next[0][3] = add31_out;
                add32_task(32'b0,m7,conv_output_ch2[0][3]);
                conv_output_ch2_next[0][3] = add32_out;
                add33_task(32'b0,m2,conv_output_ch1[0][4]);
                conv_output_ch1_next[0][4] = add33_out;
                add34_task(32'b0,m6,conv_output_ch2[0][4]);
                conv_output_ch2_next[0][4] = add34_out;
                add21_task(m1, conv_output_ch1[1][3]);
                conv_output_ch1_next[1][3] = add21_out;
                add22_task(m5, conv_output_ch2[1][3]);
                conv_output_ch2_next[1][3] = add22_out;
                add35_task(m0, conv_output_ch1[1][4],32'b0);
                conv_output_ch1_next[1][4] = add35_out;
                add36_task(m4, conv_output_ch2[1][4],32'b0);
                conv_output_ch2_next[1][4] = add36_out;
            end 
            else begin
                add31_task(m1,m3,conv_output_ch1[0][3]);
                conv_output_ch1_next[0][3] = add31_out;
                add32_task(m5,m7,conv_output_ch2[0][3]);
                conv_output_ch2_next[0][3] = add32_out;
                add33_task(m0,m2,conv_output_ch1[0][4]);
                conv_output_ch1_next[0][4] = add33_out;
                add34_task(m4,m6,conv_output_ch2[0][4]);
                conv_output_ch2_next[0][4] = add34_out;
                add21_task(m1, conv_output_ch1[1][3]);
                conv_output_ch1_next[1][3] = add21_out;
                add22_task(m5, conv_output_ch2[1][3]);
                conv_output_ch2_next[1][3] = add22_out;
                add35_task(m0, conv_output_ch1[1][4],32'b0);
                conv_output_ch1_next[1][4] = add35_out;
                add36_task(m4, conv_output_ch2[1][4],32'b0);
                conv_output_ch2_next[1][4] = add36_out;
            end
        end
        9,34,59: begin
            // print_maxpool_task;
            maxpool_output_ch1_next[0][1] = conv_output_ch1[0][3];
            maxpool_output_ch2_next[0][1] = conv_output_ch2[0][3];
            if (Opt_reg == 0) begin
                add31_task(32'b0,m3,conv_output_ch1[0][4]);
                conv_output_ch1_next[0][4] = add31_out;
                add32_task(32'b0,m7,conv_output_ch2[0][4]);
                conv_output_ch2_next[0][4] = add32_out;
                add51_task(32'b0,32'b0,m2,32'b0,conv_output_ch1[0][5]);
                conv_output_ch1_next[0][5] = add36_out;
                add52_task(32'b0,32'b0,m6,32'b0,conv_output_ch2[0][5]);
                conv_output_ch2_next[0][5] = add38_out;
                add21_task(m1,conv_output_ch1[1][4]);
                conv_output_ch1_next[1][4] = add21_out;
                add22_task(m5,conv_output_ch2[1][4]);
                conv_output_ch2_next[1][4] = add22_out;
                add33_task(m0,32'b0,conv_output_ch1[1][5]);
                conv_output_ch1_next[1][5] = add33_out;
                add34_task(m4,32'b0,conv_output_ch2[1][5]);
                conv_output_ch2_next[1][5] = add34_out;
            end
            else begin
                add31_task(m1,m3,conv_output_ch1[0][4]);
                conv_output_ch1_next[0][4] = add31_out;
                add32_task(m5,m7,conv_output_ch2[0][4]);
                conv_output_ch2_next[0][4] = add32_out;
                add51_task(m0,m1,m2,m3,conv_output_ch1[0][5]);
                conv_output_ch1_next[0][5] = add36_out;
                add52_task(m4,m5,m6,m7,conv_output_ch2[0][5]);
                conv_output_ch2_next[0][5] = add38_out;
                add21_task(m1,conv_output_ch1[1][4]);
                conv_output_ch1_next[1][4] = add21_out;
                add22_task(m5,conv_output_ch2[1][4]);
                conv_output_ch2_next[1][4] = add22_out;
                add33_task(m0,m1,conv_output_ch1[1][5]);
                conv_output_ch1_next[1][5] = add33_out;
                add34_task(m4,m5,conv_output_ch2[1][5]);
                conv_output_ch2_next[1][5] = add34_out;
            end
        end
        10,35,60: begin // second row of first channel
            // print_maxpool_task;
            cmp31_task(maxpool_output_ch1[0][1], conv_output_ch1[0][4], conv_output_ch1[0][5]);
            maxpool_output_ch1_next[0][1] = cmp2_out;
            cmp32_task(maxpool_output_ch2[0][1], conv_output_ch2[0][4], conv_output_ch2[0][5]);
            maxpool_output_ch2_next[0][1] = cmp4_out;
            if (Opt_reg == 0) begin
                add31_task(32'b0,m3,conv_output_ch1[1][0]);
                conv_output_ch1_next[1][0] = add31_out;
                add32_task(32'b0,m7,conv_output_ch2[1][0]);
                conv_output_ch2_next[1][0] = add32_out;
                add21_task(m2, conv_output_ch1[1][1]);
                conv_output_ch1_next[1][1] = add21_out;
                add22_task(m6, conv_output_ch2[1][1]);
                conv_output_ch2_next[1][1] = add22_out;
                add33_task(32'b0,m1,conv_output_ch1[2][0]);
                conv_output_ch1_next[2][0] = add33_out;
                add34_task(32'b0,m5,conv_output_ch2[2][0]);
                conv_output_ch2_next[2][0] = add34_out;
                add35_task(m0, conv_output_ch1[2][1],32'b0);
                conv_output_ch1_next[2][1] = add35_out;
                add36_task(m4, conv_output_ch2[2][1],32'b0);
                conv_output_ch2_next[2][1] = add36_out;
            end
            else begin
                add31_task(m2,m3,conv_output_ch1[1][0]);
                conv_output_ch1_next[1][0] = add31_out;
                add32_task(m6,m7,conv_output_ch2[1][0]);
                conv_output_ch2_next[1][0] = add32_out;
                add21_task(m2, conv_output_ch1[1][1]);
                conv_output_ch1_next[1][1] = add21_out;
                add22_task(m6, conv_output_ch2[1][1]);
                conv_output_ch2_next[1][1] = add22_out;
                add33_task(m0,m1,conv_output_ch1[2][0]);
                conv_output_ch1_next[2][0] = add33_out;
                add34_task(m4,m5,conv_output_ch2[2][0]);
                conv_output_ch2_next[2][0] = add34_out;
                add35_task(m0, conv_output_ch1[2][1],32'b0);
                conv_output_ch1_next[2][1] = add35_out;
                add36_task(m4, conv_output_ch2[2][1],32'b0);
                conv_output_ch2_next[2][1] = add36_out;
            end
        end
        11,36,61: begin
            // print_maxpool_task;
            cmp1_task(maxpool_output_ch1[0][0], conv_output_ch1[1][0]);
            maxpool_output_ch1_next[0][0] = cmp1_out;
            cmp2_task(maxpool_output_ch2[0][0], conv_output_ch2[1][0]);
            maxpool_output_ch2_next[0][0] = cmp2_out;
            add21_task(m3,conv_output_ch1[1][1]);
            conv_output_ch1_next[1][1] = add21_out;
            add22_task(m7,conv_output_ch2[1][1]);
            conv_output_ch2_next[1][1] = add22_out;
            add35_task(m2,conv_output_ch1[1][2],32'b0);
            conv_output_ch1_next[1][2] = add35_out;
            add36_task(m6,conv_output_ch2[1][2],32'b0);
            conv_output_ch2_next[1][2] = add36_out;
            add31_task(m1,conv_output_ch1[2][1], 32'b0);
            conv_output_ch1_next[2][1] = add31_out;
            add32_task(m5,conv_output_ch2[2][1], 32'b0);
            conv_output_ch2_next[2][1] = add32_out;
            add33_task(m0,conv_output_ch1[2][2],32'b0);
            conv_output_ch1_next[2][2] = add33_out;
            add34_task(m4,conv_output_ch2[2][2],32'b0);
            conv_output_ch2_next[2][2] = add34_out;
        end
        12,37,62: begin
            // print_maxpool_task;
            cmp1_task(maxpool_output_ch1[0][0], conv_output_ch1[1][1]);
            maxpool_output_ch1_next[0][0] = cmp1_out;
            cmp2_task(maxpool_output_ch2[0][0], conv_output_ch2[1][1]);
            maxpool_output_ch2_next[0][0] = cmp2_out;
            add21_task(m3,conv_output_ch1[1][2]);
            conv_output_ch1_next[1][2] = add21_out;
            add22_task(m7,conv_output_ch2[1][2]);
            conv_output_ch2_next[1][2] = add22_out;
            add35_task(m2,conv_output_ch1[1][3],32'b0);
            conv_output_ch1_next[1][3] = add35_out;
            add36_task(m6,conv_output_ch2[1][3],32'b0);
            conv_output_ch2_next[1][3] = add36_out;
            add31_task(m1,conv_output_ch1[2][2], 32'b0);
            conv_output_ch1_next[2][2] = add31_out;
            add32_task(m5,conv_output_ch2[2][2], 32'b0);
            conv_output_ch2_next[2][2] = add32_out;
            add33_task(m0,conv_output_ch1[2][3],32'b0);
            conv_output_ch1_next[2][3] = add33_out;
            add34_task(m4,conv_output_ch2[2][3],32'b0);
            conv_output_ch2_next[2][3] = add34_out;
        end
        13,38,63: begin
            // print_maxpool_task;
            cmp1_task(maxpool_output_ch1[0][0], conv_output_ch1[1][2]);
            maxpool_output_ch1_next[0][0] = cmp1_out;
            cmp2_task(maxpool_output_ch2[0][0], conv_output_ch2[1][2]);
            maxpool_output_ch2_next[0][0] = cmp2_out;
            add21_task(m3,conv_output_ch1[1][3]);
            conv_output_ch1_next[1][3] = add21_out;
            add22_task(m7,conv_output_ch2[1][3]);
            conv_output_ch2_next[1][3] = add22_out;
            add35_task(m2,conv_output_ch1[1][4],32'b0);
            conv_output_ch1_next[1][4] = add35_out;
            add36_task(m6,conv_output_ch2[1][4],32'b0);
            conv_output_ch2_next[1][4] = add36_out;
            add31_task(m1,conv_output_ch1[2][3], 32'b0);
            conv_output_ch1_next[2][3] = add31_out;
            add32_task(m5,conv_output_ch2[2][3], 32'b0);
            conv_output_ch2_next[2][3] = add32_out;
            add33_task(m0,conv_output_ch1[2][4],32'b0);
            conv_output_ch1_next[2][4] = add33_out;
            add34_task(m4,conv_output_ch2[2][4],32'b0);
            conv_output_ch2_next[2][4] = add34_out;
        end
        14,39,64: begin
            // print_maxpool_task;
            cmp1_task(maxpool_output_ch1[0][1], conv_output_ch1[1][3]);
            maxpool_output_ch1_next[0][1] = cmp1_out;
            cmp2_task(maxpool_output_ch2[0][1], conv_output_ch2[1][3]);
            maxpool_output_ch2_next[0][1] = cmp2_out;
            if (Opt_reg == 0) begin
                add21_task(m3,conv_output_ch1[1][4]);
                conv_output_ch1_next[1][4] = add21_out;
                add22_task(m7,conv_output_ch2[1][4]);
                conv_output_ch2_next[1][4] = add22_out;
                add31_task(m2,32'b0,conv_output_ch1[1][5]);
                conv_output_ch1_next[1][5] = add31_out;
                add32_task(m6,32'b0,conv_output_ch2[1][5]);
                conv_output_ch2_next[1][5] = add32_out;
                add35_task(m1,conv_output_ch1[2][4],32'b0);
                conv_output_ch1_next[2][4] = add35_out;
                add36_task(m5,conv_output_ch2[2][4],32'b0);
                conv_output_ch2_next[2][4] = add36_out;
                add33_task(m0,32'b0,conv_output_ch1[2][5]);
                conv_output_ch1_next[2][5] = add33_out;
                add34_task(m4,32'b0,conv_output_ch2[2][5]);
                conv_output_ch2_next[2][5] = add34_out;
            end
            else begin
                add21_task(m3,conv_output_ch1[1][4]);
                conv_output_ch1_next[1][4] = add21_out;
                add22_task(m7,conv_output_ch2[1][4]);
                conv_output_ch2_next[1][4] = add22_out;
                add31_task(m2,m3,conv_output_ch1[1][5]);
                conv_output_ch1_next[1][5] = add31_out;
                add32_task(m6,m7,conv_output_ch2[1][5]);
                conv_output_ch2_next[1][5] = add32_out;
                add35_task(m1,conv_output_ch1[2][4],32'b0);
                conv_output_ch1_next[2][4] = add35_out;
                add36_task(m5,conv_output_ch2[2][4],32'b0);
                conv_output_ch2_next[2][4] = add36_out;
                add33_task(m0,m1,conv_output_ch1[2][5]);
                conv_output_ch1_next[2][5] = add33_out;
                add34_task(m4,m5,conv_output_ch2[2][5]);
                conv_output_ch2_next[2][5] = add34_out;
            end
        end
        15,40,65: begin // third row of first channel
            // print_maxpool_task;
            cmp31_task(maxpool_output_ch1[0][1], conv_output_ch1[1][4], conv_output_ch1[1][5]);
            maxpool_output_ch1_next[0][1] = cmp2_out;
            cmp32_task(maxpool_output_ch2[0][1], conv_output_ch2[1][4], conv_output_ch2[1][5]);
            maxpool_output_ch2_next[0][1] = cmp4_out;
            if (Opt_reg == 0) begin
                    add31_task(32'b0,m3,conv_output_ch1[2][0]);
                    conv_output_ch1_next[2][0] = add31_out;
                    add32_task(32'b0,m7,conv_output_ch2[2][0]);
                    conv_output_ch2_next[2][0] = add32_out;
                    add21_task(m2, conv_output_ch1[2][1]);
                    conv_output_ch1_next[2][1] = add21_out;
                    add22_task(m6, conv_output_ch2[2][1]);
                    conv_output_ch2_next[2][1] = add22_out;
                    add33_task(32'b0,m1,conv_output_ch1[3][0]);
                    conv_output_ch1_next[3][0] = add33_out;
                    add34_task(32'b0,m5,conv_output_ch2[3][0]);
                    conv_output_ch2_next[3][0] = add34_out;
                    add35_task(m0, conv_output_ch1[3][1],32'b0);
                    conv_output_ch1_next[3][1] = add35_out;
                    add36_task(m4, conv_output_ch2[3][1],32'b0);
                    conv_output_ch2_next[3][1] = add36_out;
                end
                else begin
                    add31_task(m2,m3,conv_output_ch1[2][0]);
                    conv_output_ch1_next[2][0] = add31_out;
                    add32_task(m6,m7,conv_output_ch2[2][0]);
                    conv_output_ch2_next[2][0] = add32_out;
                    add21_task(m2, conv_output_ch1[2][1]);
                    conv_output_ch1_next[2][1] = add21_out;
                    add22_task(m6, conv_output_ch2[2][1]);
                    conv_output_ch2_next[2][1] = add22_out;
                    add33_task(m0,m1,conv_output_ch1[3][0]);
                    conv_output_ch1_next[3][0] = add33_out;
                    add34_task(m4,m5,conv_output_ch2[3][0]);
                    conv_output_ch2_next[3][0] = add34_out;
                    add35_task(m0, conv_output_ch1[3][1],32'b0);
                    conv_output_ch1_next[3][1] = add35_out;
                    add36_task(m4, conv_output_ch2[3][1],32'b0);
                    conv_output_ch2_next[3][1] = add36_out;
                end
        end
        16,41,66: begin
            // print_maxpool_task;
            cmp1_task(maxpool_output_ch1[0][0], conv_output_ch1[2][0]);
            maxpool_output_ch1_next[0][0] = cmp1_out;
            cmp2_task(maxpool_output_ch2[0][0], conv_output_ch2[2][0]);
            maxpool_output_ch2_next[0][0] = cmp2_out;
            add21_task(m3,conv_output_ch1[2][1]);
            conv_output_ch1_next[2][1] = add21_out;
            add22_task(m7,conv_output_ch2[2][1]);
            conv_output_ch2_next[2][1] = add22_out;
            add35_task(m2,conv_output_ch1[2][2],32'b0);
            conv_output_ch1_next[2][2] = add35_out;
            add36_task(m6,conv_output_ch2[2][2],32'b0);
            conv_output_ch2_next[2][2] = add36_out;
            add31_task(m1,conv_output_ch1[3][1], 32'b0);
            conv_output_ch1_next[3][1] = add31_out;
            add32_task(m5,conv_output_ch2[3][1], 32'b0);
            conv_output_ch2_next[3][1] = add32_out;
            add33_task(m0,conv_output_ch1[3][2],32'b0);
            conv_output_ch1_next[3][2] = add33_out;
            add34_task(m4,conv_output_ch2[3][2],32'b0);
            conv_output_ch2_next[3][2] = add34_out;
        end
        17,42,67: begin
            // print_maxpool_task;
            cmp1_task(maxpool_output_ch1[0][0], conv_output_ch1[2][1]);
            maxpool_output_ch1_next[0][0] = cmp1_out;
            cmp2_task(maxpool_output_ch2[0][0], conv_output_ch2[2][1]);
            maxpool_output_ch2_next[0][0] = cmp2_out;
            add21_task(m3,conv_output_ch1[2][2]);
            conv_output_ch1_next[2][2] = add21_out;
            add22_task(m7,conv_output_ch2[2][2]);
            conv_output_ch2_next[2][2] = add22_out;
            add35_task(m2,conv_output_ch1[2][3],32'b0);
            conv_output_ch1_next[2][3] = add35_out;
            add36_task(m6,conv_output_ch2[2][3],32'b0);
            conv_output_ch2_next[2][3] = add36_out;
            add31_task(m1,conv_output_ch1[3][2], 32'b0);
            conv_output_ch1_next[3][2] = add31_out;
            add32_task(m5,conv_output_ch2[3][2], 32'b0);
            conv_output_ch2_next[3][2] = add32_out;
            add33_task(m0,conv_output_ch1[3][3],32'b0);
            conv_output_ch1_next[3][3] = add33_out;
            add34_task(m4,conv_output_ch2[3][3],32'b0);
            conv_output_ch2_next[3][3] = add34_out;
        end
        18,43,68: begin
            // print_maxpool_task;
            cmp1_task(maxpool_output_ch1[0][0], conv_output_ch1[2][2]);
            maxpool_output_ch1_next[0][0] = cmp1_out;
            cmp2_task(maxpool_output_ch2[0][0], conv_output_ch2[2][2]);
            maxpool_output_ch2_next[0][0] = cmp2_out;
            add21_task(m3,conv_output_ch1[2][3]);
            conv_output_ch1_next[2][3] = add21_out;
            add22_task(m7,conv_output_ch2[2][3]);
            conv_output_ch2_next[2][3] = add22_out;
            add35_task(m2,conv_output_ch1[2][4],32'b0);
            conv_output_ch1_next[2][4] = add35_out;
            add36_task(m6,conv_output_ch2[2][4],32'b0);
            conv_output_ch2_next[2][4] = add36_out;
            add31_task(m1,conv_output_ch1[3][3], 32'b0);
            conv_output_ch1_next[3][3] = add31_out;
            add32_task(m5,conv_output_ch2[3][3], 32'b0);
            conv_output_ch2_next[3][3] = add32_out;
            add33_task(m0,conv_output_ch1[3][4],32'b0);
            conv_output_ch1_next[3][4] = add33_out;
            add34_task(m4,conv_output_ch2[3][4],32'b0);
            conv_output_ch2_next[3][4] = add34_out;
        end
        19,44,69: begin
            // print_maxpool_task;
            cmp1_task(maxpool_output_ch1[0][1], conv_output_ch1[2][3]);
            maxpool_output_ch1_next[0][1] = cmp1_out;
            cmp2_task(maxpool_output_ch2[0][1], conv_output_ch2[2][3]);
            maxpool_output_ch2_next[0][1] = cmp2_out;


            if (Opt_reg == 0) begin
                add21_task(m3,conv_output_ch1[2][4]);
                conv_output_ch1_next[2][4] = add21_out;
                add22_task(m7,conv_output_ch2[2][4]);
                conv_output_ch2_next[2][4] = add22_out;
                add31_task(m2,32'b0,conv_output_ch1[2][5]);
                conv_output_ch1_next[2][5] = add31_out;
                add32_task(m6,32'b0,conv_output_ch2[2][5]);
                conv_output_ch2_next[2][5] = add32_out;
                add35_task(m1,conv_output_ch1[3][4],32'b0);
                conv_output_ch1_next[3][4] = add35_out;
                add36_task(m5,conv_output_ch2[3][4],32'b0);
                conv_output_ch2_next[3][4] = add36_out;
                add33_task(m0,32'b0,conv_output_ch1[3][5]);
                conv_output_ch1_next[3][5] = add33_out;
                add34_task(m4,32'b0,conv_output_ch2[3][5]);
                conv_output_ch2_next[3][5] = add34_out;

                // activation
                exp1_nega_task(maxpool_output_ch1[0][0]);
                act1_ch1_next[0][0] = exp1_out;
                exp2_nega_task(maxpool_output_ch2[0][0]);
                act1_ch2_next[0][0] = exp2_out;
                
            end
            else begin
                add21_task(m3,conv_output_ch1[2][4]);
                conv_output_ch1_next[2][4] = add21_out;
                add22_task(m7,conv_output_ch2[2][4]);
                conv_output_ch2_next[2][4] = add22_out;
                add31_task(m2,m3,conv_output_ch1[2][5]);
                conv_output_ch1_next[2][5] = add31_out;
                add32_task(m6,m7,conv_output_ch2[2][5]);
                conv_output_ch2_next[2][5] = add32_out;
                add35_task(m1,conv_output_ch1[3][4],32'b0);
                conv_output_ch1_next[3][4] = add35_out;
                add36_task(m5,conv_output_ch2[3][4],32'b0);
                conv_output_ch2_next[3][4] = add36_out;
                add33_task(m0,m1,conv_output_ch1[3][5]);
                conv_output_ch1_next[3][5] = add33_out;
                add34_task(m4,m5,conv_output_ch2[3][5]);
                conv_output_ch2_next[3][5] = add34_out;

                // activation
                exp1_neg2a_task(maxpool_output_ch1[0][0]);
                act1_ch1_next[0][0] = exp1_out;
                exp2_neg2a_task(maxpool_output_ch2[0][0]);
                act1_ch2_next[0][0] = exp2_out;
                
            end
        end
        20,45,70: begin // fourth row of first channel
            // print_maxpool_task;
            cmp31_task(maxpool_output_ch1[0][1], conv_output_ch1[2][4], conv_output_ch1[2][5]);
            maxpool_output_ch1_next[0][1] = cmp2_out;
            cmp32_task(maxpool_output_ch2[0][1], conv_output_ch2[2][4], conv_output_ch2[2][5]);
            maxpool_output_ch2_next[0][1] = cmp4_out;

            // activation
            exp1_2a_task(maxpool_output_ch1[0][0]);
            act2_ch1_next[0][0] = exp1_out;
            exp2_2a_task(maxpool_output_ch2[0][0]);
            act2_ch2_next[0][0] = exp2_out;

            if (Opt_reg == 0) begin
                    add31_task(32'b0,m3,conv_output_ch1[3][0]);
                    conv_output_ch1_next[3][0] = add31_out;
                    add32_task(32'b0,m7,conv_output_ch2[3][0]);
                    conv_output_ch2_next[3][0] = add32_out;
                    add21_task(m2, conv_output_ch1[3][1]);
                    conv_output_ch1_next[3][1] = add21_out;
                    add22_task(m6, conv_output_ch2[3][1]);
                    conv_output_ch2_next[3][1] = add22_out;
                    add33_task(32'b0,m1,conv_output_ch1[4][0]);
                    conv_output_ch1_next[4][0] = add33_out;
                    add34_task(32'b0,m5,conv_output_ch2[4][0]);
                    conv_output_ch2_next[4][0] = add34_out;
                    add35_task(m0, conv_output_ch1[4][1],32'b0);
                    conv_output_ch1_next[4][1] = add35_out;
                    add36_task(m4, conv_output_ch2[4][1],32'b0);
                    conv_output_ch2_next[4][1] = add36_out;
                end
                else begin
                    add31_task(m2,m3,conv_output_ch1[3][0]);
                    conv_output_ch1_next[3][0] = add31_out;
                    add32_task(m6,m7,conv_output_ch2[3][0]);
                    conv_output_ch2_next[3][0] = add32_out;
                    add21_task(m2, conv_output_ch1[3][1]);
                    conv_output_ch1_next[3][1] = add21_out;
                    add22_task(m6, conv_output_ch2[3][1]);
                    conv_output_ch2_next[3][1] = add22_out;
                    add33_task(m0,m1,conv_output_ch1[4][0]);
                    conv_output_ch1_next[4][0] = add33_out;
                    add34_task(m4,m5,conv_output_ch2[4][0]);
                    conv_output_ch2_next[4][0] = add34_out;
                    add35_task(m0, conv_output_ch1[4][1],32'b0);
                    conv_output_ch1_next[4][1] = add35_out;
                    add36_task(m4, conv_output_ch2[4][1],32'b0);
                    conv_output_ch2_next[4][1] = add36_out;
                end
        end
        21,46,71: begin
            // print_maxpool_task;
            maxpool_output_ch1_next[1][0] = conv_output_ch1[3][0];
            maxpool_output_ch2_next[1][0] = conv_output_ch2[3][0];
            add21_task(m3,conv_output_ch1[3][1]);
            conv_output_ch1_next[3][1] = add21_out;
            add22_task(m7,conv_output_ch2[3][1]);
            conv_output_ch2_next[3][1] = add22_out;
            add35_task(m2,conv_output_ch1[3][2],32'b0);
            conv_output_ch1_next[3][2] = add35_out;
            add36_task(m6,conv_output_ch2[3][2],32'b0);
            conv_output_ch2_next[3][2] = add36_out;
            add31_task(m1,conv_output_ch1[4][1], 32'b0);
            conv_output_ch1_next[4][1] = add31_out;
            add32_task(m5,conv_output_ch2[4][1], 32'b0);
            conv_output_ch2_next[4][1] = add32_out;
            add33_task(m0,conv_output_ch1[4][2],32'b0);
            conv_output_ch1_next[4][2] = add33_out;
            add34_task(m4,conv_output_ch2[4][2],32'b0);
            conv_output_ch2_next[4][2] = add34_out;

            
            add37_task(act1_ch1[0][0],FLOATONE,32'b0);
            act1_ch1_next[0][0] = add37_out;
            add38_task(act1_ch2[0][0],FLOATONE,32'b0);
            act1_ch2_next[0][0] = add38_out;

            if (Opt_reg == 0) begin
                exp1_nega_task(maxpool_output_ch1[0][1]);
                act1_ch1_next[0][1] = exp1_out;
                exp2_nega_task(maxpool_output_ch2[0][1]);
                act1_ch2_next[0][1] = exp2_out;
            end
            else begin
                exp1_neg2a_task(maxpool_output_ch1[0][1]);
                act1_ch1_next[0][1] = exp1_out;
                exp2_neg2a_task(maxpool_output_ch2[0][1]);
                act1_ch2_next[0][1] = exp2_out;
            end
        end
        22,47,72: begin
            // print_maxpool_task;
            cmp1_task(maxpool_output_ch1[1][0], conv_output_ch1[3][1]);
            maxpool_output_ch1_next[1][0] = cmp1_out;
            cmp2_task(maxpool_output_ch2[1][0], conv_output_ch2[3][1]);
            maxpool_output_ch2_next[1][0] = cmp2_out;

            add21_task(m3,conv_output_ch1[3][2]);
            conv_output_ch1_next[3][2] = add21_out;
            add22_task(m7,conv_output_ch2[3][2]);
            conv_output_ch2_next[3][2] = add22_out;
            add35_task(m2,conv_output_ch1[3][3],32'b0);
            conv_output_ch1_next[3][3] = add35_out;
            add36_task(m6,conv_output_ch2[3][3],32'b0);
            conv_output_ch2_next[3][3] = add36_out;
            add31_task(m1,conv_output_ch1[4][2], 32'b0);
            conv_output_ch1_next[4][2] = add31_out;
            add32_task(m5,conv_output_ch2[4][2], 32'b0);
            conv_output_ch2_next[4][2] = add32_out;
            add33_task(m0,conv_output_ch1[4][3],32'b0);
            conv_output_ch1_next[4][3] = add33_out;
            add34_task(m4,conv_output_ch2[4][3],32'b0);
            conv_output_ch2_next[4][3] = add34_out;

            add37_task(act2_ch1[0][0],FLOATONE,32'b0);
            act2_ch1_next[0][0] = add37_out;
            add38_task(act2_ch2[0][0],FLOATONE,32'b0);
            act2_ch2_next[0][0] = add38_out;

            exp1_2a_task(maxpool_output_ch1[0][1]);
            act2_ch1_next[0][1] = exp1_out;
            exp2_2a_task(maxpool_output_ch2[0][1]);
            act2_ch2_next[0][1] = exp2_out;
        end
        23,48,73: begin
            // print_maxpool_task;
            cmp1_task(maxpool_output_ch1[1][0], conv_output_ch1[3][2]);
            maxpool_output_ch1_next[1][0] = cmp1_out;
            cmp2_task(maxpool_output_ch2[1][0], conv_output_ch2[3][2]);
            maxpool_output_ch2_next[1][0] = cmp2_out;
            add21_task(m3,conv_output_ch1[3][3]);
            conv_output_ch1_next[3][3] = add21_out;
            add22_task(m7,conv_output_ch2[3][3]);
            conv_output_ch2_next[3][3] = add22_out;
            add35_task(m2,conv_output_ch1[3][4],32'b0);
            conv_output_ch1_next[3][4] = add35_out;
            add36_task(m6,conv_output_ch2[3][4],32'b0);
            conv_output_ch2_next[3][4] = add36_out;
            add31_task(m1,conv_output_ch1[4][3], 32'b0);
            conv_output_ch1_next[4][3] = add31_out;
            add32_task(m5,conv_output_ch2[4][3], 32'b0);
            conv_output_ch2_next[4][3] = add32_out;
            add33_task(m0,conv_output_ch1[4][4],32'b0);
            conv_output_ch1_next[4][4] = add33_out;
            add34_task(m4,conv_output_ch2[4][4],32'b0);
            conv_output_ch2_next[4][4] = add34_out;

            rec1_a = act1_ch1[0][0];
            act1_ch1_next[0][0] = rec1_out;
            rec2_a = act1_ch2[0][0];
            act1_ch2_next[0][0] = rec2_out;

            add37_task(act1_ch1[0][1],FLOATONE,32'b0);
            act1_ch1_next[0][1] = add37_out;
            add38_task(act1_ch2[0][1],FLOATONE,32'b0);
            act1_ch2_next[0][1] = add38_out;
        end
        24,49,74: begin
            // print_maxpool_task;
            maxpool_output_ch1_next[1][1] = conv_output_ch1[3][3];
            maxpool_output_ch2_next[1][1] = conv_output_ch2[3][3];
            if (Opt_reg == 0) begin
                add21_task(m3,conv_output_ch1[3][4]);
                conv_output_ch1_next[3][4] = add21_out;
                add22_task(m7,conv_output_ch2[3][4]);
                conv_output_ch2_next[3][4] = add22_out;
                add31_task(m2,32'b0,conv_output_ch1[3][5]);
                conv_output_ch1_next[3][5] = add31_out;
                add32_task(m6,32'b0,conv_output_ch2[3][5]);
                conv_output_ch2_next[3][5] = add32_out;
                add35_task(m1,conv_output_ch1[4][4],32'b0);
                conv_output_ch1_next[4][4] = add35_out;
                add36_task(m5,conv_output_ch2[4][4],32'b0);
                conv_output_ch2_next[4][4] = add36_out;
                add33_task(m0,32'b0,conv_output_ch1[4][5]);
                conv_output_ch1_next[4][5] = add33_out;
                add34_task(m4,32'b0,conv_output_ch2[4][5]);
                conv_output_ch2_next[4][5] = add34_out;
            end
            else begin
                add21_task(m3,conv_output_ch1[3][4]);
                conv_output_ch1_next[3][4] = add21_out;
                add22_task(m7,conv_output_ch2[3][4]);
                conv_output_ch2_next[3][4] = add22_out;
                add31_task(m2,m3,conv_output_ch1[3][5]);
                conv_output_ch1_next[3][5] = add31_out;
                add32_task(m6,m7,conv_output_ch2[3][5]);
                conv_output_ch2_next[3][5] = add32_out;
                add35_task(m1,conv_output_ch1[4][4],32'b0);
                conv_output_ch1_next[4][4] = add35_out;
                add36_task(m5,conv_output_ch2[4][4],32'b0);
                conv_output_ch2_next[4][4] = add36_out;
                add33_task(m0,m1,conv_output_ch1[4][5]);
                conv_output_ch1_next[4][5] = add33_out;
                add34_task(m4,m5,conv_output_ch2[4][5]);
                conv_output_ch2_next[4][5] = add34_out;
            end

            rec1_a = act2_ch1[0][0];
            act2_ch1_next[0][0] = rec1_out;
            rec2_a = act2_ch2[0][0];
            act2_ch2_next[0][0] = rec2_out;

            add37_task(act2_ch1[0][1],FLOATONE,32'b0);
            act2_ch1_next[0][1] = add37_out;
            add38_task(act2_ch2[0][1],FLOATONE,32'b0);
            act2_ch2_next[0][1] = add38_out;
        end
        25,50,75: begin // fifth row of first channel
            // print_maxpool_task;
            cmp31_task(maxpool_output_ch1[1][1], conv_output_ch1[3][4], conv_output_ch1[3][5]);
            maxpool_output_ch1_next[1][1] = cmp2_out;
            cmp32_task(maxpool_output_ch2[1][1], conv_output_ch2[3][4], conv_output_ch2[3][5]);
            maxpool_output_ch2_next[1][1] = cmp4_out;
            if (Opt_reg == 0) begin
                add31_task(32'b0,m3,conv_output_ch1[4][0]);
                conv_output_ch1_next[4][0] = add31_out;
                add32_task(32'b0,m7,conv_output_ch2[4][0]);
                conv_output_ch2_next[4][0] = add32_out;
                add21_task(m2,conv_output_ch1[4][1]);
                conv_output_ch1_next[4][1] = add21_out;
                add22_task(m6,conv_output_ch2[4][1]);
                conv_output_ch2_next[4][1] = add22_out;
                add51_task(32'b0,m1,32'b0,32'b0,conv_output_ch1[5][0]);
                conv_output_ch1_next[5][0] = add36_out;
                add52_task(32'b0,m5,32'b0,32'b0,conv_output_ch2[5][0]);
                conv_output_ch2_next[5][0] = add38_out;
                add33_task(m0,32'b0,conv_output_ch1[5][1]);
                conv_output_ch1_next[5][1] = add33_out;
                add34_task(m4,32'b0,conv_output_ch2[5][1]);
                conv_output_ch2_next[5][1] = add34_out;
            end
            else begin
                add31_task(m2,m3,conv_output_ch1[4][0]);
                conv_output_ch1_next[4][0] = add31_out;
                add32_task(m6,m7,conv_output_ch2[4][0]);
                conv_output_ch2_next[4][0] = add32_out;
                add21_task(m2,conv_output_ch1[4][1]);
                conv_output_ch1_next[4][1] = add21_out;
                add22_task(m6,conv_output_ch2[4][1]);
                conv_output_ch2_next[4][1] = add22_out;
                add51_task(m0,m1,m2,m3,conv_output_ch1[5][0]);
                conv_output_ch1_next[5][0] = add36_out;
                add52_task(m4,m5,m6,m7,conv_output_ch2[5][0]);
                conv_output_ch2_next[5][0] = add38_out;
                add33_task(m0,m2,conv_output_ch1[5][1]);
                conv_output_ch1_next[5][1] = add33_out;
                add34_task(m4,m6,conv_output_ch2[5][1]);
                conv_output_ch2_next[5][1] = add34_out;
            end

            // act[0][0] stall
            rec1_a = act1_ch1[0][1];
            act1_ch1_next[0][1] = rec1_out;
            rec2_a = act1_ch2[0][1];
            act1_ch2_next[0][1] = rec2_out;
        end
        26,51,76: begin
            // print_maxpool_task;
            cmp31_task(maxpool_output_ch1[1][0], conv_output_ch1[4][0], conv_output_ch1[5][0]);
            maxpool_output_ch1_next[1][0] = cmp2_out;
            cmp32_task(maxpool_output_ch2[1][0], conv_output_ch2[4][0], conv_output_ch2[5][0]);
            maxpool_output_ch2_next[1][0] = cmp4_out;

            rec1_a = act2_ch1[0][1];
            act2_ch1_next[0][1] = rec1_out;
            rec2_a = act2_ch2[0][1];
            act2_ch2_next[0][1] = rec2_out;

            if (Opt_reg == 0) begin
                add21_task(m3,conv_output_ch1[4][1]);
                conv_output_ch1_next[4][1] = add21_out;
                add22_task(m7,conv_output_ch2[4][1]);
                conv_output_ch2_next[4][1] = add22_out;
                add35_task(m2,conv_output_ch1[4][2],32'b0);
                conv_output_ch1_next[4][2] = add35_out;
                add36_task(m6,conv_output_ch2[4][2],32'b0);
                conv_output_ch2_next[4][2] = add36_out;
                add31_task(m1,32'b0,conv_output_ch1[5][1]);
                conv_output_ch1_next[5][1] = add31_out;
                add32_task(m5,32'b0,conv_output_ch2[5][1]);
                conv_output_ch2_next[5][1] = add32_out;
                add33_task(m0,32'b0,conv_output_ch1[5][2]);
                conv_output_ch1_next[5][2] = add33_out;
                add34_task(m4,32'b0,conv_output_ch2[5][2]);
                conv_output_ch2_next[5][2] = add34_out;
                
            end 
            else begin
                add21_task(m3,conv_output_ch1[4][1]);
                conv_output_ch1_next[4][1] = add21_out;
                add22_task(m7,conv_output_ch2[4][1]);
                conv_output_ch2_next[4][1] = add22_out;
                add35_task(m2,conv_output_ch1[4][2],32'b0);
                conv_output_ch1_next[4][2] = add35_out;
                add36_task(m6,conv_output_ch2[4][2],32'b0);
                conv_output_ch2_next[4][2] = add36_out;
                add31_task(m1,m3,conv_output_ch1[5][1]);
                conv_output_ch1_next[5][1] = add31_out;
                add32_task(m5,m7,conv_output_ch2[5][1]);
                conv_output_ch2_next[5][1] = add32_out;
                add33_task(m0,m2,conv_output_ch1[5][2]);
                conv_output_ch1_next[5][2] = add33_out;
                add34_task(m4,m6,conv_output_ch2[5][2]);
                conv_output_ch2_next[5][2] = add34_out;
            
                sub37_task(act1_ch1[0][0], act2_ch1[0][0],32'b0);
                act1_ch1_next[0][0] = add37_out;
                sub38_task(act1_ch2[0][0], act2_ch2[0][0],32'b0);
                act1_ch2_next[0][0] = add38_out;
            end
            
            
        end
        27,52,77: begin
            // print_maxpool_task;
            cmp31_task(maxpool_output_ch1[1][0], conv_output_ch1[4][1], conv_output_ch1[5][1]);
            maxpool_output_ch1_next[1][0] = cmp2_out;
            cmp32_task(maxpool_output_ch2[1][0], conv_output_ch2[4][1], conv_output_ch2[5][1]);
            maxpool_output_ch2_next[1][0] = cmp4_out;
            if (Opt_reg == 0) begin
                add21_task(m3,conv_output_ch1[4][2]);
                conv_output_ch1_next[4][2] = add21_out;
                add22_task(m7,conv_output_ch2[4][2]);
                conv_output_ch2_next[4][2] = add22_out;
                add35_task(m2,conv_output_ch1[4][3],32'b0);
                conv_output_ch1_next[4][3] = add35_out;
                add36_task(m6,conv_output_ch2[4][3],32'b0);
                conv_output_ch2_next[4][3] = add36_out;
                add31_task(m1,32'b0,conv_output_ch1[5][2]);
                conv_output_ch1_next[5][2] = add31_out;
                add32_task(m5,32'b0,conv_output_ch2[5][2]);
                conv_output_ch2_next[5][2] = add32_out;
                add33_task(m0,32'b0,conv_output_ch1[5][3]);
                conv_output_ch1_next[5][3] = add33_out;
                add34_task(m4,32'b0,conv_output_ch2[5][3]);
                conv_output_ch2_next[5][3] = add34_out;
            end 
            else begin
                add21_task(m3,conv_output_ch1[4][2]);
                conv_output_ch1_next[4][2] = add21_out;
                add22_task(m7,conv_output_ch2[4][2]);
                conv_output_ch2_next[4][2] = add22_out;
                add35_task(m2,conv_output_ch1[4][3],32'b0);
                conv_output_ch1_next[4][3] = add35_out;
                add36_task(m6,conv_output_ch2[4][3],32'b0);
                conv_output_ch2_next[4][3] = add36_out;
                add31_task(m1,m3,conv_output_ch1[5][2]);
                conv_output_ch1_next[5][2] = add31_out;
                add32_task(m5,m7,conv_output_ch2[5][2]);
                conv_output_ch2_next[5][2] = add32_out;
                add33_task(m0,m2,conv_output_ch1[5][3]);
                conv_output_ch1_next[5][3] = add33_out;
                add34_task(m4,m6,conv_output_ch2[5][3]);
                conv_output_ch2_next[5][3] = add34_out;

                sub37_task(act1_ch1[0][1], act2_ch1[0][1],32'b0);
                act1_ch1_next[0][1] = add37_out;
                sub38_task(act1_ch2[0][1], act2_ch2[0][1],32'b0);
                act1_ch2_next[0][1] = add38_out;
            end
        end
        28,53,78: begin
            // print_maxpool_task;
            cmp31_task(maxpool_output_ch1[1][0], conv_output_ch1[4][2], conv_output_ch1[5][2]);
            maxpool_output_ch1_next[1][0] = cmp2_out;
            cmp32_task(maxpool_output_ch2[1][0], conv_output_ch2[4][2], conv_output_ch2[5][2]);
            maxpool_output_ch2_next[1][0] = cmp4_out;
            if (Opt_reg == 0) begin
                add21_task(m3,conv_output_ch1[4][3]);
                conv_output_ch1_next[4][3] = add21_out;
                add22_task(m7,conv_output_ch2[4][3]);
                conv_output_ch2_next[4][3] = add22_out;
                add35_task(m2,conv_output_ch1[4][4],32'b0);
                conv_output_ch1_next[4][4] = add35_out;
                add36_task(m6,conv_output_ch2[4][4],32'b0);
                conv_output_ch2_next[4][4] = add36_out;
                add31_task(m1,32'b0,conv_output_ch1[5][3]);
                conv_output_ch1_next[5][3] = add31_out;
                add32_task(m5,32'b0,conv_output_ch2[5][3]);
                conv_output_ch2_next[5][3] = add32_out;
                add33_task(m0,32'b0,conv_output_ch1[5][4]);
                conv_output_ch1_next[5][4] = add33_out;
                add34_task(m4,32'b0,conv_output_ch2[5][4]);
                conv_output_ch2_next[5][4] = add34_out;
            end 
            else begin
                add21_task(m3,conv_output_ch1[4][3]);
                conv_output_ch1_next[4][3] = add21_out;
                add22_task(m7,conv_output_ch2[4][3]);
                conv_output_ch2_next[4][3] = add22_out;
                add35_task(m2,conv_output_ch1[4][4],32'b0);
                conv_output_ch1_next[4][4] = add35_out;
                add36_task(m6,conv_output_ch2[4][4],32'b0);
                conv_output_ch2_next[4][4] = add36_out;
                add31_task(m1,m3,conv_output_ch1[5][3]);
                conv_output_ch1_next[5][3] = add31_out;
                add32_task(m5,m7,conv_output_ch2[5][3]);
                conv_output_ch2_next[5][3] = add32_out;
                add33_task(m0,m2,conv_output_ch1[5][4]);
                conv_output_ch1_next[5][4] = add33_out;
                add34_task(m4,m6,conv_output_ch2[5][4]);
                conv_output_ch2_next[5][4] = add34_out;
            end
        end
        29,54,79: begin
            // print_maxpool_task;
            cmp31_task(maxpool_output_ch1[1][1], conv_output_ch1[4][3], conv_output_ch1[5][3]);
            maxpool_output_ch1_next[1][1] = cmp2_out;
            cmp32_task(maxpool_output_ch2[1][1], conv_output_ch2[4][3], conv_output_ch2[5][3]);
            maxpool_output_ch2_next[1][1] = cmp4_out;
            if (Opt_reg == 0) begin
                add21_task(m3,conv_output_ch1[4][4]);
                conv_output_ch1_next[4][4] = add21_out;
                add22_task(m7,conv_output_ch2[4][4]);
                conv_output_ch2_next[4][4] = add22_out;
                add31_task(m2,32'b0,conv_output_ch1[4][5]);
                conv_output_ch1_next[4][5] = add31_out;
                add32_task(m6,32'b0,conv_output_ch2[4][5]);
                conv_output_ch2_next[4][5] = add32_out;
                add33_task(m1,32'b0,conv_output_ch1[5][4]);
                conv_output_ch1_next[5][4] = add33_out;
                add34_task(m5,32'b0,conv_output_ch2[5][4]);
                conv_output_ch2_next[5][4] = add34_out;
                add51_task(m0,32'b0,32'b0,32'b0,conv_output_ch1[5][5]);
                conv_output_ch1_next[5][5] = add36_out;
                add52_task(m4,32'b0,32'b0,32'b0,conv_output_ch2[5][5]);
                conv_output_ch2_next[5][5] = add38_out;

                exp1_nega_task(maxpool_output_ch1[1][0]);
                act1_ch1_next[1][0] = exp1_out;
                exp2_nega_task(maxpool_output_ch2[1][0]);
                act1_ch2_next[1][0] = exp2_out;
            end
            else begin
                add21_task(m3,conv_output_ch1[4][4]);
                conv_output_ch1_next[4][4] = add21_out;
                add22_task(m7,conv_output_ch2[4][4]);
                conv_output_ch2_next[4][4] = add22_out;
                add31_task(m2,m3,conv_output_ch1[4][5]);
                conv_output_ch1_next[4][5] = add31_out;
                add32_task(m6,m7,conv_output_ch2[4][5]);
                conv_output_ch2_next[4][5] = add32_out;
                add33_task(m1,m3,conv_output_ch1[5][4]);
                conv_output_ch1_next[5][4] = add33_out;
                add34_task(m5,m7,conv_output_ch2[5][4]);
                conv_output_ch2_next[5][4] = add34_out;
                add51_task(m0,m1,m2,m3,conv_output_ch1[5][5]);
                conv_output_ch1_next[5][5] = add36_out;
                add52_task(m4,m5,m6,m7,conv_output_ch2[5][5]);
                conv_output_ch2_next[5][5] = add38_out;

                exp1_neg2a_task(maxpool_output_ch1[1][0]);
                act1_ch1_next[1][0] = exp1_out;
                exp2_neg2a_task(maxpool_output_ch2[1][0]);
                act1_ch2_next[1][0] = exp2_out;
            end
        end
        80: begin
            // print_maxpool_task;
            cmp31_task(maxpool_output_ch1[1][1], conv_output_ch1[4][4], conv_output_ch1[4][5]);
            maxpool_output_ch1_next[1][1] = cmp2_out;
            cmp32_task(maxpool_output_ch2[1][1], conv_output_ch2[4][4], conv_output_ch2[4][5]);
            maxpool_output_ch2_next[1][1] = cmp4_out;

            exp1_2a_task(maxpool_output_ch1[1][0]);
            act2_ch1_next[1][0] = exp1_out;
            exp2_2a_task(maxpool_output_ch2[1][0]);
            act2_ch2_next[1][0] = exp2_out;

            add21_task(act1_ch1[1][0],FLOATONE);
            act1_ch1_next[1][0] = add21_out;
            add22_task(act1_ch2[1][0],FLOATONE);
            act1_ch2_next[1][0] = add22_out;
        end
        81: begin
            // print_maxpool_task;
            cmp31_task(maxpool_output_ch1[1][1], conv_output_ch1[5][4], conv_output_ch1[5][5]);
            maxpool_output_ch1_next[1][1] = cmp2_out;
            cmp32_task(maxpool_output_ch2[1][1], conv_output_ch2[5][4], conv_output_ch2[5][5]);
            maxpool_output_ch2_next[1][1] = cmp4_out;

            add21_task(act2_ch1[1][0],FLOATONE);
            act2_ch1_next[1][0] = add21_out;
            add22_task(act2_ch2[1][0],FLOATONE);
            act2_ch2_next[1][0] = add22_out;

            rec1_a = act1_ch1[1][0];
            act1_ch1_next[1][0] = rec1_out;
            rec2_a = act1_ch2[1][0];
            act1_ch2_next[1][0] = rec2_out;
        end
        82: begin
            rec1_a = act2_ch1[1][0];
            act2_ch1_next[1][0] = rec1_out;
            rec2_a = act2_ch2[1][0];
            act2_ch2_next[1][0] = rec2_out;

            if (Opt_reg == 0) begin
                exp1_nega_task(maxpool_output_ch1[1][1]);
                act1_ch1_next[1][1] = exp1_out;
                exp2_nega_task(maxpool_output_ch2[1][1]);
                act1_ch2_next[1][1] = exp2_out;
            end
            else begin
                exp1_neg2a_task(maxpool_output_ch1[1][1]);
                act1_ch1_next[1][1] = exp1_out;
                exp2_neg2a_task(maxpool_output_ch2[1][1]);
                act1_ch2_next[1][1] = exp2_out;
            end
        end
        83: begin
            add21_task(act1_ch1[1][1],FLOATONE);
            act1_ch1_next[1][1] = add21_out;
            add22_task(act1_ch2[1][1],FLOATONE);
            act1_ch2_next[1][1] = add22_out;

            exp1_2a_task(maxpool_output_ch1[1][1]);
            act2_ch1_next[1][1] = exp1_out;
            exp2_2a_task(maxpool_output_ch2[1][1]);
            act2_ch2_next[1][1] = exp2_out;

            
            if (Opt_reg ==1) begin
                sub37_task(act1_ch1[1][0], act2_ch1[1][0],32'b0);
                act1_ch1_next[1][0] = add37_out;
                sub38_task(act1_ch2[1][0], act2_ch2[1][0],32'b0);
                act1_ch2_next[1][0] = add38_out;
            end
        end
        84: begin
            add21_task(act2_ch1[1][1],FLOATONE);
            act2_ch1_next[1][1] = add21_out;
            add22_task(act2_ch2[1][1],FLOATONE);
            act2_ch2_next[1][1] = add22_out;

            rec1_a = act1_ch1[1][1];
            act1_ch1_next[1][1] = rec1_out;
            rec2_a = act1_ch2[1][1];
            act1_ch2_next[1][1] = rec2_out;
        end
        85: begin
            rec1_a = act2_ch1[1][1];
            act2_ch1_next[1][1] = rec1_out;
            rec2_a = act2_ch2[1][1];
            act2_ch2_next[1][1] = rec2_out;
        end
        86: begin
            if (Opt_reg == 1) begin
                sub37_task(act1_ch1[1][1], act2_ch1[1][1],32'b0);
                act1_ch1_next[1][1] = add37_out;
                sub38_task(act1_ch2[1][1], act2_ch2[1][1],32'b0);
                act1_ch2_next[1][1] = add38_out;
            end
        end
        87: begin
            mult8_task(act1_ch1, act1_ch2, weight_array[0:7]);
        end
        88: begin
            mult8_task(act1_ch1, act1_ch2, weight_array[8:15]);
            sum8_task(m0,m1,m2,m3,m4,m5,m6,m7);
            mlp_output_next[0] = add33_out;
        end
        89: begin
            mult8_task(act1_ch1, act1_ch2, weight_array[16:23]);
            sum8_task(m0,m1,m2,m3,m4,m5,m6,m7);
            mlp_output_next[1] = add33_out;
        end
        90: begin
            sum8_task(m0,m1,m2,m3,m4,m5,m6,m7);
            mlp_output_next[2] = add33_out;
            sub37_task(mlp_output[1], mlp_output[0],32'b0);
            softmax_inter1_next = add37_out;
            sub22_task(mlp_output[0], mlp_output[1]);
            softmax_inter2_next = add22_out;
        end
        91: begin
            exp1_a = softmax_inter1;
            softmax_inter1_next = exp1_out;
            exp2_a = softmax_inter2;
            softmax_inter2_next = exp2_out;
            sub21_task(mlp_output[2], mlp_output[0]);
            softmax_inter3_next = add21_out;
            sub22_task(mlp_output[2], mlp_output[1]);
            softmax_inter4_next = add22_out;
        end
        92: begin
            exp1_a = softmax_inter3;
            softmax_inter3_next = exp1_out;
            exp2_a = softmax_inter4;
            softmax_inter4_next = exp2_out;
        end
        93: begin
            add31_task(softmax_inter1, softmax_inter3, FLOATONE);
            softmax_inter1_next = add31_out;
            add32_task(softmax_inter2, softmax_inter4, FLOATONE);
            softmax_inter2_next = add32_out;
            
        end
        94: begin
            out_valid_next = 1;
            rec1_a = softmax_inter1;
            out_next = rec1_out;
            softmax_inter1_next = rec1_out;
            rec2_a = softmax_inter2;
            softmax_inter2_next = rec2_out;
            out_valid_next = 1;
        end
        95: begin
            out_valid_next = 1;
            out_next = softmax_inter2;
            add21_task(softmax_inter1, softmax_inter2);
            softmax_inter3_next = add21_out;
        end
        96: begin
            out_valid_next = 1;
            sub21_task(FLOATONE, softmax_inter3);
            out_next = add21_out;
        end
        97: begin
            next_state = IDLE;
            cnt_next = 0;
            conv_output_ch1_next[0] = {0,0,0,0,0,0};
            conv_output_ch1_next[1] = {0,0,0,0,0,0};
            conv_output_ch1_next[2] = {0,0,0,0,0,0};
            conv_output_ch1_next[3] = {0,0,0,0,0,0};
            conv_output_ch1_next[4] = {0,0,0,0,0,0};
            conv_output_ch1_next[5] = {0,0,0,0,0,0};
            conv_output_ch2_next[0] = {0,0,0,0,0,0};
            conv_output_ch2_next[1] = {0,0,0,0,0,0};
            conv_output_ch2_next[2] = {0,0,0,0,0,0};
            conv_output_ch2_next[3] = {0,0,0,0,0,0};
            conv_output_ch2_next[4] = {0,0,0,0,0,0};
            conv_output_ch2_next[5] = {0,0,0,0,0,0};
        end
        endcase
    end
    endcase
end

// synopsys translate_off
task print_feature_map_task;
    $display("Channel 1");
    for (integer i = 0; i < 6; i++) begin
        $display("%f %f %f %f %f %f",
                $bitstoshortreal(conv_output_ch1[i][0]),
                $bitstoshortreal(conv_output_ch1[i][1]),
                $bitstoshortreal(conv_output_ch1[i][2]),
                $bitstoshortreal(conv_output_ch1[i][3]),
                $bitstoshortreal(conv_output_ch1[i][4]),
                $bitstoshortreal(conv_output_ch1[i][5]));
    end
    $display("Channel 2");
    for (integer i = 0; i < 6; i++) begin
        $display("%f %f %f %f %f %f",
                $bitstoshortreal(conv_output_ch2[i][0]),
                $bitstoshortreal(conv_output_ch2[i][1]),
                $bitstoshortreal(conv_output_ch2[i][2]),
                $bitstoshortreal(conv_output_ch2[i][3]),
                $bitstoshortreal(conv_output_ch2[i][4]),
                $bitstoshortreal(conv_output_ch2[i][5]));
    end
endtask

task print_maxpool_task;
    $display("========cnt : %d==========", cnt);
    $display("Channel 1");
    for (integer i = 0; i < 2; i++) begin
        $display("%f %f",
                $bitstoshortreal(maxpool_output_ch1[i][0]),
                $bitstoshortreal(maxpool_output_ch1[i][1]));
    end
    $display("Channel 2");
    for (integer i = 0; i < 2; i++) begin
        $display("%f %f",
                $bitstoshortreal(maxpool_output_ch2[i][0]),
                $bitstoshortreal(maxpool_output_ch2[i][1]));
    end
endtask
// synopsys translate_on

endmodule
