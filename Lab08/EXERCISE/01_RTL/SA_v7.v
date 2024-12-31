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
reg [3:0] current_state, next_state;

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
reg signed [7:0] in_data_buf;
reg signed [7:0] in_data_comb;
always @(posedge clk) begin
    in_data_buf <= in_data_comb;
end

always @(posedge clk) begin
    in_data_matrix <= in_data_matrix_next;
end

reg signed [7:0] w_Q_matrix_next [0:63];
reg signed [7:0] w_Q_matrix [0:63];
reg signed [7:0] w_Q_buf;

always @(posedge clk) begin
    w_Q_buf <= w_Q;
end
always @(posedge clk) begin
    w_Q_matrix <= w_Q_matrix_next;
end

reg signed [7:0] w_K_buf;
reg signed [7:0] w_V_buf;
always @(posedge clk) begin
    w_K_buf <= w_K;
end
always @(posedge clk) begin
    w_V_buf <= w_V;
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
wire out_data_ctrl = (cg_en && (current_state == READ_Q || current_state == READ_K));
wire out_data_clk;
GATED_OR GATED_out_data_reg(.CLOCK(clk), .SLEEP_CTRL(out_data_ctrl), .RST_N(rst_n), .CLOCK_GATED(out_data_clk));
always @(posedge out_data_clk or negedge rst_n) begin
    if (!rst_n) begin
        out_data <= 0;
    end
    else begin
        out_data <= out_data_next;
    end
end

reg out_valid_next;
wire out_valid_ctrl = (cg_en && (current_state == READ_Q || current_state == READ_K));
wire out_valid_clk;
GATED_OR GATED_out_valid_reg(.CLOCK(clk), .SLEEP_CTRL(out_valid_ctrl), .RST_N(rst_n), .CLOCK_GATED(out_valid_clk));
always @(posedge out_valid_clk or negedge rst_n) begin
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


reg signed [40:0] QKT [0:63];
reg signed [40:0] QKT_next [0:63];
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i = 0; i < 64; i = i + 1) begin
            QKT[i] <= 0;
        end
    end
    else begin
        QKT <= QKT_next;
    end
end

