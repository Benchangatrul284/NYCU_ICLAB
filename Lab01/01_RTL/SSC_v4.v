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
wire [3:0] even [0:9];
assign even = {0,2,4,6,8,1,3,5,7,9};

wire [7:0] total[0:7]; // store (snack_num*price)
reg [7:0] total_sorted[0:7]; // store (snack_num*price)

reg [8:0] out_change_temp;
reg out_change_flag;
reg signed [9:0] sub_temp;

// sorting
reg [7:0] stage0 [0:7];
reg [7:0] stage1 [0:7];
reg [7:0] stage2 [0:7];
reg [7:0] stage3 [0:7];
reg [7:0] stage4 [0:7];

function [7:0] multiply;
    input [3:0] a, b;
    begin
        case (a)
        4'd0: multiply = 0;
        4'd1:
            case(b)
            4'd0: multiply = 0;
            4'd1: multiply = 1;
            4'd2: multiply = 2;
            4'd3: multiply = 3;
            4'd4: multiply = 4;
            4'd5: multiply = 5;
            4'd6: multiply = 6;
            4'd7: multiply = 7;
            4'd8: multiply = 8;
            4'd9: multiply = 9;
            4'd10: multiply = 10;
            4'd11: multiply = 11;
            4'd12: multiply = 12;
            4'd13: multiply = 13;
            4'd14: multiply = 14;
            4'd15: multiply = 15;
            endcase
        4'd2:
            case(b)
            4'd0: multiply = 0;
            4'd1: multiply = 2;
            4'd2: multiply = 4;
            4'd3: multiply = 6;
            4'd4: multiply = 8;
            4'd5: multiply = 10;
            4'd6: multiply = 12;
            4'd7: multiply = 14;
            4'd8: multiply = 16;
            4'd9: multiply = 18;
            4'd10: multiply = 20;
            4'd11: multiply = 22;
            4'd12: multiply = 24;
            4'd13: multiply = 26;
            4'd14: multiply = 28;
            4'd15: multiply = 30;
            endcase
        4'd3:
            case(b)
            4'd0: multiply = 0;
            4'd1: multiply = 3;
            4'd2: multiply = 6;
            4'd3: multiply = 9;
            4'd4: multiply = 12;
            4'd5: multiply = 15;
            4'd6: multiply = 18;
            4'd7: multiply = 21;
            4'd8: multiply = 24;
            4'd9: multiply = 27;
            4'd10: multiply = 30;
            4'd11: multiply = 33;
            4'd12: multiply = 36;
            4'd13: multiply = 39;
            4'd14: multiply = 42;
            4'd15: multiply = 45;
            endcase
        4'd4:
            case(b)
            4'd0: multiply = 0;
            4'd1: multiply = 4;
            4'd2: multiply = 8;
            4'd3: multiply = 12;
            4'd4: multiply = 16;
            4'd5: multiply = 20;
            4'd6: multiply = 24;
            4'd7: multiply = 28;
            4'd8: multiply = 32;
            4'd9: multiply = 36;
            4'd10: multiply = 40;
            4'd11: multiply = 44;
            4'd12: multiply = 48;
            4'd13: multiply = 52;
            4'd14: multiply = 56;
            4'd15: multiply = 60;
            endcase
        4'd5:
            case(b)
            4'd0: multiply = 0;
            4'd1: multiply = 5;
            4'd2: multiply = 10;
            4'd3: multiply = 15;
            4'd4: multiply = 20;
            4'd5: multiply = 25;
            4'd6: multiply = 30;
            4'd7: multiply = 35;
            4'd8: multiply = 40;
            4'd9: multiply = 45;
            4'd10: multiply = 50;
            4'd11: multiply = 55;
            4'd12: multiply = 60;
            4'd13: multiply = 65;
            4'd14: multiply = 70;
            4'd15: multiply = 75;
            endcase
        4'd6:
            case(b)
            4'd0: multiply = 0;
            4'd1: multiply = 6;
            4'd2: multiply = 12;
            4'd3: multiply = 18;
            4'd4: multiply = 24;
            4'd5: multiply = 30;
            4'd6: multiply = 36;
            4'd7: multiply = 42;
            4'd8: multiply = 48;
            4'd9: multiply = 54;
            4'd10: multiply = 60;
            4'd11: multiply = 66;
            4'd12: multiply = 72;
            4'd13: multiply = 78;
            4'd14: multiply = 84;
            4'd15: multiply = 90;
            endcase
        4'd7:
            case(b)
            4'd0: multiply = 0;
            4'd1: multiply = 7;
            4'd2: multiply = 14;
            4'd3: multiply = 21;
            4'd4: multiply = 28;
            4'd5: multiply = 35;
            4'd6: multiply = 42;
            4'd7: multiply = 49;
            4'd8: multiply = 56;
            4'd9: multiply = 63;
            4'd10: multiply = 70;
            4'd11: multiply = 77;
            4'd12: multiply = 84;
            4'd13: multiply = 91;
            4'd14: multiply = 98;
            4'd15: multiply = 105;
            endcase
        4'd8:
            case(b)
            4'd0: multiply = 0;
            4'd1: multiply = 8;
            4'd2: multiply = 16;
            4'd3: multiply = 24;
            4'd4: multiply = 32;
            4'd5: multiply = 40;
            4'd6: multiply = 48;
            4'd7: multiply = 56;
            4'd8: multiply = 64;
            4'd9: multiply = 72;
            4'd10: multiply = 80;
            4'd11: multiply = 88;
            4'd12: multiply = 96;
            4'd13: multiply = 104;
            4'd14: multiply = 112;
            4'd15: multiply = 120;
            endcase
        4'd9:
            case(b)
            4'd0: multiply = 0;
            4'd1: multiply = 9;
            4'd2: multiply = 18;
            4'd3: multiply = 27;
            4'd4: multiply = 36;
            4'd5: multiply = 45;
            4'd6: multiply = 54;
            4'd7: multiply = 63;
            4'd8: multiply = 72;
            4'd9: multiply = 81;
            4'd10: multiply = 90;
            4'd11: multiply = 99;
            4'd12: multiply = 108;
            4'd13: multiply = 117;
            4'd14: multiply = 126;
            4'd15: multiply = 135;
            endcase
        4'd10:
            case(b)
            4'd0: multiply = 0;
            4'd1: multiply = 10;
            4'd2: multiply = 20;
            4'd3: multiply = 30;
            4'd4: multiply = 40;
            4'd5: multiply = 50;
            4'd6: multiply = 60;
            4'd7: multiply = 70;
            4'd8: multiply = 80;
            4'd9: multiply = 90;
            4'd10: multiply = 100;
            4'd11: multiply = 110;
            4'd12: multiply = 120;
            4'd13: multiply = 130;
            4'd14: multiply = 140;
            4'd15: multiply = 150;
            endcase
        4'd11:
            case(b)
            4'd0: multiply = 0;
            4'd1: multiply = 11;
            4'd2: multiply = 22;
            4'd3: multiply = 33;
            4'd4: multiply = 44;
            4'd5: multiply = 55;
            4'd6: multiply = 66;
            4'd7: multiply = 77;
            4'd8: multiply = 88;
            4'd9: multiply = 99;
            4'd10: multiply = 110;
            4'd11: multiply = 121;
            4'd12: multiply = 132;
            4'd13: multiply = 143;
            4'd14: multiply = 154;
            4'd15: multiply = 165;
            endcase
        4'd12:
            case(b)
            4'd0: multiply = 0;
            4'd1: multiply = 12;
            4'd2: multiply = 24;
            4'd3: multiply = 36;
            4'd4: multiply = 48;
            4'd5: multiply = 60;
            4'd6: multiply = 72;
            4'd7: multiply = 84;
            4'd8: multiply = 96;
            4'd9: multiply = 108;
            4'd10: multiply = 120;
            4'd11: multiply = 132;
            4'd12: multiply = 144;
            4'd13: multiply = 156;
            4'd14: multiply = 168;
            4'd15: multiply = 180;
            endcase
        4'd13:
            case(b)
            4'd0: multiply = 0;
            4'd1: multiply = 13;
            4'd2: multiply = 26;
            4'd3: multiply = 39;
            4'd4: multiply = 52;
            4'd5: multiply = 65;
            4'd6: multiply = 78;
            4'd7: multiply = 91;
            4'd8: multiply = 104;
            4'd9: multiply = 117;
            4'd10: multiply = 130;
            4'd11: multiply = 143;
            4'd12: multiply = 156;
            4'd13: multiply = 169;
            4'd14: multiply = 182;
            4'd15: multiply = 195;
            endcase
        4'd14:
            case(b)
            4'd0: multiply = 0;
            4'd1: multiply = 14;
            4'd2: multiply = 28;
            4'd3: multiply = 42;
            4'd4: multiply = 56;
            4'd5: multiply = 70;
            4'd6: multiply = 84;
            4'd7: multiply = 98;
            4'd8: multiply = 112;
            4'd9: multiply = 126;
            4'd10: multiply = 140;
            4'd11: multiply = 154;
            4'd12: multiply = 168;
            4'd13: multiply = 182;
            4'd14: multiply = 196;
            4'd15: multiply = 210;
            endcase
        4'd15:
            case(b)
            4'd0: multiply = 0;
            4'd1: multiply = 15;
            4'd2: multiply = 30;
            4'd3: multiply = 45;
            4'd4: multiply = 60;
            4'd5: multiply = 75;
            4'd6: multiply = 90;
            4'd7: multiply = 105;
            4'd8: multiply = 120;
            4'd9: multiply = 135;
            4'd10: multiply = 150;
            4'd11: multiply = 165;
            4'd12: multiply = 180;
            4'd13: multiply = 195;
            4'd14: multiply = 210;
            4'd15: multiply = 225;
            endcase
        default: multiply = 0;
        endcase
    end
