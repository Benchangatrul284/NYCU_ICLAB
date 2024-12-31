module Program(input clk, INF.Program_inf inf);
import usertype::*;


enum logic [3:0] {IDLE, DRAM_READ_state1, DRAM_READ_state2, DRAM_WRITE_state1, DRAM_WRITE_state2, WAIT_BVALID_state,
                  Wait_IndexCheck_state, CALC_IndexCheck_state1, CALC_IndexCheck_state2,
                  Wait_CheckValidDate_state, CALC_CheckValidDate_state,
                  Wait_Update_state, CALC_Update_state1, CALC_Update_state2, 
                  OUTPUT} current_state, next_state;
                      

// IDLE: wait for sel_action_valid

// DRAM_READ_state1: performs first time handshake for read, go to DRAM_READ_state2 if AR_READY is high
// DRAM_READ_state2: ready to read data from DRAM, go to next state if R_VALID is high, next_state is determined by action

// DRAM_WRITE_state1: performs first time handshake for write, go to DRAM_WRITE_state2 if AW_READY is high
// DRAM_WRITE_state2: ready to write data to DRAM, go to next state if W_READY is high, next state is WAIT_BVALID_state
// WAIT_BVALID_state: wait for B_VALID signal from DRAM, go to OUTPUT if B_VALID is high

// Wait_IndexCheck_state: wait data from pattern, go to next state if index_valid is for 4 times
// Wait_Update_state: wait data from pattern, go to next state if index_valid is for 4 times
// Wait_CheckValidDate_state: wait data from pattern, go to next state if data_no_valid is high

// when going to CALC_ state, the data have already been read from DRAM
// CALC_IndexCheck_state1: calculate the month and determine whether to directly output -> CALC_IndexCheck_state2
// CALC_IndexCheck_state2: calculate the threshold and result and output -> IDLE

// CALC_Update_state1: calculate the updated index and output -> CALC_Update_state2
// CALC_Update_state2: clamping the updated index and determine if any warn message -> DRAM_WRITE_state1

// CALC_CheckValidDate_state: calculate the date and determine if any warn message -> IDLE

logic [2:0] cnt, cnt_next;

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

always_comb begin
    Pattern_Index_comb = Pattern_Index_reg;
    case (current_state)
    Wait_IndexCheck_state, Wait_Update_state: begin
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
logic out_valid_next;
Warn_Msg warn_msg_next;
logic complete_next;

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

// DRAM write logic
logic AW_VALID_next;
logic [16:0] AW_ADDR_next;
logic W_VALID_next;
logic [63:0] W_DATA_next;
logic B_READY_next;
always_ff @(posedge clk or negedge inf.rst_n)begin
    if (!inf.rst_n) begin
        inf.AW_VALID <= 0;
        inf.AW_ADDR <= 0;
        inf.W_VALID <= 0;
        inf.W_DATA <= 0;
        inf.B_READY <= 0;
    end
    else begin
        inf.AW_VALID <= AW_VALID_next;
        inf.AW_ADDR <= AW_ADDR_next;
        inf.W_VALID <= W_VALID_next;
        inf.W_DATA <= W_DATA_next;
        inf.B_READY <= B_READY_next;
    end
end

// sorting module
logic [11:0] sort_indexA, sort_indexB, sort_indexC, sort_indexD; // input
logic [11:0] sort_temp1_A, sort_temp1_B, sort_temp1_C, sort_temp1_D;
logic [11:0] sort_temp1_A_reg, sort_temp1_B_reg, sort_temp1_C_reg, sort_temp1_D_reg; // pipelien register

logic [11:0] sort_temp2_A, sort_temp2_B, sort_temp2_C, sort_temp2_D;
logic [11:0] sorted_indexA, sorted_indexB, sorted_indexC, sorted_indexD; // output

always_ff @(posedge clk) begin
    sort_temp1_A_reg <= sort_temp1_A;
    sort_temp1_B_reg <= sort_temp1_B;
    sort_temp1_C_reg <= sort_temp1_C;
    sort_temp1_D_reg <= sort_temp1_D;
end

