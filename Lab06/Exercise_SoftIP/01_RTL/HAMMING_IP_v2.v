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
reg [3:0] number;
reg [0:IP_BIT+3] result_temp0;
reg [0:IP_BIT+3] result_temp1;
reg [0:IP_BIT+3] result_temp2;
reg [0:IP_BIT+3] result_temp3;

reg [IP_BIT+4-1:0] IN_code_fixed;

genvar idx;
generate
    for (idx = 0; idx < IP_BIT + 4 ; idx = idx + 1) begin : loop_idx
        if (idx == 0) begin // (0001)
            always @(*) begin
                // $display("idx: %d, IN_code[IP_BIT+3-idx]: %b", idx, IN_code[IP_BIT+3-idx]);
                result_temp0[idx] = 0;
                result_temp1[idx] = 0;
                result_temp2[idx] = 0;
                result_temp3[idx] = 0;
                if (IN_code[IP_BIT+3-idx] == 1) begin
                    result_temp0[idx] = 1;
                end
            end
        end
        if (idx == 1) begin // (0010)
            always @(*) begin
                result_temp0[idx] = 0;
                result_temp1[idx] = 0;
                result_temp2[idx] = 0;
                result_temp3[idx] = 0;
                if (IN_code[IP_BIT+3-idx] == 1) begin
                    result_temp1[idx] = 1;
                end
            end
        end
        if (idx == 2) begin // (0011)
            always @(*) begin
                result_temp0[idx] = 0;
                result_temp1[idx] = 0;
                result_temp2[idx] = 0;
                result_temp3[idx] = 0;
                if (IN_code[IP_BIT+3-idx] == 1) begin
                    result_temp0[idx] = 1;
                    result_temp1[idx] = 1;
                end
            end
        end
        if (idx == 3) begin // (0100)
            always @(*) begin
                result_temp0[idx] = 0;
                result_temp1[idx] = 0;
                result_temp2[idx] = 0;
                result_temp3[idx] = 0;
                if (IN_code[IP_BIT+3-idx] == 1) begin
                    result_temp2[idx] = 1;
                end
            end
        end
        if (idx == 4) begin // (0101)
            always @(*) begin
                result_temp0[idx] = 0;
                result_temp1[idx] = 0;
                result_temp2[idx] = 0;
                result_temp3[idx] = 0;
                if (IN_code[IP_BIT+3-idx] == 1) begin
                    result_temp0[idx] = 1;
                    result_temp2[idx] = 1;
                end
            end
        end
        if (idx == 5) begin // (0110)
            always @(*) begin
                result_temp0[idx] = 0;
                result_temp1[idx] = 0;
                result_temp2[idx] = 0;
                result_temp3[idx] = 0;
                if (IN_code[IP_BIT+3-idx] == 1) begin
                    result_temp1[idx] = 1;
                    result_temp2[idx] = 1;
                end
            end
        end
        if (idx == 6) begin // (0111)
            always @(*) begin
                result_temp0[idx] = 0;
                result_temp1[idx] = 0;
                result_temp2[idx] = 0;
                result_temp3[idx] = 0;
                if (IN_code[IP_BIT+3-idx] == 1) begin
                    result_temp0[idx] = 1;
                    result_temp1[idx] = 1;
                    result_temp2[idx] = 1;
                end
            end
        end
        if (idx == 7) begin // (1000)
            always @(*) begin
                result_temp0[idx] = 0;
                result_temp1[idx] = 0;
                result_temp2[idx] = 0;
                result_temp3[idx] = 0;
                if (IN_code[IP_BIT+3-idx] == 1) begin
                    result_temp3[idx] = 1;
                end
            end
        end
        if (idx == 8) begin // (1001)
            always @(*) begin
                result_temp0[idx] = 0;
                result_temp1[idx] = 0;
                result_temp2[idx] = 0;
                result_temp3[idx] = 0;
                if (IN_code[IP_BIT+3-idx] == 1) begin
                    result_temp0[idx] = 1;
                    result_temp3[idx] = 1;
                end
            end
        end
        if (idx == 9) begin // (1010)
            always @(*) begin
                result_temp0[idx] = 0;
                result_temp1[idx] = 0;
                result_temp2[idx] = 0;
                result_temp3[idx] = 0;
                if (IN_code[IP_BIT+3-idx] == 1) begin
                    result_temp1[idx] = 1;
                    result_temp3[idx] = 1;
                end
            end
        end
        if (idx == 10) begin // (1011)
            always @(*) begin
                result_temp0[idx] = 0;
                result_temp1[idx] = 0;
                result_temp2[idx] = 0;
                result_temp3[idx] = 0;
                if (IN_code[IP_BIT+3-idx] == 1) begin
                    result_temp0[idx] = 1;
                    result_temp1[idx] = 1;
                    result_temp3[idx] = 1;
                end
            end
        end
        if (idx == 11) begin // (1100)
            always @(*) begin
                result_temp0[idx] = 0;
                result_temp1[idx] = 0;
                result_temp2[idx] = 0;
                result_temp3[idx] = 0;
                if (IN_code[IP_BIT+3-idx] == 1) begin
                    result_temp2[idx] = 1;
                    result_temp3[idx] = 1;
                end
            end
        end
        if (idx == 12) begin // (1101)
            always @(*) begin
                result_temp0[idx] = 0;
                result_temp1[idx] = 0;
                result_temp2[idx] = 0;
                result_temp3[idx] = 0;
                if (IN_code[IP_BIT+3-idx] == 1) begin
                    result_temp0[idx] = 1;
                    result_temp2[idx] = 1;
                    result_temp3[idx] = 1;
                end
            end
        end
        if (idx == 13) begin // (1110)
            always @(*) begin
                result_temp0[idx] = 0;
                result_temp1[idx] = 0;
                result_temp2[idx] = 0;
                result_temp3[idx] = 0;
                if (IN_code[IP_BIT+3-idx] == 1) begin
                    result_temp1[idx] = 1;
                    result_temp2[idx] = 1;
                    result_temp3[idx] = 1;
                end
            end
        end
        if (idx == 14) begin // (1111)
            always @(*) begin
                result_temp0[idx] = 0;
                result_temp1[idx] = 0;
                result_temp2[idx] = 0;
                result_temp3[idx] = 0;
                if (IN_code[IP_BIT+3-idx] == 1) begin
                    result_temp0[idx] = 1;
                    result_temp1[idx] = 1;
                    result_temp2[idx] = 1;
                    result_temp3[idx] = 1;
                end
            end
        end
    end
endgenerate

always @(*) begin
    $display("IN_code: %b", IN_code);
    $display("Result_temp0: %b", result_temp0);
    $display("Result_temp1: %b", result_temp1);
    $display("Result_temp2: %b", result_temp2);
    $display("Result_temp3: %b", result_temp3);
    number = {^result_temp3, ^result_temp2, ^result_temp1, ^result_temp0};
    if (number == 0) begin
        IN_code_fixed = IN_code;  
    end
    else begin
        IN_code_fixed = IN_code;
        IN_code_fixed[IP_BIT+4-number] = ~IN_code_fixed[IP_BIT+4-number];
    end
    $display("Number: %d", number); 
    $display("IN_code_fixed: %b", IN_code_fixed);

    // remove the parity bits
    OUT_code = {IN_code_fixed[IP_BIT+1], IN_code_fixed[IP_BIT-1:IP_BIT-3], IN_code_fixed[IP_BIT-5:0]};


    
end

endmodule