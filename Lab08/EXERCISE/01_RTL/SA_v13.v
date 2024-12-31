/**************************************************************************/
// Copyright (c) 2024, OASIS Lab
// MODULE: SA
// FILE NAME: SA.v
// VERSRION: 1.0
// DATE: Nov 06, 2024
// AUTHOR: Yen-Ning Tung, NYCU AIG
// CODE TYPE: RTL or Behavioral Level (Verilog)
// DESCRIPTION: 2024 Fall IC Lab / Exersise Lab08 / SA
// MODIFICATION HISTORY:
// Date                 Description
// 
/**************************************************************************/

// synopsys translate_off
`ifdef RTL
	`include "GATED_OR.v"
`else
	`include "Netlist/GATED_OR_SYN.v"
`endif
// synopsys translate_on


module SA(
    //Input signals
    clk,
    rst_n,
    cg_en,
    in_valid,
    T,
    in_data,
    w_Q,
    w_K,
    w_V,

    //Output signals
    out_valid,
    out_data
    );

input clk;
input rst_n;
input in_valid;
input cg_en;
input [3:0] T;
input signed [7:0] in_data;
input signed [7:0] w_Q;
input signed [7:0] w_K;
input signed [7:0] w_V;

output reg out_valid;
output reg signed [63:0] out_data;

parameter IDLE = 3'b000;
parameter READ_Q = 3'b001;
parameter READ_K = 3'b010;
parameter READ_V = 3'b011;
parameter OUTPUT = 3'b100;
reg [2:0] current_state, next_state;

// multiplier
reg signed [39:0] multi0_a, multi1_a, multi2_a, multi3_a, multi4_a, multi5_a, multi6_a, multi7_a;
reg signed [18:0] multi0_b, multi1_b, multi2_b, multi3_b, multi4_b, multi5_b, multi6_b, multi7_b;
reg signed [58:0] multi0_out, multi1_out, multi2_out, multi3_out, multi4_out, multi5_out, multi6_out, multi7_out;
reg signed [39:0] multi8_a, multi9_a, multi10_a, multi11_a, multi12_a, multi13_a, multi14_a, multi15_a;
reg signed [18:0] multi8_b, multi9_b, multi10_b, multi11_b, multi12_b, multi13_b, multi14_b, multi15_b;
reg signed [58:0] multi8_out, multi9_out, multi10_out, multi11_out, multi12_out, multi13_out, multi14_out, multi15_out;
always @(*) begin
    multi0_out = multi0_a * multi0_b;
    multi1_out = multi1_a * multi1_b;
    multi2_out = multi2_a * multi2_b;
    multi3_out = multi3_a * multi3_b;
    multi4_out = multi4_a * multi4_b;
    multi5_out = multi5_a * multi5_b;
    multi6_out = multi6_a * multi6_b;
    multi7_out = multi7_a * multi7_b;
    multi8_out = multi8_a * multi8_b;
    multi9_out = multi9_a * multi9_b;
    multi10_out = multi10_a * multi10_b;
    multi11_out = multi11_a * multi11_b;
    multi12_out = multi12_a * multi12_b;
    multi13_out = multi13_a * multi13_b;
    multi14_out = multi14_a * multi14_b;
    multi15_out = multi15_a * multi15_b;
end

// adder
reg signed [63:0] add0_a, add1_a, add2_a, add3_a, add4_a, add5_a, add6_a, add7_a;
reg signed [63:0] add0_b, add1_b, add2_b, add3_b, add4_b, add5_b, add6_b, add7_b;
reg signed [63:0] add0_out, add1_out, add2_out, add3_out, add4_out, add5_out, add6_out, add7_out;
reg signed [63:0] add8_a, add9_a, add10_a, add11_a, add12_a, add13_a, add14_a, add15_a;
reg signed [63:0] add8_b, add9_b, add10_b, add11_b, add12_b, add13_b, add14_b, add15_b;
reg signed [63:0] add8_out, add9_out, add10_out, add11_out, add12_out, add13_out, add14_out, add15_out;
always @(*) begin
    add0_out = add0_a + add0_b;
    add1_out = add1_a + add1_b;
    add2_out = add2_a + add2_b;
    add3_out = add3_a + add3_b;
    add4_out = add4_a + add4_b;
    add5_out = add5_a + add5_b;
    add6_out = add6_a + add6_b;
    add7_out = add7_a + add7_b;
    add8_out = add8_a + add8_b;
    add9_out = add9_a + add9_b;
    add10_out = add10_a + add10_b;
    add11_out = add11_a + add11_b;
    add12_out = add12_a + add12_b;
    add13_out = add13_a + add13_b;
    add14_out = add14_a + add14_b;
    add15_out = add15_a + add15_b;
end

// divider and relu
reg signed [40:0] div0_a, div0_out;
always @(*) begin
    div0_out = (div0_a[40] == 1)? 0: (div0_a / 3);
end

// T
reg [3:0] T_reg, T_comb;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;
        T_reg <= 1;
    end
    else begin
        current_state <= next_state;
        T_reg <= T_comb;
    end
end

reg signed [7:0] in_data_matrix_next [0:63];
reg signed [7:0] in_data_matrix [0:63];
reg signed [7:0] in_data_comb;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i=0; i < 64 ; i= i+ 1) begin
            in_data_matrix[i] <= 0;
        end
    end
    else begin
        in_data_matrix <= in_data_matrix_next;
    end
end



reg signed [7:0] w_Q_matrix_next [0:63];
reg signed [7:0] w_Q_matrix [0:63];


always @(posedge clk) begin
    w_Q_matrix <= w_Q_matrix_next;
end

reg signed [19:0] Q_matrix_next [0:63];
reg signed [19:0] Q_matrix [0:63];
reg signed [19:0] K_matrix_next [0:63];
reg signed [19:0] K_matrix [0:63];
reg signed [19:0] V_matrix_next [0:63];
reg signed [19:0] V_matrix [0:63];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i=0; i<64; i=i+1) begin
            Q_matrix[i] <= 0;
        end
    end
    else begin
        Q_matrix <= Q_matrix_next;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i=0; i<64; i=i+1) begin
            K_matrix[i] <= 0;
        end
    end
    else begin
        K_matrix <= K_matrix_next;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i=0; i<64; i=i+1) begin
            V_matrix[i] <= 0;
        end
    end
    else begin
        V_matrix <= V_matrix_next;
    end
end

reg signed [63:0] out_data_next;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_data <= 0;
    end
    else begin
        out_data <= out_data_next;
    end
end

reg out_valid_next;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
    end
    else begin
        out_valid <= out_valid_next;
    end
end

reg [5:0] cnt_next, cnt;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 0;
    end
    else begin
        cnt <= cnt_next;
    end
end

reg signed [39:0] QKT [0:63];
reg signed [39:0] QKT_next [0:63];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i=0; i<64; i=i+1) begin
            QKT[i] <= 0;
        end
    end
    else begin
        QKT <= QKT_next;
    end
end


always @(*) begin
    next_state = current_state;
    cnt_next = 0;
    out_valid_next = 0;
    out_data_next = 0;

    in_data_matrix_next = in_data_matrix;

    div0_a = 0;

    add0_a = 0; add0_b = 0; add1_a = 0; add1_b = 0; add2_a = 0; add2_b = 0; add3_a = 0; add3_b = 0; add4_a = 0; add4_b = 0; add5_a = 0; add5_b = 0; add6_a = 0; add6_b = 0; add7_a = 0; add7_b = 0;
    add8_a = 0; add8_b = 0; add9_a = 0; add9_b = 0; add10_a = 0; add10_b = 0; add11_a = 0; add11_b = 0; add12_a = 0; add12_b = 0; add13_a = 0; add13_b = 0; add14_a = 0; add14_b = 0; add15_a = 0; add15_b = 0;

    multi0_a = 0; multi0_b = 0; multi1_a = 0; multi1_b = 0; multi2_a = 0; multi2_b = 0; multi3_a = 0; multi3_b = 0; multi4_a = 0; multi4_b = 0; multi5_a = 0; multi5_b = 0; multi6_a = 0; multi6_b = 0; multi7_a = 0; multi7_b = 0;
    multi8_a = 0; multi8_b = 0; multi9_a = 0; multi9_b = 0; multi10_a = 0; multi10_b = 0; multi11_a = 0; multi11_b = 0; multi12_a = 0; multi12_b = 0; multi13_a = 0; multi13_b = 0; multi14_a = 0; multi14_b = 0; multi15_a = 0; multi15_b = 0;


    w_Q_matrix_next = w_Q_matrix;
    Q_matrix_next = Q_matrix;
    K_matrix_next = K_matrix;
    V_matrix_next = V_matrix;
    QKT_next = QKT;
    
    case (current_state)
    IDLE: begin
        for (integer i=0; i < 64 ; i = i + 1) begin
            Q_matrix_next[i] = 0;
            K_matrix_next[i] = 0;
            V_matrix_next[i] = 0;
        end
        if (in_valid) begin
            next_state = READ_Q;
            cnt_next = 1;
            in_data_matrix_next[0] = in_data_comb;
            w_Q_matrix_next[0] = w_Q;
        end
    end
    READ_Q: begin
        cnt_next = cnt + 1;
        in_data_matrix_next[cnt] = in_data_comb;
        w_Q_matrix_next[cnt] = w_Q;
        if (cnt == 63) begin
            next_state = READ_K;
            cnt_next = 0;
        end
    end
    READ_K: begin
        cnt_next = cnt + 1;
        
        multi0_a = w_K;
        multi1_a = w_K;
        multi2_a = w_K;
        multi3_a = w_K;
        multi4_a = w_K;
        multi5_a = w_K;
        multi6_a = w_K;
        multi7_a = w_K;

        multi8_a = w_Q_matrix[cnt];
        multi9_a = w_Q_matrix[cnt];
        multi10_a = w_Q_matrix[cnt];
        multi11_a = w_Q_matrix[cnt];
        multi12_a = w_Q_matrix[cnt];
        multi13_a = w_Q_matrix[cnt];
        multi14_a = w_Q_matrix[cnt];
        multi15_a = w_Q_matrix[cnt];


        case (cnt)
        0,1,2,3,4,5,6,7: begin
            multi0_b = in_data_matrix[0];
            multi1_b = in_data_matrix[8];
            multi2_b = in_data_matrix[16];
            multi3_b = in_data_matrix[24];
            multi4_b = in_data_matrix[32];
            multi5_b = in_data_matrix[40];
            multi6_b = in_data_matrix[48];
            multi7_b = in_data_matrix[56];
        end
        8,9,10,11,12,13,14,15: begin
            multi0_b = in_data_matrix[1];
            multi1_b = in_data_matrix[9];
            multi2_b = in_data_matrix[17];
            multi3_b = in_data_matrix[25];
            multi4_b = in_data_matrix[33];
            multi5_b = in_data_matrix[41];
            multi6_b = in_data_matrix[49];
            multi7_b = in_data_matrix[57];
        end
        16,17,18,19,20,21,22,23: begin
            multi0_b = in_data_matrix[2];
            multi1_b = in_data_matrix[10];
            multi2_b = in_data_matrix[18];
            multi3_b = in_data_matrix[26];
            multi4_b = in_data_matrix[34];
            multi5_b = in_data_matrix[42];
            multi6_b = in_data_matrix[50];
            multi7_b = in_data_matrix[58];
        end
        24,25,26,27,28,29,30,31: begin
            multi0_b = in_data_matrix[3];
            multi1_b = in_data_matrix[11];
            multi2_b = in_data_matrix[19];
            multi3_b = in_data_matrix[27];
            multi4_b = in_data_matrix[35];
            multi5_b = in_data_matrix[43];
            multi6_b = in_data_matrix[51];
            multi7_b = in_data_matrix[59];
        end
        32,33,34,35,36,37,38,39: begin
            multi0_b = in_data_matrix[4];
            multi1_b = in_data_matrix[12];
            multi2_b = in_data_matrix[20];
            multi3_b = in_data_matrix[28];
            multi4_b = in_data_matrix[36];
            multi5_b = in_data_matrix[44];
            multi6_b = in_data_matrix[52];
            multi7_b = in_data_matrix[60];
        end
        40,41,42,43,44,45,46,47: begin
            multi0_b = in_data_matrix[5];
            multi1_b = in_data_matrix[13];
            multi2_b = in_data_matrix[21];
            multi3_b = in_data_matrix[29];
            multi4_b = in_data_matrix[37];
            multi5_b = in_data_matrix[45];
            multi6_b = in_data_matrix[53];
            multi7_b = in_data_matrix[61];
        end
        48,49,50,51,52,53,54,55: begin
            multi0_b = in_data_matrix[6];
            multi1_b = in_data_matrix[14];
            multi2_b = in_data_matrix[22];
            multi3_b = in_data_matrix[30];
            multi4_b = in_data_matrix[38];
            multi5_b = in_data_matrix[46];
            multi6_b = in_data_matrix[54];
            multi7_b = in_data_matrix[62];
        end
        56,57,58,59,60,61,62,63: begin
            multi0_b = in_data_matrix[7];
            multi1_b = in_data_matrix[15];
            multi2_b = in_data_matrix[23];
            multi3_b = in_data_matrix[31];
            multi4_b = in_data_matrix[39];
            multi5_b = in_data_matrix[47];
            multi6_b = in_data_matrix[55];
            multi7_b = in_data_matrix[63];
        end
        endcase

        multi8_b = multi0_b;
        multi9_b = multi1_b;
        multi10_b = multi2_b;
        multi11_b = multi3_b;
        multi12_b = multi4_b;
        multi13_b = multi5_b;
        multi14_b = multi6_b;
        multi15_b = multi7_b;

        add0_a = multi0_out;
        add1_a = multi1_out;
        add2_a = multi2_out;
        add3_a = multi3_out;
        add4_a = multi4_out;
        add5_a = multi5_out;
        add6_a = multi6_out;
        add7_a = multi7_out;

        add8_a = multi8_out;
        add9_a = multi9_out;
        add10_a = multi10_out;
        add11_a = multi11_out;
        add12_a = multi12_out;
        add13_a = multi13_out;
        add14_a = multi14_out;
        add15_a = multi15_out;

        case (cnt)
        0,8,16,24,32,40,48,56: begin
            add0_b = Q_matrix[0]; 
            add1_b = Q_matrix[8];
            add2_b = Q_matrix[16];
            add3_b = Q_matrix[24];
            add4_b = Q_matrix[32];
            add5_b = Q_matrix[40];
            add6_b = Q_matrix[48];
            add7_b = Q_matrix[56];

            add8_b = K_matrix[0];
            add9_b = K_matrix[8];
            add10_b = K_matrix[16];
            add11_b = K_matrix[24];
            add12_b = K_matrix[32];
            add13_b = K_matrix[40];
            add14_b = K_matrix[48];
            add15_b = K_matrix[56];

            Q_matrix_next[0] = add0_out;
            Q_matrix_next[8] = add1_out;
            Q_matrix_next[16] = add2_out;
            Q_matrix_next[24] = add3_out;
            Q_matrix_next[32] = add4_out;
            Q_matrix_next[40] = add5_out;
            Q_matrix_next[48] = add6_out;
            Q_matrix_next[56] = add7_out;
        
            K_matrix_next[0] = add8_out;
            K_matrix_next[8] = add9_out;
            K_matrix_next[16] = add10_out;
            K_matrix_next[24] = add11_out;
            K_matrix_next[32] = add12_out;
            K_matrix_next[40] = add13_out;
            K_matrix_next[48] = add14_out;
            K_matrix_next[56] = add15_out;
        end
        1,9,17,25,33,41,49,57: begin
            add0_b = Q_matrix[1]; 
            add1_b = Q_matrix[9];
            add2_b = Q_matrix[17];
            add3_b = Q_matrix[25];
            add4_b = Q_matrix[33];
            add5_b = Q_matrix[41];
            add6_b = Q_matrix[49];
            add7_b = Q_matrix[57];

            add8_b = K_matrix[1];
            add9_b = K_matrix[9];
            add10_b = K_matrix[17];
            add11_b = K_matrix[25];
            add12_b = K_matrix[33];
            add13_b = K_matrix[41];
            add14_b = K_matrix[49];
            add15_b = K_matrix[57];

            Q_matrix_next[1] = add0_out;
            Q_matrix_next[9] = add1_out;
            Q_matrix_next[17] = add2_out;
            Q_matrix_next[25] = add3_out;
            Q_matrix_next[33] = add4_out;
            Q_matrix_next[41] = add5_out;
            Q_matrix_next[49] = add6_out;
            Q_matrix_next[57] = add7_out;
        
            K_matrix_next[1] = add8_out;
            K_matrix_next[9] = add9_out;
            K_matrix_next[17] = add10_out;
            K_matrix_next[25] = add11_out;
            K_matrix_next[33] = add12_out;
            K_matrix_next[41] = add13_out;
            K_matrix_next[49] = add14_out;
            K_matrix_next[57] = add15_out;
        end
        2,10,18,26,34,42,50,58: begin
            add0_b = Q_matrix[2]; 
            add1_b = Q_matrix[10];
            add2_b = Q_matrix[18];
            add3_b = Q_matrix[26];
            add4_b = Q_matrix[34];
            add5_b = Q_matrix[42];
            add6_b = Q_matrix[50];
            add7_b = Q_matrix[58];

            add8_b = K_matrix[2];
            add9_b = K_matrix[10];
            add10_b = K_matrix[18];
            add11_b = K_matrix[26];
            add12_b = K_matrix[34];
            add13_b = K_matrix[42];
            add14_b = K_matrix[50];
            add15_b = K_matrix[58];

            Q_matrix_next[2] = add0_out;
            Q_matrix_next[10] = add1_out;
            Q_matrix_next[18] = add2_out;
            Q_matrix_next[26] = add3_out;
            Q_matrix_next[34] = add4_out;
            Q_matrix_next[42] = add5_out;
            Q_matrix_next[50] = add6_out;
            Q_matrix_next[58] = add7_out;
        
            K_matrix_next[2] = add8_out;
            K_matrix_next[10] = add9_out;
            K_matrix_next[18] = add10_out;
            K_matrix_next[26] = add11_out;
            K_matrix_next[34] = add12_out;
            K_matrix_next[42] = add13_out;
            K_matrix_next[50] = add14_out;
            K_matrix_next[58] = add15_out;
        end
        3,11,19,27,35,43,51,59: begin
            add0_b = Q_matrix[3]; 
            add1_b = Q_matrix[11];
            add2_b = Q_matrix[19];
            add3_b = Q_matrix[27];
            add4_b = Q_matrix[35];
            add5_b = Q_matrix[43];
            add6_b = Q_matrix[51];
            add7_b = Q_matrix[59];

            add8_b = K_matrix[3];
            add9_b = K_matrix[11];
            add10_b = K_matrix[19];
            add11_b = K_matrix[27];
            add12_b = K_matrix[35];
            add13_b = K_matrix[43];
            add14_b = K_matrix[51];
            add15_b = K_matrix[59];

            Q_matrix_next[3] = add0_out;
            Q_matrix_next[11] = add1_out;
            Q_matrix_next[19] = add2_out;
            Q_matrix_next[27] = add3_out;
            Q_matrix_next[35] = add4_out;
            Q_matrix_next[43] = add5_out;
            Q_matrix_next[51] = add6_out;
            Q_matrix_next[59] = add7_out;
        
            K_matrix_next[3] = add8_out;
            K_matrix_next[11] = add9_out;
            K_matrix_next[19] = add10_out;
            K_matrix_next[27] = add11_out;
            K_matrix_next[35] = add12_out;
            K_matrix_next[43] = add13_out;
            K_matrix_next[51] = add14_out;
            K_matrix_next[59] = add15_out;
        end
        4,12,20,28,36,44,52,60: begin
            add0_b = Q_matrix[4]; 
            add1_b = Q_matrix[12];
            add2_b = Q_matrix[20];
            add3_b = Q_matrix[28];
            add4_b = Q_matrix[36];
            add5_b = Q_matrix[44];
            add6_b = Q_matrix[52];
            add7_b = Q_matrix[60];

            add8_b = K_matrix[4];
            add9_b = K_matrix[12];
            add10_b = K_matrix[20];
            add11_b = K_matrix[28];
            add12_b = K_matrix[36];
            add13_b = K_matrix[44];
            add14_b = K_matrix[52];
            add15_b = K_matrix[60];

            Q_matrix_next[4] = add0_out;
            Q_matrix_next[12] = add1_out;
            Q_matrix_next[20] = add2_out;
            Q_matrix_next[28] = add3_out;
            Q_matrix_next[36] = add4_out;
            Q_matrix_next[44] = add5_out;
            Q_matrix_next[52] = add6_out;
            Q_matrix_next[60] = add7_out;
        
            K_matrix_next[4] = add8_out;
            K_matrix_next[12] = add9_out;
            K_matrix_next[20] = add10_out;
            K_matrix_next[28] = add11_out;
            K_matrix_next[36] = add12_out;
            K_matrix_next[44] = add13_out;
            K_matrix_next[52] = add14_out;
            K_matrix_next[60] = add15_out;
        end
        5,13,21,29,37,45,53,61: begin
            add0_b = Q_matrix[5]; 
            add1_b = Q_matrix[13];
            add2_b = Q_matrix[21];
            add3_b = Q_matrix[29];
            add4_b = Q_matrix[37];
            add5_b = Q_matrix[45];
            add6_b = Q_matrix[53];
            add7_b = Q_matrix[61];

            add8_b = K_matrix[5];
            add9_b = K_matrix[13];
            add10_b = K_matrix[21];
            add11_b = K_matrix[29];
            add12_b = K_matrix[37];
            add13_b = K_matrix[45];
            add14_b = K_matrix[53];
            add15_b = K_matrix[61];

            Q_matrix_next[5] = add0_out;
            Q_matrix_next[13] = add1_out;
            Q_matrix_next[21] = add2_out;
            Q_matrix_next[29] = add3_out;
            Q_matrix_next[37] = add4_out;
            Q_matrix_next[45] = add5_out;
            Q_matrix_next[53] = add6_out;
            Q_matrix_next[61] = add7_out;
        
            K_matrix_next[5] = add8_out;
            K_matrix_next[13] = add9_out;
            K_matrix_next[21] = add10_out;
            K_matrix_next[29] = add11_out;
            K_matrix_next[37] = add12_out;
            K_matrix_next[45] = add13_out;
            K_matrix_next[53] = add14_out;
            K_matrix_next[61] = add15_out;
        end
        6,14,22,30,38,46,54,62: begin
            add0_b = Q_matrix[6]; 
            add1_b = Q_matrix[14];
            add2_b = Q_matrix[22];
            add3_b = Q_matrix[30];
            add4_b = Q_matrix[38];
            add5_b = Q_matrix[46];
            add6_b = Q_matrix[54];
            add7_b = Q_matrix[62];

            add8_b = K_matrix[6];
            add9_b = K_matrix[14];
            add10_b = K_matrix[22];
            add11_b = K_matrix[30];
            add12_b = K_matrix[38];
            add13_b = K_matrix[46];
            add14_b = K_matrix[54];
            add15_b = K_matrix[62];

            Q_matrix_next[6] = add0_out;
            Q_matrix_next[14] = add1_out;
            Q_matrix_next[22] = add2_out;
            Q_matrix_next[30] = add3_out;
            Q_matrix_next[38] = add4_out;
            Q_matrix_next[46] = add5_out;
            Q_matrix_next[54] = add6_out;
            Q_matrix_next[62] = add7_out;
        
            K_matrix_next[6] = add8_out;
            K_matrix_next[14] = add9_out;
            K_matrix_next[22] = add10_out;
            K_matrix_next[30] = add11_out;
            K_matrix_next[38] = add12_out;
            K_matrix_next[46] = add13_out;
            K_matrix_next[54] = add14_out;
            K_matrix_next[62] = add15_out;
        end
        7,15,23,31,39,47,55,63: begin
            add0_b = Q_matrix[7]; 
            add1_b = Q_matrix[15];
            add2_b = Q_matrix[23];
            add3_b = Q_matrix[31];
            add4_b = Q_matrix[39];
            add5_b = Q_matrix[47];
            add6_b = Q_matrix[55];
            add7_b = Q_matrix[63];

            add8_b = K_matrix[7];
            add9_b = K_matrix[15];
            add10_b = K_matrix[23];
            add11_b = K_matrix[31];
            add12_b = K_matrix[39];
            add13_b = K_matrix[47];
            add14_b = K_matrix[55];
            add15_b = K_matrix[63];

            Q_matrix_next[7] = add0_out;
            Q_matrix_next[15] = add1_out;
            Q_matrix_next[23] = add2_out;
            Q_matrix_next[31] = add3_out;
            Q_matrix_next[39] = add4_out;
            Q_matrix_next[47] = add5_out;
            Q_matrix_next[55] = add6_out;
            Q_matrix_next[63] = add7_out;
        
            K_matrix_next[7] = add8_out;
            K_matrix_next[15] = add9_out;
            K_matrix_next[23] = add10_out;
            K_matrix_next[31] = add11_out;
            K_matrix_next[39] = add12_out;
            K_matrix_next[47] = add13_out;
            K_matrix_next[55] = add14_out;
            K_matrix_next[63] = add15_out;
        end
        endcase
        if (cnt == 63) begin
            next_state = READ_V;
            cnt_next = 0;
        end
    end
    READ_V: begin
        cnt_next = cnt + 1;
        
        multi0_a = w_V;
        multi1_a = w_V;
        multi2_a = w_V;
        multi3_a = w_V;
        multi4_a = w_V;
        multi5_a = w_V;
        multi6_a = w_V;
        multi7_a = w_V;

        case (cnt)
        0,1,2,3,4,5,6,7: begin
            multi0_b = in_data_matrix[0];
            multi1_b = in_data_matrix[8];
            multi2_b = in_data_matrix[16];
            multi3_b = in_data_matrix[24];
            multi4_b = in_data_matrix[32];
            multi5_b = in_data_matrix[40];
            multi6_b = in_data_matrix[48];
            multi7_b = in_data_matrix[56];

            multi8_a = Q_matrix[0];
            multi9_a = Q_matrix[1];
            multi10_a = Q_matrix[2];
            multi11_a = Q_matrix[3];
            multi12_a = Q_matrix[4];
            multi13_a = Q_matrix[5];
            multi14_a = Q_matrix[6];
            multi15_a = Q_matrix[7];
        end
        8,9,10,11,12,13,14,15: begin
            multi0_b = in_data_matrix[1];
            multi1_b = in_data_matrix[9];
            multi2_b = in_data_matrix[17];
            multi3_b = in_data_matrix[25];
            multi4_b = in_data_matrix[33];
            multi5_b = in_data_matrix[41];
            multi6_b = in_data_matrix[49];
            multi7_b = in_data_matrix[57];

            multi8_a = Q_matrix[8];
            multi9_a = Q_matrix[9];
            multi10_a = Q_matrix[10];
            multi11_a = Q_matrix[11];
            multi12_a = Q_matrix[12];
            multi13_a = Q_matrix[13];
            multi14_a = Q_matrix[14];
            multi15_a = Q_matrix[15];
        end
        16,17,18,19,20,21,22,23: begin
            multi0_b = in_data_matrix[2];
            multi1_b = in_data_matrix[10];
            multi2_b = in_data_matrix[18];
            multi3_b = in_data_matrix[26];
            multi4_b = in_data_matrix[34];
            multi5_b = in_data_matrix[42];
            multi6_b = in_data_matrix[50];
            multi7_b = in_data_matrix[58];

            multi8_a = Q_matrix[16];
            multi9_a = Q_matrix[17];
            multi10_a = Q_matrix[18];
            multi11_a = Q_matrix[19];
            multi12_a = Q_matrix[20];
            multi13_a = Q_matrix[21];
            multi14_a = Q_matrix[22];
            multi15_a = Q_matrix[23];
        end
        24,25,26,27,28,29,30,31: begin
            multi0_b = in_data_matrix[3];
            multi1_b = in_data_matrix[11];
            multi2_b = in_data_matrix[19];
            multi3_b = in_data_matrix[27];
            multi4_b = in_data_matrix[35];
            multi5_b = in_data_matrix[43];
            multi6_b = in_data_matrix[51];
            multi7_b = in_data_matrix[59];

            multi8_a = Q_matrix[24];
            multi9_a = Q_matrix[25];
            multi10_a = Q_matrix[26];
            multi11_a = Q_matrix[27];
            multi12_a = Q_matrix[28];
            multi13_a = Q_matrix[29];
            multi14_a = Q_matrix[30];
            multi15_a = Q_matrix[31];
        end
        32,33,34,35,36,37,38,39: begin
            multi0_b = in_data_matrix[4];
            multi1_b = in_data_matrix[12];
            multi2_b = in_data_matrix[20];
            multi3_b = in_data_matrix[28];
            multi4_b = in_data_matrix[36];
            multi5_b = in_data_matrix[44];
            multi6_b = in_data_matrix[52];
            multi7_b = in_data_matrix[60];

            multi8_a = Q_matrix[32];
            multi9_a = Q_matrix[33];
            multi10_a = Q_matrix[34];
            multi11_a = Q_matrix[35];
            multi12_a = Q_matrix[36];
            multi13_a = Q_matrix[37];
            multi14_a = Q_matrix[38];
            multi15_a = Q_matrix[39];
        end
        40,41,42,43,44,45,46,47: begin
            multi0_b = in_data_matrix[5];
            multi1_b = in_data_matrix[13];
            multi2_b = in_data_matrix[21];
            multi3_b = in_data_matrix[29];
            multi4_b = in_data_matrix[37];
            multi5_b = in_data_matrix[45];
            multi6_b = in_data_matrix[53];
            multi7_b = in_data_matrix[61];

            multi8_a = Q_matrix[40];
            multi9_a = Q_matrix[41];
            multi10_a = Q_matrix[42];
            multi11_a = Q_matrix[43];
            multi12_a = Q_matrix[44];
            multi13_a = Q_matrix[45];
            multi14_a = Q_matrix[46];
            multi15_a = Q_matrix[47];
        end
        48,49,50,51,52,53,54,55: begin
            multi0_b = in_data_matrix[6];
            multi1_b = in_data_matrix[14];
            multi2_b = in_data_matrix[22];
            multi3_b = in_data_matrix[30];
            multi4_b = in_data_matrix[38];
            multi5_b = in_data_matrix[46];
            multi6_b = in_data_matrix[54];
            multi7_b = in_data_matrix[62];

            multi8_a = Q_matrix[48];
            multi9_a = Q_matrix[49];
            multi10_a = Q_matrix[50];
            multi11_a = Q_matrix[51];
            multi12_a = Q_matrix[52];
            multi13_a = Q_matrix[53];
            multi14_a = Q_matrix[54];
            multi15_a = Q_matrix[55];
        end
        56,57,58,59,60,61,62,63: begin
            multi0_b = in_data_matrix[7];
            multi1_b = in_data_matrix[15];
            multi2_b = in_data_matrix[23];
            multi3_b = in_data_matrix[31];
            multi4_b = in_data_matrix[39];
            multi5_b = in_data_matrix[47];
            multi6_b = in_data_matrix[55];
            multi7_b = in_data_matrix[63];

            multi8_a = Q_matrix[56];
            multi9_a = Q_matrix[57];
            multi10_a = Q_matrix[58];
            multi11_a = Q_matrix[59];
            multi12_a = Q_matrix[60];
            multi13_a = Q_matrix[61];
            multi14_a = Q_matrix[62];
            multi15_a = Q_matrix[63];
        end
        endcase

        add0_a = multi0_out;
        add1_a = multi1_out;
        add2_a = multi2_out;
        add3_a = multi3_out;
        add4_a = multi4_out;
        add5_a = multi5_out;
        add6_a = multi6_out;
        add7_a = multi7_out;
        case (cnt)
        0,8,16,24,32,40,48,56: begin
            add0_b = V_matrix[0]; 
            add1_b = V_matrix[8];
            add2_b = V_matrix[16];
            add3_b = V_matrix[24];
            add4_b = V_matrix[32];
            add5_b = V_matrix[40];
            add6_b = V_matrix[48];
            add7_b = V_matrix[56];

            V_matrix_next[0] = add0_out;
            V_matrix_next[8] = add1_out;
            V_matrix_next[16] = add2_out;
            V_matrix_next[24] = add3_out;
            V_matrix_next[32] = add4_out;
            V_matrix_next[40] = add5_out;
            V_matrix_next[48] = add6_out;
            V_matrix_next[56] = add7_out;

            multi8_a = Q_matrix[0];
            multi9_a = Q_matrix[1];
            multi10_a = Q_matrix[2];
            multi11_a = Q_matrix[3];
            multi12_a = Q_matrix[4];
            multi13_a = Q_matrix[5];
            multi14_a = Q_matrix[6];
            multi15_a = Q_matrix[7];
        end
        1,9,17,25,33,41,49,57: begin
            add0_b = V_matrix[1]; 
            add1_b = V_matrix[9];
            add2_b = V_matrix[17];
            add3_b = V_matrix[25];
            add4_b = V_matrix[33];
            add5_b = V_matrix[41];
            add6_b = V_matrix[49];
            add7_b = V_matrix[57];

            V_matrix_next[1] = add0_out;
            V_matrix_next[9] = add1_out;
            V_matrix_next[17] = add2_out;
            V_matrix_next[25] = add3_out;
            V_matrix_next[33] = add4_out;
            V_matrix_next[41] = add5_out;
            V_matrix_next[49] = add6_out;
            V_matrix_next[57] = add7_out;

            multi8_a = Q_matrix[8];
            multi9_a = Q_matrix[9];
            multi10_a = Q_matrix[10];
            multi11_a = Q_matrix[11];
            multi12_a = Q_matrix[12];
            multi13_a = Q_matrix[13];
            multi14_a = Q_matrix[14];
            multi15_a = Q_matrix[15];
        end
        2,10,18,26,34,42,50,58: begin
            add0_b = V_matrix[2]; 
            add1_b = V_matrix[10];
            add2_b = V_matrix[18];
            add3_b = V_matrix[26];
            add4_b = V_matrix[34];
            add5_b = V_matrix[42];
            add6_b = V_matrix[50];
            add7_b = V_matrix[58];


            V_matrix_next[2] = add0_out;
            V_matrix_next[10] = add1_out;
            V_matrix_next[18] = add2_out;
            V_matrix_next[26] = add3_out;
            V_matrix_next[34] = add4_out;
            V_matrix_next[42] = add5_out;
            V_matrix_next[50] = add6_out;
            V_matrix_next[58] = add7_out;
            
            multi8_a = Q_matrix[16];
            multi9_a = Q_matrix[17];
            multi10_a = Q_matrix[18];
            multi11_a = Q_matrix[19];
            multi12_a = Q_matrix[20];
            multi13_a = Q_matrix[21];
            multi14_a = Q_matrix[22];
            multi15_a = Q_matrix[23];
        end
        3,11,19,27,35,43,51,59: begin
            add0_b = V_matrix[3]; 
            add1_b = V_matrix[11];
            add2_b = V_matrix[19];
            add3_b = V_matrix[27];
            add4_b = V_matrix[35];
            add5_b = V_matrix[43];
            add6_b = V_matrix[51];
            add7_b = V_matrix[59];


            V_matrix_next[3] = add0_out;
            V_matrix_next[11] = add1_out;
            V_matrix_next[19] = add2_out;
            V_matrix_next[27] = add3_out;
            V_matrix_next[35] = add4_out;
            V_matrix_next[43] = add5_out;
            V_matrix_next[51] = add6_out;
            V_matrix_next[59] = add7_out;

            multi8_a = Q_matrix[24];
            multi9_a = Q_matrix[25];
            multi10_a = Q_matrix[26];
            multi11_a = Q_matrix[27];
            multi12_a = Q_matrix[28];
            multi13_a = Q_matrix[29];
            multi14_a = Q_matrix[30];
            multi15_a = Q_matrix[31];
        end
        4,12,20,28,36,44,52,60: begin
            add0_b = V_matrix[4]; 
            add1_b = V_matrix[12];
            add2_b = V_matrix[20];
            add3_b = V_matrix[28];
            add4_b = V_matrix[36];
            add5_b = V_matrix[44];
            add6_b = V_matrix[52];
            add7_b = V_matrix[60];

            V_matrix_next[4] = add0_out;
            V_matrix_next[12] = add1_out;
            V_matrix_next[20] = add2_out;
            V_matrix_next[28] = add3_out;
            V_matrix_next[36] = add4_out;
            V_matrix_next[44] = add5_out;
            V_matrix_next[52] = add6_out;
            V_matrix_next[60] = add7_out;
            
            multi8_a = Q_matrix[32];
            multi9_a = Q_matrix[33];
            multi10_a = Q_matrix[34];
            multi11_a = Q_matrix[35];
            multi12_a = Q_matrix[36];
            multi13_a = Q_matrix[37];
            multi14_a = Q_matrix[38];
            multi15_a = Q_matrix[39];
        end
        5,13,21,29,37,45,53,61: begin
            add0_b = V_matrix[5]; 
            add1_b = V_matrix[13];
            add2_b = V_matrix[21];
            add3_b = V_matrix[29];
            add4_b = V_matrix[37];
            add5_b = V_matrix[45];
            add6_b = V_matrix[53];
            add7_b = V_matrix[61];

            V_matrix_next[5] = add0_out;
            V_matrix_next[13] = add1_out;
            V_matrix_next[21] = add2_out;
            V_matrix_next[29] = add3_out;
            V_matrix_next[37] = add4_out;
            V_matrix_next[45] = add5_out;
            V_matrix_next[53] = add6_out;
            V_matrix_next[61] = add7_out;

            multi8_a = Q_matrix[40];
            multi9_a = Q_matrix[41];
            multi10_a = Q_matrix[42];
            multi11_a = Q_matrix[43];
            multi12_a = Q_matrix[44];
            multi13_a = Q_matrix[45];
            multi14_a = Q_matrix[46];
            multi15_a = Q_matrix[47];
        end
        6,14,22,30,38,46,54,62: begin
            add0_b = V_matrix[6]; 
            add1_b = V_matrix[14];
            add2_b = V_matrix[22];
            add3_b = V_matrix[30];
            add4_b = V_matrix[38];
            add5_b = V_matrix[46];
            add6_b = V_matrix[54];
            add7_b = V_matrix[62];

            V_matrix_next[6] = add0_out;
            V_matrix_next[14] = add1_out;
            V_matrix_next[22] = add2_out;
            V_matrix_next[30] = add3_out;
            V_matrix_next[38] = add4_out;
            V_matrix_next[46] = add5_out;
            V_matrix_next[54] = add6_out;
            V_matrix_next[62] = add7_out;

            multi8_a = Q_matrix[48];
            multi9_a = Q_matrix[49];
            multi10_a = Q_matrix[50];
            multi11_a = Q_matrix[51];
            multi12_a = Q_matrix[52];
            multi13_a = Q_matrix[53];
            multi14_a = Q_matrix[54];
            multi15_a = Q_matrix[55];
        end
        7,15,23,31,39,47,55,63: begin
            add0_b = V_matrix[7]; 
            add1_b = V_matrix[15];
            add2_b = V_matrix[23];
            add3_b = V_matrix[31];
            add4_b = V_matrix[39];
            add5_b = V_matrix[47];
            add6_b = V_matrix[55];
            add7_b = V_matrix[63];

            V_matrix_next[7] = add0_out;
            V_matrix_next[15] = add1_out;
            V_matrix_next[23] = add2_out;
            V_matrix_next[31] = add3_out;
            V_matrix_next[39] = add4_out;
            V_matrix_next[47] = add5_out;
            V_matrix_next[55] = add6_out;
            V_matrix_next[63] = add7_out;

            multi8_a = Q_matrix[56];
            multi9_a = Q_matrix[57];
            multi10_a = Q_matrix[58];
            multi11_a = Q_matrix[59];
            multi12_a = Q_matrix[60];
            multi13_a = Q_matrix[61];
            multi14_a = Q_matrix[62];
            multi15_a = Q_matrix[63];
        end
        endcase
        
        case (cnt)
        0,1,2,3,4,5,6,7: begin
            multi8_b = K_matrix[0];
            multi9_b = K_matrix[1];
            multi10_b = K_matrix[2];
            multi11_b = K_matrix[3];
            multi12_b = K_matrix[4];
            multi13_b = K_matrix[5];
            multi14_b = K_matrix[6];
            multi15_b = K_matrix[7];
        end
        8,9,10,11,12,13,14,15: begin
            multi8_b = K_matrix[8];
            multi9_b = K_matrix[9];
            multi10_b = K_matrix[10];
            multi11_b = K_matrix[11];
            multi12_b = K_matrix[12];
            multi13_b = K_matrix[13];
            multi14_b = K_matrix[14];
            multi15_b = K_matrix[15];
        end
        16,17,18,19,20,21,22,23: begin
            multi8_b = K_matrix[16];
            multi9_b = K_matrix[17];
            multi10_b = K_matrix[18];
            multi11_b = K_matrix[19];
            multi12_b = K_matrix[20];
            multi13_b = K_matrix[21];
            multi14_b = K_matrix[22];
            multi15_b = K_matrix[23];
        end
        24,25,26,27,28,29,30,31: begin
            multi8_b = K_matrix[24];
            multi9_b = K_matrix[25];
            multi10_b = K_matrix[26];
            multi11_b = K_matrix[27];
            multi12_b = K_matrix[28];
            multi13_b = K_matrix[29];
            multi14_b = K_matrix[30];
            multi15_b = K_matrix[31];
        end
        32,33,34,35,36,37,38,39: begin
            multi8_b = K_matrix[32];
            multi9_b = K_matrix[33];
            multi10_b = K_matrix[34];
            multi11_b = K_matrix[35];
            multi12_b = K_matrix[36];
            multi13_b = K_matrix[37];
            multi14_b = K_matrix[38];
            multi15_b = K_matrix[39];
        end
        40,41,42,43,44,45,46,47: begin
            multi8_b = K_matrix[40];
            multi9_b = K_matrix[41];
            multi10_b = K_matrix[42];
            multi11_b = K_matrix[43];
            multi12_b = K_matrix[44];
            multi13_b = K_matrix[45];
            multi14_b = K_matrix[46];
            multi15_b = K_matrix[47];
        end
        48,49,50,51,52,53,54,55: begin
            multi8_b = K_matrix[48];
            multi9_b = K_matrix[49];
            multi10_b = K_matrix[50];
            multi11_b = K_matrix[51];
            multi12_b = K_matrix[52];
            multi13_b = K_matrix[53];
            multi14_b = K_matrix[54];
            multi15_b = K_matrix[55];
        end
        56,57,58,59,60,61,62,63: begin
            multi8_b = K_matrix[56];
            multi9_b = K_matrix[57];
            multi10_b = K_matrix[58];
            multi11_b = K_matrix[59];
            multi12_b = K_matrix[60];
            multi13_b = K_matrix[61];
            multi14_b = K_matrix[62];
            multi15_b = K_matrix[63];
        end
        endcase

        add8_a = multi8_out;
        add8_b = multi9_out;
        add9_a = multi10_out;
        add9_b = multi11_out;
        add10_a = multi12_out;
        add10_b = multi13_out;
        add11_a = multi14_out;
        add11_b = multi15_out;

        add12_a = add8_out;
        add12_b = add9_out;
        add13_a = add10_out;
        add13_b = add11_out;
        add14_a = add12_out;
        add14_b = add13_out;
        div0_a = add14_out;
        QKT_next[cnt] = div0_out;

        if (cnt == 63) begin
            next_state = OUTPUT;
            cnt_next = 0;
        end
    end
    OUTPUT: begin
        out_valid_next = 1;
        cnt_next = cnt + 1;
        case (cnt)
        0,1,2,3,4,5,6,7: begin
            multi0_a = QKT[0];
            multi1_a = QKT[1];
            multi2_a = QKT[2];
            multi3_a = QKT[3];
            multi4_a = QKT[4];
            multi5_a = QKT[5];
            multi6_a = QKT[6];
            multi7_a = QKT[7];
        end
        8,9,10,11,12,13,14,15: begin
            multi0_a = QKT[8];
            multi1_a = QKT[9];
            multi2_a = QKT[10];
            multi3_a = QKT[11];
            multi4_a = QKT[12];
            multi5_a = QKT[13];
            multi6_a = QKT[14];
            multi7_a = QKT[15];
        end
        16,17,18,19,20,21,22,23: begin
            multi0_a = QKT[16];
            multi1_a = QKT[17];
            multi2_a = QKT[18];
            multi3_a = QKT[19];
            multi4_a = QKT[20];
            multi5_a = QKT[21];
            multi6_a = QKT[22];
            multi7_a = QKT[23];
        end
        24,25,26,27,28,29,30,31: begin
            multi0_a = QKT[24];
            multi1_a = QKT[25];
            multi2_a = QKT[26];
            multi3_a = QKT[27];
            multi4_a = QKT[28];
            multi5_a = QKT[29];
            multi6_a = QKT[30];
            multi7_a = QKT[31];
        end
        32,33,34,35,36,37,38,39: begin
            multi0_a = QKT[32];
            multi1_a = QKT[33];
            multi2_a = QKT[34];
            multi3_a = QKT[35];
            multi4_a = QKT[36];
            multi5_a = QKT[37];
            multi6_a = QKT[38];
            multi7_a = QKT[39];
        end
        40,41,42,43,44,45,46,47: begin
            multi0_a = QKT[40];
            multi1_a = QKT[41];
            multi2_a = QKT[42];
            multi3_a = QKT[43];
            multi4_a = QKT[44];
            multi5_a = QKT[45];
            multi6_a = QKT[46];
            multi7_a = QKT[47];
        end
        48,49,50,51,52,53,54,55: begin
            multi0_a = QKT[48];
            multi1_a = QKT[49];
            multi2_a = QKT[50];
            multi3_a = QKT[51];
            multi4_a = QKT[52];
            multi5_a = QKT[53];
            multi6_a = QKT[54];
            multi7_a = QKT[55];
        end
        56,57,58,59,60,61,62,63: begin
            multi0_a = QKT[56];
            multi1_a = QKT[57];
            multi2_a = QKT[58];
            multi3_a = QKT[59];
            multi4_a = QKT[60];
            multi5_a = QKT[61];
            multi6_a = QKT[62];
            multi7_a = QKT[63];
        end
        endcase

        case (cnt)
        0,8,16,24,32,40,48,56: begin
            multi0_b = V_matrix[0];
            multi1_b = V_matrix[8];
            multi2_b = V_matrix[16];
            multi3_b = V_matrix[24];
            multi4_b = V_matrix[32];
            multi5_b = V_matrix[40];
            multi6_b = V_matrix[48];
            multi7_b = V_matrix[56];
        end
        1,9,17,25,33,41,49,57: begin
            multi0_b = V_matrix[1];
            multi1_b = V_matrix[9];
            multi2_b = V_matrix[17];
            multi3_b = V_matrix[25];
            multi4_b = V_matrix[33];
            multi5_b = V_matrix[41];
            multi6_b = V_matrix[49];
            multi7_b = V_matrix[57];
        end
        2,10,18,26,34,42,50,58: begin
            multi0_b = V_matrix[2];
            multi1_b = V_matrix[10];
            multi2_b = V_matrix[18];
            multi3_b = V_matrix[26];
            multi4_b = V_matrix[34];
            multi5_b = V_matrix[42];
            multi6_b = V_matrix[50];
            multi7_b = V_matrix[58];
        end
        3,11,19,27,35,43,51,59: begin
            multi0_b = V_matrix[3];
            multi1_b = V_matrix[11];
            multi2_b = V_matrix[19];
            multi3_b = V_matrix[27];
            multi4_b = V_matrix[35];
            multi5_b = V_matrix[43];
            multi6_b = V_matrix[51];
            multi7_b = V_matrix[59];
        end
        4,12,20,28,36,44,52,60: begin
            multi0_b = V_matrix[4];
            multi1_b = V_matrix[12];
            multi2_b = V_matrix[20];
            multi3_b = V_matrix[28];
            multi4_b = V_matrix[36];
            multi5_b = V_matrix[44];
            multi6_b = V_matrix[52];
            multi7_b = V_matrix[60];
        end
        5,13,21,29,37,45,53,61: begin
            multi0_b = V_matrix[5];
            multi1_b = V_matrix[13];
            multi2_b = V_matrix[21];
            multi3_b = V_matrix[29];
            multi4_b = V_matrix[37];
            multi5_b = V_matrix[45];
            multi6_b = V_matrix[53];
            multi7_b = V_matrix[61];
        end
        6,14,22,30,38,46,54,62: begin
            multi0_b = V_matrix[6];
            multi1_b = V_matrix[14];
            multi2_b = V_matrix[22];
            multi3_b = V_matrix[30];
            multi4_b = V_matrix[38];
            multi5_b = V_matrix[46];
            multi6_b = V_matrix[54];
            multi7_b = V_matrix[62];
        end
        7,15,23,31,39,47,55,63: begin
            multi0_b = V_matrix[7];
            multi1_b = V_matrix[15];
            multi2_b = V_matrix[23];
            multi3_b = V_matrix[31];
            multi4_b = V_matrix[39];
            multi5_b = V_matrix[47];
            multi6_b = V_matrix[55];
            multi7_b = V_matrix[63];
        end
        endcase

        add0_a = multi0_out;
        add0_b = multi1_out;
        add1_a = multi2_out;
        add1_b = multi3_out;
        add2_a = multi4_out;
        add2_b = multi5_out;
        add3_a = multi6_out;
        add3_b = multi7_out;
        add4_a = add0_out;
        add4_b = add1_out;
        add5_a = add2_out;
        add5_b = add3_out;
        add6_a = add4_out;
        add6_b = add5_out;
        out_data_next = add6_out;

        case (T_reg)
        1: begin
            if (cnt == 7) begin
                next_state = IDLE;
                cnt_next = 0;
            end
        end
        4: begin
            if (cnt == 31) begin
                next_state = IDLE;
                cnt_next = 0;
            end
        end
        8: begin
            if (cnt == 63) begin
                next_state = IDLE;
                cnt_next = 0;
            end
        end
        endcase
    end
    endcase
end

always @(*) begin
    T_comb = T_reg;
    case (current_state)
    IDLE: begin
        if (in_valid) begin
            T_comb = T;
        end
    end
    endcase
end

// in_data_comb
always @(*) begin
    in_data_comb = 0;
    case (T_reg)
    1: begin
        if (cnt < 7) begin
            in_data_comb = in_data;
        end
    end
    4: begin
        if (cnt < 31) begin
            in_data_comb = in_data;
        end
    end
    8: in_data_comb = in_data;
    endcase
end

// synopsys translate_off
task print_in_data_matrix; begin
    $display("in_data_matrix:");
    for (integer i=0 ;i < 8 ; i = i + 1) begin
        $display("%d %d %d %d %d %d %d %d", in_data_matrix[i*8], in_data_matrix[i*8+1], in_data_matrix[i*8+2], in_data_matrix[i*8+3], in_data_matrix[i*8+4], in_data_matrix[i*8+5], in_data_matrix[i*8+6], in_data_matrix[i*8+7]);
    end
end
endtask

task print_w_Q_matrix; begin
    $display("w_Q_matrix:");
    for (integer i=0 ;i < 8 ; i = i + 1) begin
        $display("%d %d %d %d %d %d %d %d", w_Q_matrix[i*8], w_Q_matrix[i*8+1], w_Q_matrix[i*8+2], w_Q_matrix[i*8+3], w_Q_matrix[i*8+4], w_Q_matrix[i*8+5], w_Q_matrix[i*8+6], w_Q_matrix[i*8+7]);
    end
end
endtask

task print_Q_matrix; begin
    $display("Q_matrix:");
    for (integer i=0 ;i < 8 ; i = i + 1) begin
        $display("%d %d %d %d %d %d %d %d", Q_matrix[i*8], Q_matrix[i*8+1], Q_matrix[i*8+2], Q_matrix[i*8+3], Q_matrix[i*8+4], Q_matrix[i*8+5], Q_matrix[i*8+6], Q_matrix[i*8+7]);
    end
end
endtask

task print_K_matrix; begin
    $display("K_matrix:");
    for (integer i=0 ;i < 8 ; i = i + 1) begin
        $display("%d %d %d %d %d %d %d %d", K_matrix[i*8], K_matrix[i*8+1], K_matrix[i*8+2], K_matrix[i*8+3], K_matrix[i*8+4], K_matrix[i*8+5], K_matrix[i*8+6], K_matrix[i*8+7]);
    end
end
endtask

task print_V_matrix; begin
    $display("V_matrix:");
    for (integer i=0 ;i < 8 ; i = i + 1) begin
        $display("%d %d %d %d %d %d %d %d", V_matrix[i*8], V_matrix[i*8+1], V_matrix[i*8+2], V_matrix[i*8+3], V_matrix[i*8+4], V_matrix[i*8+5], V_matrix[i*8+6], V_matrix[i*8+7]);
    end
end
endtask

task print_QKT_matrix; begin
    $display("QKT_matrix:");
    for (integer i=0 ;i < 8 ; i = i + 1) begin
        $display("%d %d %d %d %d %d %d %d", QKT[i*8], QKT[i*8+1], QKT[i*8+2], QKT[i*8+3], QKT[i*8+4], QKT[i*8+5], QKT[i*8+6], QKT[i*8+7]);
    end
end
endtask
// synopsys translate_on

endmodule