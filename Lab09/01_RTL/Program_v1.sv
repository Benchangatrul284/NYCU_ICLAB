module Program(input clk, INF.Program_inf inf);
import usertype::*;



// modport Program_inf(
//         input rst_n, sel_action_valid, formula_valid, mode_valid, date_valid, data_no_valid, index_valid, D,
//             AR_READY, R_VALID, R_RESP, R_DATA, AW_READY, W_READY, B_VALID, B_RESP,
//         output out_valid, warn_msg, complete,
//             AR_VALID, AR_ADDR, R_READY, AW_VALID, AW_ADDR, W_VALID, W_DATA, B_READY
//     );

logic out_valid_next;
Warn_Msg warn_msg_next;
logic complete_next;


enum logic [8:0] {IDLE, DRAM_READ_state1, DRAM_READ_state2,
                  Wait_IndexCheck_state, CALC_IndexCheck_state1,CALC_IndexCheck_state2,
                  Wait_CheckValidDate_state, CALC_CheckValidDate_state,
                  Update_state} current_state, next_state;
                      

// IDLE: wait for sel_action_valid
// Wait_IndexCheck_state: wait data from pattern
// DRAM_IndexCheck_state1: wait data from DRAM (pull high AR_VALID and AR_ADDR) -> go to next state if AR_READY is high
// DRAM_IndexCheck_state2: pull high R_READY and wait for data from DRAM -> go to next state if R_VALID is high
// CALC_IndexCheck_state1: read data from DRAM and calculate the month and determine whether to directly output
// Wait_CheckValidDate_state: wait for date_valid and data_no_valid (from pattern)
// DRAM_CheckValidDate_state1: wait data from DRAM (pull high AR_VALID and AR_ADDR) -> go to next state if AR_READY is high
// DRAM_CheckValidDate_state2: pull high R_READY and wait for data from DRAM -> go to next state if R_VALID is high
// DRAM_CheckValidDate_state3: read data from DRAM and calculate the month and determine whether to directly output
// CALC_CheckValidDate_state: check if date is valid

logic [9:0] cnt, cnt_next;

// input buffer
Action act_reg, act_comb;
Date date_reg, date_comb;
Data_No data_no_reg, data_no_comb;
Formula_Type formula_reg, formula_comb;
Mode mode_reg, mode_comb;
Index Pattern_Index_reg [0:3]; // index from pattern (late trading index)
Index Pattern_Index_comb [0:3]; // index from pattern (late trading index)


always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        date_reg <= 0;
        data_no_reg <= 0;
        formula_reg <= 0;
        mode_reg <= 0;
        act_reg <= 0;
    end
    else begin
        date_reg <= date_comb;
        data_no_reg <= data_no_comb;
        formula_reg <= formula_comb;
        mode_reg <= mode_comb;
        act_reg <= act_comb;
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        for (int i=0; i<4; i++) begin
            Pattern_Index_reg[i] <= 0;
        end
    end
    else begin
        Pattern_Index_reg <= Pattern_Index_comb;
    end
end


always_comb begin
    act_comb = act_reg;
    if (inf.sel_action_valid) begin
        act_comb = inf.D.d_act[0];
    end
end

always_comb begin
    date_comb = date_reg;
    if (inf.date_valid) begin
        date_comb = inf.D.d_date[0];
    end
end

always_comb begin
    data_no_comb = data_no_reg;
    if (inf.data_no_valid) begin
        data_no_comb = inf.D.d_data_no[0];
    end
end

always_comb begin
    formula_comb = formula_reg;
    if (inf.formula_valid) begin
        formula_comb = inf.D.d_formula[0];
    end
end

always_comb begin
    mode_comb = mode_reg;
    if (inf.mode_valid) begin
        mode_comb = inf.D.d_mode[0];
    end
end

// we may need to sort this array
always_comb begin
    Pattern_Index_comb = Pattern_Index_reg;
    case (current_state)
    Wait_IndexCheck_state: begin
        if (inf.index_valid) begin
            Pattern_Index_comb[3] = inf.D.d_index[0];
            Pattern_Index_comb[0:2] = Pattern_Index_reg[1:3];
        end
    end
    endcase
