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



parameter IDLE = 3'b000, BYPASS = 3'b001, WAIT = 3'b010, AE = 3'b011;
parameter AF = 3'b100, AF_COMP = 3'b101, OUTPUT = 3'b110;
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
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_ratio_mode_reg <= 0; 
        in_pic_no_reg <= 0;
        in_mode_reg <= 0;
    end
    else begin
        in_ratio_mode_reg <= in_ratio_mode_comb;
        in_pic_no_reg <= in_pic_no_comb;
        in_mode_reg <= in_mode_comb;
    end
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

reg [7:0] gray_sum [0:35];
reg [7:0] gray_sum_next [0:35];
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i=0; i<36; i = i+1) begin
            gray_sum[i] <= 0;
        end
    end
    else begin
        gray_sum <= gray_sum_next;
    end
end

reg [29:0] diff_result [0:4];
reg [29:0] diff_result_next [0:4];
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i=0; i<5; i = i+1) begin
            diff_result[i] <= 0;
        end
    end
    else begin
        diff_result <= diff_result_next;
    end
end

reg [19:0] focus_sum_2, focus_sum_2_next;
reg [19:0] focus_sum_3,focus_sum_3_next;
reg [19:0] focus_sum_4, focus_sum_4_next;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        focus_sum_2 <= 0;
        focus_sum_3 <= 0;
        focus_sum_4 <= 0;
    end
    else begin
        focus_sum_2 <= focus_sum_2_next;
        focus_sum_3 <= focus_sum_3_next;
        focus_sum_4 <= focus_sum_4_next;
    end
end

reg [1:0] max_index_next, max_index;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        max_index <= 0;
    end
    else begin
        max_index <= max_index_next;
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
reg [19:0] diff0_a, diff1_a, diff2_a, diff3_a, diff4_a;
reg [19:0] diff0_b, diff1_b, diff2_b, diff3_b, diff4_b;
reg [19:0] diff0_out, diff1_out, diff2_out, diff3_out, diff4_out;
reg [19:0] diff0_inter, diff1_inter, diff2_inter, diff3_inter, diff4_inter;

always @(*) begin
    diff0_inter = diff0_a - diff0_b;
    diff1_inter = diff1_a - diff1_b;
    diff2_inter = diff2_a - diff2_b;
    diff3_inter = diff3_a - diff3_b;
    diff4_inter = diff4_a - diff4_b;

    diff0_out = (diff0_inter[19] == 0)? diff0_inter : ~diff0_inter + 1;
    diff1_out = (diff1_inter[19] == 0)? diff1_inter : ~diff1_inter + 1;
    diff2_out = (diff2_inter[19] == 0)? diff2_inter : ~diff2_inter + 1;
    diff3_out = (diff3_inter[19] == 0)? diff3_inter : ~diff3_inter + 1;
    diff4_out = (diff4_inter[19] == 0)? diff4_inter : ~diff4_inter + 1;
end

always @(*) begin
    in_mode_comb = in_mode_reg;
    case (current_state)
    IDLE: begin
        if (in_valid)
            in_mode_comb = in_mode;
    end
    endcase
end

always @(*) begin
    in_ratio_mode_comb = in_ratio_mode_reg;
    case (current_state)
    IDLE: begin
        if (in_valid) begin
            in_ratio_mode_comb = (in_mode)? in_ratio_mode : 2;
        end
    end
    endcase
end

always @(*) begin
    in_pic_no_comb = in_pic_no_reg;
    case (current_state)
    IDLE: begin
        if (in_valid) begin
            in_pic_no_comb = in_pic_no;
        end
    end
    endcase
end

// compute new num_of_div
always @(*) begin
    num_of_div_buf = num_of_div[in_pic_no_reg];
    num_of_div_comb_inter = num_of_div_buf - 2 + in_ratio_mode_reg;
    // clamp
    num_of_div_comb = (num_of_div_comb_inter < 0)? 0 : num_of_div_comb_inter;
    num_of_div_comb = (num_of_div_comb_inter > 8)? 8 : num_of_div_comb_inter;
end

