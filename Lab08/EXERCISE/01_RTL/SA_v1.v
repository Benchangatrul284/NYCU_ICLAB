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

//==============================================//
//       parameter & integer declaration        //
//==============================================//
parameter IDLE = 3'b000;
parameter READ_Q = 3'b001;
parameter READ_K = 3'b010;
parameter READ_V = 3'b011;



reg [3:0] current_state, next_state;
reg [7:0] r_cnt, r_cnt_next, c_cnt, c_cnt_next;

reg signed [7:0] data_matrix_row0 [0:7];
reg signed [7:0] data_matrix_row1 [0:7];
reg signed [7:0] data_matrix_row2 [0:7];
reg signed [7:0] data_matrix_row3 [0:7];
reg signed [7:0] data_matrix_row4 [0:7];
reg signed [7:0] data_matrix_row5 [0:7];
reg signed [7:0] data_matrix_row6 [0:7];
reg signed [7:0] data_matrix_row7 [0:7];

reg signed [7:0] data_matrix_row0_next [0:7];
reg signed [7:0] data_matrix_row1_next [0:7];
reg signed [7:0] data_matrix_row2_next [0:7];
reg signed [7:0] data_matrix_row3_next [0:7];
reg signed [7:0] data_matrix_row4_next [0:7];
reg signed [7:0] data_matrix_row5_next [0:7];
reg signed [7:0] data_matrix_row6_next [0:7];
reg signed [7:0] data_matrix_row7_next [0:7];


reg signed [7:0] weight_matrix [0:63];
reg signed [7:0] weight_matrix_next [0:63];

reg [3:0] T_comb, T_reg;

reg signed [39:0] multi0_a, multi1_a, multi2_a, multi3_a, multi4_a, multi5_a, multi6_a, multi7_a, multi8_a;
reg signed [18:0] multi0_b, multi1_b, multi2_b, multi3_b, multi4_b, multi5_b, multi6_b, multi7_b, multi8_b;
reg signed [58:0] multi0_out, multi1_out, multi2_out, multi3_out, multi4_out, multi5_out, multi6_out, multi7_out, multi8_out;

reg signed [61:0] add0_a, add1_a, add2_a, add3_a, add4_a, add5_a, add6_a, add7_a;
reg signed [61:0] add0_b, add1_b, add2_b, add3_b, add4_b, add5_b, add6_b, add7_b;
reg signed [62:0] add0_out, add1_out, add2_out, add3_out, add4_out, add5_out, add6_out, add7_out;

reg signed [58:0] multi0_out_buf, multi1_out_buf, multi2_out_buf, multi3_out_buf, multi4_out_buf, multi5_out_buf, multi6_out_buf, multi7_out_buf, multi8_out_buf;
reg signed [58:0] multi0_out_buf_next, multi1_out_buf_next, multi2_out_buf_next, multi3_out_buf_next, multi4_out_buf_next, multi5_out_buf_next, multi6_out_buf_next, multi7_out_buf_next, multi8_out_buf_next;


reg out_valid_next;
reg signed [63:0] out_data_next;

reg signed [18:0] Q_matrix [0:63];
reg signed [18:0] K_matrix [0:63];
reg signed [18:0] V_matrix [0:63];

reg signed [18:0] Q_matrix_next [0:63];
reg signed [18:0] K_matrix_next [0:63];
reg signed [18:0] V_matrix_next [0:63];

reg signed [7:0] in_data_buf;
reg signed [7:0] w_Q_buf;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i = 0; i < 64; i = i + 1) begin
            Q_matrix[i] <= 0;
            K_matrix[i] <= 0;
            V_matrix[i] <= 0;
        end
    end
    else begin
        Q_matrix <= Q_matrix_next;
        K_matrix <= K_matrix_next;
        V_matrix <= V_matrix_next;
    end
end

//==============================================//
//                 GATED_OR                     //
//==============================================//

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        r_cnt <= 0;
        c_cnt <= 0;
    end
    else begin
        r_cnt <= r_cnt_next;
        c_cnt <= c_cnt_next;
    end
end

// row 0
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
       data_matrix_row0 <= {0,0,0,0,0,0,0,0};
    end
    else begin
        data_matrix_row0 <= data_matrix_row0_next;
    end
end

// row 1
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
       data_matrix_row1 <= {0,0,0,0,0,0,0,0};
    end
    else begin
        data_matrix_row1 <= data_matrix_row1_next;
    end
end

// row 2
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
       data_matrix_row2 <= {0,0,0,0,0,0,0,0};
    end
    else begin
        data_matrix_row2 <= data_matrix_row2_next;
    end
end

// row 3
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
       data_matrix_row0 <= {0,0,0,0,0,0,0,0};
    end
    else begin
        data_matrix_row0 <= data_matrix_row0_next;
    end
end

// row 4
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
       data_matrix_row0 <= {0,0,0,0,0,0,0,0};
    end
    else begin
        data_matrix_row0 <= data_matrix_row0_next;
    end
end

