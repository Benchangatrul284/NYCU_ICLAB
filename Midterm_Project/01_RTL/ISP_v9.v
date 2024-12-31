module ISP(
    // Input Signals
    input clk,
    input rst_n,
    input in_valid,
    input [3:0] in_pic_no,
    input       in_mode,
    input [1:0] in_ratio_mode,

    // Output Signals
    output reg out_valid,
    output reg [7:0] out_data,
    
    // DRAM Signals
    // axi write address channel
    // src master
    output reg [3:0]  awid_s_inf,
    output reg [31:0] awaddr_s_inf,
    output reg [2:0]  awsize_s_inf,
    output reg [1:0]  awburst_s_inf,
    output reg [7:0]  awlen_s_inf,
    output reg        awvalid_s_inf,
    // src slave
    input         awready_s_inf,
    // -----------------------------
  
    // axi write data channel 
    // src master
    output reg [127:0] wdata_s_inf,
    output reg         wlast_s_inf,
    output reg         wvalid_s_inf,
    // src slave
    input          wready_s_inf,
  
    // axi write response channel 
    // src slave
    input [3:0]    bid_s_inf,
    input [1:0]    bresp_s_inf,
    input          bvalid_s_inf,
    // src master 
    output reg         bready_s_inf,
    // -----------------------------
  
    // axi read address channel 
    // src master
    output reg [3:0]   arid_s_inf,
    output reg [31:0]  araddr_s_inf,
    output reg [7:0]   arlen_s_inf,
    output reg [2:0]   arsize_s_inf,
    output reg [1:0]   arburst_s_inf,
    output reg         arvalid_s_inf,
    // src slave
    input          arready_s_inf,
    // -----------------------------
  
    // axi read data channel 
    // slave
    input [3:0]    rid_s_inf,
    input [127:0]  rdata_s_inf,
    input [1:0]    rresp_s_inf,
    input          rlast_s_inf,
    input          rvalid_s_inf,
    // master
    output reg         rready_s_inf
    
);

reg out_valid_next;
reg [7:0] out_data_next;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_data <= 0;
        out_valid <= 0;
    end
    else begin
        out_data <= out_data_next;
        out_valid <= out_valid_next;
    end
end



parameter IDLE = 3'b000, BYPASS = 3'b001, WAIT = 3'b010, COMP = 3'b011;
parameter OUTPUT = 3'b110;
reg [2:0] current_state, next_state;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end
end

// input_buffer
reg [1:0] in_ratio_mode_reg, in_ratio_mode_comb;
reg [3:0] in_pic_no_reg, in_pic_no_comb;
reg in_mode_comb, in_mode_reg;
always @(posedge clk) begin
    in_ratio_mode_reg <= in_ratio_mode_comb;
    in_pic_no_reg <= in_pic_no_comb;
    in_mode_reg <= in_mode_comb;
end



// store the number of division of each picture of each channel
reg signed [4:0] num_of_div [0:15];
reg signed [4:0] num_of_div_next [0:15];
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i=0; i<16; i = i+1) begin
            num_of_div[i] <= 8;
        end
    end
    else begin
        num_of_div <= num_of_div_next;
    end
end

reg [9:0] cnt, cnt_next;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 0;
    end
    else begin
        cnt <= cnt_next;
    end
end

reg signed [4:0] num_of_div_buf;
reg signed [4:0] num_of_div_comb, num_of_div_comb_inter;

// store input data
reg [7:0] in_pixel [0:15];
reg [7:0] in_pixel_next [0:15];
always @(posedge clk) begin
    in_pixel <= in_pixel_next;
end

reg [19:0] sum;
reg [19:0] sum_next;
always @(posedge clk) begin
    sum <= sum_next;
end

reg [7:0] gray_pic [0:35];
reg [7:0] gray_pic_next [0:35];
always @(posedge clk) begin
    gray_sum <= gray_sum_next;
end

reg [8:0] diff_result [0:4];
reg [8:0] diff_result_next [0:4];
always @(posedge clk) begin
    diff_result <= diff_result_next;
end

reg [19:0] focus_sum_2, focus_sum_2_next;
reg [19:0] focus_sum_3,focus_sum_3_next;
reg [19:0] focus_sum_4, focus_sum_4_next;

always @(posedge clk) begin
    focus_sum_2 <= focus_sum_2_next;
    focus_sum_3 <= focus_sum_3_next;
    focus_sum_4 <= focus_sum_4_next;
end

