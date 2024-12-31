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

// 61960
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
reg [8:0] out_change_temp;
wire [3:0] even [0:9];
assign even = {0,2,4,6,8,1,3,5,7,9};

reg [7:0] total [0:7]; // store (snack_num*price)
reg [7:0] total_sorted[0:7]; // store (snack_num*price)

reg [8:0] sub_temp;
// sorting
reg [7:0] stage0 [0:7];
reg [7:0] stage1 [0:7];
reg [7:0] stage2 [0:7];
reg [7:0] stage3 [0:7];
reg [7:0] stage4 [0:7];

function [7:0] multiply_4_2;
    input [3:0] a;
    input [3:0] b;
    begin
        reg [5:0] inter1, inter2;
        case({b,a[3:2]})
            6'b0000_00:inter1 = 6'b000000;
            6'b0000_01:inter1 = 6'b000000;
            6'b0000_10:inter1 = 6'b000000;
            6'b0000_11:inter1 = 6'b000000;
            6'b0001_00:inter1 = 6'b000000;
            6'b0001_01:inter1 = 6'b000001;
            6'b0001_10:inter1 = 6'b000010;
            6'b0001_11:inter1 = 6'b000011;
            6'b0010_00:inter1 = 6'b000000;
            6'b0010_01:inter1 = 6'b000010;
            6'b0010_10:inter1 = 6'b000100;
            6'b0010_11:inter1 = 6'b000110;
            6'b0011_00:inter1 = 6'b000000;
            6'b0011_01:inter1 = 6'b000011;
            6'b0011_10:inter1 = 6'b000110;
            6'b0011_11:inter1 = 6'b001001;
            6'b0100_00:inter1 = 6'b000000;
            6'b0100_01:inter1 = 6'b000100;
            6'b0100_10:inter1 = 6'b001000;
            6'b0100_11:inter1 = 6'b001100;
            6'b0101_00:inter1 = 6'b000000;
            6'b0101_01:inter1 = 6'b000101;
            6'b0101_10:inter1 = 6'b001010;
            6'b0101_11:inter1 = 6'b001111;
            6'b0110_00:inter1 = 6'b000000;
            6'b0110_01:inter1 = 6'b000110;
            6'b0110_10:inter1 = 6'b001100;
            6'b0110_11:inter1 = 6'b010010;
            6'b0111_00:inter1 = 6'b000000;
            6'b0111_01:inter1 = 6'b000111;
            6'b0111_10:inter1 = 6'b001110;
            6'b0111_11:inter1 = 6'b010101;
            6'b1000_00:inter1 = 6'b000000;
            6'b1000_01:inter1 = 6'b001000;
            6'b1000_10:inter1 = 6'b010000;
            6'b1000_11:inter1 = 6'b011000;
            6'b1001_00:inter1 = 6'b000000;
            6'b1001_01:inter1 = 6'b001001;
            6'b1001_10:inter1 = 6'b010010;
            6'b1001_11:inter1 = 6'b011011;
            6'b1010_00:inter1 = 6'b000000;
            6'b1010_01:inter1 = 6'b001010;
            6'b1010_10:inter1 = 6'b010100;
            6'b1010_11:inter1 = 6'b011110;
            6'b1011_00:inter1 = 6'b000000;
            6'b1011_01:inter1 = 6'b001011;
            6'b1011_10:inter1 = 6'b010110;
            6'b1011_11:inter1 = 6'b100001;
            6'b1100_00:inter1 = 6'b000000;
            6'b1100_01:inter1 = 6'b001100;
            6'b1100_10:inter1 = 6'b011000;
            6'b1100_11:inter1 = 6'b100100;
            6'b1101_00:inter1 = 6'b000000;
            6'b1101_01:inter1 = 6'b001101;
            6'b1101_10:inter1 = 6'b011010;
            6'b1101_11:inter1 = 6'b100111;
            6'b1110_00:inter1 = 6'b000000;
            6'b1110_01:inter1 = 6'b001110;
            6'b1110_10:inter1 = 6'b011100;
            6'b1110_11:inter1 = 6'b101010;
            6'b1111_00:inter1 = 6'b000000;
            6'b1111_01:inter1 = 6'b001111;
            6'b1111_10:inter1 = 6'b011110;
            6'b1111_11:inter1 = 6'b101101;
            default: inter1 = 6'bxxxxxx;
        endcase
        case({b,a[1:0]})
            6'b0000_00:inter2 = 6'b000000;
            6'b0000_01:inter2 = 6'b000000;
            6'b0000_10:inter2 = 6'b000000;
            6'b0000_11:inter2 = 6'b000000;
            6'b0001_00:inter2 = 6'b000000;
            6'b0001_01:inter2 = 6'b000001;
            6'b0001_10:inter2 = 6'b000010;
            6'b0001_11:inter2 = 6'b000011;
            6'b0010_00:inter2 = 6'b000000;
            6'b0010_01:inter2 = 6'b000010;
            6'b0010_10:inter2 = 6'b000100;
            6'b0010_11:inter2 = 6'b000110;
            6'b0011_00:inter2 = 6'b000000;
            6'b0011_01:inter2 = 6'b000011;
            6'b0011_10:inter2 = 6'b000110;
            6'b0011_11:inter2 = 6'b001001;
            6'b0100_00:inter2 = 6'b000000;
            6'b0100_01:inter2 = 6'b000100;
            6'b0100_10:inter2 = 6'b001000;
            6'b0100_11:inter2 = 6'b001100;
            6'b0101_00:inter2 = 6'b000000;
            6'b0101_01:inter2 = 6'b000101;
            6'b0101_10:inter2 = 6'b001010;
            6'b0101_11:inter2 = 6'b001111;
            6'b0110_00:inter2 = 6'b000000;
            6'b0110_01:inter2 = 6'b000110;
            6'b0110_10:inter2 = 6'b001100;
            6'b0110_11:inter2 = 6'b010010;
            6'b0111_00:inter2 = 6'b000000;
            6'b0111_01:inter2 = 6'b000111;
            6'b0111_10:inter2 = 6'b001110;
            6'b0111_11:inter2 = 6'b010101;
            6'b1000_00:inter2 = 6'b000000;
            6'b1000_01:inter2 = 6'b001000;
            6'b1000_10:inter2 = 6'b010000;
            6'b1000_11:inter2 = 6'b011000;
            6'b1001_00:inter2 = 6'b000000;
            6'b1001_01:inter2 = 6'b001001;
            6'b1001_10:inter2 = 6'b010010;
            6'b1001_11:inter2 = 6'b011011;
            6'b1010_00:inter2 = 6'b000000;
            6'b1010_01:inter2 = 6'b001010;
            6'b1010_10:inter2 = 6'b010100;
            6'b1010_11:inter2 = 6'b011110;
            6'b1011_00:inter2 = 6'b000000;
            6'b1011_01:inter2 = 6'b001011;
            6'b1011_10:inter2 = 6'b010110;
            6'b1011_11:inter2 = 6'b100001;
            6'b1100_00:inter2 = 6'b000000;
            6'b1100_01:inter2 = 6'b001100;
            6'b1100_10:inter2 = 6'b011000;
            6'b1100_11:inter2 = 6'b100100;
            6'b1101_00:inter2 = 6'b000000;
            6'b1101_01:inter2 = 6'b001101;
            6'b1101_10:inter2 = 6'b011010;
            6'b1101_11:inter2 = 6'b100111;
            6'b1110_00:inter2 = 6'b000000;
            6'b1110_01:inter2 = 6'b001110;
            6'b1110_10:inter2 = 6'b011100;
            6'b1110_11:inter2 = 6'b101010;
            6'b1111_00:inter2 = 6'b000000;
            6'b1111_01:inter2 = 6'b001111;
            6'b1111_10:inter2 = 6'b011110;
            6'b1111_11:inter2 = 6'b101101;
            default: inter2 = 6'bxxxxxx;
        endcase
        // case (a[3:2])
        //     2'b00: inter1 = 6'b000000;
        //     2'b01: inter1 = {2'b0,b};
        //     2'b10: inter1 = {1'b0,b,1'b0};
        //     2'b11: inter1 = {1'b0,b,1'b0} + b;
        // endcase
        // case(a[1:0])
        //     2'b00: inter2 = 6'b000000;
        //     2'b01: inter2 = {2'b0,b};
        //     2'b10: inter2 = {1'b0,b,1'b0};
        //     2'b11: inter2 = {1'b0,b,1'b0} + b;
        // endcase
        multiply_4_2 = {inter1,2'b00} + inter2;
    end
endfunction

function [7:0] multiply;
    input [3:0] a;
    input [3:0] b;
    begin
        reg [3:0] inter1, inter2, inter3, inter4;
        case({a[3:2],b[3:2]})
            4'b0000: inter1 = 4'b0000; // 0
            4'b0001: inter1 = 4'b0000; // 0
            4'b0010: inter1 = 4'b0000; // 0
            4'b0011: inter1 = 4'b0000; // 0
            4'b0100: inter1 = 4'b0000; // 0
            4'b0101: inter1 = 4'b0001; // 1
            4'b0110: inter1 = 4'b0010; // 2
            4'b0111: inter1 = 4'b0011; // 3
            4'b1000: inter1 = 4'b0000; // 0
            4'b1001: inter1 = 4'b0010; // 2
            4'b1010: inter1 = 4'b0100; // 4
            4'b1011: inter1 = 4'b0110; // 6
            4'b1100: inter1 = 4'b0000; // 0
            4'b1101: inter1 = 4'b0011; // 3
            4'b1110: inter1 = 4'b0110; // 6
            4'b1111: inter1 = 4'b1001; // 9
        endcase
        case({a[1:0],b[3:2]})
            4'b0000: inter2 = 4'b0000; // 0
            4'b0001: inter2 = 4'b0000; // 0
            4'b0010: inter2 = 4'b0000; // 0
            4'b0011: inter2 = 4'b0000; // 0
            4'b0100: inter2 = 4'b0000; // 0
            4'b0101: inter2 = 4'b0001; // 1
            4'b0110: inter2 = 4'b0010; // 2
            4'b0111: inter2 = 4'b0011; // 3
            4'b1000: inter2 = 4'b0000; // 0
            4'b1001: inter2 = 4'b0010; // 2
            4'b1010: inter2 = 4'b0100; // 4
            4'b1011: inter2 = 4'b0110; // 6
            4'b1100: inter2 = 4'b0000; // 0
            4'b1101: inter2 = 4'b0011; // 3
            4'b1110: inter2 = 4'b0110; // 6
            4'b1111: inter2 = 4'b1001; // 9
        endcase
        case({a[3:2],b[1:0]})
            4'b0000: inter3 = 4'b0000; // 0
            4'b0001: inter3 = 4'b0000; // 0
            4'b0010: inter3 = 4'b0000; // 0
            4'b0011: inter3 = 4'b0000; // 0
            4'b0100: inter3 = 4'b0000; // 0
            4'b0101: inter3 = 4'b0001; // 1
            4'b0110: inter3 = 4'b0010; // 2
            4'b0111: inter3 = 4'b0011; // 3
            4'b1000: inter3 = 4'b0000; // 0
            4'b1001: inter3 = 4'b0010; // 2
            4'b1010: inter3 = 4'b0100; // 4
            4'b1011: inter3 = 4'b0110; // 6
            4'b1100: inter3 = 4'b0000; // 0
            4'b1101: inter3 = 4'b0011; // 3
            4'b1110: inter3 = 4'b0110; // 6
            4'b1111: inter3 = 4'b1001; // 9
        endcase
        case({a[1:0],b[1:0]})
            4'b0000: inter4 = 4'b0000; // 0
            4'b0001: inter4 = 4'b0000; // 0
            4'b0010: inter4 = 4'b0000; // 0
            4'b0011: inter4 = 4'b0000; // 0
            4'b0100: inter4 = 4'b0000; // 0
            4'b0101: inter4 = 4'b0001; // 1
            4'b0110: inter4 = 4'b0010; // 2
            4'b0111: inter4 = 4'b0011; // 3
            4'b1000: inter4 = 4'b0000; // 0
            4'b1001: inter4 = 4'b0010; // 2
            4'b1010: inter4 = 4'b0100; // 4
            4'b1011: inter4 = 4'b0110; // 6
            4'b1100: inter4 = 4'b0000; // 0
            4'b1101: inter4 = 4'b0011; // 3
            4'b1110: inter4 = 4'b0110; // 6
            4'b1111: inter4 = 4'b1001; // 9
        endcase
        multiply = {inter1,4'b0000} + ({inter2,2'b00}  + {inter3,2'b00}) + inter4;
    end
endfunction

function [7:0] multiply_3_1;
    input [3:0] a;
    input [3:0] b;
    begin
        reg [3:0] inter1, inter2;
        reg [5:0] inter3;
        reg inter4;
        inter1 = (b[0])? a[3:1]: 3'b000;
        inter2 = (a[0])? b[3:1]: 3'b000;
        case({a[3:1],b[3:1]})
            6'b000_000: inter3 = 6'd0;
            6'b000_001: inter3 = 6'd0;
            6'b000_010: inter3 = 6'd0;
            6'b000_011: inter3 = 6'd0;
            6'b000_100: inter3 = 6'd0;
            6'b000_101: inter3 = 6'd0;
            6'b000_110: inter3 = 6'd0;
            6'b000_111: inter3 = 6'd0;
            6'b001_000: inter3 = 6'd0;
            6'b001_001: inter3 = 6'd1;
            6'b001_010: inter3 = 6'd2;
            6'b001_011: inter3 = 6'd3;
            6'b001_100: inter3 = 6'd4;
            6'b001_101: inter3 = 6'd5;
            6'b001_110: inter3 = 6'd6;
            6'b001_111: inter3 = 6'd7;
            6'b010_000: inter3 = 6'd0;
            6'b010_001: inter3 = 6'd2;
            6'b010_010: inter3 = 6'd4;
            6'b010_011: inter3 = 6'd6;
            6'b010_100: inter3 = 6'd8;
            6'b010_101: inter3 = 6'd10;
            6'b010_110: inter3 = 6'd12;
            6'b010_111: inter3 = 6'd14;
            6'b011_000: inter3 = 6'd0;
            6'b011_001: inter3 = 6'd3;
            6'b011_010: inter3 = 6'd6;
            6'b011_011: inter3 = 6'd9;
            6'b011_100: inter3 = 6'd12;
            6'b011_101: inter3 = 6'd15;
            6'b011_110: inter3 = 6'd18;
            6'b011_111: inter3 = 6'd21;
            6'b100_000: inter3 = 6'd0;
            6'b100_001: inter3 = 6'd4;
            6'b100_010: inter3 = 6'd8;
            6'b100_011: inter3 = 6'd12;
            6'b100_100: inter3 = 6'd16;
            6'b100_101: inter3 = 6'd20;
            6'b100_110: inter3 = 6'd24;
            6'b100_111: inter3 = 6'd28;
            6'b101_000: inter3 = 6'd0;
            6'b101_001: inter3 = 6'd5;
            6'b101_010: inter3 = 6'd10;
            6'b101_011: inter3 = 6'd15;
            6'b101_100: inter3 = 6'd20;
            6'b101_101: inter3 = 6'd25;
            6'b101_110: inter3 = 6'd30;
            6'b101_111: inter3 = 6'd35;
            6'b110_000: inter3 = 6'd0;
            6'b110_001: inter3 = 6'd6;
            6'b110_010: inter3 = 6'd12;
            6'b110_011: inter3 = 6'd18;
            6'b110_100: inter3 = 6'd24;
            6'b110_101: inter3 = 6'd30;
            6'b110_110: inter3 = 6'd36;
            6'b110_111: inter3 = 6'd42;
            6'b111_000: inter3 = 6'd0;
            6'b111_001: inter3 = 6'd7;
            6'b111_010: inter3 = 6'd14;
            6'b111_011: inter3 = 6'd21;
            6'b111_100: inter3 = 6'd28;
            6'b111_101: inter3 = 6'd35;
            6'b111_110: inter3 = 6'd42;
            6'b111_111: inter3 = 6'd49;
            default: inter3 = 6'dx;
        endcase
        inter4 = (a[0] & b[0]);
        multiply_3_1 = ({inter1,1'b0} + {inter2,1'b0} + {inter3,2'b00} + inter4);
    end
endfunction

function is_zero;
    input [7:0] a;
    begin
        is_zero = 0;
        case(a)
            // 8'd140: is_zero = 1;
            // 8'd130: is_zero = 1;
            8'd120: is_zero = 1;
            8'd110: is_zero = 1;
            8'd100: is_zero = 1;
            8'd90: is_zero = 1;
            8'd80: is_zero = 1;
            8'd70: is_zero = 1;
            8'd60: is_zero = 1;
            8'd50: is_zero = 1;
            // 8'd40: is_zero = 1;
            // 8'd30: is_zero = 1;
            // 8'd20: is_zero = 1;
            // 8'd10: is_zero = 1;
            // 8'd0: is_zero = 1;
        endcase
    end
endfunction


function [8:0] remain_change;
    input out_valid;
    input [8:0] input_money;
    input [7:0] total_sorted [0:7];
    reg signed [9:0] sub_temp [0:7];
    reg [0:7] leading_zero;
    begin
        sub_temp[0] = (out_valid)? input_money - total_sorted[0] : 10'b1000000000;
        sub_temp[1] = (out_valid)? sub_temp[0] - total_sorted[1] : 10'b1000000000;
        sub_temp[2] = (out_valid)? sub_temp[1] - total_sorted[2] : 10'b1000000000;
        sub_temp[3] = (out_valid)? sub_temp[2] - total_sorted[3] : 10'b1000000000;
        sub_temp[4] = (out_valid)? sub_temp[3] - total_sorted[4] : 10'b1000000000;
        sub_temp[5] = (out_valid)? sub_temp[4] - total_sorted[5] : 10'b1000000000;
        sub_temp[6] = (out_valid)? sub_temp[5] - total_sorted[6] : 10'b1000000000;
        sub_temp[7] = (out_valid)? sub_temp[6] - total_sorted[7] : 10'b1000000000;

        // leading_zero[0] = sub_temp[0][15];
        // leading_zero[1] = sub_temp[1][15];
        // leading_zero[2] = sub_temp[2][15];
        // leading_zero[3] = sub_temp[3][15];
        // leading_zero[4] = sub_temp[4][15];
        // leading_zero[5] = sub_temp[5][15];
        // leading_zero[6] = sub_temp[6][15];
        // leading_zero[7] = sub_temp[7][15];

        // $display("leading_zero: %b", leading_zero);
        // case (leading_zero) 
        //     8'b00000000: remain_change = sub_temp[7][8:0];
        //     8'b00000001: remain_change = sub_temp[6][8:0];
        //     8'b00000011: remain_change = sub_temp[5][8:0];
        //     8'b00000111: remain_change = sub_temp[4][8:0];
        //     8'b00001111: remain_change = sub_temp[3][8:0];
        //     8'b00011111: remain_change = sub_temp[2][8:0];
        //     8'b00111111: remain_change = sub_temp[1][8:0];
        //     8'b01111111: remain_change = sub_temp[0][8:0];
        //     8'b11111111: remain_change = input_money;
        //     default: remain_change = 15'bx;
        // endcase

        // case (1'b1)
        //     leading_zero[0]: remain_change = input_money;
        //     leading_zero[1]: remain_change = sub_temp[0][8:0];
        //     leading_zero[2]: remain_change = sub_temp[1][8:0];
        //     leading_zero[3]: remain_change = sub_temp[2][8:0];
        //     leading_zero[4]: remain_change = sub_temp[3][8:0];
        //     leading_zero[5]: remain_change = sub_temp[4][8:0];
        //     leading_zero[6]: remain_change = sub_temp[5][8:0];
        //     leading_zero[7]: remain_change = sub_temp[6][8:0];
        //     default: remain_change = sub_temp[7][8:0];
        // endcase

        // case (leading_zero[4:7])
        //     4'b0000: remain_change = sub_temp[7];
        //     4'b0001: remain_change = sub_temp[6];
        //     4'b0011: remain_change = sub_temp[5];
        //     4'b0111: remain_change = sub_temp[4];
        //     4'b1111: remain_change = sub_temp[3];
        //     default: remain_change = 16'bx;
        // endcase

        // if (&(leading_zero[4:7]))
        //     case(leading_zero[0:3])
        //         4'b0000: remain_change = sub_temp[3];
        //         4'b0001: remain_change = sub_temp[2];
        //         4'b0011: remain_change = sub_temp[1];
        //         4'b0111: remain_change = sub_temp[0];
        //         4'b1111: remain_change = input_money;
        //         default: remain_change = 16'bx;
        //     endcase

        remain_change = sub_temp[7];
        if (sub_temp[7][9]) begin
            remain_change = sub_temp[6];
            if (sub_temp[6][9]) begin
                remain_change = sub_temp[5];
            end
        end
        
        if (sub_temp[5][9]) begin
            remain_change = sub_temp[4];
            if (sub_temp[4][9]) begin
                remain_change = sub_temp[3];
            end
        end
        
        if (sub_temp[3][9]) begin
            remain_change = sub_temp[2];
            if (sub_temp[2][9]) begin
                remain_change = sub_temp[1];
            end
        end
        
        if (sub_temp[1][9]) begin
            remain_change = sub_temp[0];
            if (sub_temp[0][9]) begin
                remain_change = input_money;
            end
        end
        

    end

endfunction

function [3:0] four_to_one;
    input [3:0] a,b,c,d;
    reg [5:0] temp;
    begin
        temp = (a + b + c + d);
        four_to_one = temp;
        case(temp)
        6'd0: four_to_one = 4'd0;
        6'd1: four_to_one = 4'd1;
        6'd2: four_to_one = 4'd2;
        6'd3: four_to_one = 4'd3;
        6'd4: four_to_one = 4'd4;
        6'd5: four_to_one = 4'd5;
        6'd6: four_to_one = 4'd6;
        6'd7: four_to_one = 4'd7;
        6'd8: four_to_one = 4'd8;
        6'd9: four_to_one = 4'd9;
        6'd10: four_to_one = 4'd0;
        6'd11: four_to_one = 4'd1;
        6'd12: four_to_one = 4'd2;
        6'd13: four_to_one = 4'd3;
        6'd14: four_to_one = 4'd4;
        6'd15: four_to_one = 4'd5;
        6'd16: four_to_one = 4'd6;
        6'd17: four_to_one = 4'd7;
        6'd18: four_to_one = 4'd8;
        6'd19: four_to_one = 4'd9;
        6'd20: four_to_one = 4'd0;
        6'd21: four_to_one = 4'd1;
        6'd22: four_to_one = 4'd2;
        6'd23: four_to_one = 4'd3;
        6'd24: four_to_one = 4'd4;
        6'd25: four_to_one = 4'd5;
        6'd26: four_to_one = 4'd6;
        6'd27: four_to_one = 4'd7;
        6'd28: four_to_one = 4'd8;
        6'd29: four_to_one = 4'd9;
        6'd30: four_to_one = 4'd0;
        6'd31: four_to_one = 4'd1;
        6'd32: four_to_one = 4'd2;
        6'd33: four_to_one = 4'd3;
        6'd34: four_to_one = 4'd4;
        6'd35: four_to_one = 4'd5;
        6'd36: four_to_one = 4'd6;
        6'd37: four_to_one = 4'd7;
        6'd38: four_to_one = 4'd8;
        6'd39: four_to_one = 4'd9;
        6'd40: four_to_one = 4'd0;
        6'd41: four_to_one = 4'd1;
        6'd42: four_to_one = 4'd2;
        6'd43: four_to_one = 4'd3;
        6'd44: four_to_one = 4'd4;
        6'd45: four_to_one = 4'd5;
        6'd46: four_to_one = 4'd6;
        6'd47: four_to_one = 4'd7;
        6'd48: four_to_one = 4'd8;
        6'd49: four_to_one = 4'd9;
        6'd50: four_to_one = 4'd0;
        6'd51: four_to_one = 4'd1;
        6'd52: four_to_one = 4'd2;
        6'd53: four_to_one = 4'd3;
        6'd54: four_to_one = 4'd4;
        6'd55: four_to_one = 4'd5;
        6'd56: four_to_one = 4'd6;
        6'd57: four_to_one = 4'd7;
        6'd58: four_to_one = 4'd8;
        6'd59: four_to_one = 4'd9;
        6'd60: four_to_one = 4'd0;
        6'd61: four_to_one = 4'd1;
        6'd62: four_to_one = 4'd2;
        6'd63: four_to_one = 4'd3;
        default: four_to_one = 4'dx;
        endcase
    end
endfunction


always @(*) begin
    out_change = input_money;
    // do the ID
    // out_valid = is_zero((even[card_num[63:60]] + even[card_num[55:52]] + even[card_num[47:44]] + even[card_num[39:36]]) + 
    //                (even[card_num[31:28]] + even[card_num[23:20]] + even[card_num[15:12]] + even[card_num[7:4]]) +
    //                (card_num[59:56] + card_num[51:48] + card_num[43:40] + card_num[35:32]) + 
    //                (card_num[27:24] + card_num[19:16] + card_num[11:8] + card_num[3:0]));
    
    out_valid = is_zero((even[card_num[63:60]] + even[card_num[55:52]] + (card_num[59:56] + card_num[51:48])) + 
                        (even[card_num[47:44]] + even[card_num[39:36]] + (card_num[43:40] + card_num[35:32])) +
                        (even[card_num[31:28]] + even[card_num[23:20]] + (card_num[27:24] + card_num[19:16])) + 
                        (even[card_num[15:12]] + even[card_num[7:4]] + (card_num[11:8] + card_num[3:0])));
                   
    // out_valid = !four_to_one((four_to_one(even[card_num[63:60]], even[card_num[55:52]], even[card_num[47:44]], even[card_num[39:36]])), 
    //                 (four_to_one(even[card_num[31:28]], even[card_num[23:20]], even[card_num[15:12]], even[card_num[7:4]])),
    //                 (four_to_one(card_num[59:56], card_num[51:48], card_num[43:40], card_num[35:32])), 
    //                 (four_to_one(card_num[27:24], card_num[19:16], card_num[11:8], card_num[3:0])));

    // out_valid = !four_to_one((four_to_one(even[card_num[63:60]], card_num[59:56], even[card_num[55:52]], card_num[51:48])), 
    //                 (four_to_one(even[card_num[47:44]], card_num[43:40], even[card_num[39:36]], card_num[35:32])),
    //                 (four_to_one(even[card_num[31:28]], card_num[27:24], even[card_num[23:20]], card_num[19:16])), 
    //                 (four_to_one(even[card_num[15:12]], card_num[11:8], even[card_num[7:4]], card_num[3:0])));

    total[0] = multiply(snack_num[31:28], price[31:28]);
    total[1] = multiply(snack_num[27:24], price[27:24]);
    total[2] = multiply(snack_num[23:20], price[23:20]);
    total[3] = multiply(snack_num[19:16], price[19:16]);
    total[4] = multiply(snack_num[15:12], price[15:12]);
    total[5] = multiply(snack_num[11:8], price[11:8]);
    total[6] = multiply(snack_num[7:4], price[7:4]);
    total[7] = multiply(snack_num[3:0], price[3:0]);

    // Stage 0: [(0,2), (1,3), (4,6), (5,7)]
    stage0 = total;
    sub_temp = total[0] - total[2];
    if (sub_temp[8]) begin
        stage0[0] = total[2];
        stage0[2] = total[0];
    end
    sub_temp = total[1] - total[3];
    if (sub_temp[8]) begin
        stage0[1] = total[3];
        stage0[3] = total[1];
    end

    sub_temp = total[4] - total[6];
    if (sub_temp[8]) begin
        stage0[4] = total[6];
        stage0[6] = total[4];
    end

    sub_temp = total[5] - total[7];
    if (sub_temp[8]) begin
        stage0[5] = total[7];
        stage0[7] = total[5];
    end

    // Stage 1: [(0,4), (1,5), (2,6), (3,7)]
    stage1 = stage0;

    sub_temp = stage0[0] - stage0[4];
    if (sub_temp[8]) begin
        stage1[0] = stage0[4];
        stage1[4] = stage0[0];
    end

    sub_temp = stage0[1] - stage0[5];
    if (sub_temp[8]) begin
        stage1[1] = stage0[5];
        stage1[5] = stage0[1];
    end

    sub_temp = stage0[2] - stage0[6];
    if (sub_temp[8]) begin
        stage1[2] = stage0[6];
        stage1[6] = stage0[2];
    end
    
    sub_temp = stage0[3] - stage0[7];
    if (sub_temp[8]) begin
        stage1[3] = stage0[7];
        stage1[7] = stage0[3];
    end


    // Stage 2: [(0,1), (2,3), (4,5), (6,7)]
    stage2 = stage1;

    sub_temp = stage1[0] - stage1[1];
    if (sub_temp[8]) begin
        stage2[0] = stage1[1];
        stage2[1] = stage1[0];
        end

    sub_temp = stage1[2] - stage1[3];
    if (sub_temp[8]) begin
        stage2[2] = stage1[3];
        stage2[3] = stage1[2];
    end

    sub_temp = stage1[4] - stage1[5];
    if (sub_temp[8]) begin
        stage2[4] = stage1[5];
        stage2[5] = stage1[4];
    end

    sub_temp = stage1[6] - stage1[7];
    if (sub_temp[8]) begin
        stage2[6] = stage1[7];
        stage2[7] = stage1[6];
    end


    // Stage 3: [(2,4), (3,5)]
    stage3 = stage2;

    sub_temp = stage2[2] - stage2[4];
    if (sub_temp[8]) begin
        stage3[2] = stage2[4];
        stage3[4] = stage2[2];
    end

    sub_temp = stage2[3] - stage2[5];
    if (sub_temp[8]) begin
        stage3[3] = stage2[5];
        stage3[5] = stage2[3];
    end

    // Stage 4: [(1,4), (3,6)]
    stage4 = stage3;

    sub_temp = stage3[1] - stage3[4];
    if (sub_temp[8]) begin
        stage4[1] = stage3[4];
        stage4[4] = stage3[1];
    end

    sub_temp = stage3[3] - stage3[6];
    if (sub_temp[8]) begin
        stage4[3] = stage3[6];
        stage4[6] = stage3[3];
    end

    // Stage 5: [(1,2), (3,4), (5,6)]
    total_sorted = stage4;

    sub_temp = stage4[1] - stage4[2];
    if (sub_temp[8]) begin
        total_sorted[1] = stage4[2];
        total_sorted[2] = stage4[1];
    end

    sub_temp = stage4[3] - stage4[4];
    if (sub_temp[8]) begin
        total_sorted[3] = stage4[4];
        total_sorted[4] = stage4[3];
    end

    sub_temp = stage4[5] - stage4[6];
    if (sub_temp[8]) begin
        total_sorted[5] = stage4[6];
        total_sorted[6] = stage4[5];
    end

    // out_change_temp = remain_change(input_money, total_sorted);
    // if (out_valid)
        out_change = remain_change(out_valid,input_money, total_sorted);
end
endmodule