always @(*) begin
    next_state = current_state;
    T_comb = T_reg;
    in_data_matrix_next = in_data_matrix;
    out_valid_next = 0;
    out_data_next = 0;

    cnt_next = 0;


    w_Q_matrix_next = w_Q_matrix;
    Q_matrix_next = Q_matrix;
    K_matrix_next = K_matrix;
    V_matrix_next = V_matrix;

    QKT_next = QKT;
    div0_a = 0;

    add0_a = 0; add0_b = 0; add1_a = 0; add1_b = 0; add2_a = 0; add2_b = 0; add3_a = 0; add3_b = 0; add4_a = 0; add4_b = 0; add5_a = 0; add5_b = 0; add6_a = 0; add6_b = 0; add7_a = 0; add7_b = 0;
    add8_a = 0; add8_b = 0; add9_a = 0; add9_b = 0; add10_a = 0; add10_b = 0; add11_a = 0; add11_b = 0; add12_a = 0; add12_b = 0; add13_a = 0; add13_b = 0; add14_a = 0; add14_b = 0; add15_a = 0; add15_b = 0;

    multi0_a = 0; multi0_b = 0; multi1_a = 0; multi1_b = 0; multi2_a = 0; multi2_b = 0; multi3_a = 0; multi3_b = 0; multi4_a = 0; multi4_b = 0; multi5_a = 0; multi5_b = 0; multi6_a = 0; multi6_b = 0; multi7_a = 0; multi7_b = 0;
    multi8_a = 0; multi8_b = 0; multi9_a = 0; multi9_b = 0; multi10_a = 0; multi10_b = 0; multi11_a = 0; multi11_b = 0; multi12_a = 0; multi12_b = 0; multi13_a = 0; multi13_b = 0; multi14_a = 0; multi14_b = 0; multi15_a = 0; multi15_b = 0;

    case (current_state)
    IDLE: begin
        if (in_valid) begin
            next_state = READ_Q;
            T_comb = T;
            cnt_next = 0;
        end
    end
    READ_Q: begin
        cnt_next = cnt + 1;
        in_data_matrix_next[63] = in_data_buf;
        in_data_matrix_next[0:62] = in_data_matrix[1:63];
        w_Q_matrix_next[63] = w_Q_buf;
        w_Q_matrix_next[0:62] = w_Q_matrix[1:63];
        if (cnt == 63) begin
            next_state = READ_K;
            cnt_next = 0;
        end
    end
    READ_K: begin
        cnt_next = cnt + 1;

        // left shift
        Q_matrix_next[0:62] = Q_matrix[1:63];
        Q_matrix_next[63] = Q_matrix[0];
        K_matrix_next[0:62] = K_matrix[1:63];
        K_matrix_next[63] = K_matrix[0];

        w_Q_matrix_next[0:62] = w_Q_matrix[1:63];
        w_Q_matrix_next[63] = w_Q_matrix[0];

        case (cnt)
        7,15,23,31,39,47,55: begin
            in_data_matrix_next[63] = in_data_matrix[0];
            in_data_matrix_next[0:62] = in_data_matrix[1:63];
        end
        63: begin
            in_data_matrix_next[0:6] = in_data_matrix[57:63];
            in_data_matrix_next[7:63] = in_data_matrix[0:56];
            next_state = READ_V;   
            cnt_next = 0;
        end
        endcase

        // Q matrix
        multi0_a = in_data_matrix[0];
        multi1_a = in_data_matrix[8];
        multi2_a = in_data_matrix[16];
        multi3_a = in_data_matrix[24];
        multi4_a = in_data_matrix[32];
        multi5_a = in_data_matrix[40];
        multi6_a = in_data_matrix[48];
        multi7_a = in_data_matrix[56];
        multi0_b = w_Q_matrix[0];
        multi1_b = w_Q_matrix[0];
        multi2_b = w_Q_matrix[0];
        multi3_b = w_Q_matrix[0];
        multi4_b = w_Q_matrix[0];
        multi5_b = w_Q_matrix[0];
        multi6_b = w_Q_matrix[0];
        multi7_b = w_Q_matrix[0];

        add0_a = multi0_out;
        add1_a = multi1_out;
        add2_a = multi2_out;
        add3_a = multi3_out;
        add4_a = multi4_out;
        add5_a = multi5_out;
        add6_a = multi6_out;
        add7_a = multi7_out;
        add0_b = Q_matrix[0];
        add1_b = Q_matrix[8];
        add2_b = Q_matrix[16];
        add3_b = Q_matrix[24];
        add4_b = Q_matrix[32];
        add5_b = Q_matrix[40];
        add6_b = Q_matrix[48];
        add7_b = Q_matrix[56];

        Q_matrix_next[7] = add0_out;
        Q_matrix_next[15] = add1_out;
        Q_matrix_next[23] = add2_out;
        Q_matrix_next[31] = add3_out;
        Q_matrix_next[39] = add4_out;
        Q_matrix_next[47] = add5_out;
        Q_matrix_next[55] = add6_out;
        Q_matrix_next[63] = add7_out;

        // K matrix
        multi8_a = in_data_matrix[0];
        multi9_a = in_data_matrix[8];
        multi10_a = in_data_matrix[16];
        multi11_a = in_data_matrix[24];
        multi12_a = in_data_matrix[32];
        multi13_a = in_data_matrix[40];
        multi14_a = in_data_matrix[48];
        multi15_a = in_data_matrix[56];
        multi8_b = w_K_buf;
        multi9_b = w_K_buf;
        multi10_b = w_K_buf;
        multi11_b = w_K_buf;
        multi12_b = w_K_buf;
        multi13_b = w_K_buf;
        multi14_b = w_K_buf;
        multi15_b = w_K_buf;

        add8_a = multi8_out;
        add9_a = multi9_out;
        add10_a = multi10_out;
        add11_a = multi11_out;
        add12_a = multi12_out;
        add13_a = multi13_out;
        add14_a = multi14_out;
        add15_a = multi15_out;
        add8_b = K_matrix[0];
        add9_b = K_matrix[8];
        add10_b = K_matrix[16];
        add11_b = K_matrix[24];
        add12_b = K_matrix[32];
        add13_b = K_matrix[40];
        add14_b = K_matrix[48];
        add15_b = K_matrix[56];

        K_matrix_next[7] = add8_out;
        K_matrix_next[15] = add9_out;
        K_matrix_next[23] = add10_out;
        K_matrix_next[31] = add11_out;
        K_matrix_next[39] = add12_out;
        K_matrix_next[47] = add13_out;
        K_matrix_next[55] = add14_out;
        K_matrix_next[63] = add15_out;
    end
    READ_V: begin
        cnt_next = cnt + 1;

        // left shift
        V_matrix_next[0:62] = V_matrix[1:63];
        V_matrix_next[63] = V_matrix[0];

        QKT_next[0:62] = QKT[1:63];
        QKT_next[63] = QKT[0];

        // QKT matrix
        multi0_a = Q_matrix[0];
        multi1_a = Q_matrix[1];
        multi2_a = Q_matrix[2];
        multi3_a = Q_matrix[3];
        multi4_a = Q_matrix[4];
        multi5_a = Q_matrix[5];
        multi6_a = Q_matrix[6];
        multi7_a = Q_matrix[7];
        multi0_b = K_matrix[0];
        multi1_b = K_matrix[1];
        multi2_b = K_matrix[2];
        multi3_b = K_matrix[3];
        multi4_b = K_matrix[4];
        multi5_b = K_matrix[5];
        multi6_b = K_matrix[6];
        multi7_b = K_matrix[7];

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

        QKT_next[63] = add6_out;
        div0_a = QKT[63];
        QKT_next[62] = div0_out;
        
        // V matrix
        multi8_a = in_data_matrix[0];
        multi9_a = in_data_matrix[8];
        multi10_a = in_data_matrix[16];
        multi11_a = in_data_matrix[24];
        multi12_a = in_data_matrix[32];
        multi13_a = in_data_matrix[40];
        multi14_a = in_data_matrix[48];
        multi15_a = in_data_matrix[56];
        multi8_b = w_V_buf;
        multi9_b = w_V_buf;
        multi10_b = w_V_buf;
        multi11_b = w_V_buf;
        multi12_b = w_V_buf;
        multi13_b = w_V_buf;
        multi14_b = w_V_buf;
        multi15_b = w_V_buf;

        add8_a = multi8_out;
        add9_a = multi9_out;
        add10_a = multi10_out;
        add11_a = multi11_out;
        add12_a = multi12_out;
        add13_a = multi13_out;
        add14_a = multi14_out;
        add15_a = multi15_out;
        add8_b = V_matrix[0];
        add9_b = V_matrix[8];
        add10_b = V_matrix[16];
        add11_b = V_matrix[24];
        add12_b = V_matrix[32];
        add13_b = V_matrix[40];
        add14_b = V_matrix[48];
        add15_b = V_matrix[56];

        V_matrix_next[7] = add8_out;
        V_matrix_next[15] = add9_out;
        V_matrix_next[23] = add10_out;
        V_matrix_next[31] = add11_out;
        V_matrix_next[39] = add12_out;
        V_matrix_next[47] = add13_out;
        V_matrix_next[55] = add14_out;
        V_matrix_next[63] = add15_out;

        K_matrix_next[0:55] = K_matrix[8:63];
        K_matrix_next[56:63] = K_matrix[0:7];

        case (cnt)
        7,15,23,31,39,47,55: begin
            in_data_matrix_next[63] = in_data_matrix[0];
            in_data_matrix_next[0:62] = in_data_matrix[1:63];
            Q_matrix_next[0:55] = Q_matrix[8:63];
            Q_matrix_next[56:63] = Q_matrix[0:7];
        end
        63: begin
            // at last cycle, stall QKT
            QKT_next = QKT;
            Q_matrix_next = Q_matrix;
            K_matrix_next = K_matrix;

            multi0_a = QKT[1];
            multi1_a = QKT[2];
            multi2_a = QKT[3];
            multi3_a = QKT[4];
            multi4_a = QKT[5];
            multi5_a = QKT[6];
            multi6_a = QKT[7];
            multi7_a = QKT[8];
            multi0_b = V_matrix[1];
            multi1_b = V_matrix[9];
            multi2_b = V_matrix[17];
            multi3_b = V_matrix[25];
            multi4_b = V_matrix[33];
            multi5_b = V_matrix[41];
            multi6_b = V_matrix[49];
            multi7_b = V_matrix[57];

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
            out_valid_next = 1;
            out_data_next = add6_out;
            next_state = OUTPUT;
            cnt_next = 0;
        end
        endcase        
    end
    OUTPUT: begin
        cnt_next = cnt + 1;
        out_valid_next = 1;

        // shift column
        V_matrix_next[0:62] = V_matrix[1:63];
        V_matrix_next[63] = V_matrix[0];

        case (cnt)
        6,14,22,30,38,46,54: begin
            V_matrix_next[7:63] = V_matrix[0:56];
            V_matrix_next[0:6] = V_matrix[57:63];
            QKT_next[0:55] = QKT[8:63];
            QKT_next[56:63] = QKT[0:7];
        end
        endcase

        // output
        multi8_a = QKT[0];
        multi9_a = QKT[1];
        multi10_a = QKT[2];
        multi11_a = QKT[3];
        multi12_a = QKT[4];
        multi13_a = QKT[5];
        multi14_a = QKT[6];
        multi15_a = QKT[7];
        multi8_b = V_matrix[1];
        multi9_b = V_matrix[9];
        multi10_b = V_matrix[17];
        multi11_b = V_matrix[25];
        multi12_b = V_matrix[33];
        multi13_b = V_matrix[41];
        multi14_b = V_matrix[49];
        multi15_b = V_matrix[57];

        add7_a = multi8_out;
        add7_b = multi9_out;
        add8_a = multi10_out;
        add8_b = multi11_out;
        add9_a = multi12_out;
        add9_b = multi13_out;
        add10_a = multi14_out;
        add10_b = multi15_out;
        add11_a = add7_out;
        add11_b = add8_out;
        add12_a = add9_out;
        add12_b = add10_out;
        add13_a = add11_out;
        add13_b = add12_out;

        out_data_next = add13_out;

        case (cnt)
        0: begin
            // left shift
            QKT_next[0:62] = QKT[1:63];
            QKT_next[63] = QKT[0];

            // QKT matrix
            multi0_a = Q_matrix[0];
            multi1_a = Q_matrix[1];
            multi2_a = Q_matrix[2];
            multi3_a = Q_matrix[3];
            multi4_a = Q_matrix[4];
            multi5_a = Q_matrix[5];
            multi6_a = Q_matrix[6];
            multi7_a = Q_matrix[7];
            multi0_b = K_matrix[0];
            multi1_b = K_matrix[1];
            multi2_b = K_matrix[2];
            multi3_b = K_matrix[3];
            multi4_b = K_matrix[4];
            multi5_b = K_matrix[5];
            multi6_b = K_matrix[6];
            multi7_b = K_matrix[7];

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

            QKT_next[63] = add6_out;
            div0_a = QKT[63];
            QKT_next[62] = div0_out;

            // output
            multi8_a = QKT[1];
            multi9_a = QKT[2];
            multi10_a = QKT[3];
            multi11_a = QKT[4];
            multi12_a = QKT[5];
            multi13_a = QKT[6];
            multi14_a = QKT[7];
            multi15_a = QKT[8];
            multi8_b = V_matrix[1];
            multi9_b = V_matrix[9];
            multi10_b = V_matrix[17];
            multi11_b = V_matrix[25];
            multi12_b = V_matrix[33];
            multi13_b = V_matrix[41];
            multi14_b = V_matrix[49];
            multi15_b = V_matrix[57];

            add7_a = multi8_out;
            add7_b = multi9_out;
            add8_a = multi10_out;
            add8_b = multi11_out;
            add9_a = multi12_out;
            add9_b = multi13_out;
            add10_a = multi14_out;
            add10_b = multi15_out;
            add11_a = add7_out;
            add11_b = add8_out;
            add12_a = add9_out;
            add12_b = add10_out;
            add13_a = add11_out;
            add13_b = add12_out;
            out_data_next = add13_out;
        end
        1: begin
            div0_a = QKT[63];
            QKT_next[63] = div0_out;
        end
        endcase
        
        case (T_reg)
        1: begin
            if (cnt == 6) begin
                next_state = IDLE;
                cnt_next = 0;
                for (integer i=0; i<64; i=i+1) begin
                    Q_matrix_next[i] = 0;
                    K_matrix_next[i] = 0;
                    V_matrix_next[i] = 0;
                end
            end
        end
        4: begin
            if (cnt == 30) begin
                next_state = IDLE;
                cnt_next = 0;
                for (integer i=0; i<64; i=i+1) begin
                    Q_matrix_next[i] = 0;
                    K_matrix_next[i] = 0;
                    V_matrix_next[i] = 0;
                end
            end
        end
        8: begin
            if (cnt == 62) begin
                next_state = IDLE;
                cnt_next = 0;
                for (integer i=0; i<64; i=i+1) begin
                    Q_matrix_next[i] = 0;
                    K_matrix_next[i] = 0;
                    V_matrix_next[i] = 0;
                end
            end
        end
        endcase

    end
    endcase
end

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




