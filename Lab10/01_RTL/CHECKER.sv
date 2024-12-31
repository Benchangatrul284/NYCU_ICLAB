/*
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
NYCU Institute of Electronic
2023 Autumn IC Design Laboratory 
Lab10: SystemVerilog Coverage & Assertion
File Name   : CHECKER.sv
Module Name : CHECKER
Release version : v1.0 (Release Date: Nov-2023)
Author : Jui-Huang Tsai (erictsai.10@nycu.edu.tw)
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/

`include "Usertype.sv"
module Checker(input clk, INF.CHECKER inf);
import usertype::*;

// integer fp_w;

// initial begin
// fp_w = $fopen("out_valid.txt", "w");
// end

/**
 * This section contains the definition of the class and the instantiation of the object.
 *  * 
 * The always_ff blocks update the object based on the values of valid signals.
 * When valid signal is true, the corresponding property is updated with the value of inf.D
 */

class Formula_and_mode;
    Formula_Type f_type;
    Mode f_mode;
endclass

Formula_and_mode fm_radio = new();

always_ff @(posedge clk iff inf.formula_valid) begin
    fm_radio.f_type = inf.D.d_formula[0];
end

always_ff @(posedge clk iff inf.mode_valid) begin
    fm_radio.f_mode = inf.D.d_mode[0];
end

covergroup CG_1_2_3 @(negedge clk iff inf.mode_valid);
    option.at_least = 150;
    coverpoint fm_radio.f_type{
        bins bin_formula [] = {Formula_A, Formula_B, Formula_C, Formula_D, Formula_E, Formula_F, Formula_G, Formula_H};
    }
    coverpoint fm_radio.f_mode{
        bins bin_mode [] = {Insensitive, Normal, Sensitive};
    }
    cross fm_radio.f_type, fm_radio.f_mode;
endgroup

covergroup CG_4 @(posedge clk iff inf.out_valid);
    option.at_least = 50;
    coverpoint inf.warn_msg{
        bins bin_msg [] = {No_Warn, Date_Warn, Data_Warn, Risk_Warn};
    }
endgroup


// covergroup CG_5 @(posedge clk iff inf.sel_action_valid);
//     option.at_least = 300;
//     coverpoint inf.D.d_act[0] {
//         bins b_act_trains[] = ([Index_Check:Check_Valid_Date] => [Index_Check:Check_Valid_Date]);
//     }
// endgroup


// Action act_now;
// Action act_previous;
// always_ff @(posedge clk iff inf.sel_action_valid) begin
//         act_previous = act_now;
//         act_now = inf.D.d_act[0];
// end

covergroup CG_5 @(posedge clk iff inf.sel_action_valid);
    option.at_least = 300;
    coverpoint inf.D.d_act[0]{
        bins act_trans [] = (Index_Check, Update, Check_Valid_Date => Index_Check, Update, Check_Valid_Date); 
    }
endgroup

Action action_reg;
always_ff @(posedge clk iff inf.sel_action_valid) begin
    action_reg = inf.D.d_act[0];
end

covergroup CG_6 @(posedge clk iff (inf.index_valid && action_reg == Update));
    option.at_least = 1;
    option.auto_bin_max = 32;
    coverpoint inf.D.d_index[0];
endgroup

CG_1_2_3 CG_1_2_inst = new();
CG_4 CG_4_inst = new();
CG_5 CG_5_inst = new();
CG_6 CG_6_inst = new();

/*
    Asseration
*/

/*
    1. All outputs signals should be zero after reset.
*/


