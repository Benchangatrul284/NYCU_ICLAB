module ISP(
    // Input Signals
    input clk,
    input rst_n,
    input in_valid,
    input [3:0] in_pic_no,
    input [1:0] in_mode,
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


parameter IDLE = 2'b00, BYPASS = 2'b01, WAIT = 2'b10, COMP = 2'b11;
reg [1:0] current_state, next_state;
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
reg [1:0] in_mode_comb, in_mode_reg;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
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

reg [7:0] cnt, cnt_next;
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

// store input data (shifted)
reg [7:0] in_pixel [0:15];
reg [7:0] in_pixel_next [0:15];
always @(posedge clk) begin
    in_pixel <= in_pixel_next;
end


reg [17:0] sum;
reg [17:0] sum_next;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum <= 0;
    end
    else begin
        sum <= sum_next;
    end
end

reg [7:0] gray_pic [0:35];
reg [7:0] gray_pic_next [0:35];
always @(posedge clk) begin
    gray_pic <= gray_pic_next;
end

reg [8:0] diff_result [0:4];
reg [8:0] diff_result_next [0:4];
always @(posedge clk) begin
    diff_result <= diff_result_next;
end

reg [9:0] focus_sum_2, focus_sum_2_next;
reg [11:0] focus_sum_3,focus_sum_3_next;
reg [13:0] focus_sum_4, focus_sum_4_next;

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
        max_index <= 2'b11;
    end
    else begin
        max_index <= max_index_next;
    end
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
always @(posedge clk) begin
    AE_result <= AE_result_next;
end

reg [7:0] MinMax_result [0:15];
reg [7:0] MinMax_result_next [0:15];
always @(posedge clk) begin
    MinMax_result <= MinMax_result_next;
end


function is_smaller;
    input [7:0] a, b;
    reg [8:0] diff;
    begin
        diff = a - b;
        is_smaller = diff[8];
    end
endfunction



reg [7:0] add0_a, add1_a, add2_a, add3_a, add4_a, add5_a, add6_a, add7_a;
reg [7:0] add0_b, add1_b, add2_b, add3_b, add4_b, add5_b, add6_b, add7_b;
reg [8:0] add8_a, add9_a, add10_a, add11_a;
reg [8:0] add8_b, add9_b, add10_b, add11_b;
reg [9:0] add12_a, add13_a, add14_a;
reg [9:0] add12_b, add13_b, add14_b;
reg [17:0] add15_a, add15_b;

reg [8:0] add0_out, add1_out, add2_out, add3_out, add4_out, add5_out, add6_out, add7_out;
reg [9:0] add8_out, add9_out, add10_out, add11_out;
reg [10:0] add12_out, add13_out, add14_out;
reg [18:0] add15_out;

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

reg [8:0] add0_out_reg, add1_out_reg, add2_out_reg, add3_out_reg, add4_out_reg, add5_out_reg, add6_out_reg, add7_out_reg;
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

reg [9:0] add8_out_reg, add9_out_reg, add10_out_reg, add11_out_reg;

always @(posedge clk) begin
    add8_out_reg <= add8_out;
    add9_out_reg <= add9_out;
    add10_out_reg <= add10_out;
    add11_out_reg <= add11_out;
end


reg [10:0] add12_out_reg, add13_out_reg;
always @(posedge clk) begin
    add12_out_reg <= add12_out;
    add13_out_reg <= add13_out;
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

reg [7:0] shift0_a_gp1, shift1_a_gp1, shift2_a_gp1, shift3_a_gp1, shift4_a_gp1, shift5_a_gp1, shift6_a_gp1, shift7_a_gp1;
reg [7:0] shift8_a_gp1, shift9_a_gp1, shift10_a_gp1, shift11_a_gp1, shift12_a_gp1, shift13_a_gp1, shift14_a_gp1, shift15_a_gp1;
reg [1:0] shift_num;
reg [7:0] shift0_out_gp1, shift1_out_gp1, shift2_out_gp1, shift3_out_gp1, shift4_out_gp1, shift5_out_gp1, shift6_out_gp1, shift7_out_gp1;
reg [7:0] shift8_out_gp1, shift9_out_gp1, shift10_out_gp1, shift11_out_gp1, shift12_out_gp1, shift13_out_gp1, shift14_out_gp1, shift15_out_gp1;

// add shifted pixel to compute grayscale and average
always @(*) begin
    shift0_out_gp1 = shift0_a_gp1 >> shift_num;
    shift1_out_gp1 = shift1_a_gp1 >> shift_num;
    shift2_out_gp1 = shift2_a_gp1 >> shift_num;
    shift3_out_gp1 = shift3_a_gp1 >> shift_num;
    shift4_out_gp1 = shift4_a_gp1 >> shift_num;
    shift5_out_gp1 = shift5_a_gp1 >> shift_num;
    shift6_out_gp1 = shift6_a_gp1 >> shift_num;
    shift7_out_gp1 = shift7_a_gp1 >> shift_num;
    shift8_out_gp1 = shift8_a_gp1 >> shift_num;
    shift9_out_gp1 = shift9_a_gp1 >> shift_num;
    shift10_out_gp1 = shift10_a_gp1 >> shift_num;
    shift11_out_gp1 = shift11_a_gp1 >> shift_num;
    shift12_out_gp1 = shift12_a_gp1 >> shift_num;
    shift13_out_gp1 = shift13_a_gp1 >> shift_num;
    shift14_out_gp1 = shift14_a_gp1 >> shift_num;
    shift15_out_gp1 = shift15_a_gp1 >> shift_num;
end

// difference
reg [7:0] diff0_a, diff1_a, diff2_a, diff3_a, diff4_a;
reg [7:0] diff0_b, diff1_b, diff2_b, diff3_b, diff4_b;
reg [8:0] diff0_out, diff1_out, diff2_out, diff3_out, diff4_out;
reg [8:0] diff0_inter, diff1_inter, diff2_inter, diff3_inter, diff4_inter;
reg [8:0] diff0_inter_next, diff1_inter_next, diff2_inter_next, diff3_inter_next, diff4_inter_next;

always @(posedge clk) begin
    diff0_inter <= diff0_inter_next;
    diff1_inter <= diff1_inter_next;
    diff2_inter <= diff2_inter_next;
    diff3_inter <= diff3_inter_next;
    diff4_inter <= diff4_inter_next;
end

always @(*) begin
    diff0_inter_next = diff0_a - diff0_b;
    diff1_inter_next = diff1_a - diff1_b;
    diff2_inter_next = diff2_a - diff2_b;
    diff3_inter_next = diff3_a - diff3_b;
    diff4_inter_next = diff4_a - diff4_b;

    diff0_out = (diff0_inter[8] == 0)? diff0_inter : ~diff0_inter + 1;
    diff1_out = (diff1_inter[8] == 0)? diff1_inter : ~diff1_inter + 1;
    diff2_out = (diff2_inter[8] == 0)? diff2_inter : ~diff2_inter + 1;
    diff3_out = (diff3_inter[8] == 0)? diff3_inter : ~diff3_inter + 1;
    diff4_out = (diff4_inter[8] == 0)? diff4_inter : ~diff4_inter + 1;
end


// divider
reg [9:0] div_in, div_out;
reg [9:0] div_out_buf;

always @(*) begin
    case (div_in)
    0,1,2: div_out = 0;
    3,4,5: div_out = 1;
    6,7,8: div_out = 2;
    9,10,11: div_out = 3;
    12,13,14: div_out = 4;
    15,16,17: div_out = 5;
    18,19,20: div_out = 6;
    21,22,23: div_out = 7;
    24,25,26: div_out = 8;
    27,28,29: div_out = 9;
    30,31,32: div_out = 10;
    33,34,35: div_out = 11;
    36,37,38: div_out = 12;
    39,40,41: div_out = 13;
    42,43,44: div_out = 14;
    45,46,47: div_out = 15;
    48,49,50: div_out = 16;
    51,52,53: div_out = 17;
    54,55,56: div_out = 18;
    57,58,59: div_out = 19;
    60,61,62: div_out = 20;
    63,64,65: div_out = 21;
    66,67,68: div_out = 22;
    69,70,71: div_out = 23;
    72,73,74: div_out = 24;
    75,76,77: div_out = 25;
    78,79,80: div_out = 26;
    81,82,83: div_out = 27;
    84,85,86: div_out = 28;
    87,88,89: div_out = 29;
    90,91,92: div_out = 30;
    93,94,95: div_out = 31;
    96,97,98: div_out = 32;
    99,100,101: div_out = 33;
    102,103,104: div_out = 34;
    105,106,107: div_out = 35;
    108,109,110: div_out = 36;
    111,112,113: div_out = 37;
    114,115,116: div_out = 38;
    117,118,119: div_out = 39;
    120,121,122: div_out = 40;
    123,124,125: div_out = 41;
    126,127,128: div_out = 42;
    129,130,131: div_out = 43;
    132,133,134: div_out = 44;
    135,136,137: div_out = 45;
    138,139,140: div_out = 46;
    141,142,143: div_out = 47;
    144,145,146: div_out = 48;
    147,148,149: div_out = 49;
    150,151,152: div_out = 50;
    153,154,155: div_out = 51;
    156,157,158: div_out = 52;
    159,160,161: div_out = 53;
    162,163,164: div_out = 54;
    165,166,167: div_out = 55;
    168,169,170: div_out = 56;
    171,172,173: div_out = 57;
    174,175,176: div_out = 58;
    177,178,179: div_out = 59;
    180,181,182: div_out = 60;
    183,184,185: div_out = 61;
    186,187,188: div_out = 62;
    189,190,191: div_out = 63;
    192,193,194: div_out = 64;
    195,196,197: div_out = 65;
    198,199,200: div_out = 66;
    201,202,203: div_out = 67;
    204,205,206: div_out = 68;
    207,208,209: div_out = 69;
    210,211,212: div_out = 70;
    213,214,215: div_out = 71;
    216,217,218: div_out = 72;
    219,220,221: div_out = 73;
    222,223,224: div_out = 74;
    225,226,227: div_out = 75;
    228,229,230: div_out = 76;
    231,232,233: div_out = 77;
    234,235,236: div_out = 78;
    237,238,239: div_out = 79;
    240,241,242: div_out = 80;
    243,244,245: div_out = 81;
    246,247,248: div_out = 82;
    249,250,251: div_out = 83;
    252,253,254: div_out = 84;
    255,256,257: div_out = 85;
    258,259,260: div_out = 86;
    261,262,263: div_out = 87;
    264,265,266: div_out = 88;
    267,268,269: div_out = 89;
    270,271,272: div_out = 90;
    273,274,275: div_out = 91;
    276,277,278: div_out = 92;
    279,280,281: div_out = 93;
    282,283,284: div_out = 94;
    285,286,287: div_out = 95;
    288,289,290: div_out = 96;
    291,292,293: div_out = 97;
    294,295,296: div_out = 98;
    297,298,299: div_out = 99;
    300,301,302: div_out = 100;
    303,304,305: div_out = 101;
    306,307,308: div_out = 102;
    309,310,311: div_out = 103;
    312,313,314: div_out = 104;
    315,316,317: div_out = 105;
    318,319,320: div_out = 106;
    321,322,323: div_out = 107;
    324,325,326: div_out = 108;
    327,328,329: div_out = 109;
    330,331,332: div_out = 110;
    333,334,335: div_out = 111;
    336,337,338: div_out = 112;
    339,340,341: div_out = 113;
    342,343,344: div_out = 114;
    345,346,347: div_out = 115;
    348,349,350: div_out = 116;
    351,352,353: div_out = 117;
    354,355,356: div_out = 118;
    357,358,359: div_out = 119;
    360,361,362: div_out = 120;
    363,364,365: div_out = 121;
    366,367,368: div_out = 122;
    369,370,371: div_out = 123;
    372,373,374: div_out = 124;
    375,376,377: div_out = 125;
    378,379,380: div_out = 126;
    381,382,383: div_out = 127;
    384,385,386: div_out = 128;
    387,388,389: div_out = 129;
    390,391,392: div_out = 130;
    393,394,395: div_out = 131;
    396,397,398: div_out = 132;
    399,400,401: div_out = 133;
    402,403,404: div_out = 134;
    405,406,407: div_out = 135;
    408,409,410: div_out = 136;
    411,412,413: div_out = 137;
    414,415,416: div_out = 138;
    417,418,419: div_out = 139;
    420,421,422: div_out = 140;
    423,424,425: div_out = 141;
    426,427,428: div_out = 142;
    429,430,431: div_out = 143;
    432,433,434: div_out = 144;
    435,436,437: div_out = 145;
    438,439,440: div_out = 146;
    441,442,443: div_out = 147;
    444,445,446: div_out = 148;
    447,448,449: div_out = 149;
    450,451,452: div_out = 150;
    453,454,455: div_out = 151;
    456,457,458: div_out = 152;
    459,460,461: div_out = 153;
    462,463,464: div_out = 154;
    465,466,467: div_out = 155;
    468,469,470: div_out = 156;
    471,472,473: div_out = 157;
    474,475,476: div_out = 158;
    477,478,479: div_out = 159;
    480,481,482: div_out = 160;
    483,484,485: div_out = 161;
    486,487,488: div_out = 162;
    489,490,491: div_out = 163;
    492,493,494: div_out = 164;
    495,496,497: div_out = 165;
    498,499,500: div_out = 166;
    501,502,503: div_out = 167;
    504,505,506: div_out = 168;
    507,508,509: div_out = 169;
    510,511,512: div_out = 170;
    513,514,515: div_out = 171;
    516,517,518: div_out = 172;
    519,520,521: div_out = 173;
    522,523,524: div_out = 174;
    525,526,527: div_out = 175;
    528,529,530: div_out = 176;
    531,532,533: div_out = 177;
    534,535,536: div_out = 178;
    537,538,539: div_out = 179;
    540,541,542: div_out = 180;
    543,544,545: div_out = 181;
    546,547,548: div_out = 182;
    549,550,551: div_out = 183;
    552,553,554: div_out = 184;
    555,556,557: div_out = 185;
    558,559,560: div_out = 186;
    561,562,563: div_out = 187;
    564,565,566: div_out = 188;
    567,568,569: div_out = 189;
    570,571,572: div_out = 190;
    573,574,575: div_out = 191;
    576,577,578: div_out = 192;
    579,580,581: div_out = 193;
    582,583,584: div_out = 194;
    585,586,587: div_out = 195;
    588,589,590: div_out = 196;
    591,592,593: div_out = 197;
    594,595,596: div_out = 198;
    597,598,599: div_out = 199;
    600,601,602: div_out = 200;
    603,604,605: div_out = 201;
    606,607,608: div_out = 202;
    609,610,611: div_out = 203;
    612,613,614: div_out = 204;
    615,616,617: div_out = 205;
    618,619,620: div_out = 206;
    621,622,623: div_out = 207;
    624,625,626: div_out = 208;
    627,628,629: div_out = 209;
    630,631,632: div_out = 210;
    633,634,635: div_out = 211;
    636,637,638: div_out = 212;
    639,640,641: div_out = 213;
    642,643,644: div_out = 214;
    645,646,647: div_out = 215;
    648,649,650: div_out = 216;
    651,652,653: div_out = 217;
    654,655,656: div_out = 218;
    657,658,659: div_out = 219;
    660,661,662: div_out = 220;
    663,664,665: div_out = 221;
    666,667,668: div_out = 222;
    669,670,671: div_out = 223;
    672,673,674: div_out = 224;
    675,676,677: div_out = 225;
    678,679,680: div_out = 226;
    681,682,683: div_out = 227;
    684,685,686: div_out = 228;
    687,688,689: div_out = 229;
    690,691,692: div_out = 230;
    693,694,695: div_out = 231;
    696,697,698: div_out = 232;
    699,700,701: div_out = 233;
    702,703,704: div_out = 234;
    705,706,707: div_out = 235;
    708,709,710: div_out = 236;
    711,712,713: div_out = 237;
    714,715,716: div_out = 238;
    717,718,719: div_out = 239;
    720,721,722: div_out = 240;
    723,724,725: div_out = 241;
    726,727,728: div_out = 242;
    729,730,731: div_out = 243;
    732,733,734: div_out = 244;
    735,736,737: div_out = 245;
    738,739,740: div_out = 246;
    741,742,743: div_out = 247;
    744,745,746: div_out = 248;
    747,748,749: div_out = 249;
    750,751,752: div_out = 250;
    753,754,755: div_out = 251;
    756,757,758: div_out = 252;
    759,760,761: div_out = 253;
    762,763,764: div_out = 254;
    765: div_out = 255;
    default: div_out = 8'bx;
    endcase
end
always @(posedge clk) begin
    div_out_buf <= div_out;
end

always @(*) begin
    case (in_pic_no_reg)
    0: num_of_div_buf = num_of_div[0];
    1: num_of_div_buf = num_of_div[1];
    2: num_of_div_buf = num_of_div[2];
    3: num_of_div_buf = num_of_div[3];
    4: num_of_div_buf = num_of_div[4];
    5: num_of_div_buf = num_of_div[5];
    6: num_of_div_buf = num_of_div[6];
    7: num_of_div_buf = num_of_div[7];
    8: num_of_div_buf = num_of_div[8];
    9: num_of_div_buf = num_of_div[9];
    10: num_of_div_buf = num_of_div[10];
    11: num_of_div_buf = num_of_div[11];
    12: num_of_div_buf = num_of_div[12];
    13: num_of_div_buf = num_of_div[13];
    14: num_of_div_buf = num_of_div[14];
    15: num_of_div_buf = num_of_div[15];
    endcase
end


reg signed [4:0] num_of_div_comb_temp;
always @(*) begin
    num_of_div_comb_inter = num_of_div_buf - 2 + in_ratio_mode_reg;
    // clamp
    num_of_div_comb_temp = (num_of_div_comb_inter <= 0)? 0 : num_of_div_comb_inter;
    num_of_div_comb = (num_of_div_comb_temp >= 8)? 8 : num_of_div_comb_temp ;
end

// in_ratio_mode_comb will be 2 if mode is AF
always @(*) begin
    in_ratio_mode_comb = in_ratio_mode_reg;
    case (current_state)
    IDLE: begin
        if (in_valid) begin
            in_ratio_mode_comb = (in_mode == 1)? in_ratio_mode : 2;
        end
    end
    endcase
end

always @(*) begin
    in_pic_no_comb = in_pic_no_reg;
    in_mode_comb = in_mode_reg;
    case (current_state)
    IDLE: begin
        if (in_valid) begin
            in_pic_no_comb = in_pic_no;
            in_mode_comb = in_mode;
        end
    end
    endcase
end

// shift input (shift input from DRAM)
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
end

always @(*) begin
    shift_num = 1;
    shift0_a_gp1 = in_pixel[0];
    shift1_a_gp1 = in_pixel[1];
    shift2_a_gp1 = in_pixel[2];
    shift3_a_gp1 = in_pixel[3];
    shift4_a_gp1 = in_pixel[4];
    shift5_a_gp1 = in_pixel[5];
    shift6_a_gp1 = in_pixel[6];
    shift7_a_gp1 = in_pixel[7];
    shift8_a_gp1 = in_pixel[8];
    shift9_a_gp1 = in_pixel[9];
    shift10_a_gp1 = in_pixel[10];
    shift11_a_gp1 = in_pixel[11];
    shift12_a_gp1 = in_pixel[12];
    shift13_a_gp1 = in_pixel[13];
    shift14_a_gp1 = in_pixel[14];
    shift15_a_gp1 = in_pixel[15];

    if (cnt <= 64 || (cnt >= 129 && cnt <= 192)) begin // R
        shift_num = 2;
    end
    else begin
        shift_num = 1;
    end
end

// rdata buffer for AF
reg [7:0] add_pixel0, add_pixel1, add_pixel2;
reg [7:0] add_pixel0_next, add_pixel1_next, add_pixel2_next;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        add_pixel0 <= 0;
        add_pixel1 <= 0;
        add_pixel2 <= 0;
    end 
    else begin
        add_pixel0 <= add_pixel0_next;
        add_pixel1 <= add_pixel1_next;
        add_pixel2 <= add_pixel2_next;
    end
end

always @(*) begin
    add_pixel0_next = 0;
    add_pixel1_next = 0;
    add_pixel2_next = 0;
    case (current_state)
        COMP: begin
            if (cnt[0] == 1) begin
                add_pixel0_next = shift13_out_gp1; // 13
                add_pixel1_next = shift14_out_gp1; // 14
                add_pixel2_next = shift15_out_gp1; // 15 
            end
            else begin
                add_pixel0_next = shift0_out_gp1; // 0
                add_pixel1_next = shift1_out_gp1; // 1
                add_pixel2_next = shift2_out_gp1; // 2
            end
        end
    endcase
end

// diff input
always @(*) begin
    diff0_a = 0; diff1_a = 0; diff2_a = 0; diff3_a = 0; diff4_a = 0;
    diff0_b = 0; diff1_b = 0; diff2_b = 0; diff3_b = 0; diff4_b = 0;
    case (current_state)
    COMP: begin
        if (cnt <= 173 && cnt >= 168) begin
            diff0_a = gray_pic[0];
            diff0_b = gray_pic[1];

            diff1_a = gray_pic[1];
            diff1_b = gray_pic[2];

            diff2_a = gray_pic[2];
            diff2_b = gray_pic[3];

            diff3_a = gray_pic[3];
            diff3_b = gray_pic[4];

            diff4_a = gray_pic[4];
            diff4_b = gray_pic[5];
        end
        else if (cnt <= 179 && cnt >= 174)begin
            diff0_a = gray_pic[0];
            diff0_b = gray_pic[6];

            diff1_a = gray_pic[6];
            diff1_b = gray_pic[12];

            diff2_a = gray_pic[12];
            diff2_b = gray_pic[18];

            diff3_a = gray_pic[18];
            diff3_b = gray_pic[24];

            diff4_a = gray_pic[24];
            diff4_b = gray_pic[30];
        end
    end
    endcase
end

// diff_result (may need to modify)
always @(*) begin
    diff_result_next[0] = diff0_out;
    diff_result_next[1] = diff1_out;
    diff_result_next[2] = diff2_out;
    diff_result_next[3] = diff3_out;
    diff_result_next[4] = diff4_out;
end

// diff adder
reg [8:0] diff_add2_next, diff_add2;
reg [9:0] diff_add12_next, diff_add12, diff_add04_next, diff_add04;
reg [10:0] diff_add123_next, diff_add123;
reg [11:0] diff_add01234_next, diff_add01234;

always @(*) begin
    diff_add12_next = diff_result[1] + diff_result[2];
    diff_add123_next = diff_add12_next + diff_result[3];
    diff_add04_next = diff_result[0] + diff_result[4];
    diff_add2_next = diff_result[2];
    diff_add01234_next = diff_add123_next + diff_add04_next;
end

always @(posedge clk) begin
    diff_add12 <= diff_add12_next;
    diff_add123 <= diff_add123_next;
    diff_add04 <= diff_add04_next;
    diff_add2 <= diff_add2_next;
    diff_add01234 <= diff_add01234_next;
end

always @(*) begin
    gray_pic_next = gray_pic;
    case (current_state)
    IDLE: begin
        for (integer i=0; i<36; i = i+1) begin
            gray_pic_next[i] = 0;
        end
    end
    COMP: begin
        if ((cnt >= 28 && cnt <= 39) || ((cnt >= 92 && cnt <= 103)) || ((cnt >= 156 && cnt <= 167))) begin
            // left shift three
            gray_pic_next[0:32] = gray_pic[3:35];
            gray_pic_next[33] = gray_pic[0] + add_pixel0;
            gray_pic_next[34] = gray_pic[1] + add_pixel1;
            gray_pic_next[35] = gray_pic[2] + add_pixel2;
        end
        else if (cnt >= 168 && cnt <= 173) begin
            gray_pic_next[0:29] = gray_pic[6:35];
            gray_pic_next[30:35] = gray_pic[0:5];
        end
        else if (cnt >=174 && cnt <= 179) begin
            gray_pic_next[0:34] = gray_pic[1:35];
            gray_pic_next[35] = gray_pic[0];
        end
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
    COMP: begin
        if (cnt >= 171) begin
            focus_sum_4_next = diff_add01234 + focus_sum_4;
        end
        case (cnt)
        172,178: begin
            focus_sum_3_next = diff_add123 + focus_sum_3;
        end
        173,179: begin
            focus_sum_3_next = diff_add123 + focus_sum_3;
            focus_sum_2_next = diff_add2 + focus_sum_2;
        end
        174,180: begin
            focus_sum_3_next = diff_add123 + focus_sum_3;
            focus_sum_2_next = diff_add2 + focus_sum_2;
        end
        175,181: begin
            focus_sum_3_next = diff_add123 + focus_sum_3;
        end
        endcase
    end
    endcase
end

// max_index_next
always @(*) begin
    max_index_next = max_index;
    case (cnt)
    182: begin
        max_index_next = (focus_sum_3 >> 4 > focus_sum_2 >> 2);
    end
    183: begin
        if (max_index == 1)
            max_index_next = (focus_sum_4 > (focus_sum_3 >> 4) * 36 + 35)? 2 : max_index;
        else
            max_index_next = (focus_sum_4 > (focus_sum_2 >> 2) * 36 + 35)? 2 : max_index;
    end
    endcase
end



// min max
reg [7:0] min_max_pipe0 [0:15];
reg [7:0] min_pipe1 [0:3];
reg [7:0] max_pipe1 [0:3];
reg [7:0] min_pipe2 [0:1];
reg [7:0] max_pipe2 [0:1];
reg [7:0] min_pipe3, max_pipe3;

// min_max_pipe0
always @(posedge clk) begin
    if (is_smaller(in_pixel[0],in_pixel[1])) begin
        min_max_pipe0[0] <= in_pixel[0];
        min_max_pipe0[1] <= in_pixel[1];
    end
    else begin
        min_max_pipe0[0] <= in_pixel[1];
        min_max_pipe0[1] <= in_pixel[0];
    end
    if (is_smaller(in_pixel[2],in_pixel[3])) begin
        min_max_pipe0[2] <= in_pixel[2];
        min_max_pipe0[3] <= in_pixel[3];
    end
    else begin
        min_max_pipe0[2] <= in_pixel[3];
        min_max_pipe0[3] <= in_pixel[2];
    end
    if (is_smaller(in_pixel[4],in_pixel[5])) begin
        min_max_pipe0[4] <= in_pixel[4];
        min_max_pipe0[5] <= in_pixel[5];
    end
    else begin
        min_max_pipe0[4] <= in_pixel[5];
        min_max_pipe0[5] <= in_pixel[4];
    end
    if (is_smaller(in_pixel[6],in_pixel[7])) begin
        min_max_pipe0[6] <= in_pixel[6];
        min_max_pipe0[7] <= in_pixel[7];
    end
    else begin
        min_max_pipe0[6] <= in_pixel[7];
        min_max_pipe0[7] <= in_pixel[6];
    end
    if (is_smaller(in_pixel[8],in_pixel[9])) begin
        min_max_pipe0[8] <= in_pixel[8];
        min_max_pipe0[9] <= in_pixel[9];
    end
    else begin
        min_max_pipe0[8] <= in_pixel[9];
        min_max_pipe0[9] <= in_pixel[8];
    end
    if (is_smaller(in_pixel[10],in_pixel[11])) begin
        min_max_pipe0[10] <= in_pixel[10];
        min_max_pipe0[11] <= in_pixel[11];
    end
    else begin
        min_max_pipe0[10] <= in_pixel[11];
        min_max_pipe0[11] <= in_pixel[10];
    end
    if (is_smaller(in_pixel[12],in_pixel[13])) begin
        min_max_pipe0[12] <= in_pixel[12];
        min_max_pipe0[13] <= in_pixel[13];
    end
    else begin
        min_max_pipe0[12] <= in_pixel[13];
        min_max_pipe0[13] <= in_pixel[12];
    end
    if (is_smaller(in_pixel[14],in_pixel[15])) begin
        min_max_pipe0[14] <= in_pixel[14];
        min_max_pipe0[15] <= in_pixel[15];
    end
    else begin
        min_max_pipe0[14] <= in_pixel[15];
        min_max_pipe0[15] <= in_pixel[14];
    end
end

// min_pipe1, max_pipe1
always @(posedge clk) begin
    min_pipe1[0] <= (is_smaller(min_max_pipe0[0], min_max_pipe0[2]))? min_max_pipe0[0] : min_max_pipe0[2];
    min_pipe1[1] <= (is_smaller(min_max_pipe0[4], min_max_pipe0[6]))? min_max_pipe0[4] : min_max_pipe0[6];
    min_pipe1[2] <= (is_smaller(min_max_pipe0[8], min_max_pipe0[10]))? min_max_pipe0[8] : min_max_pipe0[10];
    min_pipe1[3] <= (is_smaller(min_max_pipe0[12], min_max_pipe0[14]))? min_max_pipe0[12] : min_max_pipe0[14];

    max_pipe1[0] <= (min_max_pipe0[1] > min_max_pipe0[3])? min_max_pipe0[1] : min_max_pipe0[3];
    max_pipe1[1] <= (min_max_pipe0[5] > min_max_pipe0[7])? min_max_pipe0[5] : min_max_pipe0[7];
    max_pipe1[2] <= (min_max_pipe0[9] > min_max_pipe0[11])? min_max_pipe0[9] : min_max_pipe0[11];
    max_pipe1[3] <= (min_max_pipe0[13] > min_max_pipe0[15])? min_max_pipe0[13] : min_max_pipe0[15];
end

// min_pipe2, max_pipe2
always @(posedge clk) begin
    min_pipe2[0] <= (min_pipe1[0] < min_pipe1[1])? min_pipe1[0] : min_pipe1[1];
    min_pipe2[1] <= (min_pipe1[2] < min_pipe1[3])? min_pipe1[2] : min_pipe1[3];

    max_pipe2[0] <= (max_pipe1[0] > max_pipe1[1])? max_pipe1[0] : max_pipe1[1];
    max_pipe2[1] <= (max_pipe1[2] > max_pipe1[3])? max_pipe1[2] : max_pipe1[3];
end

// min_pipe3, max_pipe3
always @(posedge clk) begin
    min_pipe3 <= (min_pipe2[0] < min_pipe2[1])? min_pipe2[0] : min_pipe2[1];
    max_pipe3 <= (max_pipe2[0] > max_pipe2[1])? max_pipe2[0] : max_pipe2[1];
end

// min_temp, max_temp
reg [7:0] min_temp_next, min_temp;
reg [7:0] max_temp_next, max_temp;
always @(posedge clk) begin
    min_temp <= min_temp_next;
    max_temp <= max_temp_next;
end

always @(*) begin
    min_temp_next = min_pipe3;
    max_temp_next = max_pipe3;
    case (current_state)
    COMP: begin
        if (cnt == 4 || cnt == 68 || cnt == 132) begin
            min_temp_next = min_pipe3;
            max_temp_next = max_pipe3;
        end
        else begin
            min_temp_next = (min_pipe3 < min_temp)? min_pipe3 : min_temp;
            max_temp_next = (max_pipe3 > max_temp)? max_pipe3 : max_temp;
        end
    end
    endcase
end


// max_sum, min_sum
reg [9:0] max_sum_next, max_sum;
reg [9:0] min_sum_next, min_sum;

always @(posedge clk) begin
    max_sum <= max_sum_next;
    min_sum <= min_sum_next;
end

always @(*) begin
    max_sum_next = max_sum;
    min_sum_next = min_sum;
    div_in = 0;
    case (cnt)
    0: begin
        max_sum_next = 0;
        min_sum_next = 0;
    end
    68, 132, 196: begin
        min_sum_next = min_sum + min_temp;
        max_sum_next = max_sum + max_temp;
    end
    197: begin
        div_in = min_sum;
    end
    198: begin
        div_in = max_sum;
        min_sum_next = div_out_buf;
    end
    199: begin
        max_sum_next = div_out_buf;
    end
    endcase
    
end

// MinMax_result_next
always @(*) begin
    MinMax_result_next = MinMax_result;
    case (cnt)
    200: begin
        MinMax_result_next[in_pic_no_reg] = (max_sum + min_sum) >> 1;
    end
    endcase
end

// AF_result_next
always @(*) begin
    AF_result_next = AF_result;
    case (cnt)
    184: begin
        AF_result_next[in_pic_no_reg] = max_index;
    end
    endcase
end

// AF_result_buf (read data from AF_result)
reg [1:0] AF_result_buf;
always @(*) begin
    case (in_pic_no_reg)
    0: AF_result_buf = AF_result[0];
    1: AF_result_buf = AF_result[1];
    2: AF_result_buf = AF_result[2];
    3: AF_result_buf = AF_result[3];
    4: AF_result_buf = AF_result[4];
    5: AF_result_buf = AF_result[5];
    6: AF_result_buf = AF_result[6];
    7: AF_result_buf = AF_result[7];
    8: AF_result_buf = AF_result[8];
    9: AF_result_buf = AF_result[9];
    10: AF_result_buf = AF_result[10];
    11: AF_result_buf = AF_result[11];
    12: AF_result_buf = AF_result[12];
    13: AF_result_buf = AF_result[13];
    14: AF_result_buf = AF_result[14];
    15: AF_result_buf = AF_result[15];
    endcase

end

// AE_result_buf
reg [7:0] AE_result_buf;
always @(*) begin
    case (in_pic_no_reg)
    0: AE_result_buf = AE_result[0];
    1: AE_result_buf = AE_result[1];
    2: AE_result_buf = AE_result[2];
    3: AE_result_buf = AE_result[3];
    4: AE_result_buf = AE_result[4];
    5: AE_result_buf = AE_result[5];
    6: AE_result_buf = AE_result[6];
    7: AE_result_buf = AE_result[7];
    8: AE_result_buf = AE_result[8];
    9: AE_result_buf = AE_result[9];
    10: AE_result_buf = AE_result[10];
    11: AE_result_buf = AE_result[11];
    12: AE_result_buf = AE_result[12];
    13: AE_result_buf = AE_result[13];
    14: AE_result_buf = AE_result[14];
    15: AE_result_buf = AE_result[15];
    endcase
end

// MinMax_result_buf
reg [7:0] MinMax_result_buf;
always @(*) begin
    case (in_pic_no_reg)
    0: MinMax_result_buf = MinMax_result[0];
    1: MinMax_result_buf = MinMax_result[1];
    2: MinMax_result_buf = MinMax_result[2];
    3: MinMax_result_buf = MinMax_result[3];
    4: MinMax_result_buf = MinMax_result[4];
    5: MinMax_result_buf = MinMax_result[5];
    6: MinMax_result_buf = MinMax_result[6];
    7: MinMax_result_buf = MinMax_result[7];
    8: MinMax_result_buf = MinMax_result[8];
    9: MinMax_result_buf = MinMax_result[9];
    10: MinMax_result_buf = MinMax_result[10];
    11: MinMax_result_buf = MinMax_result[11];
    12: MinMax_result_buf = MinMax_result[12];
    13: MinMax_result_buf = MinMax_result[13];
    14: MinMax_result_buf = MinMax_result[14];
    15: MinMax_result_buf = MinMax_result[15];
    endcase
end


// num_of_div_next
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


reg [31:0] araddr_s_inf_next;
reg [7:0] arlen_s_inf_next;
reg [7:0] arvalid_s_inf_next;
always @(posedge clk) begin
    araddr_s_inf <= araddr_s_inf_next;
    arlen_s_inf <= arlen_s_inf_next;
    arvalid_s_inf <= arvalid_s_inf_next;
end

reg [31:0] awaddr_s_inf_next;
reg [7:0] awlen_s_inf_next;
reg [7:0] awvalid_s_inf_next;
always @(posedge clk) begin
    awaddr_s_inf <= awaddr_s_inf_next;
    awlen_s_inf <= awlen_s_inf_next;
    awvalid_s_inf <= awvalid_s_inf_next;
end


// w_data
always @(*) begin
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
end


// in_pixel_next (shifted input from DRAM)
always @(*) begin
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


// add input
always @(*) begin
    add0_a = shift0_out_gp1;
    add0_b = shift1_out_gp1;
    add1_a = shift2_out_gp1;
    add1_b = shift3_out_gp1;
    add2_a = shift4_out_gp1;
    add2_b = shift5_out_gp1;
    add3_a = shift6_out_gp1;
    add3_b = shift7_out_gp1;
    add4_a = shift8_out_gp1;
    add4_b = shift9_out_gp1;
    add5_a = shift10_out_gp1;
    add5_b = shift11_out_gp1;
    add6_a = shift12_out_gp1;
    add6_b = shift13_out_gp1;
    add7_a = shift14_out_gp1;
    add7_b = shift15_out_gp1;
    
    add8_a = add0_out_reg;
    add8_b = add1_out_reg;
    add9_a = add2_out_reg;
    add9_b = add3_out_reg;
    add10_a = add4_out_reg;
    add10_b = add5_out_reg;
    add11_a = add6_out_reg;
    add11_b = add7_out_reg;

    add12_a = add8_out_reg;
    add12_b = add9_out_reg;
    add13_a = add10_out_reg;
    add13_b = add11_out_reg;
    add14_a = add12_out_reg;
    add14_b = add13_out_reg;
    add15_a = add14_out;
    add15_b = sum;
end

reg wait_flag, wait_flag_next;
always @(posedge clk) begin
    wait_flag <= wait_flag_next;
end

always @(*) begin
    next_state = current_state;
    cnt_next = cnt + 1;
    // read
    arid_s_inf = 4'b0; // host i
    arsize_s_inf = 3'b100; // burst size
    arburst_s_inf = 2'b01; // burst type
    araddr_s_inf_next = 0;
    arvalid_s_inf_next = 0;
    arlen_s_inf_next = 0;
    rready_s_inf = 0;

    // write
    awid_s_inf = 4'b0; // host id
    awaddr_s_inf_next = 0; // start address
    awlen_s_inf_next = 0;
    awvalid_s_inf_next = 0;
    awsize_s_inf = 3'b100; // burst length (196 bits)
    awburst_s_inf = 2'b01; // burst type

    wlast_s_inf = 0;
    wvalid_s_inf = 0;
    bready_s_inf = 0;

    AE_result_next = AE_result;
    sum_next = sum;

    out_valid_next = 0;
    out_data_next = 0;

    wait_flag_next = wait_flag;
    case (current_state)
    IDLE: begin
        if (in_valid) begin
            sum_next = 0;
            next_state = BYPASS;
            cnt_next = 0;
        end
    end
    BYPASS: begin // determine if able to directly output result
        next_state = WAIT;
        cnt_next = 0;

        // output result form cache
        if (((in_mode_reg == 0 || in_mode_reg == 2) && (AF_result_buf != 3)) ||
            ((in_mode_reg == 1) && (in_ratio_mode_reg == 2) && (AF_result_buf != 3))) begin
            next_state = COMP;
            cnt_next = 201;
            // $display("Bypass");
        end

        // directly output 0
        if ((num_of_div_buf == 0) || 
            (in_mode_reg == 1 && num_of_div_buf == 1 && (in_ratio_mode_reg == 0 || in_ratio_mode_reg == 1)) || 
            (in_mode_reg == 1 && num_of_div_buf == 2 && in_ratio_mode_reg == 0)) begin
            out_data_next = 0;
            out_valid_next = 1;
            next_state = IDLE;
        end

        wait_flag_next = 1;
    end
    WAIT: begin
        if (wait_flag) begin
            case (cnt)
            0: begin
                araddr_s_inf_next = 32'h10000 + 3072*(in_pic_no_reg);
                arlen_s_inf_next = 191;
                arvalid_s_inf_next = 1;
            end
            endcase

            // prepare to write data
            case (cnt)
            0,1: begin
                awaddr_s_inf_next = 32'h10000 + 3072*(in_pic_no_reg);
                awlen_s_inf_next = 191;
                awvalid_s_inf_next = 1;
            end
            3,4,5: begin
                wvalid_s_inf = 1;
            end
            6: begin
                wait_flag_next = 0;
            end
            endcase
        end

        if (rvalid_s_inf && cnt > 6) begin 
            next_state = COMP;
            cnt_next = 0;
        end
    end
    COMP: begin
        // keep reading
        rready_s_inf = 1;

        if (cnt >= 1) begin
            wvalid_s_inf = 1;
            wlast_s_inf = 0;
            bready_s_inf = 1;
        end

        if (cnt >= 4) begin
            sum_next = add15_out;
        end

        case (cnt)
        192: begin
            wlast_s_inf = 1; // last write
            rready_s_inf = 0; // stop reading
        end
        193: begin
            wvalid_s_inf = 0; // stop writing
            rready_s_inf = 0; // stop reading
        end
        194: begin
            bready_s_inf = 1; // ready for write response
            rready_s_inf = 0; // stop reading
            wvalid_s_inf = 0; // stop writing
        end
        196: begin
            AE_result_next[in_pic_no_reg] = sum >> 10;
        end
        201: begin
            cnt_next = 0;
            next_state = IDLE;
            out_valid_next = 1;
            case (in_mode_reg)
            0: out_data_next = AF_result_buf;
            1: out_data_next = AE_result_buf;
            2: out_data_next = MinMax_result_buf;
            endcase
        end
        endcase
    end
    endcase
end
endmodule