end

// cnt 
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        cnt <= 0;
    end
    else begin
        cnt <= cnt_next;
    end
end

// state
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end
end

// output signals
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.out_valid <= 0;
        inf.complete <= 0;
        inf.warn_msg <= No_Warn;
    end
    else begin
        inf.out_valid <= out_valid_next;
        inf.complete <= complete_next;
        inf.warn_msg <= warn_msg_next;
    end
end


// simple assign to make more readable
logic [7:0] R_month_reg;
logic [7:0] R_day_reg;
logic [11:0] R_indexA_reg;
logic [11:0] R_indexB_reg;
logic [11:0] R_indexC_reg;
logic [11:0] R_indexD_reg;
always_ff @(posedge clk) begin
    case (current_state)
    DRAM_READ_state2: begin
        R_indexA_reg <= inf.R_DATA[63:52];
        R_indexB_reg <= inf.R_DATA[51:40];
        R_month_reg <= inf.R_DATA[39:32];
        R_indexC_reg <= inf.R_DATA[31:20];
        R_indexD_reg <= inf.R_DATA[19:8];
        R_day_reg <= inf.R_DATA[7:0];
    end
    endcase
end

// sorted data from DRAM
logic [11:0] R_indexA_sorted_reg, R_indexA_sorted_comb;
logic [11:0] R_indexB_sorted_reg, R_indexB_sorted_comb;
logic [11:0] R_indexC_sorted_reg, R_indexC_sorted_comb;
logic [11:0] R_indexD_sorted_reg, R_indexD_sorted_comb;

always_ff @(posedge clk) begin
    R_indexA_sorted_reg <= R_indexA_sorted_comb;
    R_indexB_sorted_reg <= R_indexB_sorted_comb;
    R_indexC_sorted_reg <= R_indexC_sorted_comb;
    R_indexD_sorted_reg <= R_indexD_sorted_comb;
end

// difference between index from DRAM and pattern
logic [11:0] G_indexA_comb, G_indexB_comb, G_indexC_comb, G_indexD_comb;
logic [11:0] G_indexA_reg, G_indexB_reg, G_indexC_reg, G_indexD_reg;
always_ff @(posedge clk) begin
    G_indexA_reg <= G_indexA_comb;
    G_indexB_reg <= G_indexB_comb;
    G_indexC_reg <= G_indexC_comb;
    G_indexD_reg <= G_indexD_comb;
end

// DRAM read logic
logic AR_VALID_next; 
logic [16:0] AR_ADDR_next;
logic R_READY_next;

always_ff @(posedge clk or negedge inf.rst_n)begin
    if (!inf.rst_n) begin
        inf.AR_VALID <= 0;
        inf.AR_ADDR <= 0;
        inf.R_READY <= 0;
    end
    else begin
        inf.AR_VALID <= AR_VALID_next;
        inf.AR_ADDR <= AR_ADDR_next;
        inf.R_READY <= R_READY_next;
    end
end

// sorting module
logic [11:0] sort_indexA, sort_indexB, sort_indexC, sort_indexD; // input
logic [11:0] sort_temp1_A, sort_temp1_B, sort_temp1_C, sort_temp1_D;
logic [11:0] sort_temp2_A, sort_temp2_B, sort_temp2_C, sort_temp2_D;
logic [11:0] sort_temp3_A, sort_temp3_B, sort_temp3_C, sort_temp3_D;
logic [11:0] sorted_indexA, sorted_indexB, sorted_indexC, sorted_indexD; // output