// determine if update num_of_div
always @(*) begin
    num_of_div_next = num_of_div;
    case (current_state)
    BYPASS: begin
        if (num_of_div_buf != 0) begin
            num_of_div_next[in_pic_no_reg] = num_of_div_comb;
        end
    end
    endcase
end

// sum for exposure
always @(*) begin
    sum_next = 0;
    case (current_state)
    AE: begin
        sum_next = add15_out;
    end
    endcase
end

// gray_sum
always @(*) begin
    gray_sum_next = gray_sum;
    case (current_state)
    IDLE: begin
        for (integer i=0; i<36; i = i+1) begin
            gray_sum_next[i] = 0;
        end
    end
    AF: begin
        if ((cnt >= 1 && cnt <= 12) || ((cnt >= 1+64 && cnt <= 12+64)) || ((cnt >= 1+128 && cnt <= 12+128))) begin
            // left shift three
            gray_sum_next[0:32] = gray_sum[3:35];
            gray_sum_next[33] = add0_out;
            gray_sum_next[34] = add1_out;
            gray_sum_next[35] = add2_out;
        end
    end
    AF_COMP: begin
        if (cnt <= 5) begin
            gray_sum_next[0:29] = gray_sum[6:35];
            gray_sum_next[30:35] = gray_sum[0:5];
        end
        else begin
            gray_sum_next[0:34] = gray_sum[1:35];
            gray_sum_next[35] = gray_sum[0];
        end
        
    end
    endcase
end

// in_pixel (store DRAM input value)
// no need to modify since AF do right shift too
always @(*) begin
    in_pixel_next = in_pixel;
    case (in_ratio_mode_reg)
    0,1,2: begin
        in_pixel_next[15] = rshift0_out;
        in_pixel_next[14] = rshift1_out;
        in_pixel_next[13] = rshift2_out;
        in_pixel_next[12] = rshift3_out;
        in_pixel_next[11] = rshift4_out;
        in_pixel_next[10] = rshift5_out;
        in_pixel_next[9] = rshift6_out;
        in_pixel_next[8] = rshift7_out;
        in_pixel_next[7] = rshift8_out;
        in_pixel_next[6] = rshift9_out;
        in_pixel_next[5] = rshift10_out;
        in_pixel_next[4] = rshift11_out;
        in_pixel_next[3] = rshift12_out;
        in_pixel_next[2] = rshift13_out;
        in_pixel_next[1] = rshift14_out;
        in_pixel_next[0] = rshift15_out;
    end
    3: begin
        in_pixel_next[15] = (rdata_s_inf[127] == 1) ? 255: lshift0_out;
        in_pixel_next[14] = (rdata_s_inf[119] == 1) ? 255: lshift1_out;
        in_pixel_next[13] = (rdata_s_inf[111] == 1) ? 255: lshift2_out;
        in_pixel_next[12] = (rdata_s_inf[103] == 1) ? 255: lshift3_out;
        in_pixel_next[11] = (rdata_s_inf[95] == 1) ? 255: lshift4_out;
        in_pixel_next[10] = (rdata_s_inf[87] == 1) ? 255: lshift5_out;
        in_pixel_next[9] = (rdata_s_inf[79] == 1) ? 255: lshift6_out;
        in_pixel_next[8] = (rdata_s_inf[71] == 1) ? 255: lshift7_out;
        in_pixel_next[7] = (rdata_s_inf[63] == 1) ? 255: lshift8_out;
        in_pixel_next[6] = (rdata_s_inf[55] == 1) ? 255: lshift9_out;
        in_pixel_next[5] = (rdata_s_inf[47] == 1) ? 255: lshift10_out;
        in_pixel_next[4] = (rdata_s_inf[39] == 1) ? 255: lshift11_out;
        in_pixel_next[3] = (rdata_s_inf[31] == 1) ? 255: lshift12_out;
        in_pixel_next[2] = (rdata_s_inf[23] == 1) ? 255: lshift13_out;
        in_pixel_next[1] = (rdata_s_inf[15] == 1) ? 255: lshift14_out;
        in_pixel_next[0] = (rdata_s_inf[7] == 1) ? 255: lshift15_out;
    end
    endcase