// row 5
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
       data_matrix_row0 <= {0,0,0,0,0,0,0,0};
    end
    else begin
        data_matrix_row0 <= data_matrix_row0_next;
    end
end

// row 6
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
       data_matrix_row0 <= {0,0,0,0,0,0,0,0};
    end
    else begin
        data_matrix_row0 <= data_matrix_row0_next;
    end
end

// row 7
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
       data_matrix_row0 <= {0,0,0,0,0,0,0,0};
    end
    else begin
        data_matrix_row0 <= data_matrix_row0_next;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i = 0; i < 64; i = i + 1) begin
            weight_matrix[i] <= 0;
        end
    end
    else begin
        weight_matrix <= weight_matrix_next;
    end
end

always @(posedge clk) begin
    T_reg <= T_comb;
end

always @(posedge clk or rst_n) begin
    if (~rst_n) begin
        out_valid <= 0;
        out_data <= 0;
    end
    else begin
        out_valid <= out_valid_next;
        out_data <= out_data_next;
    end
end

always @(posedge clk) begin
    if (rst_n)
    multi0_out_buf <= multi0_out_buf_next;
    multi1_out_buf <= multi1_out_buf_next;
    multi2_out_buf <= multi2_out_buf_next;
    multi3_out_buf <= multi3_out_buf_next;
    multi4_out_buf <= multi4_out_buf_next;
    multi5_out_buf <= multi5_out_buf_next;
    multi6_out_buf <= multi6_out_buf_next;
    multi7_out_buf <= multi7_out_buf_next;
    multi8_out_buf <= multi8_out_buf_next;
end

always @(posedge clk) begin
    in_data_buf <= in_data;
    w_Q_buf <= w_Q;
end

always @(*) begin
    next_state = current_state;
    T_comb = T_reg;
    out_valid_next = 0;
    out_data_next = 0;

    r_cnt_next = r_cnt;
    c_cnt_next = c_cnt;


    data_matrix_row0_next = data_matrix_row0;
    data_matrix_row1_next = data_matrix_row1;
    data_matrix_row2_next = data_matrix_row2;
    data_matrix_row3_next = data_matrix_row3;
    data_matrix_row4_next = data_matrix_row4;
    data_matrix_row5_next = data_matrix_row5;
    data_matrix_row6_next = data_matrix_row6;
    data_matrix_row7_next = data_matrix_row7;

    multi0_a = 0;
    multi0_b = 0;
    multi1_a = 0;
    multi1_b = 0;
    multi2_a = 0;
    multi2_b = 0;
    multi3_a = 0;
    multi3_b = 0;
    multi4_a = 0;
    multi4_b = 0;
    multi5_a = 0;
    multi5_b = 0;
    multi6_a = 0;
    multi6_b = 0;
    multi7_a = 0;
    multi7_b = 0;
    multi8_a = 0;
    multi8_b = 0;

    multi0_out_buf_next = 0;
    multi1_out_buf_next = 0;
    multi2_out_buf_next = 0;
    multi3_out_buf_next = 0;
    multi4_out_buf_next = 0;
    multi5_out_buf_next = 0;
    multi6_out_buf_next = 0;
    multi7_out_buf_next = 0;
    multi8_out_buf_next = 0;

    add0_a = 0;
    add0_b = 0;
    add1_a = 0;
    add1_b = 0;
    add2_a = 0;
    add2_b = 0;
    add3_a = 0;
    add3_b = 0;
    add4_a = 0;
    add4_b = 0;
    add5_a = 0;
    add5_b = 0;
    add6_a = 0;
    add6_b = 0;
    add7_a = 0;
    add7_b = 0;

    Q_matrix_next = Q_matrix;
    K_matrix_next = K_matrix;
    V_matrix_next = V_matrix;

    case (current_state)
    IDLE: begin
        if (in_valid) begin
            next_state = READ_Q;
            T_comb = T;
            r_cnt_next = 0;
            c_cnt_next = 0;
            data_matrix_row0_next[0] = in_data;
            weight_matrix_next[63] = w_Q;
        end
    end
    READ_Q: begin
        c_cnt_next = c_cnt + 1;

        // left shift
        weight_matrix_next[63] = w_Q;
        weight_matrix_next[0:62] = weight_matrix[1:63];
        
        // left shift
        Q_matrix_next[0:62] = Q_matrix[1:63];
        Q_matrix_next[63] = Q_matrix[0];

        case (r_cnt)
            0: begin
                // multiply
                multi0_a = data_matrix_row0[0];
                multi0_b = weight_matrix[63];
                multi0_out_buf_next = multi0_out;
                
                // add
                add0_a = multi0_out_buf;
                add0_b = Q_matrix[0];
                Q_matrix_next[63] = add0_out;

                // store in_data
                case (c_cnt)
                0: begin
                    data_matrix_row0_next[1] = in_data;
                end
                1: begin
                    data_matrix_row0_next[2] = in_data;
                end
                2: begin
                    data_matrix_row0_next[3] = in_data;
                end
                3: begin
                    data_matrix_row0_next[4] = in_data;
                end
                4: begin
                    data_matrix_row0_next[5] = in_data;
                end
                5: begin
                    data_matrix_row0_next[6] = in_data;
                end
                6: begin
                    data_matrix_row0_next[7] = in_data;
                end
                7: begin
                    data_matrix_row1_next[0] = in_data;
                    c_cnt_next = 0;
                    r_cnt_next = r_cnt + 1;
                end
                endcase
            end
            1: begin
                // multiply
                multi0_a = data_matrix_row1[0];
                multi0_b = weight_matrix[55];
                multi0_out_buf_next = multi0_out;

                multi1_a = data_matrix_row0[1];
                multi1_b = weight_matrix[63];
                multi1_out_buf_next = multi1_out;

                // add
                add0_a = multi0_out_buf;
                add0_b = Q_matrix[0];
                Q_matrix_next[63] = add0_out;
                add1_a = multi1_out_buf;
                add1_b = Q_matrix[56];
                Q_matrix_next[55] = add1_out;

                case (c_cnt)
                0: begin
                    data_matrix_row1_next[1] = in_data;
                    // add
                    // add0_a = multi0_out_buf;
                    // add0_b = Q_matrix[0];
                    // Q_matrix_next[63] = add0_out;

                    // two multiply
                    // multi0_a = data_matrix_row1[0];
                    // multi0_b = weight_matrix[55];
                    // multi0_out_buf_next = multi0_out;

                    // multi1_a = data_matrix_row0[1];
                    // multi1_b = weight_matrix[63];
                    // multi1_out_buf_next = multi1_out;
                end
                1: begin
                    data_matrix_row1_next[2] = in_data;

                    // two adds
                    // now q will add to previous wq
                    add0_a = multi0_out_buf;
                    add0_b = Q_matrix[0];
                    Q_matrix_next[63] = add0_out;
                    // previous wq will add to now q
                    add1_a = multi1_out_buf;
                    add1_b = Q_matrix[56];
                    Q_matrix_next[55] = add1_out;
                end
                2: begin
                    data_matrix_row1_next[3] = in_data;
                    
                end
                3: begin
                    data_matrix_row1_next[4] = in_data;
                end
                4: begin
                    data_matrix_row1_next[5] = in_data;
                end
                5: begin
                    data_matrix_row1_next[6] = in_data;
                end
                6: begin
                    data_matrix_row1_next[7] = in_data;
                end
                7: begin
                    data_matrix_row2_next[0] = in_data;
                    c_cnt_next = 0;
                    r_cnt_next = r_cnt + 1;
                end
                endcase
            end
            2: begin
                print_Q_matrix_task;
                print_weight_matrix_task;
                $finish;
                r_cnt_next = r_cnt + 1;
            end
            3: begin
                r_cnt_next = r_cnt + 1;
            end
            4: begin
                r_cnt_next = r_cnt + 1;
            end
            5: begin
                r_cnt_next = r_cnt + 1;
            end
            6: begin
                r_cnt_next = r_cnt + 1;
            end
            7: begin
                next_state = READ_K;
                c_cnt_next = 0;
                r_cnt_next = 0;
                
            end
        endcase
    end
    endcase
