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



parameter IDLE = 3'b000, CORR = 3'b001, EXP = 3'b010, EXP_WAIT = 3'b011;
parameter EXP_COMP = 3'b100, OUTPUT = 3'b101;
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
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_ratio_mode_reg <= 0; 
        in_pic_no_reg <= 0;
    end
    else begin
        in_ratio_mode_reg <= in_ratio_mode_comb;
        in_pic_no_reg <= in_pic_no_comb;
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

// reg wvalid_s_inf_next;
// reg bready_s_inf_next;
// always @(posedge clk) begin
//     wvalid_s_inf <= wvalid_s_inf_next;
//     bready_s_inf <= bready_s_inf_next;
// end

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




always @(*) begin
    next_state = current_state;
    out_valid_next = 0;
    out_data_next = 0;
    in_ratio_mode_comb = in_ratio_mode_reg;
    num_of_div_next = num_of_div;
    in_pic_no_comb = in_pic_no_reg;
    cnt_next = cnt + 1;

    num_of_div_buf = num_of_div[in_pic_no_reg];
    num_of_div_comb_inter = num_of_div_buf - 2 + in_ratio_mode_reg;

    // clamp
    num_of_div_comb = (num_of_div_comb_inter < 0)? 0 : num_of_div_comb_inter;
    num_of_div_comb = (num_of_div_comb_inter > 8)? 8 : num_of_div_comb_inter;

    // sum
    sum_next = 0;

    // add
    add0_a = 0; add1_a = 0; add2_a = 0; add3_a = 0; add4_a = 0; add5_a = 0; add6_a = 0; add7_a = 0;
    add8_a = 0; add9_a = 0; add10_a = 0; add11_a = 0; add12_a = 0; add13_a = 0; add14_a = 0; add15_a = 0;
    add0_b = 0; add1_b = 0; add2_b = 0; add3_b = 0; add4_b = 0; add5_b = 0; add6_b = 0; add7_b = 0;
    add8_b = 0; add9_b = 0; add10_b = 0; add11_b = 0; add12_b = 0; add13_b = 0; add14_b = 0; add15_b = 0;


    // shift
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
    
    rshift_b = (2-in_ratio_mode_reg);
    lshift_b = 1;
    
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

    // read
    arid_s_inf = 4'b0; // host id
    arsize_s_inf = 3'b100; // burst size
    arburst_s_inf = 2'b01; // burst type
    araddr_s_inf = 0;
    arvalid_s_inf = 0;
    arlen_s_inf = 0;
    rready_s_inf = 0;

    // write
    awid_s_inf = 4'b1; // host id
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
            next_state = (in_mode == 0)? CORR : EXP;
            in_ratio_mode_comb = in_ratio_mode;
            in_pic_no_comb = in_pic_no;
            cnt_next = 0;
            sum_next = 0;
        end
    end
    CORR: begin
    end
    EXP: begin
        if (num_of_div_buf == 0) begin
            num_of_div_next = num_of_div;
            cnt_next = 0;
            out_data_next = 0;
            out_valid_next = 1;
            next_state = IDLE;
        end
        else begin
            num_of_div_next[in_pic_no_reg] = num_of_div_comb;
            // read data (address, and valid signal)
            araddr_s_inf = 32'h10000 + 3072*in_pic_no_reg; // start address
            arlen_s_inf = 191;
            arvalid_s_inf = 1;
            next_state = EXP_WAIT;
            cnt_next = 0;
        end
    end
    EXP_WAIT: begin
        araddr_s_inf = 0;
        arvalid_s_inf = 0;
        arlen_s_inf = 0;

        rready_s_inf = 1;
        

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

        if (rvalid_s_inf) begin
            next_state = EXP_COMP;
            cnt_next = 1;
        end
    end
    EXP_COMP: begin
        
        cnt_next = cnt + 1;
        // read
        rready_s_inf = 1;
        
        awaddr_s_inf = 0;
        awvalid_s_inf = 0;

        // write
        awaddr_s_inf = 0; 
        awlen_s_inf = 0;
        awvalid_s_inf = 0;

        // write data
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
        sum_next = add15_out;

        if (cnt == 192) begin
            wlast_s_inf = 1;
        end

        // write data
        if (cnt == 193) begin
            out_data_next = sum >> 10;
            out_valid_next = 1;
            next_state = OUTPUT;
            sum_next = 0;
            cnt_next = 0;
            wvalid_s_inf = 0;
        end
    end
    OUTPUT: begin
        bready_s_inf = 1;
        next_state = IDLE;
    end
    endcase
end


endmodule