end

// shift input
always @(*) begin
    shift0_a = rdata_s_inf[127:120];
    shift1_a = rdata_s_inf[119:112];
    shift2_a = rdata_s_inf[111:104];   
    shift3_a = rdata_s_inf[103:96];
    shift4_a = rdata_s_inf[95:88];
    shift5_a = rdata_s_inf[87:80];
    shift6_a = rdata_s_inf[79:72];
    shift7_a = rdata_s_inf[71:64];
    shift8_a = rdata_s_inf[63:56];
    shift9_a = rdata_s_inf[55:48];
    shift10_a = rdata_s_inf[47:40];
    shift11_a = rdata_s_inf[39:32];
    shift12_a = rdata_s_inf[31:24];
    shift13_a = rdata_s_inf[23:16];
    shift14_a = rdata_s_inf[15:8];
    shift15_a = rdata_s_inf[7:0];
    
    rshift_b = (2-in_ratio_mode_reg); // need modification
    lshift_b = 1;

    case (current_state)
    AF: begin
        if ((cnt >= 0 && cnt <= 11) || (cnt >= 128 && cnt <= 11+128)) begin
            rshift_b = 2;
        end
        else if (cnt >= 64 && cnt <= 11+64)
            rshift_b = 1;
    end
    endcase
end

// add input
always @(*) begin
    // add
    add0_a = 0; add1_a = 0; add2_a = 0; add3_a = 0; add4_a = 0; add5_a = 0; add6_a = 0; add7_a = 0;
    add8_a = 0; add9_a = 0; add10_a = 0; add11_a = 0; add12_a = 0; add13_a = 0; add14_a = 0; add15_a = 0;
    add0_b = 0; add1_b = 0; add2_b = 0; add3_b = 0; add4_b = 0; add5_b = 0; add6_b = 0; add7_b = 0;
    add8_b = 0; add9_b = 0; add10_b = 0; add11_b = 0; add12_b = 0; add13_b = 0; add14_b = 0; add15_b = 0;

    case (current_state)
    AE: begin
        // sum
        if (cnt <= 64 || (cnt >= 129 && cnt <= 192)) begin // R
            add0_a = in_pixel[0] >> 2;
            add0_b = in_pixel[1] >> 2;
            add1_a = in_pixel[2] >> 2;
            add1_b = in_pixel[3] >> 2;
            add2_a = in_pixel[4] >> 2;
            add2_b = in_pixel[5] >> 2;
            add3_a = in_pixel[6] >> 2;
            add3_b = in_pixel[7] >> 2;
            add4_a = in_pixel[8] >> 2;
            add4_b = in_pixel[9] >> 2;
            add5_a = in_pixel[10] >> 2;
            add5_b = in_pixel[11] >> 2;
            add6_a = in_pixel[12] >> 2;
            add6_b = in_pixel[13] >> 2;
            add7_a = in_pixel[14] >> 2;
            add7_b = in_pixel[15] >> 2;
        end
        else begin
            add0_a = in_pixel[0] >> 1;
            add0_b = in_pixel[1] >> 1;
            add1_a = in_pixel[2] >> 1;
            add1_b = in_pixel[3] >> 1;
            add2_a = in_pixel[4] >> 1;
            add2_b = in_pixel[5] >> 1;
            add3_a = in_pixel[6] >> 1;
            add3_b = in_pixel[7] >> 1;
            add4_a = in_pixel[8] >> 1;
            add4_b = in_pixel[9] >> 1;
            add5_a = in_pixel[10] >> 1;
            add5_b = in_pixel[11] >> 1;
            add6_a = in_pixel[12] >> 1;
            add6_b = in_pixel[13] >> 1;
            add7_a = in_pixel[14] >> 1;
            add7_b = in_pixel[15] >> 1;
        end
        add8_a = add0_out;
        add8_b = add1_out;
        add9_a = add2_out;
        add9_b = add3_out;
        add10_a = add4_out;
        add10_b = add5_out;
        add11_a = add6_out;
        add11_b = add7_out;
        add12_a = add8_out;
        add12_b = add9_out;
        add13_a = add10_out;
        add13_b = add11_out;
        add14_a = add12_out;
        add14_b = add13_out;
        add15_a = add14_out;
        add15_b = sum;
    end
    AF: begin
        add0_b = gray_sum[0];
        add1_b = gray_sum[1];
        add2_b = gray_sum[2];
        if (cnt[0] == 1) begin
            add0_a = in_pixel[13];
            add1_a = in_pixel[14];
            add2_a = in_pixel[15];
        end
        else begin
            add0_a = in_pixel[0];
            add1_a = in_pixel[1];
            add2_a = in_pixel[2];
        end
        
    end
    AF_COMP: begin
        add0_a = diff_result[1];
        add0_b = diff_result[2];
        add1_a = add0_out;
        add1_b = diff_result[3];
        add2_a = diff_result[0];
        add2_b = diff_result[4];
        add3_a = add1_out;
        add3_b = add2_out;
        ///////////////////////
        
    end
    endcase
