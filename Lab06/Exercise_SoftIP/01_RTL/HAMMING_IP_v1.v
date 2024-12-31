//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2024/10
//		Version		: v1.0
//   	File Name   : HAMMING_IP.v
//   	Module Name : HAMMING_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module HAMMING_IP #(parameter IP_BIT = 8) (
    // Input signals
    IN_code,
    // Output signals
    OUT_code
);

// ===============================================================
// Input & Output
// ===============================================================
input [IP_BIT+4-1:0]  IN_code;

output reg [IP_BIT-1:0] OUT_code;

// ===============================================================
// Design
// ===============================================================
reg [0:IP_BIT+4] IN_code_reverse;

genvar idx;
generate
    for (idx = 0; idx < IP_BIT + 4 ; idx = idx + 1) begin : loop_idx
        reg position_temp0;
        reg position_temp1;
        reg position_temp2;
        reg position_temp3;
        if (idx == 0) begin // (0001)
            always @(*) begin
                $display("idx = %d", idx);
                $display("IN_code = %b", IN_code[IP_BIT+3-idx]);
                position_temp0 = 0;
                position_temp1 = 0;
                position_temp2 = 0;
                position_temp3 = 0;
                if (IN_code[IP_BIT+3-idx] == 1) begin
                    position_temp0 = 1;
                end
                $display("position_temp0 = %b", position_temp0);
                $display("position_temp1 = %b", position_temp1);
                $display("position_temp2 = %b", position_temp2);
                $display("position_temp3 = %b", position_temp3);
            end
        end
        else if (idx == 1) begin // (0010)
            always @(*) begin
                $display("idx = %d", idx);
                $display("IN_code = %b", IN_code[IP_BIT+3-idx]);
                position_temp0 = loop_idx[0].position_temp0;
                position_temp1 = loop_idx[0].position_temp1;
                position_temp2 = loop_idx[0].position_temp2;
                position_temp3 = loop_idx[0].position_temp3;
                if (IN_code[IP_BIT+3-idx] == 1) begin
                    position_temp1 = !loop_idx[0].position_temp1;
                end
                $display("position_temp0 = %b", position_temp0);
                $display("position_temp1 = %b", position_temp1);
                $display("position_temp2 = %b", position_temp2);
                $display("position_temp3 = %b", position_temp3);

            end
        end
        else if (idx == 2) begin // (0011)
            always @(*) begin
                $display("idx = %d", idx);
                $display("IN_code = %b", IN_code[IP_BIT+3-idx]);
                position_temp0 = loop_idx[1].position_temp0;
                position_temp1 = loop_idx[1].position_temp1;
                position_temp2 = loop_idx[1].position_temp2;
                position_temp3 = loop_idx[1].position_temp3;
                if (IN_code[IP_BIT+3-idx] == 1) begin
                    position_temp0 = !loop_idx[1].position_temp0;
                    position_temp1 = !loop_idx[1].position_temp1;
                end
                $display("position_temp0 = %b", position_temp0);
                $display("position_temp1 = %b", position_temp1);
                $display("position_temp2 = %b", position_temp2);
                $display("position_temp3 = %b", position_temp3);
            end
        end
        else if (idx == 3) begin // (0100)
            always @(*) begin
                $display("idx = %d", idx);
                $display("IN_code = %b", IN_code[IP_BIT+3-idx]);
                position_temp0 = loop_idx[2].position_temp0;
                position_temp1 = loop_idx[2].position_temp1;
                position_temp2 = loop_idx[2].position_temp2;
                position_temp3 = loop_idx[2].position_temp3;
                if (IN_code[IP_BIT+3-idx] == 1) begin
                    position_temp2 = !loop_idx[2].position_temp2;
                end
                $display("position_temp0 = %b", position_temp0);
                $display("position_temp1 = %b", position_temp1);
                $display("position_temp2 = %b", position_temp2);
                $display("position_temp3 = %b", position_temp3);
            end
        end
        else if (idx == 4) begin // (0101)
            always @(*) begin
                $display("idx = %d", idx);
                $display("IN_code = %b", IN_code[IP_BIT+3-idx]);
                position_temp0 = loop_idx[3].position_temp0;
                position_temp1 = loop_idx[3].position_temp1;
                position_temp2 = loop_idx[3].position_temp2;
                position_temp3 = loop_idx[3].position_temp3;
                if (IN_code[IP_BIT+3-idx] == 1) begin
                    position_temp0 = !loop_idx[3].position_temp0;
                    position_temp2 = !loop_idx[3].position_temp2;
                end
                $display("position_temp0 = %b", position_temp0);
                $display("position_temp1 = %b", position_temp1);
                $display("position_temp2 = %b", position_temp2);
                $display("position_temp3 = %b", position_temp3);
            end
        end
        else if (idx == 5) begin // (0110)
            always @(*) begin
                $display("idx = %d", idx);
                $display("IN_code = %b", IN_code[IP_BIT+3-idx]);
                position_temp0 = loop_idx[4].position_temp0;
                position_temp1 = loop_idx[4].position_temp1;
                position_temp2 = loop_idx[4].position_temp2;
                position_temp3 = loop_idx[4].position_temp3;
                if (IN_code[IP_BIT+3-idx] == 1) begin
                    position_temp1 = !loop_idx[4].position_temp1;
                    position_temp2 = !loop_idx[4].position_temp2;
                end
                $display("position_temp0 = %b", position_temp0);
                $display("position_temp1 = %b", position_temp1);
                $display("position_temp2 = %b", position_temp2);
                $display("position_temp3 = %b", position_temp3);
            end
        end
        else if (idx == 6) begin // (0111)
            always @(*) begin
                $display("idx = %d", idx);
                $display("IN_code = %b", IN_code[IP_BIT+3-idx]);
                position_temp0 = loop_idx[5].position_temp0;
                position_temp1 = loop_idx[5].position_temp1;
                position_temp2 = loop_idx[5].position_temp2;
                position_temp3 = loop_idx[5].position_temp3;
                if (IN_code[IP_BIT+3-idx] == 1) begin
                    position_temp0 = !loop_idx[5].position_temp0;
                    position_temp1 = !loop_idx[5].position_temp1;
                    position_temp2 = !loop_idx[5].position_temp2;
                end
                $display("position_temp0 = %b", position_temp0);
                $display("position_temp1 = %b", position_temp1);
                $display("position_temp2 = %b", position_temp2);
                $display("position_temp3 = %b", position_temp3);
            end
        end
        else if (idx == 7) begin // (1000)
            always @(*) begin
                $display("idx = %d", idx);
                $display("IN_code = %b", IN_code[IP_BIT+3-idx]);
                position_temp0 = loop_idx[6].position_temp0;
                position_temp1 = loop_idx[6].position_temp1;
                position_temp2 = loop_idx[6].position_temp2;
                position_temp3 = loop_idx[6].position_temp3;
                if (IN_code[IP_BIT+3-idx] == 1) begin
                    position_temp3 = !loop_idx[6].position_temp3;
                end
                $display("position_temp0 = %b", position_temp0);
                $display("position_temp1 = %b", position_temp1);
                $display("position_temp2 = %b", position_temp2);
                $display("position_temp3 = %b", position_temp3);
            end
        end
        else if (idx == 8) begin // (1001)
            always @(*) begin
                $display("idx = %d", idx);
                $display("IN_code = %b", IN_code[IP_BIT+3-idx]);
                position_temp0 = loop_idx[7].position_temp0;
                position_temp1 = loop_idx[7].position_temp1;
                position_temp2 = loop_idx[7].position_temp2;
                position_temp3 = loop_idx[7].position_temp3;
                if (IN_code[IP_BIT+3-idx] == 1) begin
                    position_temp0 = !loop_idx[7].position_temp0;
                    position_temp3 = !loop_idx[7].position_temp3;
                end
                $display("position_temp0 = %b", position_temp0);
                $display("position_temp1 = %b", position_temp1);
                $display("position_temp2 = %b", position_temp2);
                $display("position_temp3 = %b", position_temp3);
                if (IP_BIT == 5)
            end
        end
        else if (idx == 9) begin // (1010)
            always @(*) begin
                $display("idx = %d", idx);
                $display("IN_code = %b", IN_code[IP_BIT+3-idx]);
                position_temp0 = loop_idx[8].position_temp0;
                position_temp1 = loop_idx[8].position_temp1;
                position_temp2 = loop_idx[8].position_temp2;
                position_temp3 = loop_idx[8].position_temp3;
                if (IN_code[IP_BIT+3-idx] == 1) begin
                    position_temp1 = !loop_idx[8].position_temp1;
                    position_temp3 = !loop_idx[8].position_temp3;
                end
                $display("position_temp0 = %b", position_temp0);
                $display("position_temp1 = %b", position_temp1);
                $display("position_temp2 = %b", position_temp2);
                $display("position_temp3 = %b", position_temp3);
            end
        end
        else if (idx == 10) begin // (1011)
            always @(*) begin
                $display("idx = %d", idx);
                $display("IN_code = %b", IN_code[IP_BIT+3-idx]);
                position_temp0 = loop_idx[9].position_temp0;
                position_temp1 = loop_idx[9].position_temp1;
                position_temp2 = loop_idx[9].position_temp2;
                position_temp3 = loop_idx[9].position_temp3;
                if (IN_code[IP_BIT+3-idx] == 1) begin
                    position_temp0 = !loop_idx[9].position_temp0;
                    position_temp1 = !loop_idx[9].position_temp1;
                    position_temp3 = !loop_idx[9].position_temp3;
                end
                $display("position_temp0 = %b", position_temp0);
                $display("position_temp1 = %b", position_temp1);
                $display("position_temp2 = %b", position_temp2);
                $display("position_temp3 = %b", position_temp3);
            end
        end
    end
endgenerate



endmodule