reg [1:0] max_index_next, max_index;
always @(posedge clk) begin
    max_index <= max_index_next;
end

reg [1:0] AF_result [0:15];
reg [1:0] AF_result_next [0:15];
// 2'b11: not computed
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i=0; i<16; i = i+1) begin
            AF_result[i] <= 2'b11;
        end
    end
    else begin
        AF_result <= AF_result_next;
    end
end

reg [7:0] AE_result [0:15];
reg [7:0] AE_result_next [0:15];
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i=0; i<16; i = i+1) begin
            AE_result[i] <= 0;
        end
    end
    else begin
        AE_result <= AE_result_next;
    end
end

reg [19:0] add0_a, add1_a, add2_a, add3_a, add4_a, add5_a, add6_a, add7_a;
reg [19:0] add8_a, add9_a, add10_a, add11_a, add12_a, add13_a, add14_a, add15_a;
reg [19:0] add0_b, add1_b, add2_b, add3_b, add4_b, add5_b, add6_b, add7_b;
reg [19:0] add8_b, add9_b, add10_b, add11_b, add12_b, add13_b, add14_b, add15_b;
reg [19:0] add0_out, add1_out, add2_out, add3_out, add4_out, add5_out, add6_out, add7_out;
reg [19:0] add8_out, add9_out, add10_out, add11_out, add12_out, add13_out, add14_out, add15_out;

// 16*adder
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

reg [19:0] add0_out_reg, add1_out_reg, add2_out_reg, add3_out_reg, add4_out_reg, add5_out_reg, add6_out_reg, add7_out_reg;
always @(posedge clk) begin
    add0_out_reg <= add0_out;
    add1_out_reg <= add1_out;
    add2_out_reg <= add2_out;
    add3_out_reg <= add3_out;
    add4_out_reg <= add4_out;
    add5_out_reg <= add5_out;
    add6_out_reg <= add6_out;
    add7_out_reg <= add7_out;
end


reg [7:0] shift0_a, shift1_a, shift2_a, shift3_a, shift4_a, shift5_a, shift6_a, shift7_a;
reg [7:0] shift8_a, shift9_a, shift10_a, shift11_a, shift12_a, shift13_a, shift14_a, shift15_a;
reg [7:0] rshift0_out, rshift1_out, rshift2_out, rshift3_out, rshift4_out, rshift5_out, rshift6_out, rshift7_out;
reg [7:0] rshift8_out, rshift9_out, rshift10_out, rshift11_out, rshift12_out, rshift13_out, rshift14_out, rshift15_out;
reg [7:0] lshift0_out, lshift1_out, lshift2_out, lshift3_out, lshift4_out, lshift5_out, lshift6_out, lshift7_out;
reg [7:0] lshift8_out, lshift9_out, lshift10_out, lshift11_out, lshift12_out, lshift13_out, lshift14_out, lshift15_out;
reg [2:0] rshift_b, lshift_b;

always @(*) begin
    rshift0_out = shift0_a >> rshift_b;
    rshift1_out = shift1_a >> rshift_b;
    rshift2_out = shift2_a >> rshift_b;
    rshift3_out = shift3_a >> rshift_b;
    rshift4_out = shift4_a >> rshift_b;
    rshift5_out = shift5_a >> rshift_b;
    rshift6_out = shift6_a >> rshift_b;
    rshift7_out = shift7_a >> rshift_b;
    rshift8_out = shift8_a >> rshift_b;
    rshift9_out = shift9_a >> rshift_b;
    rshift10_out = shift10_a >> rshift_b;
    rshift11_out = shift11_a >> rshift_b;
    rshift12_out = shift12_a >> rshift_b;
    rshift13_out = shift13_a >> rshift_b;
    rshift14_out = shift14_a >> rshift_b;
    rshift15_out = shift15_a >> rshift_b;

    lshift0_out = shift0_a << lshift_b;
    lshift1_out = shift1_a << lshift_b;
    lshift2_out = shift2_a << lshift_b;
    lshift3_out = shift3_a << lshift_b;
    lshift4_out = shift4_a << lshift_b;
    lshift5_out = shift5_a << lshift_b;
    lshift6_out = shift6_a << lshift_b;
    lshift7_out = shift7_a << lshift_b;
    lshift8_out = shift8_a << lshift_b;
    lshift9_out = shift9_a << lshift_b;
    lshift10_out = shift10_a << lshift_b;
    lshift11_out = shift11_a << lshift_b;
    lshift12_out = shift12_a << lshift_b;
    lshift13_out = shift13_a << lshift_b;
    lshift14_out = shift14_a << lshift_b;
    lshift15_out = shift15_a << lshift_b;
