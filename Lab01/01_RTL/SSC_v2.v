//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2024 Fall
//   Lab01 Exercise		: Snack Shopping Calculator
//   Author     		  : Yu-Hsiang Wang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : SSC.v
//   Module Name : SSC
//   Release version : V1.0 (Release Date: 2024-09)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

// 63880
module SSC(
    // Input signals
    card_num,
    input_money,
    snack_num,
    price, 
    // Output signals
    out_valid,
    out_change
);

//================================================================
//   INPUT AND OUTPUT DECLARATION                         
//================================================================
input [63:0] card_num;
input [8:0] input_money;
input [31:0] snack_num;
input [31:0] price;
output out_valid;
output [8:0] out_change;    

//================================================================
//    Wire & Registers 
//================================================================
// Declare the wire/reg you would use in your circuit
// remember 
// wire for port connection and cont. assignment
// reg for proc. assignment

//================================================================
//    DESIGN
//================================================================
reg out_valid;
reg [8:0] out_change;
reg [3:0] even [0:9];
// assign even_odd[0] = {0,1,2,3,4,5,6,7,8,9};
// assign even_odd[1] = {2,3,4,5,6,7,8,9,0,1};
// assign even_odd[2] = {4,5,6,7,8,9,0,1,2,3};
// assign even_odd[3] = {6,7,8,9,0,1,2,3,4,5};
// assign even_odd[4] = {8,9,0,1,2,3,4,5,6,7};
// assign even_odd[5] = {1,2,3,4,5,6,7,8,9,0};
// assign even_odd[6] = {3,4,5,6,7,8,9,0,1,2};
// assign even_odd[7] = {5,6,7,8,9,0,1,2,3,4};
// assign even_odd[8] = {7,8,9,0,1,2,3,4,5,6};
// assign even_odd[9] = {9,0,1,2,3,4,5,6,7,8};


// // different way: look up table is better
// // wire [3:0] get_digit [0:19];
// // assign get_digit = {0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9};


// wire [4:0] sum[0:7]; // store the intermediate result of ID

// assign sum[0] = even_odd[card_num[63:60]][card_num[59:56]];
// get_digit_module get_digit1(.input_digit(even_odd[card_num[55:52]][card_num[51:48]] + sum[0]), .output_digit(sum[1]));
// get_digit_module get_digit2(.input_digit(even_odd[card_num[47:44]][card_num[43:40]] + sum[1]), .output_digit(sum[2]));
// get_digit_module get_digit3(.input_digit(even_odd[card_num[39:36]][card_num[35:32]] + sum[2]), .output_digit(sum[3]));
// get_digit_module get_digit4(.input_digit(even_odd[card_num[31:28]][card_num[27:24]] + sum[3]), .output_digit(sum[4]));
// get_digit_module get_digit5(.input_digit(even_odd[card_num[23:20]][card_num[19:16]] + sum[4]), .output_digit(sum[5]));
// get_digit_module get_digit6(.input_digit(even_odd[card_num[15:12]][card_num[11:8]] + sum[5]), .output_digit(sum[6]));
// get_digit_module get_digit7(.input_digit(even_odd[card_num[7:4]][card_num[3:0]] + sum[6]), .output_digit(sum[7]));


reg [7:0] total[0:7]; // store (snack_num*price)
reg [7:0] total_sorted[0:7]; // store (snack_num*price)

reg [8:0] out_change_intermediate;
reg [8:0] out_change_intermediate_pre;
reg [8:0] out_change_temp;
reg out_change_flag;

// sorting
reg [7:0] stage0 [0:7];
reg [7:0] stage1 [0:7];
reg [7:0] stage2 [0:7];
reg [7:0] stage3 [0:7];
reg [7:0] stage4 [0:7];