end

// diff input
always @(*) begin
    diff0_a = 0; diff1_a = 0; diff2_a = 0; diff3_a = 0; diff4_a = 0;
    diff0_b = 0; diff1_b = 0; diff2_b = 0; diff3_b = 0; diff4_b = 0;
    case (current_state)
    AF_COMP: begin
        if (cnt <= 5) begin
            diff0_a = gray_sum[0];
            diff0_b = gray_sum[1];

            diff1_a = gray_sum[1];
            diff1_b = gray_sum[2];

            diff2_a = gray_sum[2];
            diff2_b = gray_sum[3];

            diff3_a = gray_sum[3];
            diff3_b = gray_sum[4];

            diff4_a = gray_sum[4];
            diff4_b = gray_sum[5];
        end
        else begin
            diff0_a = gray_sum[0];
            diff0_b = gray_sum[6];

            diff1_a = gray_sum[6];
            diff1_b = gray_sum[12];

            diff2_a = gray_sum[12];
            diff2_b = gray_sum[18];

            diff3_a = gray_sum[18];
            diff3_b = gray_sum[24];

            diff4_a = gray_sum[24];
            diff4_b = gray_sum[30];
        end
    end
    endcase
end

// diff_result (may need to modify)
always @(*) begin
    diff_result_next = diff_result;
    case (current_state)
    IDLE: begin
        for (integer i=0; i<5; i = i+1) begin
            diff_result_next[i] = 0;
        end
    end
    AF_COMP: begin
        diff_result_next[0] = diff0_out;
        diff_result_next[1] = diff1_out;
        diff_result_next[2] = diff2_out;
        diff_result_next[3] = diff3_out;
        diff_result_next[4] = diff4_out;
    end
    endcase
end

// focus_sum_2, focus_sum_3, focus_sum_4
always @(*) begin
    focus_sum_2_next = focus_sum_2;
    focus_sum_3_next = focus_sum_3;
    focus_sum_4_next = focus_sum_4;
    case (current_state)
    IDLE: begin
        focus_sum_2_next = 0;
        focus_sum_3_next = 0;
        focus_sum_4_next = 0;
    end
    AF_COMP: begin
        focus_sum_4_next = add3_out + focus_sum_4;
        case (cnt)
        2,8: begin
            focus_sum_3_next = add1_out + focus_sum_3;
        end
        3,9: begin
            focus_sum_3_next = add1_out + focus_sum_3;
            focus_sum_2_next = diff_result[2] + focus_sum_2;
        end
        4,10: begin
            focus_sum_3_next = add1_out + focus_sum_3;
            focus_sum_2_next = diff_result[2] + focus_sum_2;
        end
        5,11: begin
            focus_sum_3_next = add1_out + focus_sum_3;
        end
        endcase
    end
    endcase
end