always_comb begin
    // stage 1
    sort_temp1_A = sort_indexA;
    sort_temp1_B = sort_indexB;
    sort_temp1_C = sort_indexC;
    sort_temp1_D = sort_indexD;

    if (sort_indexA > sort_indexB) begin
        sort_temp1_A = sort_indexB;
        sort_temp1_B = sort_indexA;
    end
    if (sort_indexC > sort_indexD) begin
        sort_temp1_C = sort_indexD;
        sort_temp1_D = sort_indexC;
    end

    // stage 2
    sort_temp2_A = sort_temp1_A;
    sort_temp2_B = sort_temp1_B;
    sort_temp2_C = sort_temp1_C;
    sort_temp2_D = sort_temp1_D;

    if (sort_temp1_B > sort_temp1_C) begin
        sort_temp2_B = sort_temp1_C;
        sort_temp2_C = sort_temp1_B;
    end

    // stage 3
    sort_temp3_A = sort_temp2_A;
    sort_temp3_B = sort_temp2_B;
    sort_temp3_C = sort_temp2_C;
    sort_temp3_D = sort_temp2_D;

    if (sort_temp2_A > sort_temp2_B) begin
        sort_temp3_A = sort_temp2_B;
        sort_temp3_B = sort_temp2_A;
    end
    if (sort_temp2_C > sort_temp2_D) begin
        sort_temp3_C = sort_temp2_D;
        sort_temp3_D = sort_temp2_C;
    end

    // stage 4
    sorted_indexA = sort_temp3_A;
    sorted_indexB = sort_temp3_B;
    sorted_indexC = sort_temp3_C;
    sorted_indexD = sort_temp3_D;

    if (sort_temp3_B > sort_temp3_C) begin
        sorted_indexB = sort_temp3_C;
        sorted_indexC = sort_temp3_B;
    end
end

// ads(diff) module
logic [11:0] abs_diff1_in1, abs_diff2_in1, abs_diff3_in1, abs_diff4_in1;
logic [11:0] abs_diff1_in2, abs_diff2_in2, abs_diff3_in2, abs_diff4_in2;
logic [12:0] abs_diff1_inter, abs_diff2_inter, abs_diff3_inter, abs_diff4_inter;
logic [11:0] abs_diff1_out, abs_diff2_out, abs_diff3_out, abs_diff4_out;

always_comb begin
    abs_diff1_inter = abs_diff1_in1 - abs_diff1_in2;
    abs_diff2_inter = abs_diff2_in1 - abs_diff2_in2;
    abs_diff3_inter = abs_diff3_in1 - abs_diff3_in2;
    abs_diff4_inter = abs_diff4_in1 - abs_diff4_in2;

    abs_diff1_out = (abs_diff1_inter[12] == 0) ? abs_diff1_inter : ~abs_diff1_inter + 1;
    abs_diff2_out = (abs_diff2_inter[12] == 0) ? abs_diff2_inter : ~abs_diff2_inter + 1;
    abs_diff3_out = (abs_diff3_inter[12] == 0) ? abs_diff3_inter : ~abs_diff3_inter + 1;
    abs_diff4_out = (abs_diff4_inter[12] == 0) ? abs_diff4_inter : ~abs_diff4_inter + 1;
end

logic [19:0] diff_add3_comb, diff_add3_reg;
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        diff_add3_reg <= 0;
    end
    else begin
        diff_add3_reg <= diff_add3_comb;
    end
end

reg [2:0] formula_E_cache_comb, formula_E_cache_reg;
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        formula_E_cache_reg <= 0;
    end
    else begin
        formula_E_cache_reg <= formula_E_cache_comb;
    end
end