always @(*) begin
    even = {0,2,4,6,8,1,3,5,7,9};
    out_change = input_money;
    out_change_intermediate = input_money;
    out_change_flag = 1;// store true when able to keep subtracting
    out_change_intermediate_pre = 0;
    out_change_temp = input_money;

    // do the ID
    out_valid = !(((even[card_num[63:60]] + even[card_num[55:52]] + even[card_num[47:44]] + even[card_num[39:36]]) + 
                   (even[card_num[31:28]] + even[card_num[23:20]] + even[card_num[15:12]] + even[card_num[7:4]]) +
                   (card_num[59:56] + card_num[51:48] + card_num[43:40] + card_num[35:32]) + 
                   (card_num[27:24] + card_num[19:16] + card_num[11:8] + card_num[3:0])) % 10);

    total[0] = snack_num[31:28] * price[31:28];
    total[1] = snack_num[27:24] * price[27:24];
    total[2] = snack_num[23:20] * price[23:20];
    total[3] = snack_num[19:16] * price[19:16];
    total[4] = snack_num[15:12] * price[15:12];
    total[5] = snack_num[11:8] * price[11:8];
    total[6] = snack_num[7:4] * price[7:4];
    total[7] = snack_num[3:0] * price[3:0];

    // Stage 0: [(0,2), (1,3), (4,6), (5,7)]
    stage0 = total;
    if (total[0] < total[2]) begin
        stage0[0] = total[2];
        stage0[2] = total[0];
    end
    
    if (total[1] < total[3]) begin
        stage0[1] = total[3];
        stage0[3] = total[1];
    end

    if (total[4] < total[6]) begin
    stage0[4] = total[6];
    stage0[6] = total[4];
    end

    if (total[5] < total[7]) begin
        stage0[5] = total[7];
        stage0[7] = total[5];
    end

    // Stage 1: [(0,4), (1,5), (2,6), (3,7)]
    stage1 = stage0;
    if (stage0[0] < stage0[4]) begin
    stage1[0] = stage0[4];
    stage1[4] = stage0[0];
    end

    if (stage0[1] < stage0[5]) begin
        stage1[1] = stage0[5];
        stage1[5] = stage0[1];
    end

    if (stage0[2] < stage0[6]) begin
        stage1[2] = stage0[6];
        stage1[6] = stage0[2];
    end

    if (stage0[3] < stage0[7]) begin
        stage1[3] = stage0[7];
        stage1[7] = stage0[3];
    end


    // Stage 2: [(0,1), (2,3), (4,5), (6,7)]
    stage2 = stage1;
    if (stage1[0] < stage1[1]) begin
        stage2[0] = stage1[1];
        stage2[1] = stage1[0];
        end

    if (stage1[2] < stage1[3]) begin
        stage2[2] = stage1[3];
        stage2[3] = stage1[2];
    end

    if (stage1[4] < stage1[5]) begin
        stage2[4] = stage1[5];
        stage2[5] = stage1[4];
    end

    if (stage1[6] < stage1[7]) begin
        stage2[6] = stage1[7];
        stage2[7] = stage1[6];
    end


    // Stage 3: [(2,4), (3,5)]
    stage3 = stage2;
    if (stage2[2] < stage2[4]) begin
        stage3[2] = stage2[4];
        stage3[4] = stage2[2];
    end

    if (stage2[3] < stage2[5]) begin
        stage3[3] = stage2[5];
        stage3[5] = stage2[3];
    end

    // Stage 4: [(1,4), (3,6)]
    stage4 = stage3;
    if (stage3[1] < stage3[4]) begin
        stage4[1] = stage3[4];
        stage4[4] = stage3[1];
    end

    if (stage3[3] < stage3[6]) begin
        stage4[3] = stage3[6];
        stage4[6] = stage3[3];
    end


    // Stage 5: [(1,2), (3,4), (5,6)]
    total_sorted = stage4;
    if (stage4[1] < stage4[2]) begin
        total_sorted[1] = stage4[2];
        total_sorted[2] = stage4[1];
    end
    if (stage4[3] < stage4[4]) begin
        total_sorted[3] = stage4[4];
        total_sorted[4] = stage4[3];
    end
    if (stage4[5] < stage4[6]) begin
        total_sorted[5] = stage4[6];
        total_sorted[6] = stage4[5];
    end
    
    
    
    if ((input_money >= total_sorted[0]) && out_change_flag) begin
        out_change_intermediate = input_money - total_sorted[0];
        out_change_temp = out_change_intermediate;
        out_change_intermediate_pre = out_change_intermediate;
    end else begin
        out_change_flag = 0;
    end
        

    if (out_change_intermediate_pre >= total_sorted[1] && out_change_flag) begin
        out_change_intermediate = out_change_intermediate_pre - total_sorted[1];
        out_change_temp = out_change_intermediate;
        out_change_intermediate_pre = out_change_intermediate;
    end else begin
        out_change_flag = 0;
    end
        

    if (out_change_intermediate_pre >= total_sorted[2] && out_change_flag) begin
        out_change_intermediate = out_change_intermediate_pre - total_sorted[2];
        out_change_temp = out_change_intermediate;
        out_change_intermediate_pre = out_change_intermediate;
    end else begin
        out_change_flag = 0;
    end

    if (out_change_intermediate_pre >= total_sorted[3] && out_change_flag) begin
        out_change_intermediate = out_change_intermediate_pre - total_sorted[3];
        out_change_temp = out_change_intermediate;
        out_change_intermediate_pre = out_change_intermediate;
    end else begin
        out_change_flag = 0;
    end

    if (out_change_intermediate_pre >= total_sorted[4] && out_change_flag) begin
        out_change_intermediate = out_change_intermediate_pre - total_sorted[4];
        out_change_temp = out_change_intermediate;
        out_change_intermediate_pre = out_change_intermediate;
    end else begin
        out_change_flag = 0;
    end

    if (out_change_intermediate_pre >= total_sorted[5] && out_change_flag) begin
        out_change_intermediate = out_change_intermediate_pre - total_sorted[5];
        out_change_temp = out_change_intermediate;
        out_change_intermediate_pre = out_change_intermediate;
    end else begin
        out_change_flag = 0;
    end

    if (out_change_intermediate_pre >= total_sorted[6] && out_change_flag) begin
        out_change_intermediate = out_change_intermediate_pre - total_sorted[6];
        out_change_temp = out_change_intermediate;
        out_change_intermediate_pre = out_change_intermediate;
    end else begin
        out_change_flag = 0;
    end

    if (out_change_intermediate_pre >= total_sorted[7] && out_change_flag) begin
        out_change_intermediate = out_change_intermediate_pre - total_sorted[7];
        out_change_temp = out_change_intermediate;
        out_change_intermediate_pre = out_change_intermediate;
    end else begin
        out_change_flag = 0;
    end
    
    if (out_valid)
        out_change = out_change_temp;
   
end

endmodule