end

// difference
reg [7:0] diff0_a, diff1_a, diff2_a, diff3_a, diff4_a;
reg [7:0] diff0_b, diff1_b, diff2_b, diff3_b, diff4_b;
reg [8:0] diff0_out, diff1_out, diff2_out, diff3_out, diff4_out;
reg [8:0] diff0_inter, diff1_inter, diff2_inter, diff3_inter, diff4_inter;

always @(*) begin
    diff0_inter = diff0_a - diff0_b;
    diff1_inter = diff1_a - diff1_b;
    diff2_inter = diff2_a - diff2_b;
    diff3_inter = diff3_a - diff3_b;
    diff4_inter = diff4_a - diff4_b;

    diff0_out = (diff0_inter[8] == 0)? diff0_inter : ~diff0_inter + 1;
    diff1_out = (diff1_inter[8] == 0)? diff1_inter : ~diff1_inter + 1;
    diff2_out = (diff2_inter[8] == 0)? diff2_inter : ~diff2_inter + 1;
    diff3_out = (diff3_inter[8] == 0)? diff3_inter : ~diff3_inter + 1;
    diff4_out = (diff4_inter[8] == 0)? diff4_inter : ~diff4_inter + 1;
end


always @(*) begin
    next_state = current_state;
    out_valid_next = 0;
    out_data_next = 0;
    cnt_next = cnt + 1;
    // read
    arid_s_inf = 4'b0; // host i
    arsize_s_inf = 3'b100; // burst size
    arburst_s_inf = 2'b01; // burst type
    araddr_s_inf = 0;
    arvalid_s_inf = 0;
    arlen_s_inf = 0;
    rready_s_inf = 0;

    // write
    awid_s_inf = 4'b0; // host id
    awaddr_s_inf = 0; // start address
    awsize_s_inf = 3'b100; // burst length (196 bits)
    awlen_s_inf = 0;
    awburst_s_inf = 2'b01; // burst type
    awvalid_s_inf = 0;

    wdata_s_inf = 0;
    wlast_s_inf = 0;
    wvalid_s_inf = 0;
    bready_s_inf = 0;

    num_of_div_buf = num_of_div[in_pic_no_reg];
    num_of_div_comb_inter = num_of_div_buf - 2 + in_ratio_mode_reg;
    // clamp
    num_of_div_comb = (num_of_div_comb_inter < 0)? 0 : num_of_div_comb_inter;
    num_of_div_comb = (num_of_div_comb_inter > 8)? 8 : num_of_div_comb_inter;

    case (current_state)
    IDLE: begin
        if (in_valid) begin
            next_state = BYPASS;
            cnt_next = 0;
        end
    end
    BYPASS: begin // determine if able to directly output result
        if (num_of_div_buf == 0 || 
           (in_mode_reg == 0 && AF_result[in_pic_no_reg] != 3) ||
           (in_mode_reg == 1 && in_ratio_mode_reg == 2 && AF_result[in_pic_no_reg] != 3)) begin
            next_state = OUTPUT;
        end
        else begin
            next_state = WAIT;
            araddr_s_inf = 32'h10000 + 3072*in_pic_no_reg; // start address
            arlen_s_inf = 191;
            arvalid_s_inf = 1;
        end
    end
    WAIT: begin
        // close first time handshake of reading
        araddr_s_inf = 0;
        arvalid_s_inf = 0;
        arlen_s_inf = 0;
        
        // prepare to write data
        case (cnt)
        0,1: begin
            awaddr_s_inf = 32'h10000 + 3072*(in_pic_no_reg);
            awlen_s_inf = 191;
            awvalid_s_inf = 1;
        end
        2,3,4: begin
            wvalid_s_inf = 1;
        end
        endcase
        
        in_ratio_mode_comb = (in_mode_reg == 0)? 2 : in_ratio_mode_reg;
        
        if (rvalid_s_inf) begin 
            next_state = COMP;
            cnt_next = 0;
        end
    end
    COMP: begin

    end
    OUTPUT: begin
        out_valid_next = 1;
        case (in_ratio_mode_reg)
        0: out_data_next = AF_result[in_pic_no_reg];
        1: out_data_next = AE_result[in_pic_no_reg];
        endcase
        next_state = IDLE;
    end
    endcase
end


endmodule