// pipeline for sorting and calculating the difference
always_comb begin
    sort_indexA = 0; sort_indexB = 0; sort_indexC = 0; sort_indexD = 0;
    abs_diff1_in1 = 0; abs_diff2_in1 = 0; abs_diff3_in1 = 0; abs_diff4_in1 = 0;
    abs_diff1_in2 = 0; abs_diff2_in2 = 0; abs_diff3_in2 = 0; abs_diff4_in2 = 0;
    
    R_indexA_sorted_comb = R_indexA_sorted_reg;
    R_indexB_sorted_comb = R_indexB_sorted_reg;
    R_indexC_sorted_comb = R_indexC_sorted_reg;
    R_indexD_sorted_comb = R_indexD_sorted_reg;

    G_indexA_comb = G_indexA_reg;
    G_indexB_comb = G_indexB_reg;
    G_indexC_comb = G_indexC_reg;
    G_indexD_comb = G_indexD_reg;

    diff_add3_comb = diff_add3_reg;
    formula_E_cache_comb = formula_E_cache_reg;
    case (cnt)
    0: begin
        // sort data from DRAM
        sort_indexA = R_indexA_reg;
        sort_indexB = R_indexB_reg;
        sort_indexC = R_indexC_reg;
        sort_indexD = R_indexD_reg;

        R_indexA_sorted_comb = sorted_indexA;
        R_indexB_sorted_comb = sorted_indexB;
        R_indexC_sorted_comb = sorted_indexC;
        R_indexD_sorted_comb = sorted_indexD;

        // calculate the difference with absolute value
        abs_diff1_in1 = R_indexA_reg;
        abs_diff1_in2 = Pattern_Index_reg[0];
        abs_diff2_in1 = R_indexB_reg;
        abs_diff2_in2 = Pattern_Index_reg[1];
        abs_diff3_in1 = R_indexC_reg;
        abs_diff3_in2 = Pattern_Index_reg[2];
        abs_diff4_in1 = R_indexD_reg;
        abs_diff4_in2 = Pattern_Index_reg[3];
        
        G_indexA_comb = abs_diff1_out;
        G_indexB_comb = abs_diff2_out;
        G_indexC_comb = abs_diff3_out;
        G_indexD_comb = abs_diff4_out;
    end
    1: begin
        // sort difference with absolute value
        sort_indexA = G_indexA_reg;
        sort_indexB = G_indexB_reg;
        sort_indexC = G_indexC_reg;
        sort_indexD = G_indexD_reg;

        G_indexA_comb = sorted_indexA;
        G_indexB_comb = sorted_indexB;
        G_indexC_comb = sorted_indexC;
        G_indexD_comb = sorted_indexD;

        // if we apply pipeline for diff -> abs, can save comparators
        formula_E_cache_comb = (R_indexA_reg >= Pattern_Index_reg[0]) +
                               (R_indexB_reg >= Pattern_Index_reg[1]) +
                               (R_indexC_reg >= Pattern_Index_reg[2]) +
                               (R_indexD_reg >= Pattern_Index_reg[3]);
    end
    2: begin
        // add
        diff_add3_comb = G_indexA_reg + G_indexB_reg + G_indexC_reg;
    end
    3: begin
        // compute result_comb
    end
    endcase
end

// result
logic signed [19:0] result_comb, result_reg;
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        result_reg <= 0;
    end
    else begin
        result_reg <= result_comb;
    end
end

// the final stage of result pipeline
always_comb begin
    result_comb = result_reg;
    case (formula_reg)
    Formula_A: begin
        result_comb = ((R_indexA_reg + R_indexB_reg) + (R_indexC_reg + R_indexD_reg)) >> 2;
    end
    Formula_B: begin
        result_comb = R_indexD_sorted_reg - R_indexA_sorted_reg;
    end
    Formula_C: begin
        result_comb = R_indexA_sorted_reg;
    end
    Formula_D: begin
        result_comb = (R_indexA_reg >= 2047) + (R_indexB_reg >= 2047) + (R_indexC_reg >= 2047) + (R_indexD_reg >= 2047);
    end
    Formula_E: begin
        result_comb = formula_E_cache_reg;
    end
    Formula_F: begin
        result_comb = diff_add3_reg / 3;
    end
    Formula_G: begin
        result_comb = (G_indexA_reg >> 1) + (G_indexB_reg >> 2) + (G_indexC_reg >> 2);
    end
    Formula_H: begin
        result_comb = ((G_indexA_reg + G_indexB_reg) + (G_indexC_reg + G_indexD_reg)) >> 2;
    end
    endcase
end

// threshold (may use pipeline here?)
logic signed [13:0] threshold_comb, threshold_reg;
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        threshold_reg <= 0;
    end
    else begin
        threshold_reg <= threshold_comb;
    end