property SPEC_1;
    @(posedge inf.rst_n) 1 |-> @(posedge clk)
    (inf.complete === 1'b0) && (inf.out_valid === 1'b0) && (inf.warn_msg === No_Warn)
    && (inf.AR_VALID === 1'b0) && (inf.AR_ADDR === 17'b0) && (inf.R_READY === 1'b0)
    && (inf.AW_VALID === 1'b0) && (inf.AW_ADDR === 17'b0) && (inf.W_VALID === 1'b0) && (inf.W_DATA === 64'b0);
endproperty: SPEC_1


assert property(SPEC_1) else begin
    $display("                 Assertion 1 is violated                     ");
    $fatal;
end

/*
    2. Latency should be less that 1000 cycles
*/

property SPEC_2;
    @(posedge clk) (inf.sel_action_valid) |-> ##[1:999] inf.out_valid;
endproperty

assert property(SPEC_2) else begin
    $display("                 Assertion 2 is violated                     ");
    $fatal;
end

/*
    3. If action is completed (1), warn_msg should be No_Warn
*/

// need to check at negedge of clk otherwise pattern will check first
property SPEC_3;
    @(negedge clk) (inf.out_valid!==0 && inf.complete) |-> inf.warn_msg === No_Warn; 
endproperty


assert property(SPEC_3) else begin
    $display("                 Assertion 3 is violated                     ");
    $fatal;
end

/*
    4. Next input valid will be valid 1-4 cycles after previous input valid fall.
*/

property SPEC_4_IndexCheck;
    @(posedge clk) (inf.sel_action_valid && inf.D.d_act[0] === Index_Check) |-> 
    ##[1:4] inf.formula_valid 
    ##[1:4] inf.mode_valid 
    ##[1:4] inf.date_valid 
    ##[1:4] inf.data_no_valid
    ##[1:4] inf.index_valid
    ##[1:4] inf.index_valid
    ##[1:4] inf.index_valid
    ##[1:4] inf.index_valid;
endproperty

property SPEC_4_Update;
    @(posedge clk) (inf.sel_action_valid && inf.D.d_act[0] === Update) |-> 
    ##[1:4] inf.date_valid 
    ##[1:4] inf.data_no_valid
    ##[1:4] inf.index_valid
    ##[1:4] inf.index_valid
    ##[1:4] inf.index_valid 
    ##[1:4] inf.index_valid; 
endproperty

property SPEC_4_CheckValidDate;
    @(posedge clk) (inf.sel_action_valid && inf.D.d_act[0] === Check_Valid_Date) |-> 
    ##[1:4] inf.date_valid 
    ##[1:4] inf.data_no_valid; 
endproperty

assert property(SPEC_4_IndexCheck) else begin
    // $display("                   SPEC_4_IndexCheck                         ");
    $display("                 Assertion 4 is violated                     ");
    $fatal;
end
assert property(SPEC_4_Update) else begin
    // $display("                     SPEC_4_Update                           ");
    $display("                 Assertion 4 is violated                     ");
    $fatal;
end
assert property(SPEC_4_CheckValidDate) else begin
    // $display("                 SPEC_4_CheckValidDate                      ");
    $display("                 Assertion 4 is violated                     ");
    $fatal;
end

/*
    5. All input valid signals won't overlap with each other. 
*/
// There are total sel_action_valid, formula_valid, mode_valid, date_valid, data_no_valid, index_valid
// valid signal, if one of them is high, the others should be low

property SPEC_5_sel_action_valid;
    @(posedge clk) inf.sel_action_valid |-> 
    !inf.formula_valid && !inf.mode_valid && !inf.date_valid && !inf.data_no_valid && !inf.index_valid; 
endproperty

property SPEC_5_formula_valid;
    @(posedge clk) inf.formula_valid |->
    !inf.sel_action_valid && !inf.mode_valid && !inf.date_valid && !inf.data_no_valid && !inf.index_valid;
endproperty

property SPEC_5_mode_valid;
    @(posedge clk) inf.mode_valid |->
    !inf.sel_action_valid && !inf.formula_valid && !inf.date_valid && !inf.data_no_valid && !inf.index_valid;
endproperty

property SPEC_5_date_valid;
    @(posedge clk) inf.date_valid |->
    !inf.sel_action_valid && !inf.formula_valid && !inf.mode_valid && !inf.data_no_valid && !inf.index_valid;
endproperty

property SPEC_5_data_no_valid;
    @(posedge clk) inf.data_no_valid |->
    !inf.sel_action_valid && !inf.formula_valid && !inf.mode_valid && !inf.date_valid && !inf.index_valid;
endproperty

property SPEC_5_index_valid;
    @(posedge clk) inf.index_valid |->
    !inf.sel_action_valid && !inf.formula_valid && !inf.mode_valid && !inf.date_valid && !inf.data_no_valid;
endproperty

assert property(SPEC_5_sel_action_valid) else begin
    $display("                 Assertion 5 is violated                     ");
    $fatal;
end
assert property(SPEC_5_formula_valid) else begin
    $display("                 Assertion 5 is violated                     ");
    $fatal;
end
assert property(SPEC_5_mode_valid) else begin
    $display("                 Assertion 5 is violated                     ");
    $fatal;
end
assert property(SPEC_5_date_valid) else begin
    $display("                 Assertion 5 is violated                     ");
    $fatal;
end
assert property(SPEC_5_data_no_valid) else begin
    $display("                 Assertion 5 is violated                     ");
    $fatal;
end
assert property(SPEC_5_index_valid) else begin
    $display("                 Assertion 5 is violated                     ");
    $fatal;
end

/*
    6. Out_valid can only be high for exactly one cycle.
*/
property SPEC_6;
    @(posedge clk) inf.out_valid!==0 |=> !inf.out_valid; 
endproperty

assert property(SPEC_6) else begin
    $display("                 Assertion 6 is violated                     ");
    $fatal;
end

/*
    7. Next operation will be valid 1-4 cycles after out_valid fall.
*/
property SPEC_7;
    @(posedge clk) inf.out_valid  |-> ##[1:4] inf.sel_action_valid; 
endproperty

assert property(SPEC_7) else begin
    $display("                 Assertion 7 is violated                     ");
    $fatal;
end

/*
    8. The input date from pattern should adhere to the real calendar. (ex: 2/29, 3/0, 4/31, 13/1 are illegal cases)
*/
property SPEC_8_MONTH;
    @(posedge clk) 
    inf.date_valid |-> inf.D.d_date[0].M inside {[1:12]}; 
endproperty

property SPEC_8_31;
    @(posedge clk) 
    inf.date_valid && (inf.D.d_date[0].M==1 || inf.D.d_date[0].M==3 || inf.D.d_date[0].M==5 || inf.D.d_date[0].M==7 || inf.D.d_date[0].M==8 || inf.D.d_date[0].M==10 || inf.D.d_date[0].M==12)
    |-> inf.D.d_date[0].D inside {[1:31]}; 
endproperty

property SPEC_8_28;
    @(posedge clk) 
    inf.date_valid && inf.D.d_date[0].M==2 |-> inf.D.d_date[0].D inside {[1:28]}; 
endproperty

property SPEC_8_30;
    @(posedge clk) 
    inf.date_valid && (inf.D.d_date[0].M==4 || inf.D.d_date[0].M==6 || inf.D.d_date[0].M==9 || inf.D.d_date[0].M==11)
    |-> inf.D.d_date[0].D inside {[1:30]}; 
endproperty



assert property(SPEC_8_MONTH) else begin
    // $display("                       SPEC_8_MONTH                          ");
    $display("                 Assertion 8 is violated                     ");
    $fatal;
end
assert property(SPEC_8_31) else begin
    // $display("                       SPEC_8_JAN                            ");
    $display("                 Assertion 8 is violated                     ");
    $fatal;
end
assert property(SPEC_8_28) else begin
    // $display("                        SPEC_8_FEB                           ");
    $display("                 Assertion 8 is violated                     ");
    $fatal;
end
assert property(SPEC_8_30) else begin
    $display("                 Assertion 8 is violated                     ");
    $fatal;
end

/*
    9. AR_VALID signal should not overlap with AW_VALID signal.
*/
property SPEC_9;
    @(posedge clk) inf.AR_VALID |-> !inf.AW_VALID;
endproperty

assert property(SPEC_9) else begin
    $display("                 Assertion 9 is violated                     ");
    $fatal;
end

endmodule