end

// multiplier
always @(*) begin
    multi0_out = multi0_a * multi0_b;
    multi1_out = multi1_a * multi1_b;
    multi2_out = multi2_a * multi2_b;
    multi3_out = multi3_a * multi3_b;
    multi4_out = multi4_a * multi4_b;
    multi5_out = multi5_a * multi5_b;
    multi6_out = multi6_a * multi6_b;
    multi7_out = multi7_a * multi7_b;
end

// adder
always @(*) begin
    add0_out = add0_a + add0_b;
    add1_out = add1_a + add1_b;
    add2_out = add2_a + add2_b;
    add3_out = add3_a + add3_b;
    add4_out = add4_a + add4_b;
    add5_out = add5_a + add5_b;
    add6_out = add6_a + add6_b;
    add7_out = add7_a + add7_b;
end

task print_weight_matrix_task;
    $display("weight_matrix:");
    for (integer i = 0; i < 8 ; i = i + 1) begin
        $display("%d %d %d %d %d %d %d %d", weight_matrix[i*8], weight_matrix[i*8+1], weight_matrix[i*8+2], weight_matrix[i*8+3], weight_matrix[i*8+4], weight_matrix[i*8+5], weight_matrix[i*8+6], weight_matrix[i*8+7]);
    end
endtask

task print_Q_matrix_task;
    $display("Q_matrix:");
    for (integer i = 0; i < 8 ; i = i + 1) begin
        $display("%d %d %d %d %d %d %d %d", Q_matrix[i*8], Q_matrix[i*8+1], Q_matrix[i*8+2], Q_matrix[i*8+3], Q_matrix[i*8+4], Q_matrix[i*8+5], Q_matrix[i*8+6], Q_matrix[i*8+7]);
    end
endtask
endmodule