end


always_comb begin
    threshold_comb = threshold_reg;
    case (formula_reg)
    Formula_A, Formula_C: begin
        case (mode_reg)
        Insensitive: threshold_comb = 2047;
        Normal: threshold_comb = 1023;
        Sensitive: threshold_comb = 511;
        endcase
    end
    Formula_B, Formula_F, Formula_G, Formula_H: begin
        case (mode_reg)
        Insensitive: threshold_comb = 800;
        Normal: threshold_comb = 400;
        Sensitive: threshold_comb = 200;
        endcase
    end
    Formula_D, Formula_E: begin
        case (mode_reg)
        Insensitive: threshold_comb = 3;
        Normal: threshold_comb = 2;
        Sensitive: threshold_comb = 1;
        endcase
    end
    endcase
end


// control logic
always_comb begin
    next_state = current_state;
    out_valid_next = 0;
    warn_msg_next = No_Warn;
    complete_next = 0;
    cnt_next = 0;

    // DRAM
    AR_VALID_next = 0;
    AR_ADDR_next = 0;

    R_READY_next = 0;

    case (current_state)
    IDLE: begin
        if (inf.sel_action_valid) begin
            case (inf.D.d_act[0])
            Index_Check: next_state = Wait_IndexCheck_state;
            Update: next_state = Update_state;
            Check_Valid_Date: next_state = Wait_CheckValidDate_state;
            endcase
        end
        cnt_next = 0;
    end
    Wait_IndexCheck_state: begin
        // count number of index_valid signal
        if (inf.index_valid) begin
            cnt_next = cnt + 1;
        end
        if (cnt == 3) begin
            next_state = DRAM_READ_state1;
            cnt_next = 0;
        end
    end
    Wait_CheckValidDate_state: begin
        // wait for date_valid and data_no_valid
        if (inf.data_no_valid) begin
            next_state = DRAM_READ_state1;
        end
    end
    DRAM_READ_state1: begin
        // first time handshake (send address)
        AR_VALID_next = 1;
        AR_ADDR_next = 'h10000 + (data_no_reg << 3);
        if (inf.AR_READY) begin
            next_state = DRAM_READ_state2;
            R_READY_next = 1;
        end
    end
    DRAM_READ_state2: begin
        // pull high R_READY and wait for data from DRAM -> go to next state if R_VALID is high
        R_READY_next = 1;
        if (inf.R_VALID) begin
            next_state = (act_reg == Index_Check)? CALC_IndexCheck_state1 : CALC_CheckValidDate_state;
            R_READY_next = 0;
        end
    end
    CALC_IndexCheck_state1: begin
        // data is read from DRAM, check the date
        if (date_reg.M < R_month_reg || (date_reg.M == R_month_reg && date_reg.D < R_day_reg)) begin
            warn_msg_next = Date_Warn;
            complete_next = 0;
            out_valid_next = 1;
            next_state = IDLE;
        end
        else begin
            next_state = CALC_IndexCheck_state2;
        end
    end
    CALC_IndexCheck_state2: begin
        // calculate the result
        cnt_next = cnt + 1;
        if (cnt == 4) begin
            if (result_reg >= threshold_reg) begin
                warn_msg_next = Risk_Warn;
                complete_next = 0;
            end
            else begin
                warn_msg_next = No_Warn;
                complete_next = 1;
            end
            out_valid_next = 1;
            next_state = IDLE;
            cnt_next = 0;
        end
    end
    CALC_CheckValidDate_state: begin
        // today's date data_reg.M data_reg.D 
        // DRAM's date R_month_reg R_day_reg
        out_valid_next = 1;
        next_state = IDLE;
        if (date_reg.M < R_month_reg || (date_reg.M == R_month_reg && date_reg.D < R_day_reg)) begin
            warn_msg_next = Date_Warn;
            complete_next = 0;
        end
        else begin
            warn_msg_next = No_Warn;
            complete_next = 1;
        end
    end
    Update_state: begin
    end
    endcase
end

endmodule