// max_index_next
always @(*) begin
    max_index_next = max_index;
    case (current_state)
    OUTPUT: begin
        case (cnt)
        0: begin
            max_index_next = (focus_sum_3 >> 4 > focus_sum_2 >> 2);
        end
        1: begin
            if (max_index == 1)
                max_index_next = (focus_sum_4 > (focus_sum_3 >> 4) * 36 + 35)? 2 : max_index;
            else
                max_index_next = (focus_sum_4 > (focus_sum_2 >> 2) * 36 + 35)? 2 : max_index;
        end
        endcase
    end
    endcase
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

    case (current_state)
    IDLE: begin
        if (in_valid) begin
            next_state = BYPASS;
            cnt_next = 0;
        end
    end

    BYPASS: begin
        if (num_of_div_buf == 0) begin
            cnt_next = 0;
            out_data_next = 0;
            out_valid_next = 1;
            next_state = IDLE;
        end
        else begin
            // read data (address, and valid signal)
            if (in_mode_reg) begin
                araddr_s_inf = 32'h10000 + 3072*in_pic_no_reg; // start address
                arlen_s_inf = 191;
            end
            else begin
                araddr_s_inf = 32'h10000 + 3072*in_pic_no_reg + 26*16; // start address
                arlen_s_inf = 139;
            end
            arvalid_s_inf = 1;
            next_state = WAIT;
            cnt_next = 0;
        end
    end
    WAIT: begin
        // close first time handshake of reading
        araddr_s_inf = 0;
        arvalid_s_inf = 0;
        arlen_s_inf = 0;
        
        // prepare to write data
        if (in_mode_reg) begin
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
        end
        
        // at this cycle, the data is not yet read since rready_s_inf = 0;
        // if (rvalid_s_inf && cnt >= 5) begin 
        //     next_state = (in_mode_reg)? AE : AF;
        //     cnt_next = 0;
        // end
        if (rvalid_s_inf) begin 
            next_state = (in_mode_reg)? AE : AF;
            cnt_next = 0;
        end
    end
    AF: begin
        // keep reading
        rready_s_inf = 1;
        if (cnt == 140) begin
            next_state = AF_COMP;
            cnt_next = 0;
            rready_s_inf = 0;
        end
    end
    AF_COMP: begin
        if (cnt == 12) begin
            next_state = OUTPUT;
            cnt_next = 0;
        end
    end
    OUTPUT: begin
        case (cnt)
        2: begin
            out_data_next = max_index;
            out_valid_next = 1;
            next_state = IDLE;
        end
        endcase
    end
    AE: begin
        // keep reading
        rready_s_inf = 1;

        // write data
        if (cnt >= 1) begin
            wdata_s_inf[7:0] = in_pixel[0];
            wdata_s_inf[15:8] = in_pixel[1];
            wdata_s_inf[23:16] = in_pixel[2];
            wdata_s_inf[31:24] = in_pixel[3];
            wdata_s_inf[39:32] = in_pixel[4];
            wdata_s_inf[47:40] = in_pixel[5];
            wdata_s_inf[55:48] = in_pixel[6];
            wdata_s_inf[63:56] = in_pixel[7];
            wdata_s_inf[71:64] = in_pixel[8];
            wdata_s_inf[79:72] = in_pixel[9];
            wdata_s_inf[87:80] = in_pixel[10];
            wdata_s_inf[95:88] = in_pixel[11];
            wdata_s_inf[103:96] = in_pixel[12];
            wdata_s_inf[111:104] = in_pixel[13];
            wdata_s_inf[119:112] = in_pixel[14];
            wdata_s_inf[127:120] = in_pixel[15];
            wvalid_s_inf = 1;
            wlast_s_inf = 0;
            bready_s_inf = 1;
        end

        case (cnt)
        192: begin
            wlast_s_inf = 1; // last write
            rready_s_inf = 0; // stop reading
        end
        193: begin 
            out_data_next = sum >> 10;
            out_valid_next = 1;
            wvalid_s_inf = 0; // stop writing
            rready_s_inf = 0; // stop reading
        end
        194: begin
            bready_s_inf = 1; // ready for write response
            next_state = IDLE;
            rready_s_inf = 0; // stop reading
            wvalid_s_inf = 0; // stop writing
            cnt_next = 0;
        end
        endcase
    end
    endcase
end


endmodule
