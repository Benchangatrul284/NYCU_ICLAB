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
reg [4:0] temp_idx;

genvar idx;
generate
    for (idx = 0; idx < IP_BIT + 4 ; idx = idx + 1) begin : loop_idx
        always @(*) begin
            temp_idx = idx + 1;
            result_temp0[idx] = IN_code[IP_BIT+3-idx] & temp_idx[0];
            result_temp1[idx] = IN_code[IP_BIT+3-idx] & temp_idx[1];
            result_temp2[idx] = IN_code[IP_BIT+3-idx] & temp_idx[2];
            result_temp3[idx] = IN_code[IP_BIT+3-idx] & temp_idx[3];
        end
    end
endgenerate

always @(*) begin
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