always_comb begin
    // stage 1
    sort_temp1_A = sort_indexA;
    sort_temp1_B = sort_indexB;
    sort_temp1_C = sort_indexC;
    sort_temp1_D = sort_indexD;

    if (sort_indexA > sort_indexC) begin
        sort_temp1_A = sort_indexC;
        sort_temp1_C = sort_indexA;
    end
    if (sort_indexB > sort_indexD) begin
        sort_temp1_B = sort_indexD;
        sort_temp1_D = sort_indexB;
    end

    // stage 2
    sort_temp2_A = sort_temp1_A_reg;
    sort_temp2_B = sort_temp1_B_reg;
    sort_temp2_C = sort_temp1_C_reg;
    sort_temp2_D = sort_temp1_D_reg;

    if (sort_temp1_A_reg > sort_temp1_B_reg) begin
        sort_temp2_A = sort_temp1_B_reg;
        sort_temp2_B = sort_temp1_A_reg;
    end
    if (sort_temp1_C_reg > sort_temp1_D_reg) begin
        sort_temp2_C = sort_temp1_D_reg;
        sort_temp2_D = sort_temp1_C_reg;
    end

    // stage 3
    sorted_indexA = sort_temp2_A;
    sorted_indexB = sort_temp2_B;
    sorted_indexC = sort_temp2_C;
    sorted_indexD = sort_temp2_D;

    if (sort_temp2_B > sort_temp2_C) begin
        sorted_indexB = sort_temp2_C;
        sorted_indexC = sort_temp2_B;
    end
end

// ads(diff) module
logic [11:0] abs_diff1_in1, abs_diff2_in1, abs_diff3_in1, abs_diff4_in1;
logic [11:0] abs_diff1_in2, abs_diff2_in2, abs_diff3_in2, abs_diff4_in2;
logic [12:0] abs_diff1_inter, abs_diff2_inter, abs_diff3_inter, abs_diff4_inter;
logic [12:0] abs_diff1_inter_reg, abs_diff2_inter_reg, abs_diff3_inter_reg, abs_diff4_inter_reg; // pipeline register

logic [11:0] abs_diff1_out, abs_diff2_out, abs_diff3_out, abs_diff4_out;

always_ff @(posedge clk)begin
    abs_diff1_inter_reg <= abs_diff1_inter;
    abs_diff2_inter_reg <= abs_diff2_inter;
    abs_diff3_inter_reg <= abs_diff3_inter;
    abs_diff4_inter_reg <= abs_diff4_inter;
end

always_comb begin
    abs_diff1_inter = abs_diff1_in1 - abs_diff1_in2;
    abs_diff2_inter = abs_diff2_in1 - abs_diff2_in2;
    abs_diff3_inter = abs_diff3_in1 - abs_diff3_in2;
    abs_diff4_inter = abs_diff4_in1 - abs_diff4_in2;

    abs_diff1_out = (abs_diff1_inter_reg[12] == 0) ? abs_diff1_inter_reg : ~abs_diff1_inter_reg + 1;
    abs_diff2_out = (abs_diff2_inter_reg[12] == 0) ? abs_diff2_inter_reg : ~abs_diff2_inter_reg + 1;
    abs_diff3_out = (abs_diff3_inter_reg[12] == 0) ? abs_diff3_inter_reg : ~abs_diff3_inter_reg + 1;
    abs_diff4_out = (abs_diff4_inter_reg[12] == 0) ? abs_diff4_inter_reg : ~abs_diff4_inter_reg + 1;
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
always_ff @(posedge clk) begin
    formula_E_cache_reg <= formula_E_cache_comb;
end

