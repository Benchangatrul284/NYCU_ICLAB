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

parameter IDLE = 3'b000;
parameter PREFILL = 3'b001;
parameter CONV = 3'b010;
parameter MAXPOOL = 3'b011;
parameter OUTPUT = 3'b101;

input rst_n, clk, in_valid;
input [inst_sig_width+inst_exp_width:0] Img, Kernel_ch1, Kernel_ch2, Weight;
input Opt;

output reg	out_valid;
output reg [inst_sig_width+inst_exp_width:0] out;


//---------------------------------------------------------------------
//   Reg & Wires
//---------------------------------------------------------------------
reg [9:0] cnt, cnt_next;
reg [2:0] current_state, next_state;
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
reg [31:0] add21_a, add21_b, add22_a, add22_b, add23_a, add23_b, add24_a, add24_b;
wire [31:0] add21_out, add22_out, add23_out, add24_out;

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type)
    ADD2_1 ( .a(add21_a), .b(add21_b), .rnd(3'b000), .z(add21_out), .status());

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type)
    ADD2_2 ( .a(add22_a), .b(add22_b), .rnd(3'b000), .z(add22_out), .status());

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type)
    ADD2_3 ( .a(add23_a), .b(add23_b), .rnd(3'b000), .z(add23_out), .status());

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type)
    ADD2_4 ( .a(add24_a), .b(add24_b), .rnd(3'b000), .z(add24_out), .status());

// DW_fp_sum3
reg [31:0] add31_a, add31_b, add31_c;
reg [31:0] add32_a, add32_b, add32_c;
reg [31:0] add33_a, add33_b, add33_c;
reg [31:0] add34_a, add34_b, add34_c;
wire [31:0] add31_out, add32_out, add33_out, add34_out;

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type) 
    ADD3_1 ( .a(add31_a), .b(add31_b), .c(add31_c), .rnd(3'b000), .z(add31_out), .status());

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type) 
    ADD3_2 ( .a(add32_a), .b(add32_b), .c(add32_c), .rnd(3'b000), .z(add32_out), .status());

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type) 
    ADD3_3 ( .a(add33_a), .b(add33_b), .c(add33_c), .rnd(3'b000), .z(add33_out), .status());

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type) 
    ADD3_4 ( .a(add34_a), .b(add34_b), .c(add34_c), .rnd(3'b000), .z(add34_out), .status());

// DW_fp_sum4
reg [31:0] add41_a, add41_b, add41_c, add41_d;
reg [31:0] add42_a, add42_b, add42_c, add42_d;
wire [31:0] add41_out, add42_out;

DW_fp_sum4 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type) 
    ADD4_1 ( .a(add41_a), .b(add41_b), .c(add41_c), .d(add41_d), .rnd(3'b000), .z(add41_out), .status());

DW_fp_sum4 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type) 
    ADD4_2 ( .a(add42_a), .b(add42_b), .c(add42_c), .d(add42_d), .rnd(3'b000), .z(add42_out), .status());

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

//---------------------------------------------------------------------
// Design
//---------------------------------------------------------------------

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


task pixel_dot_kernel;
    // the pixel is broadcasted to 8 pixels, and then multiplied by the kernel
    // kernel is only a channel with shape (2,2)
    input [31:0] pixel;
    input [31:0] kernel_channel1 [0:3];
    input [31:0] kernel_channel2 [0:3];
    // output [31:0] out0, out1, out2, out3, out4, out5, out6, out7;
    begin
        $display("pixel_dot_kernel evoked at %d", cnt);
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

task add21_task;
    /* adds 2 numbers by using ADD2_1 */
    input [31:0] add21_task_input1, add21_task_input2;
    begin
        $display("add21_task evoked at time %d", cnt);
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

task add23_task;
    /* adds 2 numbers by using ADD2_3 */
    input [31:0] add23_task_input1, add23_task_input2;

    begin
        add23_a = add23_task_input1;
        add23_b = add23_task_input2;

    end
endtask

task add24_task;
    /* adds 2 numbers by using ADD2_4 */
    input [31:0] add24_task_input1, add24_task_input2;
    begin
        add24_a = add24_task_input1;
        add24_b = add24_task_input2;
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
    /* adds 3 numbers by using ADD3_1 */
    input [31:0] add33_task_input1, add33_task_input2, add33_task_input3;
    begin
        add33_a = add33_task_input1;
        add33_b = add33_task_input2;
        add33_c = add33_task_input3;
    end
endtask

task add34_task;
    /* adds 3 numbers by using ADD3_1 */
    input [31:0] add34_task_input1, add34_task_input2, add34_task_input3;
    begin
        add34_a = add34_task_input1;
        add34_b = add34_task_input2;
        add34_c = add34_task_input3;
    end
endtask

task add51_task;
    /* adds 5 numbers by using ADD4_1 and ADD2_1 */
    input [31:0] add51_task_input1, add51_task_input2, add51_task_input3, add51_task_input4, add51_task_input5;
    // output [31:0] add_output;
    begin
        $display("add51_task evoked at time %d", cnt);
        add41_a = add51_task_input1;
        add41_b = add51_task_input2;
        add41_c = add51_task_input3;
        add41_d = add51_task_input4;
        add21_a = add41_out;
        add21_b = add51_task_input5;
        // add_output = add21_out;
    end
endtask

task add52_task;
    /* adds 5 numbers by using ADD4_2 and ADD2_2 */
    input [31:0] add52_task_input1, add52_task_input2, add52_task_input3, add52_task_input4, add52_task_input5;
    begin
        $display("add52_task evoked at time %d", cnt);
        add42_a = add52_task_input1;
        add42_b = add52_task_input2;
        add42_c = add52_task_input3;
        add42_d = add52_task_input4;
        add22_a = add42_out;
        add22_b = add52_task_input5;
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

// multiplication intermediate value for convolution
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
    if (in_valid) begin
        if (cnt == 0 || cnt == 1 || cnt == 2 || cnt == 3) begin
            kernel1_ch1[3] <= Kernel_ch1;
            kernel1_ch1[0:2] <= kernel1_ch1[1:3];
            kernel2_ch1[3] <= Kernel_ch2;
            kernel2_ch1[0:2] <= kernel2_ch1[1:3];
        end
        if (cnt == 4 || cnt == 5 || cnt == 6 || cnt == 7) begin
            kernel1_ch2[3] <= Kernel_ch1;
            kernel1_ch2[0:2] <= kernel1_ch2[1:3];
            kernel2_ch2[3] <= Kernel_ch2;
            kernel2_ch2[0:2] <= kernel2_ch2[1:3];
        end
        if (cnt == 8 || cnt == 9 || cnt == 10 || cnt == 11 ) begin
            kernel1_ch3[3] <= Kernel_ch1;
            kernel1_ch3[0:2] <= kernel1_ch3[1:3];
            kernel2_ch3[3] <= Kernel_ch2;
            kernel2_ch3[0:2] <= kernel2_ch3[1:3];
        end
        if (cnt == 28) begin
            kernel1_ch1 <= kernel1_ch2;
            kernel2_ch1 <= kernel2_ch2;
        end
        if (cnt == 53) begin
            kernel1_ch1 <= kernel1_ch3;
            kernel2_ch1 <= kernel2_ch3;
        end
    end
end

// max pooling intermediate value
always @(posedge clk) begin
    
end

always @(*) begin
    // input
    Opt_next = Opt_reg;

    // intermediate
    conv_output_ch1_next = conv_output_ch1;
    conv_output_ch2_next = conv_output_ch2;
    maxpool_output_ch1_next = maxpool_output_ch1;
    maxpool_output_ch2_next = maxpool_output_ch2;

    m0_next = m0;
    m1_next = m1;
    m2_next = m2;
    m3_next = m3;
    m4_next = m4;
    m5_next = m5;
    m6_next = m6;
    m7_next = m7;

    mul1_a = 0; mul1_b = 0;
    mul2_a = 0; mul2_b = 0;
    mul3_a = 0; mul3_b = 0;
    mul4_a = 0; mul4_b = 0;
    mul5_a = 0; mul5_b = 0;
    mul6_a = 0; mul6_b = 0;
    mul7_a = 0; mul7_b = 0;
    mul8_a = 0; mul8_b = 0;

    add41_a = 0; add41_b = 0; add41_c = 0; add41_d = 0;
    add42_a = 0; add42_b = 0; add42_c = 0; add42_d = 0;

    add31_a = 0; add31_b = 0; add31_c = 0;
    add32_a = 0; add32_b = 0; add32_c = 0;
    add33_a = 0; add33_b = 0; add33_c = 0;
    add34_a = 0; add34_b = 0; add34_c = 0;

    add21_a = 0; add21_b = 0; add22_a = 0; add22_b = 0;
    add23_a = 0; add23_b = 0; add24_a = 0; add24_b = 0;

    cmp1_a = 0; cmp1_b = 0; cmp2_a = 0; cmp2_b = 0;
    cmp3_a = 0; cmp3_b = 0; cmp4_a = 0; cmp4_b = 0;

    out_next = 0;
    out_valid_next = 0;
    cnt_next = cnt;
    next_state = current_state;

    case (current_state)
    IDLE: begin
        if (in_valid) begin
            cnt_next = cnt + 1;
            next_state = CONV;
            Opt_next = Opt;
        end
    end
    CONV: begin
        cnt_next = cnt + 1;
        pixel_dot_kernel(idata3, kernel1_ch1, kernel2_ch1);
        m0_next = mul1_out;
        m1_next = mul2_out;
        m2_next = mul3_out;
        m3_next = mul4_out;
        m4_next = mul5_out;
        m5_next = mul6_out;
        m6_next = mul7_out;
        m7_next = mul8_out;
        case (cnt)
        10'd4: begin
        end
        10'd5,10'd30,10'd55: begin // top-left corner of first channel
            if (Opt_reg == 1'b0) begin
                add51_task(32'b0,32'b0,32'b0,m3,conv_output_ch1[0][0]);
                conv_output_ch1_next[0][0] = add21_out;
                add52_task(32'b0,32'b0,32'b0,m7,conv_output_ch2[0][0]);
                conv_output_ch2_next[0][0] = add22_out;
                add31_task(32'b0,m2,conv_output_ch1[0][1]);
                conv_output_ch1_next[0][1] = add31_out;
                add32_task(32'b0,m6,conv_output_ch2[0][1]);
                conv_output_ch2_next[0][1] = add32_out;
                add33_task(32'b0,m1,conv_output_ch1[1][0]);
                conv_output_ch1_next[1][0] = add33_out;
                add34_task(32'b0,m5,conv_output_ch2[1][0]);
                conv_output_ch2_next[1][0] = add34_out;
                add23_task(m0, conv_output_ch1[1][1]);
                conv_output_ch1_next[1][1] = add23_out;
                add24_task(m4, conv_output_ch2[1][1]);
                conv_output_ch2_next[1][1] = add24_out;
            end 
            else begin
                add51_task(m0,m1,m2,m3,conv_output_ch1[0][0]);
                conv_output_ch1_next[0][0] = add21_out;
                add52_task(m4,m5,m6,m7,conv_output_ch2[0][0]);
                conv_output_ch2_next[0][0] = add22_out;
                add31_task(m0,m2,conv_output_ch1[0][1]);
                conv_output_ch1_next[0][1] = add31_out;
                add32_task(m4,m6,conv_output_ch2[0][1]);
                conv_output_ch2_next[0][1] = add32_out;
                add33_task(m0,m1,conv_output_ch1[1][0]);
                conv_output_ch1_next[1][0] = add33_out;
                add34_task(m4,m5,conv_output_ch2[1][0]);
                conv_output_ch2_next[1][0] = add34_out;
                add23_task(m0, conv_output_ch1[1][1]);
                conv_output_ch1_next[1][1] = add23_out;
                add24_task(m4, conv_output_ch2[1][1]);
                conv_output_ch2_next[1][1] = add24_out;
            end
        end
        10'd6,10'd31,10'd56: begin
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
                add23_task(m0, conv_output_ch1[1][2]);
                conv_output_ch1_next[1][2] = add23_out;
                add24_task(m4, conv_output_ch2[1][2]);
                conv_output_ch2_next[1][2] = add24_out;
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
                add23_task(m0, conv_output_ch1[1][2]);
                conv_output_ch1_next[1][2] = add23_out;
                add24_task(m4, conv_output_ch2[1][2]);
                conv_output_ch2_next[1][2] = add24_out;
            end
        end
        10'd7,10'd32,10'd57: begin
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
                add23_task(m0, conv_output_ch1[1][3]);
                conv_output_ch1_next[1][3] = add23_out;
                add24_task(m4, conv_output_ch2[1][3]);
                conv_output_ch2_next[1][3] = add24_out;
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
                add23_task(m0, conv_output_ch1[1][3]);
                conv_output_ch1_next[1][3] = add23_out;
                add24_task(m4, conv_output_ch2[1][3]);
                conv_output_ch2_next[1][3] = add24_out;
            end
        end
        10'd8,10'd33,10'd58: begin
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
                add23_task(m0, conv_output_ch1[1][4]);
                conv_output_ch1_next[1][4] = add23_out;
                add24_task(m4, conv_output_ch2[1][4]);
                conv_output_ch2_next[1][4] = add24_out;
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
                add23_task(m0, conv_output_ch1[1][4]);
                conv_output_ch1_next[1][4] = add23_out;
                add24_task(m4, conv_output_ch2[1][4]);
                conv_output_ch2_next[1][4] = add24_out;
            end
        end
        10'd9,10'd34,10'd59: begin
            // print_maxpool_task;
            maxpool_output_ch1_next[0][1] = conv_output_ch1[0][3];
            maxpool_output_ch2_next[0][1] = conv_output_ch2[0][3];
            if (Opt_reg == 0) begin
                add31_task(32'b0,m3,conv_output_ch1[0][4]);
                conv_output_ch1_next[0][4] = add31_out;
                add32_task(32'b0,m7,conv_output_ch2[0][4]);
                conv_output_ch2_next[0][4] = add32_out;
                add51_task(32'b0,32'b0,m2,32'b0,conv_output_ch1[0][5]);
                conv_output_ch1_next[0][5] = add21_out;
                add52_task(32'b0,32'b0,m6,32'b0,conv_output_ch2[0][5]);
                conv_output_ch2_next[0][5] = add22_out;
                add23_task(m1,conv_output_ch1[1][4]);
                conv_output_ch1_next[1][4] = add23_out;
                add24_task(m5,conv_output_ch2[1][4]);
                conv_output_ch2_next[1][4] = add24_out;
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
                conv_output_ch1_next[0][5] = add21_out;
                add52_task(m4,m5,m6,m7,conv_output_ch2[0][5]);
                conv_output_ch2_next[0][5] = add22_out;
                add23_task(m1,conv_output_ch1[1][4]);
                conv_output_ch1_next[1][4] = add23_out;
                add24_task(m5,conv_output_ch2[1][4]);
                conv_output_ch2_next[1][4] = add24_out;
                add33_task(m0,m1,conv_output_ch1[1][5]);
                conv_output_ch1_next[1][5] = add33_out;
                add34_task(m4,m5,conv_output_ch2[1][5]);
                conv_output_ch2_next[1][5] = add34_out;
            end
        end
        10'd10,10'd35,10'd60: begin // second row of first channel
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
                add23_task(m0, conv_output_ch1[2][1]);
                conv_output_ch1_next[2][1] = add23_out;
                add24_task(m4, conv_output_ch2[2][1]);
                conv_output_ch2_next[2][1] = add24_out;
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
                add23_task(m0, conv_output_ch1[2][1]);
                conv_output_ch1_next[2][1] = add23_out;
                add24_task(m4, conv_output_ch2[2][1]);
                conv_output_ch2_next[2][1] = add24_out;
            end
        end
        10'd11,10'd36,10'd61: begin
            // print_maxpool_task;
            cmp1_task(maxpool_output_ch1[0][0], conv_output_ch1[1][0]);
            maxpool_output_ch1_next[0][0] = cmp1_out;
            cmp2_task(maxpool_output_ch2[0][0], conv_output_ch2[1][0]);
            maxpool_output_ch2_next[0][0] = cmp2_out;
            add21_task(m3,conv_output_ch1[1][1]);
            conv_output_ch1_next[1][1] = add21_out;
            add22_task(m7,conv_output_ch2[1][1]);
            conv_output_ch2_next[1][1] = add22_out;
            add23_task(m2,conv_output_ch1[1][2]);
            conv_output_ch1_next[1][2] = add23_out;
            add24_task(m6,conv_output_ch2[1][2]);
            conv_output_ch2_next[1][2] = add24_out;
            add31_task(m1,conv_output_ch1[2][1], 32'b0);
            conv_output_ch1_next[2][1] = add31_out;
            add32_task(m5,conv_output_ch2[2][1], 32'b0);
            conv_output_ch2_next[2][1] = add32_out;
            add33_task(m0,conv_output_ch1[2][2],32'b0);
            conv_output_ch1_next[2][2] = add33_out;
            add34_task(m4,conv_output_ch2[2][2],32'b0);
            conv_output_ch2_next[2][2] = add34_out;
        end
        10'd12,10'd37,10'd62: begin
            // print_maxpool_task;
            cmp1_task(maxpool_output_ch1[0][0], conv_output_ch1[1][1]);
            maxpool_output_ch1_next[0][0] = cmp1_out;
            cmp2_task(maxpool_output_ch2[0][0], conv_output_ch2[1][1]);
            maxpool_output_ch2_next[0][0] = cmp2_out;
            add21_task(m3,conv_output_ch1[1][2]);
            conv_output_ch1_next[1][2] = add21_out;
            add22_task(m7,conv_output_ch2[1][2]);
            conv_output_ch2_next[1][2] = add22_out;
            add23_task(m2,conv_output_ch1[1][3]);
            conv_output_ch1_next[1][3] = add23_out;
            add24_task(m6,conv_output_ch2[1][3]);
            conv_output_ch2_next[1][3] = add24_out;
            add31_task(m1,conv_output_ch1[2][2], 32'b0);
            conv_output_ch1_next[2][2] = add31_out;
            add32_task(m5,conv_output_ch2[2][2], 32'b0);
            conv_output_ch2_next[2][2] = add32_out;
            add33_task(m0,conv_output_ch1[2][3],32'b0);
            conv_output_ch1_next[2][3] = add33_out;
            add34_task(m4,conv_output_ch2[2][3],32'b0);
            conv_output_ch2_next[2][3] = add34_out;
        end
        10'd13,10'd38,10'd63: begin
            // print_maxpool_task;
            cmp1_task(maxpool_output_ch1[0][0], conv_output_ch1[1][2]);
            maxpool_output_ch1_next[0][0] = cmp1_out;
            cmp2_task(maxpool_output_ch2[0][0], conv_output_ch2[1][2]);
            maxpool_output_ch2_next[0][0] = cmp2_out;
            add21_task(m3,conv_output_ch1[1][3]);
            conv_output_ch1_next[1][3] = add21_out;
            add22_task(m7,conv_output_ch2[1][3]);
            conv_output_ch2_next[1][3] = add22_out;
            add23_task(m2,conv_output_ch1[1][4]);
            conv_output_ch1_next[1][4] = add23_out;
            add24_task(m6,conv_output_ch2[1][4]);
            conv_output_ch2_next[1][4] = add24_out;
            add31_task(m1,conv_output_ch1[2][3], 32'b0);
            conv_output_ch1_next[2][3] = add31_out;
            add32_task(m5,conv_output_ch2[2][3], 32'b0);
            conv_output_ch2_next[2][3] = add32_out;
            add33_task(m0,conv_output_ch1[2][4],32'b0);
            conv_output_ch1_next[2][4] = add33_out;
            add34_task(m4,conv_output_ch2[2][4],32'b0);
            conv_output_ch2_next[2][4] = add34_out;
        end
        10'd14,10'd39,10'd64: begin
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
                add23_task(m1,conv_output_ch1[2][4]);
                conv_output_ch1_next[2][4] = add23_out;
                add24_task(m5,conv_output_ch2[2][4]);
                conv_output_ch2_next[2][4] = add24_out;
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
                add23_task(m1,conv_output_ch1[2][4]);
                conv_output_ch1_next[2][4] = add23_out;
                add24_task(m5,conv_output_ch2[2][4]);
                conv_output_ch2_next[2][4] = add24_out;
                add33_task(m0,m1,conv_output_ch1[2][5]);
                conv_output_ch1_next[2][5] = add33_out;
                add34_task(m4,m5,conv_output_ch2[2][5]);
                conv_output_ch2_next[2][5] = add34_out;
            end
        end
        10'd15,10'd40,10'd65: begin // third row of first channel
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
                    add23_task(m0, conv_output_ch1[3][1]);
                    conv_output_ch1_next[3][1] = add23_out;
                    add24_task(m4, conv_output_ch2[3][1]);
                    conv_output_ch2_next[3][1] = add24_out;
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
                    add23_task(m0, conv_output_ch1[3][1]);
                    conv_output_ch1_next[3][1] = add23_out;
                    add24_task(m4, conv_output_ch2[3][1]);
                    conv_output_ch2_next[3][1] = add24_out;
                end
        end
        10'd16,10'd41,10'd66: begin
            // print_maxpool_task;
            cmp1_task(maxpool_output_ch1[0][0], conv_output_ch1[2][0]);
            maxpool_output_ch1_next[0][0] = cmp1_out;
            cmp2_task(maxpool_output_ch2[0][0], conv_output_ch2[2][0]);
            maxpool_output_ch2_next[0][0] = cmp2_out;
            add21_task(m3,conv_output_ch1[2][1]);
            conv_output_ch1_next[2][1] = add21_out;
            add22_task(m7,conv_output_ch2[2][1]);
            conv_output_ch2_next[2][1] = add22_out;
            add23_task(m2,conv_output_ch1[2][2]);
            conv_output_ch1_next[2][2] = add23_out;
            add24_task(m6,conv_output_ch2[2][2]);
            conv_output_ch2_next[2][2] = add24_out;
            add31_task(m1,conv_output_ch1[3][1], 32'b0);
            conv_output_ch1_next[3][1] = add31_out;
            add32_task(m5,conv_output_ch2[3][1], 32'b0);
            conv_output_ch2_next[3][1] = add32_out;
            add33_task(m0,conv_output_ch1[3][2],32'b0);
            conv_output_ch1_next[3][2] = add33_out;
            add34_task(m4,conv_output_ch2[3][2],32'b0);
            conv_output_ch2_next[3][2] = add34_out;
        end
        10'd17,10'd42,10'd67: begin
            // print_maxpool_task;
            cmp1_task(maxpool_output_ch1[0][0], conv_output_ch1[2][1]);
            maxpool_output_ch1_next[0][0] = cmp1_out;
            cmp2_task(maxpool_output_ch2[0][0], conv_output_ch2[2][1]);
            maxpool_output_ch2_next[0][0] = cmp2_out;
            add21_task(m3,conv_output_ch1[2][2]);
            conv_output_ch1_next[2][2] = add21_out;
            add22_task(m7,conv_output_ch2[2][2]);
            conv_output_ch2_next[2][2] = add22_out;
            add23_task(m2,conv_output_ch1[2][3]);
            conv_output_ch1_next[2][3] = add23_out;
            add24_task(m6,conv_output_ch2[2][3]);
            conv_output_ch2_next[2][3] = add24_out;
            add31_task(m1,conv_output_ch1[3][2], 32'b0);
            conv_output_ch1_next[3][2] = add31_out;
            add32_task(m5,conv_output_ch2[3][2], 32'b0);
            conv_output_ch2_next[3][2] = add32_out;
            add33_task(m0,conv_output_ch1[3][3],32'b0);
            conv_output_ch1_next[3][3] = add33_out;
            add34_task(m4,conv_output_ch2[3][3],32'b0);
            conv_output_ch2_next[3][3] = add34_out;
        end
        10'd18,10'd43,10'd68: begin
            // print_maxpool_task;
            cmp1_task(maxpool_output_ch1[0][0], conv_output_ch1[2][2]);
            maxpool_output_ch1_next[0][0] = cmp1_out;
            cmp2_task(maxpool_output_ch2[0][0], conv_output_ch2[2][2]);
            maxpool_output_ch2_next[0][0] = cmp2_out;
            add21_task(m3,conv_output_ch1[2][3]);
            conv_output_ch1_next[2][3] = add21_out;
            add22_task(m7,conv_output_ch2[2][3]);
            conv_output_ch2_next[2][3] = add22_out;
            add23_task(m2,conv_output_ch1[2][4]);
            conv_output_ch1_next[2][4] = add23_out;
            add24_task(m6,conv_output_ch2[2][4]);
            conv_output_ch2_next[2][4] = add24_out;
            add31_task(m1,conv_output_ch1[3][3], 32'b0);
            conv_output_ch1_next[3][3] = add31_out;
            add32_task(m5,conv_output_ch2[3][3], 32'b0);
            conv_output_ch2_next[3][3] = add32_out;
            add33_task(m0,conv_output_ch1[3][4],32'b0);
            conv_output_ch1_next[3][4] = add33_out;
            add34_task(m4,conv_output_ch2[3][4],32'b0);
            conv_output_ch2_next[3][4] = add34_out;
        end
        10'd19,10'd44,10'd69: begin
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
                add23_task(m1,conv_output_ch1[3][4]);
                conv_output_ch1_next[3][4] = add23_out;
                add24_task(m5,conv_output_ch2[3][4]);
                conv_output_ch2_next[3][4] = add24_out;
                add33_task(m0,32'b0,conv_output_ch1[3][5]);
                conv_output_ch1_next[3][5] = add33_out;
                add34_task(m4,32'b0,conv_output_ch2[3][5]);
                conv_output_ch2_next[3][5] = add34_out;
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
                add23_task(m1,conv_output_ch1[3][4]);
                conv_output_ch1_next[3][4] = add23_out;
                add24_task(m5,conv_output_ch2[3][4]);
                conv_output_ch2_next[3][4] = add24_out;
                add33_task(m0,m1,conv_output_ch1[3][5]);
                conv_output_ch1_next[3][5] = add33_out;
                add34_task(m4,m5,conv_output_ch2[3][5]);
                conv_output_ch2_next[3][5] = add34_out;
            end
        end
        10'd20,10'd45,10'd70: begin // fourth row of first channel
            // print_maxpool_task;
            cmp31_task(maxpool_output_ch1[0][1], conv_output_ch1[2][4], conv_output_ch1[2][5]);
            maxpool_output_ch1_next[0][1] = cmp2_out;
            cmp32_task(maxpool_output_ch2[0][1], conv_output_ch2[2][4], conv_output_ch2[2][5]);
            maxpool_output_ch2_next[0][1] = cmp4_out;
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
                    add23_task(m0, conv_output_ch1[4][1]);
                    conv_output_ch1_next[4][1] = add23_out;
                    add24_task(m4, conv_output_ch2[4][1]);
                    conv_output_ch2_next[4][1] = add24_out;
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
                    add23_task(m0, conv_output_ch1[4][1]);
                    conv_output_ch1_next[4][1] = add23_out;
                    add24_task(m4, conv_output_ch2[4][1]);
                    conv_output_ch2_next[4][1] = add24_out;
                end
        end
        10'd21,10'd46,10'd71: begin
            // print_maxpool_task;
            maxpool_output_ch1_next[1][0] = conv_output_ch1[3][0];
            maxpool_output_ch2_next[1][0] = conv_output_ch2[3][0];
            add21_task(m3,conv_output_ch1[3][1]);
            conv_output_ch1_next[3][1] = add21_out;
            add22_task(m7,conv_output_ch2[3][1]);
            conv_output_ch2_next[3][1] = add22_out;
            add23_task(m2,conv_output_ch1[3][2]);
            conv_output_ch1_next[3][2] = add23_out;
            add24_task(m6,conv_output_ch2[3][2]);
            conv_output_ch2_next[3][2] = add24_out;
            add31_task(m1,conv_output_ch1[4][1], 32'b0);
            conv_output_ch1_next[4][1] = add31_out;
            add32_task(m5,conv_output_ch2[4][1], 32'b0);
            conv_output_ch2_next[4][1] = add32_out;
            add33_task(m0,conv_output_ch1[4][2],32'b0);
            conv_output_ch1_next[4][2] = add33_out;
            add34_task(m4,conv_output_ch2[4][2],32'b0);
            conv_output_ch2_next[4][2] = add34_out;
        end
        10'd22,10'd47,10'd72: begin
            // print_maxpool_task;
            cmp1_task(maxpool_output_ch1[1][0], conv_output_ch1[3][1]);
            maxpool_output_ch1_next[1][0] = cmp1_out;
            cmp2_task(maxpool_output_ch2[1][0], conv_output_ch2[3][1]);
            maxpool_output_ch2_next[1][0] = cmp2_out;
            add21_task(m3,conv_output_ch1[3][2]);
            conv_output_ch1_next[3][2] = add21_out;
            add22_task(m7,conv_output_ch2[3][2]);
            conv_output_ch2_next[3][2] = add22_out;
            add23_task(m2,conv_output_ch1[3][3]);
            conv_output_ch1_next[3][3] = add23_out;
            add24_task(m6,conv_output_ch2[3][3]);
            conv_output_ch2_next[3][3] = add24_out;
            add31_task(m1,conv_output_ch1[4][2], 32'b0);
            conv_output_ch1_next[4][2] = add31_out;
            add32_task(m5,conv_output_ch2[4][2], 32'b0);
            conv_output_ch2_next[4][2] = add32_out;
            add33_task(m0,conv_output_ch1[4][3],32'b0);
            conv_output_ch1_next[4][3] = add33_out;
            add34_task(m4,conv_output_ch2[4][3],32'b0);
            conv_output_ch2_next[4][3] = add34_out;
        end
        10'd23,10'd48,10'd73: begin
            // print_maxpool_task;
            cmp1_task(maxpool_output_ch1[1][0], conv_output_ch1[3][2]);
            maxpool_output_ch1_next[1][0] = cmp1_out;
            cmp2_task(maxpool_output_ch2[1][0], conv_output_ch2[3][2]);
            maxpool_output_ch2_next[1][0] = cmp2_out;
            add21_task(m3,conv_output_ch1[3][3]);
            conv_output_ch1_next[3][3] = add21_out;
            add22_task(m7,conv_output_ch2[3][3]);
            conv_output_ch2_next[3][3] = add22_out;
            add23_task(m2,conv_output_ch1[3][4]);
            conv_output_ch1_next[3][4] = add23_out;
            add24_task(m6,conv_output_ch2[3][4]);
            conv_output_ch2_next[3][4] = add24_out;
            add31_task(m1,conv_output_ch1[4][3], 32'b0);
            conv_output_ch1_next[4][3] = add31_out;
            add32_task(m5,conv_output_ch2[4][3], 32'b0);
            conv_output_ch2_next[4][3] = add32_out;
            add33_task(m0,conv_output_ch1[4][4],32'b0);
            conv_output_ch1_next[4][4] = add33_out;
            add34_task(m4,conv_output_ch2[4][4],32'b0);
            conv_output_ch2_next[4][4] = add34_out;
        end
        10'd24,10'd49,10'd74: begin
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
                add23_task(m1,conv_output_ch1[4][4]);
                conv_output_ch1_next[4][4] = add23_out;
                add24_task(m5,conv_output_ch2[4][4]);
                conv_output_ch2_next[4][4] = add24_out;
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
                add23_task(m1,conv_output_ch1[4][4]);
                conv_output_ch1_next[4][4] = add23_out;
                add24_task(m5,conv_output_ch2[4][4]);
                conv_output_ch2_next[4][4] = add24_out;
                add33_task(m0,m1,conv_output_ch1[4][5]);
                conv_output_ch1_next[4][5] = add33_out;
                add34_task(m4,m5,conv_output_ch2[4][5]);
                conv_output_ch2_next[4][5] = add34_out;
            end
        end
        10'd25,10'd50,10'd75: begin // fifth row of first channel
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
                add23_task(m2,conv_output_ch1[4][1]);
                conv_output_ch1_next[4][1] = add23_out;
                add24_task(m6,conv_output_ch2[4][1]);
                conv_output_ch2_next[4][1] = add24_out;
                add51_task(32'b0,m1,32'b0,32'b0,conv_output_ch1[5][0]);
                conv_output_ch1_next[5][0] = add21_out;
                add52_task(32'b0,m5,32'b0,32'b0,conv_output_ch2[5][0]);
                conv_output_ch2_next[5][0] = add22_out;
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
                add23_task(m2,conv_output_ch1[4][1]);
                conv_output_ch1_next[4][1] = add23_out;
                add24_task(m6,conv_output_ch2[4][1]);
                conv_output_ch2_next[4][1] = add24_out;
                add51_task(m0,m1,m2,m3,conv_output_ch1[5][0]);
                conv_output_ch1_next[5][0] = add21_out;
                add52_task(m4,m5,m6,m7,conv_output_ch2[5][0]);
                conv_output_ch2_next[5][0] = add22_out;
                add33_task(m0,m2,conv_output_ch1[5][1]);
                conv_output_ch1_next[5][1] = add33_out;
                add34_task(m4,m6,conv_output_ch2[5][1]);
                conv_output_ch2_next[5][1] = add34_out;
            end
        end
        10'd26,10'd51,10'd76: begin
            // print_maxpool_task;
            cmp31_task(maxpool_output_ch1[1][0], conv_output_ch1[4][0], conv_output_ch1[5][0]);
            maxpool_output_ch1_next[1][0] = cmp2_out;
            cmp32_task(maxpool_output_ch2[1][0], conv_output_ch2[4][0], conv_output_ch2[5][0]);
            maxpool_output_ch2_next[1][0] = cmp4_out;
            if (Opt_reg == 0) begin
                add21_task(m3,conv_output_ch1[4][1]);
                conv_output_ch1_next[4][1] = add21_out;
                add22_task(m7,conv_output_ch2[4][1]);
                conv_output_ch2_next[4][1] = add22_out;
                add23_task(m2,conv_output_ch1[4][2]);
                conv_output_ch1_next[4][2] = add23_out;
                add24_task(m6,conv_output_ch2[4][2]);
                conv_output_ch2_next[4][2] = add24_out;
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
                add23_task(m2,conv_output_ch1[4][2]);
                conv_output_ch1_next[4][2] = add23_out;
                add24_task(m6,conv_output_ch2[4][2]);
                conv_output_ch2_next[4][2] = add24_out;
                add31_task(m1,m3,conv_output_ch1[5][1]);
                conv_output_ch1_next[5][1] = add31_out;
                add32_task(m5,m7,conv_output_ch2[5][1]);
                conv_output_ch2_next[5][1] = add32_out;
                add33_task(m0,m2,conv_output_ch1[5][2]);
                conv_output_ch1_next[5][2] = add33_out;
                add34_task(m4,m6,conv_output_ch2[5][2]);
                conv_output_ch2_next[5][2] = add34_out;
            end
        end
        10'd27,10'd52,10'd77: begin
            // print_maxpool_task;
            cmp31_task(maxpool_output_ch1[1][1], conv_output_ch1[4][1], conv_output_ch1[5][1]);
            maxpool_output_ch1_next[1][1] = cmp2_out;
            cmp32_task(maxpool_output_ch2[1][1], conv_output_ch2[4][1], conv_output_ch2[5][1]);
            maxpool_output_ch2_next[1][1] = cmp4_out;
            if (Opt_reg == 0) begin
                add21_task(m3,conv_output_ch1[4][2]);
                conv_output_ch1_next[4][2] = add21_out;
                add22_task(m7,conv_output_ch2[4][2]);
                conv_output_ch2_next[4][2] = add22_out;
                add23_task(m2,conv_output_ch1[4][3]);
                conv_output_ch1_next[4][3] = add23_out;
                add24_task(m6,conv_output_ch2[4][3]);
                conv_output_ch2_next[4][3] = add24_out;
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
                add23_task(m2,conv_output_ch1[4][3]);
                conv_output_ch1_next[4][3] = add23_out;
                add24_task(m6,conv_output_ch2[4][3]);
                conv_output_ch2_next[4][3] = add24_out;
                add31_task(m1,m3,conv_output_ch1[5][2]);
                conv_output_ch1_next[5][2] = add31_out;
                add32_task(m5,m7,conv_output_ch2[5][2]);
                conv_output_ch2_next[5][2] = add32_out;
                add33_task(m0,m2,conv_output_ch1[5][3]);
                conv_output_ch1_next[5][3] = add33_out;
                add34_task(m4,m6,conv_output_ch2[5][3]);
                conv_output_ch2_next[5][3] = add34_out;
            end
        end
        10'd28,10'd53,10'd78: begin
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
                add23_task(m2,conv_output_ch1[4][4]);
                conv_output_ch1_next[4][4] = add23_out;
                add24_task(m6,conv_output_ch2[4][4]);
                conv_output_ch2_next[4][4] = add24_out;
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
                add23_task(m2,conv_output_ch1[4][4]);
                conv_output_ch1_next[4][4] = add23_out;
                add24_task(m6,conv_output_ch2[4][4]);
                conv_output_ch2_next[4][4] = add24_out;
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
        10'd29,10'd54,10'd79: begin
            // print_maxpool_task;
            cmp31_task(maxpool_output_ch1[1][1], conv_output_ch1[4][3], conv_output_ch1[5][3]);
            maxpool_output_ch1_next[1][1] = cmp2_out;
            cmp32_task(maxpool_output_ch2[1][1], conv_output_ch2[4][3], conv_output_ch2[5][3]);
            maxpool_output_ch2_next[1][1] = cmp4_out;
            if (Opt_reg == 0) begin
                add23_task(m3,conv_output_ch1[4][4]);
                conv_output_ch1_next[4][4] = add23_out;
                add24_task(m7,conv_output_ch2[4][4]);
                conv_output_ch2_next[4][4] = add24_out;
                add31_task(m2,32'b0,conv_output_ch1[4][5]);
                conv_output_ch1_next[4][5] = add31_out;
                add32_task(m6,32'b0,conv_output_ch2[4][5]);
                conv_output_ch2_next[4][5] = add32_out;
                add33_task(m1,32'b0,conv_output_ch1[5][4]);
                conv_output_ch1_next[5][4] = add33_out;
                add34_task(m5,32'b0,conv_output_ch2[5][4]);
                conv_output_ch2_next[5][4] = add34_out;
                add51_task(m0,32'b0,32'b0,32'b0,conv_output_ch1[5][5]);
                conv_output_ch1_next[5][5] = add21_out;
                add52_task(m4,32'b0,32'b0,32'b0,conv_output_ch2[5][5]);
                conv_output_ch2_next[5][5] = add22_out;

                
            end
            else begin
                add23_task(m3,conv_output_ch1[4][4]);
                conv_output_ch1_next[4][4] = add23_out;
                add24_task(m7,conv_output_ch2[4][4]);
                conv_output_ch2_next[4][4] = add24_out;
                add31_task(m2,m3,conv_output_ch1[4][5]);
                conv_output_ch1_next[4][5] = add31_out;
                add32_task(m6,m7,conv_output_ch2[4][5]);
                conv_output_ch2_next[4][5] = add32_out;
                add33_task(m1,m3,conv_output_ch1[5][4]);
                conv_output_ch1_next[5][4] = add33_out;
                add34_task(m5,m7,conv_output_ch2[5][4]);
                conv_output_ch2_next[5][4] = add34_out;
                add51_task(m0,m1,m2,m3,conv_output_ch1[5][5]);
                conv_output_ch1_next[5][5] = add21_out;
                add52_task(m4,m5,m6,m7,conv_output_ch2[5][5]);
                conv_output_ch2_next[5][5] = add22_out;

                exp1_neg2a_task;
            end
        end
        10'd80: begin
            // print_maxpool_task;
            cmp31_task(maxpool_output_ch1[1][1], conv_output_ch1[4][4], conv_output_ch1[4][5]);
            maxpool_output_ch1_next[1][1] = cmp2_out;
            cmp32_task(maxpool_output_ch2[1][1], conv_output_ch2[4][4], conv_output_ch2[4][5]);
            maxpool_output_ch2_next[1][1] = cmp4_out;
        end
        10'd81: begin
            // print_maxpool_task;
            cmp31_task(maxpool_output_ch1[1][1], conv_output_ch1[5][4], conv_output_ch1[5][5]);
            maxpool_output_ch1_next[1][1] = cmp2_out;
            cmp32_task(maxpool_output_ch2[1][1], conv_output_ch2[5][4], conv_output_ch2[5][5]);
            maxpool_output_ch2_next[1][1] = cmp4_out;
        end
        10'd82: begin
            // print_maxpool_task;
            next_state = OUTPUT;
        end
        endcase
    end
    OUTPUT: begin
        if (!in_valid) begin
            out_valid_next = 1;
            out_next = 0;
            for (integer i=0; i<2; i=i+1) begin
                for (integer j=0; j<2; j=j+1) begin
                    out_next = out_next | maxpool_output_ch1[i][j];
                end
            end
            for (integer i=0; i<2; i=i+1) begin
                for (integer j=0; j<2; j=j+1) begin
                    out_next = out_next | maxpool_output_ch2[i][j];
                end
            end
            next_state = IDLE;
        end
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