endfunction



get_multiply_module get_multiply0(.a(snack_num[31:28]),.b(price[31:28]),.multiply(total[0]));
get_multiply_module get_multiply1(.a(snack_num[27:24]),.b(price[27:24]),.multiply(total[1]));
get_multiply_module get_multiply2(.a(snack_num[23:20]),.b(price[23:20]),.multiply(total[2]));
get_multiply_module get_multiply3(.a(snack_num[19:16]),.b(price[19:16]),.multiply(total[3]));
get_multiply_module get_multiply4(.a(snack_num[15:12]),.b(price[15:12]),.multiply(total[4]));
get_multiply_module get_multiply5(.a(snack_num[11:8]),.b(price[11:8]),.multiply(total[5]));
get_multiply_module get_multiply6(.a(snack_num[7:4]),.b(price[7:4]),.multiply(total[6]));
get_multiply_module get_multiply7(.a(snack_num[3:0]),.b(price[3:0]),.multiply(total[7]));

always @(*) begin
    out_change = input_money;
    out_change_flag = 1;// store true when able to keep subtracting
    out_change_temp = input_money;
    sub_temp = 0;

    // do the ID
    out_valid = !(((even[card_num[63:60]] + even[card_num[55:52]] + even[card_num[47:44]] + even[card_num[39:36]]) + 
                   (even[card_num[31:28]] + even[card_num[23:20]] + even[card_num[15:12]] + even[card_num[7:4]]) +
                   (card_num[59:56] + card_num[51:48] + card_num[43:40] + card_num[35:32]) + 
                   (card_num[27:24] + card_num[19:16] + card_num[11:8] + card_num[3:0])) % 10);
    
    // total[0] = snack_num[31:28] * price[31:28];
    // total[1] = snack_num[27:24] * price[27:24];
    // total[2] = snack_num[23:20] * price[23:20];
    // total[3] = snack_num[19:16] * price[19:16];
    // total[4] = snack_num[15:12] * price[15:12];
    // total[5] = snack_num[11:8] * price[11:8];
    // total[6] = snack_num[7:4] * price[7:4];
    // total[7] = snack_num[3:0] * price[3:0];


    // total[0] = multiply(snack_num[31:28], price[31:28]);
    // total[1] = multiply(snack_num[27:24], price[27:24]);
    // total[2] = multiply(snack_num[23:20], price[23:20]);
    // total[3] = multiply(snack_num[19:16], price[19:16]);
    // total[4] = multiply(snack_num[15:12], price[15:12]);
    // total[5] = multiply(snack_num[11:8], price[11:8]);
    // total[6] = multiply(snack_num[7:4], price[7:4]);
    // total[7] = multiply(snack_num[3:0], price[3:0]);

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
    
    
    sub_temp = out_change_temp - total_sorted[0];
    if (sub_temp[9] == 1'b0) begin
        out_change_temp = sub_temp;
    end else begin
        out_change_flag = 0;
    end
        
    sub_temp = out_change_temp - total_sorted[1];
    if (sub_temp[9] == 1'b0 && out_change_flag) begin
        out_change_temp = sub_temp;
    end else begin
        out_change_flag = 0;
    end
        
    sub_temp = out_change_temp - total_sorted[2];
    if (sub_temp[9] == 1'b0 && out_change_flag) begin
        out_change_temp = sub_temp;
    end else begin
        out_change_flag = 0;
    end

    sub_temp = out_change_temp - total_sorted[3];
    if (sub_temp[9] == 1'b0 && out_change_flag) begin
        out_change_temp = sub_temp;
    end else begin
        out_change_flag = 0;
    end

    sub_temp = out_change_temp - total_sorted[4];
    if (sub_temp[9] == 1'b0 && out_change_flag) begin
        out_change_temp = sub_temp;
    end else begin
        out_change_flag = 0;
    end

    sub_temp = out_change_temp - total_sorted[5];
    if (sub_temp[9] == 1'b0 && out_change_flag) begin
        out_change_temp = sub_temp;
    end else begin
        out_change_flag = 0;
    end

    sub_temp = out_change_temp - total_sorted[6];
    if (sub_temp[9] == 1'b0 && out_change_flag) begin
        out_change_temp = sub_temp;
    end else begin
        out_change_flag = 0;
    end

    sub_temp = out_change_temp - total_sorted[7];
    if (sub_temp[9] == 1'b0 && out_change_flag) begin
        out_change_temp = sub_temp;
    end else begin
        out_change_flag = 0;
    end

    if (out_valid)
        out_change = out_change_temp;
   
end

endmodule

module get_multiply_module(
    input [3:0] a,
    input [3:0] b,
    output reg [7:0] multiply
);

always @(*)
    begin
        multiply = a * b;
    //     case (a)
    //     4'd0: multiply = 0;
    //     4'd1:
    //         case(b)
    //         4'd0: multiply = 0;
    //         4'd1: multiply = 1;
    //         4'd2: multiply = 2;
    //         4'd3: multiply = 3;
    //         4'd4: multiply = 4;
    //         4'd5: multiply = 5;
    //         4'd6: multiply = 6;
    //         4'd7: multiply = 7;
    //         4'd8: multiply = 8;
    //         4'd9: multiply = 9;
    //         4'd10: multiply = 10;
    //         4'd11: multiply = 11;
    //         4'd12: multiply = 12;
    //         4'd13: multiply = 13;
    //         4'd14: multiply = 14;
    //         4'd15: multiply = 15;
    //         endcase
    //     4'd2:
    //         case(b)
    //         4'd0: multiply = 0;
    //         4'd1: multiply = 2;
    //         4'd2: multiply = 4;
    //         4'd3: multiply = 6;
    //         4'd4: multiply = 8;
    //         4'd5: multiply = 10;
    //         4'd6: multiply = 12;
    //         4'd7: multiply = 14;
    //         4'd8: multiply = 16;
    //         4'd9: multiply = 18;
    //         4'd10: multiply = 20;
    //         4'd11: multiply = 22;
    //         4'd12: multiply = 24;
    //         4'd13: multiply = 26;
    //         4'd14: multiply = 28;
    //         4'd15: multiply = 30;
    //         endcase
    //     4'd3:
    //         case(b)
    //         4'd0: multiply = 0;
    //         4'd1: multiply = 3;
    //         4'd2: multiply = 6;
    //         4'd3: multiply = 9;
    //         4'd4: multiply = 12;
    //         4'd5: multiply = 15;
    //         4'd6: multiply = 18;
    //         4'd7: multiply = 21;
    //         4'd8: multiply = 24;
    //         4'd9: multiply = 27;
    //         4'd10: multiply = 30;
    //         4'd11: multiply = 33;
    //         4'd12: multiply = 36;
    //         4'd13: multiply = 39;
    //         4'd14: multiply = 42;
    //         4'd15: multiply = 45;
    //         endcase
    //     4'd4:
    //         case(b)
    //         4'd0: multiply = 0;
    //         4'd1: multiply = 4;
    //         4'd2: multiply = 8;
    //         4'd3: multiply = 12;
    //         4'd4: multiply = 16;
    //         4'd5: multiply = 20;
    //         4'd6: multiply = 24;
    //         4'd7: multiply = 28;
    //         4'd8: multiply = 32;
    //         4'd9: multiply = 36;
    //         4'd10: multiply = 40;
    //         4'd11: multiply = 44;
    //         4'd12: multiply = 48;
    //         4'd13: multiply = 52;
    //         4'd14: multiply = 56;
    //         4'd15: multiply = 60;
    //         endcase
    //     4'd5:
    //         case(b)
    //         4'd0: multiply = 0;
    //         4'd1: multiply = 5;
    //         4'd2: multiply = 10;
    //         4'd3: multiply = 15;
    //         4'd4: multiply = 20;
    //         4'd5: multiply = 25;
    //         4'd6: multiply = 30;
    //         4'd7: multiply = 35;
    //         4'd8: multiply = 40;
    //         4'd9: multiply = 45;
    //         4'd10: multiply = 50;
    //         4'd11: multiply = 55;
    //         4'd12: multiply = 60;
    //         4'd13: multiply = 65;
    //         4'd14: multiply = 70;
    //         4'd15: multiply = 75;
    //         endcase
    //     4'd6:
    //         case(b)
    //         4'd0: multiply = 0;
    //         4'd1: multiply = 6;
    //         4'd2: multiply = 12;
    //         4'd3: multiply = 18;
    //         4'd4: multiply = 24;
    //         4'd5: multiply = 30;
    //         4'd6: multiply = 36;
    //         4'd7: multiply = 42;
    //         4'd8: multiply = 48;
    //         4'd9: multiply = 54;
    //         4'd10: multiply = 60;
    //         4'd11: multiply = 66;
    //         4'd12: multiply = 72;
    //         4'd13: multiply = 78;
    //         4'd14: multiply = 84;
    //         4'd15: multiply = 90;
    //         endcase
    //     4'd7:
    //         case(b)
    //         4'd0: multiply = 0;
    //         4'd1: multiply = 7;
    //         4'd2: multiply = 14;
    //         4'd3: multiply = 21;
    //         4'd4: multiply = 28;
    //         4'd5: multiply = 35;
    //         4'd6: multiply = 42;
    //         4'd7: multiply = 49;
    //         4'd8: multiply = 56;
    //         4'd9: multiply = 63;
    //         4'd10: multiply = 70;
    //         4'd11: multiply = 77;
    //         4'd12: multiply = 84;
    //         4'd13: multiply = 91;
    //         4'd14: multiply = 98;
    //         4'd15: multiply = 105;
    //         endcase
    //     4'd8:
    //         case(b)
    //         4'd0: multiply = 0;
    //         4'd1: multiply = 8;
    //         4'd2: multiply = 16;
    //         4'd3: multiply = 24;
    //         4'd4: multiply = 32;
    //         4'd5: multiply = 40;
    //         4'd6: multiply = 48;
    //         4'd7: multiply = 56;
    //         4'd8: multiply = 64;
    //         4'd9: multiply = 72;
    //         4'd10: multiply = 80;
    //         4'd11: multiply = 88;
    //         4'd12: multiply = 96;
    //         4'd13: multiply = 104;
    //         4'd14: multiply = 112;
    //         4'd15: multiply = 120;
    //         endcase
    //     4'd9:
    //         case(b)
    //         4'd0: multiply = 0;
    //         4'd1: multiply = 9;
    //         4'd2: multiply = 18;
    //         4'd3: multiply = 27;
    //         4'd4: multiply = 36;
    //         4'd5: multiply = 45;
    //         4'd6: multiply = 54;
    //         4'd7: multiply = 63;
    //         4'd8: multiply = 72;
    //         4'd9: multiply = 81;
    //         4'd10: multiply = 90;
    //         4'd11: multiply = 99;
    //         4'd12: multiply = 108;
    //         4'd13: multiply = 117;
    //         4'd14: multiply = 126;
    //         4'd15: multiply = 135;
    //         endcase
    //     4'd10:
    //         case(b)
    //         4'd0: multiply = 0;
    //         4'd1: multiply = 10;
    //         4'd2: multiply = 20;
    //         4'd3: multiply = 30;
    //         4'd4: multiply = 40;
    //         4'd5: multiply = 50;
    //         4'd6: multiply = 60;
    //         4'd7: multiply = 70;
    //         4'd8: multiply = 80;
    //         4'd9: multiply = 90;
    //         4'd10: multiply = 100;
    //         4'd11: multiply = 110;
    //         4'd12: multiply = 120;
    //         4'd13: multiply = 130;
    //         4'd14: multiply = 140;
    //         4'd15: multiply = 150;
    //         endcase
    //     4'd11:
    //         case(b)
    //         4'd0: multiply = 0;
    //         4'd1: multiply = 11;
    //         4'd2: multiply = 22;
    //         4'd3: multiply = 33;
    //         4'd4: multiply = 44;
    //         4'd5: multiply = 55;
    //         4'd6: multiply = 66;
    //         4'd7: multiply = 77;
    //         4'd8: multiply = 88;
    //         4'd9: multiply = 99;
    //         4'd10: multiply = 110;
    //         4'd11: multiply = 121;
    //         4'd12: multiply = 132;
    //         4'd13: multiply = 143;
    //         4'd14: multiply = 154;
    //         4'd15: multiply = 165;
    //         endcase
    //     4'd12:
    //         case(b)
    //         4'd0: multiply = 0;
    //         4'd1: multiply = 12;
    //         4'd2: multiply = 24;
    //         4'd3: multiply = 36;
    //         4'd4: multiply = 48;
    //         4'd5: multiply = 60;
    //         4'd6: multiply = 72;
    //         4'd7: multiply = 84;
    //         4'd8: multiply = 96;
    //         4'd9: multiply = 108;
    //         4'd10: multiply = 120;
    //         4'd11: multiply = 132;
    //         4'd12: multiply = 144;
    //         4'd13: multiply = 156;
    //         4'd14: multiply = 168;
    //         4'd15: multiply = 180;
    //         endcase
    //     4'd13:
    //         case(b)
    //         4'd0: multiply = 0;
    //         4'd1: multiply = 13;
    //         4'd2: multiply = 26;
    //         4'd3: multiply = 39;
    //         4'd4: multiply = 52;
    //         4'd5: multiply = 65;
    //         4'd6: multiply = 78;
    //         4'd7: multiply = 91;
    //         4'd8: multiply = 104;
    //         4'd9: multiply = 117;
    //         4'd10: multiply = 130;
    //         4'd11: multiply = 143;
    //         4'd12: multiply = 156;
    //         4'd13: multiply = 169;
    //         4'd14: multiply = 182;
    //         4'd15: multiply = 195;
    //         endcase
    //     4'd14:
    //         case(b)
    //         4'd0: multiply = 0;
    //         4'd1: multiply = 14;
    //         4'd2: multiply = 28;
    //         4'd3: multiply = 42;
    //         4'd4: multiply = 56;
    //         4'd5: multiply = 70;
    //         4'd6: multiply = 84;
    //         4'd7: multiply = 98;
    //         4'd8: multiply = 112;
    //         4'd9: multiply = 126;
    //         4'd10: multiply = 140;
    //         4'd11: multiply = 154;
    //         4'd12: multiply = 168;
    //         4'd13: multiply = 182;
    //         4'd14: multiply = 196;
    //         4'd15: multiply = 210;
    //         endcase
    //     4'd15:
    //         case(b)
    //         4'd0: multiply = 0;
    //         4'd1: multiply = 15;
    //         4'd2: multiply = 30;
    //         4'd3: multiply = 45;
    //         4'd4: multiply = 60;
    //         4'd5: multiply = 75;
    //         4'd6: multiply = 90;
    //         4'd7: multiply = 105;
    //         4'd8: multiply = 120;
    //         4'd9: multiply = 135;
    //         4'd10: multiply = 150;
    //         4'd11: multiply = 165;
    //         4'd12: multiply = 180;
    //         4'd13: multiply = 195;
    //         4'd14: multiply = 210;
    //         4'd15: multiply = 225;
    //         endcase
    //     default: multiply = 0;
    //     endcase
    end
    
endmodule