// pipeline for sorting and calculating the difference
always_comb begin
    sort_indexA = 0; sort_indexB = 0; sort_indexC = 0; sort_indexD = 0;
    
    // abs_diff1_in1 = 0; abs_diff2_in1 = 0; abs_diff3_in1 = 0; abs_diff4_in1 = 0;
    // abs_diff1_in2 = 0; abs_diff2_in2 = 0; abs_diff3_in2 = 0; abs_diff4_in2 = 0;
    
    // calculate the difference with absolute value (cnt == 0)
    abs_diff1_in1 = R_indexA_reg;
    abs_diff1_in2 = Pattern_Index_reg[0];
    abs_diff2_in1 = R_indexB_reg;
    abs_diff2_in2 = Pattern_Index_reg[1];
    abs_diff3_in1 = R_indexC_reg;
    abs_diff3_in2 = Pattern_Index_reg[2];
    abs_diff4_in1 = R_indexD_reg;
    abs_diff4_in2 = Pattern_Index_reg[3];

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

        formula_E_cache_comb = (R_indexA_reg >= Pattern_Index_reg[0]) +
                               (R_indexB_reg >= Pattern_Index_reg[1]) +
                               (R_indexC_reg >= Pattern_Index_reg[2]) +
                               (R_indexD_reg >= Pattern_Index_reg[3]);
    end
    1: begin
        // data from DRAM finish sorting
        R_indexA_sorted_comb = sorted_indexA;
        R_indexB_sorted_comb = sorted_indexB;
        R_indexC_sorted_comb = sorted_indexC;
        R_indexD_sorted_comb = sorted_indexD;

        G_indexA_comb = abs_diff1_out;
        G_indexB_comb = abs_diff2_out;
        G_indexC_comb = abs_diff3_out;
        G_indexD_comb = abs_diff4_out;
    end
    2: begin
        // sort data of G
        sort_indexA = G_indexA_reg;
        sort_indexB = G_indexB_reg; 
        sort_indexC = G_indexC_reg;
        sort_indexD = G_indexD_reg;
    end
    3: begin
        G_indexA_comb = sorted_indexA;
        G_indexB_comb = sorted_indexB;
        G_indexC_comb = sorted_indexC;
        G_indexD_comb = sorted_indexD;
    end
    4: begin
        diff_add3_comb = G_indexA_reg + G_indexB_reg + G_indexC_reg;
    end
    endcase
end

// result
logic [14:0] result_comb, result_reg;
always_ff @(posedge clk) begin
    result_reg <= result_comb;
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
always_ff @(posedge clk) begin
    threshold_reg <= threshold_comb;
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

// updated index
logic signed [14:0] updated_indexA_comb, updated_indexB_comb, updated_indexC_comb, updated_indexD_comb;
logic signed [14:0] updated_indexA_reg, updated_indexB_reg, updated_indexC_reg, updated_indexD_reg;
always_ff @(posedge clk) begin
    updated_indexA_reg <= updated_indexA_comb;
    updated_indexB_reg <= updated_indexB_comb;
    updated_indexC_reg <= updated_indexC_comb;
    updated_indexD_reg <= updated_indexD_comb;
end

logic warn_comb, warn_reg;
// remember to reset the warning signal !!!!
always_ff @(posedge clk) begin
    warn_reg <= warn_comb;
end

