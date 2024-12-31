//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2024/9
//		Version		: v1.0
//   	File Name   : MDC.v
//   	Module Name : MDC
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

//synopsys translate_off
`include "HAMMING_IP.v"
//synopsys translate_on

module MDC(
    // Input signals
    clk,
	rst_n,
	in_valid,
    in_data, 
	in_mode,
    // Output signals
    out_valid, 
	out_data
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk, rst_n, in_valid;
input [8:0] in_mode;
input [14:0] in_data;

output reg out_valid;
output reg [206:0] out_data;

reg [8:0] mode_buf;
reg [14:0] data_buf;

wire [4:0] mode_dec_out;
wire [10:0] data_dec_out;

reg signed [10:0] data_dec [0:15];
reg signed [10:0] data_dec_next [0:15];
reg [4:0] mode_dec;
reg [4:0] mode_dec_next;

reg [1:0] current_state, next_state;
parameter IDLE = 2'b00;
parameter DET2 = 2'b01, DET3 = 2'b10, DET4 = 2'b11;

reg signed [206:0] out_data_buf;
reg signed [206:0] out_data_buf_next;

reg add_flag, add_flag_next;
always @(posedge clk) begin
        add_flag <= add_flag_next;
end
reg [8:0] cnt, cnt_next;
// stores the intermediate values of det4 output
reg signed [22:0] det4_out0_next, det4_out1_next, det4_out2_next;
reg signed [22:0] det4_out0, det4_out1, det4_out2;
always @(posedge clk) begin
    det4_out0 <= det4_out0_next;
    det4_out1 <= det4_out1_next;
    det4_out2 <= det4_out2_next;
end

reg signed [10:0] coeff0_next, coeff1_next, coeff2_next;
reg signed [10:0] coeff0, coeff1, coeff2;
always @(posedge clk) begin
    coeff0 <= coeff0_next;
    coeff1 <= coeff1_next;
    coeff2 <= coeff2_next;
end

HAMMING_IP #(5) mode_dec_inst (
    .IN_code(in_mode),
    .OUT_code(mode_dec_out)
);

HAMMING_IP #(11) data_dec_inst (
    .IN_code(data_buf),
    .OUT_code(data_dec_out)
);

reg signed [10:0] det4_inst1_a, det4_inst1_b, det4_inst1_c, det4_inst1_d;
wire signed [22:0] det4_inst1_out;
det4 det4_inst1 (
    .a(det4_inst1_a),
    .b(det4_inst1_b),
    .c(det4_inst1_c),
    .d(det4_inst1_d),
    .out(det4_inst1_out)
);

reg signed [10:0] det4_inst2_a, det4_inst2_b, det4_inst2_c, det4_inst2_d;
wire signed [22:0] det4_inst2_out;
det4 det4_inst2 (
    .a(det4_inst2_a),
    .b(det4_inst2_b),
    .c(det4_inst2_c),
    .d(det4_inst2_d),
    .out(det4_inst2_out)
);

reg signed [10:0] det4_inst3_a, det4_inst3_b, det4_inst3_c, det4_inst3_d;
wire signed [22:0] det4_inst3_out;
det4 det4_inst3 (
    .a(det4_inst3_a),
    .b(det4_inst3_b),
    .c(det4_inst3_c),
    .d(det4_inst3_d),
    .out(det4_inst3_out)
);


reg signed [22:0] multi_23_11_inst0_det_23;
reg signed [10:0] multi_23_11_inst0_coeff_11;
wire signed [33:0] multi_23_11_inst0_out;
multi_23_11 multi_23_11_inst0 (
    .det_23(multi_23_11_inst0_det_23),
    .coeff_11(multi_23_11_inst0_coeff_11),
    .multi_23_11_out(multi_23_11_inst0_out)
);

reg signed [22:0] multi_23_11_inst1_det_23;
reg signed [10:0] multi_23_11_inst1_coeff_11;
wire signed [33:0] multi_23_11_inst1_out;
multi_23_11 multi_23_11_inst1 (
    .det_23(multi_23_11_inst1_det_23),
    .coeff_11(multi_23_11_inst1_coeff_11),
    .multi_23_11_out(multi_23_11_inst1_out)
);

reg signed [22:0] multi_23_11_inst2_det_23;
reg signed [10:0] multi_23_11_inst2_coeff_11;
wire signed [33:0] multi_23_11_inst2_out;
multi_23_11 multi_23_11_inst2 (
    .det_23(multi_23_11_inst2_det_23),
    .coeff_11(multi_23_11_inst2_coeff_11),
    .multi_23_11_out(multi_23_11_inst2_out)
);


reg signed [33:0] det_inter0, det_inter1, det_inter2;
reg signed [33:0] det_inter0_next, det_inter1_next, det_inter2_next;
always @(posedge clk) begin
    det_inter0 <= det_inter0_next;
    det_inter1 <= det_inter1_next;
    det_inter2 <= det_inter2_next;
end

reg signed [35:0] det_inter3_next;
reg signed [35:0] det_inter3;
always @(posedge clk) begin
    det_inter3 <= det_inter3_next;
end

reg signed [33:0] add_sub_add_50_inst_a, add_sub_add_50_inst_b, add_sub_add_50_inst_c;
wire signed [50:0] add_sub_add_50_inst_out;
add_sub_add_50 add_sub_add_50_inst (
    .a(add_sub_add_50_inst_a),
    .b(add_sub_add_50_inst_b),
    .c(add_sub_add_50_inst_c),
    .out(add_sub_add_50_inst_out)
);

reg signed [35:0] multi_36_11_inst_det_36;
reg signed [10:0] multi_36_11_inst_coeff_11;
wire signed [46:0] multi_36_11_inst_out;
multi_36_11 multi_36_11_inst (
    .det_36(multi_36_11_inst_det_36),
    .coeff_11(multi_36_11_inst_coeff_11),
    .multi_36_11_out(multi_36_11_inst_out)
);

reg signed [46:0] det_multi_47, det_multi_47_next;
always @(posedge clk) begin
    det_multi_47 <= det_multi_47_next;
end
reg signed [46:0] det_multi_47_add_sub;
reg signed [10:0] det4_coeff_pipe0_next, det4_coeff_pipe0;
reg signed [10:0] det4_coeff_pipe1, det4_coeff_pipe2;
always @(posedge clk) begin
    det4_coeff_pipe0 <= det4_coeff_pipe0_next;
    det4_coeff_pipe1 <= det4_coeff_pipe0;
    det4_coeff_pipe2 <= det4_coeff_pipe1;
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        current_state <= IDLE;
        out_data_buf <= 0;
    end else begin
        current_state <= next_state;
        out_data_buf <= out_data_buf_next;
    end
end

always @(posedge clk) begin
    mode_buf <= in_mode;
    data_buf <= in_data;
    mode_dec <= mode_dec_next;
    cnt <= cnt_next;
end

always @(posedge clk) begin
    case (current_state)
    DET2, DET3: begin
        data_dec[15] <= data_dec_out;
        data_dec[0:14] <= data_dec[1:15];
    end
    DET4: begin
        if (cnt < 16) begin
            data_dec[15] <= data_dec_out;
            data_dec[0:14] <= data_dec[1:15];
        end
    end
    endcase
end

// always @(negedge clk) begin
//     case (current_state)
//     DET4: begin
//         $display("===========cnt = %d===========", cnt);
//         case (cnt)
//         15: begin
//             print_dec_task;
//         end
//         16: begin
//             print_dec_task;
//         end
//         17: begin
            
//         end
//         endcase
//     end
//     endcase
// end

always @(*) begin
    out_valid = 0;
    out_data = 0;
    out_data_buf_next = out_data_buf;
    next_state = current_state;

    mode_dec_next = mode_dec;
    cnt_next = 0;

    det4_inst1_a = 0;
    det4_inst1_b = 0;
    det4_inst1_c = 0;
    det4_inst1_d = 0;
    det4_inst2_a = 0;
    det4_inst2_b = 0;
    det4_inst2_c = 0;
    det4_inst2_d = 0;
    det4_inst3_a = 0;
    det4_inst3_b = 0;
    det4_inst3_c = 0;
    det4_inst3_d = 0;

    det4_out0_next = 0;
    det4_out1_next = 0;
    det4_out2_next = 0;
    
    coeff0_next = 0;
    coeff1_next = 0;
    coeff2_next = 0;

    multi_23_11_inst0_det_23 = 0;
    multi_23_11_inst0_coeff_11 = 0;
    multi_23_11_inst1_det_23 = 0;
    multi_23_11_inst1_coeff_11 = 0;
    multi_23_11_inst2_det_23 = 0;
    multi_23_11_inst2_coeff_11 = 0;

    det_inter0_next = 0;
    det_inter1_next = 0;
    det_inter2_next = 0;
    
    add_sub_add_50_inst_a = 0;
    add_sub_add_50_inst_b = 0;
    add_sub_add_50_inst_c = 0;

    det_inter3_next = 0;

    multi_36_11_inst_det_36 = 0;
    multi_36_11_inst_coeff_11 = 0;
    det_multi_47_next = 0;
    det4_coeff_pipe0_next = 0;
    add_flag_next = 1;

    case (current_state)
    IDLE: begin
        if (in_valid) begin
            mode_dec_next = mode_dec_out;
            out_data_buf_next = 0;
            cnt_next = 0;
            case ({mode_dec_next[4],mode_dec_next[1]})
                2'b00: next_state = DET2;
                2'b01: next_state = DET3;
                2'b11: next_state = DET4;
                2'b10: next_state = DET4; // impossible case
            endcase
        end
    end
    DET2: begin
        cnt_next = cnt + 1;
        if (cnt == 8 || cnt == 12 || cnt == 16) begin
            det4_inst1_a = data_dec[8];
            det4_inst1_b = data_dec[9];
            det4_inst1_c = data_dec[12];
            det4_inst1_d = data_dec[13];
            det4_inst2_a = data_dec[9];
            det4_inst2_b = data_dec[10];
            det4_inst2_c = data_dec[13];
            det4_inst2_d = data_dec[14];
            det4_inst3_a = data_dec[10];
            det4_inst3_b = data_dec[11];
            det4_inst3_c = data_dec[14];
            det4_inst3_d = data_dec[15];
            out_data_buf_next[206:138] = out_data_buf[137:69];
            out_data_buf_next[137:69] = out_data_buf[68:0];
            out_data_buf_next[68:46] = det4_inst1_out;
            out_data_buf_next[45:23] = det4_inst2_out;
            out_data_buf_next[22:0] = det4_inst3_out;
        end
        if (cnt == 17) begin
            next_state = IDLE;
            out_valid = 1;
            out_data = out_data_buf;
            cnt_next = 0;
        end
    end
    DET3: begin
        cnt_next = cnt + 1;
        // stage 1
        det4_inst1_a = data_dec[4];
        det4_inst1_b = data_dec[5];
        det4_inst1_c = data_dec[8];
        det4_inst1_d = data_dec[9];
        det4_inst2_a = data_dec[4];
        det4_inst2_b = data_dec[6];
        det4_inst2_c = data_dec[8];
        det4_inst2_d = data_dec[10];
        det4_inst3_a = data_dec[5];
        det4_inst3_b = data_dec[6];
        det4_inst3_c = data_dec[9];
        det4_inst3_d = data_dec[10];

        det4_out0_next = det4_inst1_out;
        det4_out1_next = det4_inst2_out;
        det4_out2_next = det4_inst3_out;

        coeff0_next = data_dec[14];
        coeff1_next = data_dec[13];
        coeff2_next = data_dec[12];
        
        // stage 2
        multi_23_11_inst0_det_23 = det4_out0;
        multi_23_11_inst0_coeff_11 = coeff0;
        multi_23_11_inst1_det_23 = det4_out1;
        multi_23_11_inst1_coeff_11 = coeff1;
        multi_23_11_inst2_det_23 = det4_out2;
        multi_23_11_inst2_coeff_11 = coeff2;

        det_inter0_next = multi_23_11_inst0_out;
        det_inter1_next = multi_23_11_inst1_out;
        det_inter2_next = multi_23_11_inst2_out;
        
        if (cnt == 14 || cnt == 15 || cnt == 18 || cnt == 19) begin
            // stage 3
            add_sub_add_50_inst_a = det_inter0;
            add_sub_add_50_inst_b = det_inter1;
            add_sub_add_50_inst_c = det_inter2;
            out_data_buf_next[206:204] = 3'b000;
            out_data_buf_next[203:153] = out_data_buf[152:102];
            out_data_buf_next[152:102] = out_data_buf[101:51];
            out_data_buf_next[101:51] = out_data_buf[50:0];
            out_data_buf_next[50:0] = add_sub_add_50_inst_out;
        end

        if (cnt == 20) begin
            next_state = IDLE;
            out_valid = 1;
            out_data = out_data_buf;
            cnt_next = 0;
        end
    end
    DET4: begin
        add_flag_next = !add_flag;
        cnt_next = cnt + 1;
        case (cnt)
        16: begin
            // stage 1
            det4_inst1_a = data_dec[0];
            det4_inst1_b = data_dec[1];
            det4_inst1_c = data_dec[4];
            det4_inst1_d = data_dec[5];
            det4_inst2_a = data_dec[0];
            det4_inst2_b = data_dec[2];
            det4_inst2_c = data_dec[4];
            det4_inst2_d = data_dec[6];
            det4_inst3_a = data_dec[1];
            det4_inst3_b = data_dec[2];
            det4_inst3_c = data_dec[5];
            det4_inst3_d = data_dec[6];

            det4_coeff_pipe0_next = data_dec[15];
            coeff0_next = data_dec[10]; // coeff for det3
            coeff1_next = data_dec[9]; // coeff for det3
            coeff2_next = data_dec[8]; // coeff for det3
        end
        17: begin
            // stage 1
            det4_inst1_a = data_dec[0];
            det4_inst1_b = data_dec[1];
            det4_inst1_c = data_dec[4];
            det4_inst1_d = data_dec[5];
            det4_inst2_a = data_dec[0];
            det4_inst2_b = data_dec[3];
            det4_inst2_c = data_dec[4];
            det4_inst2_d = data_dec[7];
            det4_inst3_a = data_dec[1];
            det4_inst3_b = data_dec[3];
            det4_inst3_c = data_dec[5];
            det4_inst3_d = data_dec[7];

            det4_coeff_pipe0_next = data_dec[14];
            coeff0_next = data_dec[11]; // coeff for det3
            coeff1_next = data_dec[9]; // coeff for det3
            coeff2_next = data_dec[8]; // coeff for det3
        end
        18: begin
            // stage 1
            det4_inst1_a = data_dec[0];
            det4_inst1_b = data_dec[2];
            det4_inst1_c = data_dec[4];
            det4_inst1_d = data_dec[6];
            det4_inst2_a = data_dec[0];
            det4_inst2_b = data_dec[3];
            det4_inst2_c = data_dec[4];
            det4_inst2_d = data_dec[7];
            det4_inst3_a = data_dec[2];
            det4_inst3_b = data_dec[3];
            det4_inst3_c = data_dec[6];
            det4_inst3_d = data_dec[7];

            det4_coeff_pipe0_next = data_dec[13];
            coeff0_next = data_dec[11]; // coeff for det3
            coeff1_next = data_dec[10]; // coeff for det3
            coeff2_next = data_dec[8]; // coeff for det3
        end
        19: begin
            // stage 1
            det4_inst1_a = data_dec[1];
            det4_inst1_b = data_dec[2];
            det4_inst1_c = data_dec[5];
            det4_inst1_d = data_dec[6];
            det4_inst2_a = data_dec[1];
            det4_inst2_b = data_dec[3];
            det4_inst2_c = data_dec[5];
            det4_inst2_d = data_dec[7];
            det4_inst3_a = data_dec[2];
            det4_inst3_b = data_dec[3];
            det4_inst3_c = data_dec[6];
            det4_inst3_d = data_dec[7];

            det4_coeff_pipe0_next = data_dec[12];
            coeff0_next = data_dec[11]; // coeff for det3
            coeff1_next = data_dec[10]; // coeff for det3
            coeff2_next = data_dec[9]; // coeff for det3
        end
        endcase

        // stage 1
        det4_out0_next = det4_inst1_out;
        det4_out1_next = det4_inst2_out;
        det4_out2_next = det4_inst3_out;
        // stage 2
        multi_23_11_inst0_det_23 = det4_out0;
        multi_23_11_inst0_coeff_11 = coeff0;
        multi_23_11_inst1_det_23 = det4_out1;
        multi_23_11_inst1_coeff_11 = coeff1;
        multi_23_11_inst2_det_23 = det4_out2;
        multi_23_11_inst2_coeff_11 = coeff2;

        det_inter0_next = multi_23_11_inst0_out; // 2*2 intermediate value of det3 
        det_inter1_next = multi_23_11_inst1_out; // 2*2 intermediate value of det3 
        det_inter2_next = multi_23_11_inst2_out; // 2*2 intermediate value of det3 

        // stage 3
        add_sub_add_50_inst_a = det_inter0; 
        add_sub_add_50_inst_b = det_inter1;
        add_sub_add_50_inst_c = det_inter2;
        det_inter3_next = add_sub_add_50_inst_out; // 3*3 intermediate value of det4

        // stage 4
        multi_36_11_inst_det_36 = det_inter3;
        multi_36_11_inst_coeff_11 = det4_coeff_pipe2;
        det_multi_47_next = multi_36_11_inst_out; // add intermediate value of det4

        // stage 5
        det_multi_47_add_sub = (add_flag) ? det_multi_47 : -det_multi_47;
        out_data_buf_next = out_data_buf + det_multi_47_add_sub;

        if (cnt == 24) begin
            next_state = IDLE;
            out_valid = 1;
            out_data = out_data_buf;
            cnt_next = 0;
        end
       
    end
    endcase
end



//synopsys translate_off
task print_dec_task; begin
    for (integer i = 0; i < 4; i = i + 1) begin
        $display("%d %d %d %d", data_dec[i*4], data_dec[i*4+1], data_dec[i*4+2], data_dec[i*4+3]); 
    end
end
endtask

task print_out2_task; begin
    $display("out_data_buf[206:184] = %b", out_data_buf[206:184]);
    $display("out_data_buf[183:161] = %b", out_data_buf[183:161]);
    $display("out_data_buf[160:138] = %b", out_data_buf[160:138]);
    $display("out_data_buf[137:115] = %b", out_data_buf[137:115]);
    $display("out_data_buf[114:92] = %b", out_data_buf[114:92]);
    $display("out_data_buf[91:69] = %b", out_data_buf[91:69]);
    $display("out_data_buf[68:46] = %b", out_data_buf[68:46]);
    $display("out_data_buf[45:23] = %b", out_data_buf[45:23]);
    $display("out_data_buf[22:0] = %b", out_data_buf[22:0]);


    // $display("out_data_buf[206:184] = %d", out_data_buf[206-1:184]);
    // $display("out_data_buf[183:161] = %d", out_data_buf[183-1:161]);
    // $display("out_data_buf[160:138] = %d", out_data_buf[160-1:138]);
    // $display("out_data_buf[137:115] = %d", out_data_buf[137-1:115]);
    // $display("out_data_buf[114:92] = %d", out_data_buf[114-1:92]);
    // $display("out_data_buf[91:69] = %d", out_data_buf[91-1:69]);
    // $display("out_data_buf[68:46] = %d", out_data_buf[68-1:46]);
    // $display("out_data_buf[45:23] = %d", out_data_buf[45-1:23]);
    // $display("out_data_buf[22:0] = %d", out_data_buf[22-1:0]);
end
endtask

task print_out3_task; begin
    $display("out_data_buf[203:153] = %b", out_data_buf[203:153]);
    $display("out_data_buf[152:102] = %b", out_data_buf[152:102]);
    $display("out_data_buf[101:51] = %b", out_data_buf[101:51]);
    $display("out_data_buf[50:0] = %b", out_data_buf[50:0]);

    // $display("out_data_buf[203:153] = %d", out_data_buf[203:153]);
    // $display("out_data_buf[152:102] = %d", out_data_buf[152:102]);
    // $display("out_data_buf[101:51] = %d", out_data_buf[101:51]);
    // $display("out_data_buf[50:0] = %d", out_data_buf[50:0]);
end
endtask

task print_out4_task; begin
    $display("out_data_buf = %d", out_data_buf);
end
endtask
// synopsys translate_on
endmodule


module multi_23_11(
    det_23,
    coeff_11,
    multi_23_11_out
);
    input signed [22:0] det_23;
    input signed [10:0] coeff_11;
    output reg signed [33:0] multi_23_11_out;
    always @(*) begin
        multi_23_11_out = det_23 * coeff_11;
    end
endmodule

module det4(
    // Input signals
    a,
    b,
    c,
    d,
    // Output signals
    out
);
    input signed [10:0] a, b, c, d;
    output reg signed [22:0] out;
    always @(*) begin
        out = a * d - b * c;
    end
endmodule


module add_sub_add_50(
    a,b,c,out
);
    input signed [33:0] a, b, c;
    output reg signed [50:0] out;
    always @(*) begin
        out = a - b + c;
    end
endmodule


module multi_36_11(
    det_36,
    coeff_11,
    multi_36_11_out
);
    input signed [35:0] det_36;
    input signed [10:0] coeff_11;
    output reg signed [46:0] multi_36_11_out;
    always @(*) begin
        multi_36_11_out = det_36 * coeff_11;
    end
endmodule