always_comb begin
    warn_comb = warn_reg;

    updated_indexA_comb = updated_indexA_reg;
    updated_indexB_comb = updated_indexB_reg;
    updated_indexC_comb = updated_indexC_reg;
    updated_indexD_comb = updated_indexD_reg;

    case (current_state)
    IDLE: begin
        warn_comb = 0;
    end
    CALC_Update_state1: begin
        updated_indexA_comb = $signed({1'b0,R_indexA_reg}) + $signed(Pattern_Index_reg[0]);
        updated_indexB_comb = $signed({1'b0,R_indexB_reg}) + $signed(Pattern_Index_reg[1]);
        updated_indexC_comb = $signed({1'b0,R_indexC_reg}) + $signed(Pattern_Index_reg[2]);
        updated_indexD_comb = $signed({1'b0,R_indexD_reg}) + $signed(Pattern_Index_reg[3]);
    end
    CALC_Update_state2: begin
        // clamping
        case (1'b1)
        (updated_indexA_reg > 4095): begin
            warn_comb = 1;
            updated_indexA_comb = 4095;
        end
        (updated_indexA_reg < 0): begin
            warn_comb = 1;
            updated_indexA_comb = 0;
        end
        endcase
        case (1'b1)
        (updated_indexB_reg > 4095): begin
            warn_comb = 1;
            updated_indexB_comb = 4095;
        end
        (updated_indexB_reg < 0): begin
            warn_comb = 1;
            updated_indexB_comb = 0;
        end
        endcase
        case (1'b1)
        (updated_indexC_reg > 4095): begin
            warn_comb = 1;
            updated_indexC_comb = 4095;
        end
        (updated_indexC_reg < 0): begin
            warn_comb = 1;
            updated_indexC_comb = 0;
        end
        endcase
        case (1'b1)
        (updated_indexD_reg > 4095): begin
            warn_comb = 1;
            updated_indexD_comb = 4095;
        end
        (updated_indexD_reg < 0): begin
            warn_comb = 1;
            updated_indexD_comb = 0;
        end
        endcase
    end
    endcase
end


logic is_early;
assign is_early = date_reg.M < R_month_reg || (date_reg.M == R_month_reg && date_reg.D < R_day_reg);

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

    AW_VALID_next = 0;
    AW_ADDR_next = 0;
    W_VALID_next = 0;
    W_DATA_next = 0;
    B_READY_next = 0;

    case (current_state)
    IDLE: begin
        if (inf.sel_action_valid) begin
            case (inf.D.d_act[0])
            Index_Check: next_state = Wait_IndexCheck_state;
            Update: next_state = Wait_Update_state;
            Check_Valid_Date: next_state = Wait_CheckValidDate_state;
            endcase
        end
        cnt_next = 0;
    end
    Wait_IndexCheck_state, Wait_Update_state: begin
        // count number of index_valid signal
        if (inf.index_valid) begin
            cnt_next = cnt + 1;
        end 
        else begin
            cnt_next = cnt;
        end
        if (cnt == 4) begin
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
            case (act_reg)
            Index_Check: next_state = CALC_IndexCheck_state1;
            Check_Valid_Date: next_state = CALC_CheckValidDate_state;
            Update: next_state = CALC_Update_state1;
            endcase
            R_READY_next = 0;
        end
    end
    CALC_IndexCheck_state1: begin
        // data is read from DRAM, check the date
        if (is_early) begin
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
        if (cnt == 6) begin
            warn_msg_next = (result_reg >= threshold_reg) << 1;
            complete_next = !(result_reg >= threshold_reg);
            out_valid_next = 1;
            next_state = IDLE;
            cnt_next = 0;
        end
    end
    CALC_CheckValidDate_state: begin
        out_valid_next = 1;
        next_state = IDLE;
        if (is_early) begin
            warn_msg_next = Date_Warn;
            complete_next = 0;
        end
        else begin
            warn_msg_next = No_Warn;
            complete_next = 1;
        end
    end
    CALC_Update_state1: begin
        next_state = CALC_Update_state2;
    end
    CALC_Update_state2: begin
        next_state = DRAM_WRITE_state1;
    end
    DRAM_WRITE_state1: begin
        // first time handshake (send address)
        AW_VALID_next = 1;
        AW_ADDR_next = 'h10000 + (data_no_reg << 3);
        if (inf.AW_READY) begin
            next_state = DRAM_WRITE_state2;
        end 
    end
    DRAM_WRITE_state2: begin
        // pull high W_VALID and wait DRAM to pull high -> go to next state if W_READY is high
        W_VALID_next = 1;
        B_READY_next = 1;
        W_DATA_next = {
            updated_indexA_reg[11:0],
            updated_indexB_reg[11:0],
            4'b0000,
            date_reg.M, 
            updated_indexC_reg[11:0],
            updated_indexD_reg[11:0],
            3'b000,
            date_reg.D
        };
        if (inf.W_READY) begin
            next_state = WAIT_BVALID_state;
        end
    end
    WAIT_BVALID_state: begin
        B_READY_next = 1;
        if (inf.B_VALID) begin
            next_state = OUTPUT;
        end
    end
    OUTPUT: begin
        out_valid_next = 1;
        next_state = IDLE;
        if (warn_reg) begin
            complete_next = 0;
            warn_msg_next = Data_Warn;
        end
        else begin
            complete_next = 1;
            warn_msg_next = No_Warn;
        end
    end
    endcase
end
endmodule
