module TMIP(
    // input signals
    clk,
    rst_n,
    in_valid, 
    in_valid2,
    
    image,
    template,
    image_size,
	action,
	
    // output signals
    out_valid,
    out_value
    );

input            clk, rst_n;
input            in_valid, in_valid2;

input      [7:0] image;
input      [7:0] template;
input      [1:0] image_size;
input      [2:0] action;

output reg       out_valid;
output reg       out_value;

//==================================================================
// parameter & integer
//==================================================================


parameter IDLE =  4'b0000, READ_IMG = 4'b0001, READ_ACT = 4'b0010,
          CENTER = 4'b0011, MAXPOOL = 4'b0100, NEGATIVE = 4'b0101,
		  FLIP = 4'b0110, FILTER = 4'b0111, READ_SRAM = 4'b1000, OUTPUT = 4'b1001;


reg [7:0] MEM_MAX_addr, MEM_MAX_in;
wire [7:0] MEM_MAX_out;
reg MEM_MAX_web;
MEM_256_8 MEM_MAX (.DO0(MEM_MAX_out[0]),.DO1(MEM_MAX_out[1]),.DO2(MEM_MAX_out[2]),.DO3(MEM_MAX_out[3]),
                   .DO4(MEM_MAX_out[4]),.DO5(MEM_MAX_out[5]),.DO6(MEM_MAX_out[6]),.DO7(MEM_MAX_out[7]),
                   .DI0(MEM_MAX_in[0]),.DI1(MEM_MAX_in[1]),.DI2(MEM_MAX_in[2]),.DI3(MEM_MAX_in[3]),
                   .DI4(MEM_MAX_in[4]),.DI5(MEM_MAX_in[5]),.DI6(MEM_MAX_in[6]),.DI7(MEM_MAX_in[7]),
                   .A0(MEM_MAX_addr[0]),.A1(MEM_MAX_addr[1]),.A2(MEM_MAX_addr[2]),.A3(MEM_MAX_addr[3]),
                   .A4(MEM_MAX_addr[4]),.A5(MEM_MAX_addr[5]),.A6(MEM_MAX_addr[6]),.A7(MEM_MAX_addr[7]),
                   .WEB(MEM_MAX_web),.CK(clk),.CS(1'b1),.OE(1'b1));

reg [7:0] MEM_AVG_addr, MEM_AVG_in;
wire [7:0] MEM_AVG_out;
reg MEM_AVG_web;
MEM_256_8 MEM_AVG (.DO0(MEM_AVG_out[0]),.DO1(MEM_AVG_out[1]),.DO2(MEM_AVG_out[2]),.DO3(MEM_AVG_out[3]),
                   .DO4(MEM_AVG_out[4]),.DO5(MEM_AVG_out[5]),.DO6(MEM_AVG_out[6]),.DO7(MEM_AVG_out[7]),
                   .DI0(MEM_AVG_in[0]),.DI1(MEM_AVG_in[1]),.DI2(MEM_AVG_in[2]),.DI3(MEM_AVG_in[3]),
                   .DI4(MEM_AVG_in[4]),.DI5(MEM_AVG_in[5]),.DI6(MEM_AVG_in[6]),.DI7(MEM_AVG_in[7]),
                   .A0(MEM_AVG_addr[0]),.A1(MEM_AVG_addr[1]),.A2(MEM_AVG_addr[2]),.A3(MEM_AVG_addr[3]),
                   .A4(MEM_AVG_addr[4]),.A5(MEM_AVG_addr[5]),.A6(MEM_AVG_addr[6]),.A7(MEM_AVG_addr[7]),
                   .WEB(MEM_AVG_web),.CK(clk),.CS(1'b1),.OE(1'b1));

reg [7:0] MEM_WAVG_addr, MEM_WAVG_in;
wire [7:0] MEM_WAVG_out;
reg MEM_WAVG_web;
MEM_256_8 MEM_WAVG (.DO0(MEM_WAVG_out[0]),.DO1(MEM_WAVG_out[1]),.DO2(MEM_WAVG_out[2]),.DO3(MEM_WAVG_out[3]),
                   .DO4(MEM_WAVG_out[4]),.DO5(MEM_WAVG_out[5]),.DO6(MEM_WAVG_out[6]),.DO7(MEM_WAVG_out[7]),
                   .DI0(MEM_WAVG_in[0]),.DI1(MEM_WAVG_in[1]),.DI2(MEM_WAVG_in[2]),.DI3(MEM_WAVG_in[3]),
                   .DI4(MEM_WAVG_in[4]),.DI5(MEM_WAVG_in[5]),.DI6(MEM_WAVG_in[6]),.DI7(MEM_WAVG_in[7]),
                   .A0(MEM_WAVG_addr[0]),.A1(MEM_WAVG_addr[1]),.A2(MEM_WAVG_addr[2]),.A3(MEM_WAVG_addr[3]),
                   .A4(MEM_WAVG_addr[4]),.A5(MEM_WAVG_addr[5]),.A6(MEM_WAVG_addr[6]),.A7(MEM_WAVG_addr[7]),
                   .WEB(MEM_WAVG_web),.CK(clk),.CS(1'b1),.OE(1'b1));

reg [7:0] MEM_addr_src;
reg [7:0] MEM_out;

wire [7:0] max4_out;
reg [7:0] max4_a, max4_b, max4_c, max4_d;
max4 max4_inst (
	.a (max4_a),
	.b (max4_b),
	.c (max4_c),
	.d (max4_d),
	.out (max4_out)
);

reg [7:0] inter0 [0:8];
reg [7:0] inter1 [0:8];
reg [7:0] inter2 [0:8];
reg [7:0] inter3 [0:8];
reg [7:0] inter4 [0:8];
reg [7:0] inter5 [0:8];

reg [7:0] sort9_pre_out [0:8];
reg [7:0] sort9_post_in [0:8];

//==================================================================
// reg & wire
//==================================================================
reg [7:0] template_array [0:8];
reg [7:0] template_array_next [0:8];
reg [3:0] current_state, next_state;
reg [9:0] cnt, cnt_next;
reg [8:0] i_cnt, i_cnt_next;
reg [1:0] rgb_cnt, rgb_cnt_next;
reg [3:0] set_cnt, set_cnt_next;
reg [2:0] act_cnt, act_cnt_next;

reg [7:0] image_reg;
reg [7:0] gs_max_next, gs_max;
reg [9:0] gs_avg_next, gs_avg;
reg [7:0] gs_wavg_next, gs_wavg;

reg [1:0] image_size_next, image_size_reg;
reg [1:0] image_size_inter, image_size_inter_next; // this image size stores the new image size during each set

reg out_valid_next, out_value_next;

reg max_flag, max_flag_next; // indicate whether it is the first cycle reading the image


reg in_valid2_reg;
reg [2:0] action_reg;

reg [2:0] action_list [0:7];
reg [2:0] action_list_next [0:7];
reg [2:0] number_of_action, number_of_action_next;

reg [7:0] INTER [0:255];
reg [7:0] INTER_next [0:255];

reg [7:0] conv_input0, conv_input0_next;


reg [15:0] conv0, conv0_next;
reg [15:0] conv1, conv1_next;
reg [15:0] conv2, conv2_next;
reg [15:0] conv3, conv3_next;
reg [15:0] conv4, conv4_next;
reg [15:0] conv5, conv5_next;
reg [15:0] conv6, conv6_next;
reg [15:0] conv7, conv7_next;
reg [15:0] conv8, conv8_next;
reg [19:0] conv_result, conv_result_next;
reg [7:0] mult_a, mult_b;

reg [5:0] actual_size_next, actual_size;

reg in_valid_reg;


always @(posedge clk) begin
	conv_input0 <= conv_input0_next;
end

always @(posedge clk) begin
	conv0 <= conv0_next;
	conv1 <= conv1_next;
	conv2 <= conv2_next;
	conv3 <= conv3_next;
	conv4 <= conv4_next;
	conv5 <= conv5_next;
	conv6 <= conv6_next;
	conv7 <= conv7_next;
	conv8 <= conv8_next;
	conv_result <= conv_result_next;
end

reg [7:0] filter_in [0:8];
reg [7:0] filter_in_next [0:8];
reg [7:0] filter_pipe0 [0:8];
reg [7:0] filter_pipe0_next [0:8];
reg [7:0] filter_pipe1, filter_pipe1_next;
reg [7:0] filter_pipe2, filter_pipe3, filter_pipe4, filter_pipe5, filter_pipe6, filter_pipe7, filter_pipe8,
		  filter_pipe9, filter_pipe10, filter_pipe11, filter_pipe12, filter_pipe13, filter_pipe14, filter_pipe15;

always @(posedge clk) begin
	filter_in <= filter_in_next;
	filter_pipe0 <= filter_pipe0_next;
	filter_pipe1 <= filter_pipe1_next;
end

always@(posedge clk) begin
	filter_pipe15 <= filter_pipe14;
	filter_pipe14 <= filter_pipe13;
	filter_pipe13 <= filter_pipe12;
	filter_pipe12 <= filter_pipe11;
	filter_pipe11 <= filter_pipe10;
	filter_pipe10 <= filter_pipe9;
	filter_pipe9 <= filter_pipe8;
	filter_pipe8 <= filter_pipe7;
	filter_pipe7 <= filter_pipe6;
	filter_pipe6 <= filter_pipe5;
	filter_pipe5 <= filter_pipe4;
	filter_pipe4 <= filter_pipe3;
	filter_pipe3 <= filter_pipe2;
	filter_pipe2 <= filter_pipe1;
end

//==================================================================
// design
//==================================================================

wire [15:0] mult_out;
wire [19:0] add9_out;

assign mult_out = mult_a * mult_b;
assign add9_out = (conv0 + conv1) + (conv2 + conv3) + (conv4 + conv5) + (conv6 + conv7) + conv8;

always @(posedge clk) begin
    if (cnt < 8 && (current_state == IDLE || current_state == READ_IMG)) begin
        template_array[8] <= template;
        template_array[0:7] <= template_array[1:8];
    end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		image_size_reg <= 0;
		image_size_inter <= 0;
		in_valid2_reg <= 0;
		in_valid_reg <= 0;
		image_reg <= 0;
		action_reg <= 0;
		max_flag <= 0;
		action_list <= {0,0,0,0,0,0,0,0};
		number_of_action <= 0;
		actual_size <= 0;
	end 
	else begin
		image_size_reg <= image_size_next;
		image_size_inter <= image_size_inter_next;
		in_valid2_reg <= in_valid2;
		in_valid_reg <= in_valid;
		image_reg <= image;
		action_reg <= action;
		max_flag <= max_flag_next;
		action_list <= action_list_next;
		number_of_action <= number_of_action_next;
		actual_size <= actual_size_next;
	end
   
end


always @(posedge clk) begin
	if (!rst_n) begin
		for (integer i = 0; i < 256; i = i + 1) begin
			INTER[i] <= 0;
		end
	end
	else begin
		INTER <= INTER_next;
	end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        current_state <= IDLE;
        cnt <= 0;
        i_cnt <= 9'b11111_1111;
        rgb_cnt <= 0;
        set_cnt <= 0;
        act_cnt <= 0;

        out_valid <= 0;
        out_value <= 0;
        gs_max <= 0;
        gs_avg <= 0;
    end
    else begin
        current_state <= next_state;
        cnt <= cnt_next;
        i_cnt <= i_cnt_next;
        rgb_cnt <= rgb_cnt_next;
        set_cnt <= set_cnt_next;
        act_cnt <= act_cnt_next;

        out_valid <= out_valid_next;
        out_value <= out_value_next;
        gs_max <= gs_max_next;
        gs_avg <= gs_avg_next;
        gs_wavg <= gs_wavg_next;
    end
end

function [7:0] is_bigger;
    input [7:0] a, b;
	reg [8:0] diff;
    begin
		diff = b-a;
        is_bigger = (diff[8])? a:b;
    end
endfunction

function [7:0] compare;
    input [7:0] a, b;
	reg [8:0] diff;
    begin
		diff = b-a;
        compare = diff[8];
    end
endfunction

always @(*) begin
    next_state = current_state;
    rgb_cnt_next = rgb_cnt;
    i_cnt_next = i_cnt;
    cnt_next = cnt + 1;
    set_cnt_next = set_cnt;
    act_cnt_next = act_cnt;

    image_size_next = image_size_reg;
	image_size_inter_next = image_size_inter;
	INTER_next = INTER;

    // read mode
    MEM_MAX_web = 1;
    MEM_AVG_web = 1;
    MEM_WAVG_web = 1;

    MEM_MAX_addr = 0;
    MEM_AVG_addr = 0;
    MEM_WAVG_addr = 0;

    MEM_AVG_in = 0;
    MEM_WAVG_in = 0;
    MEM_MAX_in = 0;

	MEM_out = 0;
	MEM_addr_src = 0;

    gs_max_next = gs_max;
    gs_avg_next = gs_avg;
    gs_wavg_next = gs_wavg;

    out_valid_next = 0;
    out_value_next = 0;

    max_flag_next = max_flag;

    number_of_action_next = number_of_action;
	action_list_next = action_list;
	
	conv0_next = conv0;
	conv1_next = conv1;
	conv2_next = conv2;
	conv3_next = conv3;
	conv4_next = conv4;
	conv5_next = conv5;
	conv6_next = conv6;
	conv7_next = conv7;
	conv8_next = conv8;
	conv_result_next = conv_result;

	conv_input0_next = 0;

	mult_a = 0;
	mult_b = 0;
	max4_a = 0; 
	max4_b = 0; 
	max4_c = 0;
	max4_d = 0;
	actual_size_next = actual_size;

	filter_in_next = filter_in;

	sort9_post_in = {0,0,0,0,0,0,0,0,0};

	inter0 = {0,0,0,0,0,0,0,0,0};
	inter1 = {0,0,0,0,0,0,0,0,0};
	inter2 = {0,0,0,0,0,0,0,0,0};
	inter3 = {0,0,0,0,0,0,0,0,0};
	inter4 = {0,0,0,0,0,0,0,0,0};
	inter5 = {0,0,0,0,0,0,0,0,0};

	sort9_pre_out = {0,0,0,0,0,0,0,0,0};
	
	filter_pipe0_next[0] = 0;
	filter_pipe0_next[1] = 0;
	filter_pipe0_next[2] = 0;
	filter_pipe0_next[3] = 0;
	filter_pipe0_next[4] = 0;
	filter_pipe0_next[5] = 0;
	filter_pipe0_next[6] = 0;
	filter_pipe0_next[7] = 0;
	filter_pipe0_next[8] = 0;
	
	filter_pipe1_next = 0;

	
    case (current_state)
    IDLE: begin
        if (in_valid) begin
            rgb_cnt_next = 0;
            cnt_next = 0;
			i_cnt_next = 9'b11111_1111;
            next_state = READ_IMG;
            image_size_next = image_size;
        end
    end
    READ_IMG: begin
        rgb_cnt_next = rgb_cnt + 1;
        // cnt_next = cnt + 1;
		i_cnt_next = i_cnt;
        case (rgb_cnt)
            0: begin // R channel in image_reg;
                // MAX_MEM
                gs_max_next = image_reg;
                // write gs_max to SRAM with addr calculated by i_cnt
                MEM_MAX_web = 0;
                MEM_MAX_addr = i_cnt;
                MEM_MAX_in = gs_max;

                // MEM_AVG
                gs_avg_next = image_reg;
                // write gs_avg to SRAM with addr calculated by i_cnt
                MEM_AVG_web = 0;
                MEM_AVG_addr = i_cnt;
                MEM_AVG_in = gs_avg / 3;

                // MEM_WAVG
                gs_wavg_next = {2'b00, image_reg[7:2]};
                // write gs_wavg to SRAM with addr calculated by i_cnt
                MEM_WAVG_web = 0;
                MEM_WAVG_addr = i_cnt;
                MEM_WAVG_in = gs_wavg;

                max_flag_next = 1;
                // check if go to next_state
                if (image_size_reg == 2 && i_cnt == 255 && max_flag == 1) begin
                    next_state = READ_ACT;
                    i_cnt_next = 0;
                    cnt_next = 0;
                    number_of_action_next = 0;
                end
                else if (image_size_reg == 1 && i_cnt == 63) begin
                    next_state = READ_ACT;
                    i_cnt_next = 0;
                    cnt_next = 0;
                    number_of_action_next = 0;
                end
                else if (image_size_reg == 0 && i_cnt == 15) begin
                    next_state = READ_ACT;
                    i_cnt_next = 0;
                    cnt_next = 0;
                    number_of_action_next = 0;
                end
            end
            1: begin // G channel in image_reg;
                // MAX_MEM
                gs_max_next = is_bigger(gs_max, image_reg);
                // MEM_AVG
                gs_avg_next = image_reg + gs_avg;
                // MEM_WAVG
                gs_wavg_next = gs_wavg + {1'b0, image_reg[7:1]};
            end
            2: begin // B channel in image_reg;
                // MAX_MEM
                gs_max_next = is_bigger(gs_max, image_reg);
                // MEM_AVG
                gs_avg_next = image_reg + gs_avg;
                // MEM_WAVG
                gs_wavg_next = gs_wavg + {2'b00,image_reg[7:2]};
                i_cnt_next = i_cnt + 1;
                rgb_cnt_next = 0;
            end
        endcase
    end
    READ_ACT: begin
		out_valid_next = 0;
		out_value_next = 0;
		image_size_inter_next = image_size_reg;
        if (in_valid2_reg) begin
			action_list_next[number_of_action] = action_reg;
			number_of_action_next = number_of_action + 1;
			if (action_reg == 7) begin
				next_state = READ_SRAM;
				act_cnt_next = 1;
				i_cnt_next = 0;
				cnt_next = 0;
			end
        end
    end
	READ_SRAM: begin
		case (action_list[0])
		0: MEM_out = MEM_MAX_out;
		1: MEM_out = MEM_AVG_out;
		2: MEM_out = MEM_WAVG_out;
		endcase
		cnt_next = cnt + 1;
		MEM_addr_src = cnt;
		case (image_size_reg)
		0: begin
			if (cnt < 17) begin
				INTER_next[15] = MEM_out;
				INTER_next[0:14] = INTER[1:15];
			end
			else begin
				next_state = CENTER;
				act_cnt_next = 1;
			end
		end
		1: begin
			if (cnt < 65) begin
				INTER_next[63] = MEM_out;
				INTER_next[0:62] = INTER[1:63];
			end
			else begin
				next_state = CENTER;
				act_cnt_next = 1;
			end
		end
		2: begin
			if (cnt < 257) begin
				INTER_next[255] = MEM_out;
				INTER_next[0:254] = INTER[1:255];
			end
			else begin
				next_state = CENTER;
				act_cnt_next = 1;
			end
		end
		endcase
		case (action_list[0])
		0:	MEM_MAX_addr = MEM_addr_src;
		1:	MEM_AVG_addr = MEM_addr_src;
		2:	MEM_WAVG_addr = MEM_addr_src;
		endcase
	end
	CENTER: begin
		act_cnt_next = act_cnt + 1;
		i_cnt_next = 0;
		cnt_next = 0;
		case (image_size_inter)
		0: actual_size_next = 4;
		1: actual_size_next = 8;
		2: actual_size_next = 16;
		endcase
		case (action_list[act_cnt])
		3: begin
			next_state = MAXPOOL;
		end
		4: begin
			next_state = NEGATIVE;
		end
		5: begin
			next_state = FLIP;
		end
		6: begin
			next_state = FILTER;
		end
		7: begin
			next_state = OUTPUT;
		end
		endcase
	end
	MAXPOOL: begin
		cnt_next = cnt + 1;
		case (image_size_inter)
		0: begin
			next_state = CENTER;
		end
		1: begin
			max4_a = INTER[0];
			max4_b = INTER[1];
			max4_c = INTER[8];
			max4_d = INTER[9];
		
			case (cnt)
			0,1,2,3: begin
				INTER_next[0:61] = INTER[2:63];
				INTER_next[62] = max4_out;
				INTER_next[63] = 0;
				INTER_next[6] = 0;
				INTER_next[7] = 0;
			end
			4: begin
				INTER_next[0:55] = INTER[8:63];
				INTER_next[56:63] = INTER[0:7];
				i_cnt_next = i_cnt + 1;
				cnt_next = 0;
			end
			endcase
			
			if (i_cnt == 3 && cnt[2] == 1) begin
				image_size_inter_next = 0;
				next_state = CENTER;
				INTER_next[0] = INTER[8];
				INTER_next[1] = INTER[10];
				INTER_next[2] = INTER[12];
				INTER_next[3] = INTER[14];

				INTER_next[4] = INTER[24];
				INTER_next[5] = INTER[26];
				INTER_next[6] = INTER[28];
				INTER_next[7] = INTER[30];
				
				INTER_next[8] = INTER[40];
				INTER_next[9] = INTER[42];
				INTER_next[10] = INTER[44];
				INTER_next[11] = INTER[46];

				INTER_next[12] = INTER[56];
				INTER_next[13] = INTER[58];
				INTER_next[14] = INTER[60];
				INTER_next[15] = INTER[62];
			end
		end
		2: begin
			max4_a = INTER[0];
			max4_b = INTER[1];
			max4_c = INTER[16];
			max4_d = INTER[17];
		
			case (cnt)
			0,1,2,3,4,5,6,7: begin
				INTER_next[0:253] = INTER[2:255];
				INTER_next[254] = max4_out;
				INTER_next[255] = 0;
				INTER_next[14] = 0;
				INTER_next[15] = 0;
			end
			8: begin
				INTER_next[0:239] = INTER[16:255];
				INTER_next[240:255] = INTER[0:15];
				i_cnt_next = i_cnt + 1;
				cnt_next = 0;
			end
			endcase
			
			if (i_cnt == 7 && cnt[3] == 1) begin
				image_size_inter_next = 1;
				next_state = CENTER;
				INTER_next[0] = INTER[16];
				INTER_next[1] = INTER[18];
				INTER_next[2] = INTER[20];
				INTER_next[3] = INTER[22];
				INTER_next[4] = INTER[24];
				INTER_next[5] = INTER[26];
				INTER_next[6] = INTER[28];
				INTER_next[7] = INTER[30];
				
				INTER_next[8] = INTER[48];
				INTER_next[9] = INTER[50];
				INTER_next[10] = INTER[52];
				INTER_next[11] = INTER[54];
				INTER_next[12] = INTER[56];
				INTER_next[13] = INTER[58];
				INTER_next[14] = INTER[60];
				INTER_next[15] = INTER[62];

				INTER_next[16] = INTER[80];
				INTER_next[17] = INTER[82];
				INTER_next[18] = INTER[84];
				INTER_next[19] = INTER[86];
				INTER_next[20] = INTER[88];
				INTER_next[21] = INTER[90];
				INTER_next[22] = INTER[92];
				INTER_next[23] = INTER[94];

				INTER_next[24] = INTER[112];
				INTER_next[25] = INTER[114];
				INTER_next[26] = INTER[116];
				INTER_next[27] = INTER[118];
				INTER_next[28] = INTER[120];
				INTER_next[29] = INTER[122];
				INTER_next[30] = INTER[124];
				INTER_next[31] = INTER[126];

				INTER_next[32] = INTER[144];
				INTER_next[33] = INTER[146];
				INTER_next[34] = INTER[148];
				INTER_next[35] = INTER[150];
				INTER_next[36] = INTER[152];
				INTER_next[37] = INTER[154];
				INTER_next[38] = INTER[156];
				INTER_next[39] = INTER[158];

				INTER_next[40] = INTER[176];
				INTER_next[41] = INTER[178];
				INTER_next[42] = INTER[180];
				INTER_next[43] = INTER[182];
				INTER_next[44] = INTER[184];
				INTER_next[45] = INTER[186];
				INTER_next[46] = INTER[188];
				
				INTER_next[47] = INTER[190];
				INTER_next[48] = INTER[208];
				INTER_next[49] = INTER[210];
				INTER_next[50] = INTER[212];
				INTER_next[51] = INTER[214];
				INTER_next[52] = INTER[216];
				INTER_next[53] = INTER[218];
				INTER_next[54] = INTER[220];
				INTER_next[55] = INTER[222];

				INTER_next[56] = INTER[240];
				INTER_next[57] = INTER[242];
				INTER_next[58] = INTER[244];
				INTER_next[59] = INTER[246];
				INTER_next[60] = INTER[248];
				INTER_next[61] = INTER[250];
				INTER_next[62] = INTER[252];
				INTER_next[63] = INTER[254];
			end
		end
		endcase	
	end
	FILTER: begin
		cnt_next = cnt + 1;
		i_cnt_next = i_cnt + 1;
		inter0 = filter_in;
		if (compare(filter_in[2],filter_in[5])) begin
			inter0[2] = filter_in[5];
			inter0[5] = filter_in[2];
		end
		// (0,3)
		if (compare(filter_in[0],filter_in[3])) begin
			inter0[0] = filter_in[3];
			inter0[3] = filter_in[0];
		end
		// (4,8)
		if (compare(filter_in[4],filter_in[8])) begin
			inter0[4] = filter_in[8];
			inter0[8] = filter_in[4];
		end
		// (1,7)
		if (compare(filter_in[1],filter_in[7])) begin
			inter0[1] = filter_in[7];
			inter0[7] = filter_in[1];
		end

		inter1 = inter0;
		// (0,7)
		if (compare(inter0[0],inter0[7])) begin
			inter1[0] = inter0[7];
			inter1[7] = inter0[0];
		end
		// (2,4)
		if (compare(inter0[2],inter0[4])) begin
			inter1[2] = inter0[4];
			inter1[4] = inter0[2];
		end
		// (5,6)
		if (compare(inter0[5],inter0[6])) begin
			inter1[5] = inter0[6];
			inter1[6] = inter0[5];
		end
		// (3,8)
		if (compare(inter0[3],inter0[8])) begin
			inter1[3] = inter0[8];
			inter1[8] = inter0[3];
		end
		
        sort9_pre_out = inter1;
		//(0,2)
		if (compare(inter1[0],inter1[2])) begin
			sort9_pre_out[0] = inter1[2];
			sort9_pre_out[2] = inter1[0];
		end
		//(1,3)
		if (compare(inter1[1],inter1[3])) begin
			sort9_pre_out[1] = inter1[3];
			sort9_pre_out[3] = inter1[1];
		end
		//(4,5)
		if (compare(inter1[4],inter1[5])) begin
			sort9_pre_out[4] = inter1[5];
			sort9_pre_out[5] = inter1[4];
		end
		//(7,8)
		if (compare(inter1[7],inter1[8])) begin
			sort9_pre_out[7] = inter1[8];
			sort9_pre_out[8] = inter1[7];
		end
    
		filter_pipe0_next = sort9_pre_out;

		inter3 = filter_pipe0;
		// (1,4)
		if (compare(filter_pipe0[1], filter_pipe0[4])) begin
			inter3[1] = filter_pipe0[4];
			inter3[4] = filter_pipe0[1];
		end
		// (5,7)
		if (compare(filter_pipe0[5], filter_pipe0[7])) begin
			inter3[5] = filter_pipe0[7];
			inter3[7] = filter_pipe0[5];
		end
		// (3,6)
		if (compare(filter_pipe0[3], filter_pipe0[6])) begin
			inter3[3] = filter_pipe0[6];
			inter3[6] = filter_pipe0[3];
		end
		
		inter4 = inter3;
		// (0,1)
		if (compare(inter3[0], inter3[1])) begin
			inter4[0] = inter3[1];
			inter4[1] = inter3[0];
		end
		// (2,4)
		if (compare(inter3[2], inter3[4])) begin
			inter4[2] = inter3[4];
			inter4[4] = inter3[2];
		end
		// (3,5)
		if (compare(inter3[3], inter3[5])) begin
			inter4[3] = inter3[5];
			inter4[5] = inter3[3];
		end
		// (6,8)
		if (compare(inter3[6], inter3[8])) begin
			inter4[6] = inter3[8];
			inter4[8] = inter3[6];
		end
		

		inter5 = inter4;
		// (2,3)
		if (compare(inter4[2], inter4[3])) begin
			inter5[2] = inter4[3];
			inter5[3] = inter4[2];
		end
		// (4,5)
		if (compare(inter4[4], inter4[5])) begin
			inter5[4] = inter4[5];
			inter5[5] = inter4[4];
		end
		// (6,7)
		if (compare(inter4[6], inter4[7])) begin
			inter5[6] = inter4[7];
			inter5[7] = inter4[6];
		end
		
		filter_pipe1_next = is_bigger(inter5[3], inter5[4]);

		filter_in_next[0] = INTER[cnt-actual_size-1];
		filter_in_next[1] = INTER[cnt-actual_size];
		filter_in_next[2] = INTER[cnt-actual_size+1];
		filter_in_next[3] = INTER[cnt-1];
		filter_in_next[4] = INTER[cnt];
		filter_in_next[5] = INTER[cnt+1];
		filter_in_next[6] = INTER[cnt+actual_size-1];
		filter_in_next[7] = INTER[cnt+actual_size];
		filter_in_next[8] = INTER[cnt+actual_size+1];
		

		case (image_size_inter)
		0: begin
			if (i_cnt == 20) begin
				next_state = CENTER;
				i_cnt_next = 0;
				cnt_next = 0;
			end
			INTER_next[cnt-5] = filter_pipe3;
			case (cnt)
			0: begin // top-left
				filter_in_next[0] = INTER[0];
				filter_in_next[1] = INTER[0];
				filter_in_next[2] = INTER[1];
				filter_in_next[3] = INTER[0];
				filter_in_next[4] = INTER[0];
				filter_in_next[5] = INTER[1];
				filter_in_next[6] = INTER[4];
				filter_in_next[7] = INTER[4];
				filter_in_next[8] = INTER[5];
			end
			1,2: begin // top
				filter_in_next[0] = INTER[cnt-1];
				filter_in_next[1] = INTER[cnt];
				filter_in_next[2] = INTER[cnt+1];
			end
			3: begin // top-right
				filter_in_next[0] = INTER[2];
				filter_in_next[1] = INTER[3];
				filter_in_next[2] = INTER[3];
				filter_in_next[3] = INTER[2];
				filter_in_next[4] = INTER[3];
				filter_in_next[5] = INTER[3];
				filter_in_next[6] = INTER[6];
				filter_in_next[7] = INTER[7];
				filter_in_next[8] = INTER[7];
			end
			4,8: begin // left
				filter_in_next[0] = INTER[cnt-4];
				filter_in_next[3] = INTER[cnt];
				filter_in_next[6] = INTER[cnt+4];
			end
			7,11: begin // right
				filter_in_next[2] = INTER[cnt-4];
				filter_in_next[5] = INTER[cnt];
				filter_in_next[8] = INTER[cnt+4];
			end
			12: begin // bottom-left
				filter_in_next[0] = INTER[8];
				filter_in_next[1] = INTER[8];
				filter_in_next[2] = INTER[9];
				filter_in_next[3] = INTER[12];
				filter_in_next[4] = INTER[12];
				filter_in_next[5] = INTER[13];
				filter_in_next[6] = INTER[12];
				filter_in_next[7] = INTER[12];
				filter_in_next[8] = INTER[13];
			end
			13,14: begin // bottom
				filter_in_next[6] = INTER[cnt-1];
				filter_in_next[7] = INTER[cnt];
				filter_in_next[8] = INTER[cnt+1];
			end
			15: begin
				filter_in_next[0] = INTER[10];
				filter_in_next[1] = INTER[11];
				filter_in_next[2] = INTER[11];
				filter_in_next[3] = INTER[14];
				filter_in_next[4] = INTER[15];
				filter_in_next[5] = INTER[15];
				filter_in_next[6] = INTER[14];
				filter_in_next[7] = INTER[15];
				filter_in_next[8] = INTER[15];
				i_cnt_next = 15;
			end
			endcase
		end
		1: begin
			if (i_cnt == 72) begin
				next_state = CENTER;
				i_cnt_next = 0;
				cnt_next = 0;
			end
			INTER_next[cnt-9] = filter_pipe7;
			case (cnt)
			0: begin // top-left
				filter_in_next[0] = INTER[0];
				filter_in_next[1] = INTER[0];
				filter_in_next[2] = INTER[1];
				filter_in_next[3] = INTER[0];
				filter_in_next[4] = INTER[0];
				filter_in_next[5] = INTER[1];
				filter_in_next[6] = INTER[8];
				filter_in_next[7] = INTER[8];
				filter_in_next[8] = INTER[9];
			end
			1,2,3,4,5,6: begin // top
				filter_in_next[0] = INTER[cnt-1];
				filter_in_next[1] = INTER[cnt];
				filter_in_next[2] = INTER[cnt+1];
			end
			7: begin // top-right
				filter_in_next[0] = INTER[6];
				filter_in_next[1] = INTER[7];
				filter_in_next[2] = INTER[7];
				filter_in_next[3] = INTER[6];
				filter_in_next[4] = INTER[7];
				filter_in_next[5] = INTER[7];
				filter_in_next[6] = INTER[14];
				filter_in_next[7] = INTER[15];
				filter_in_next[8] = INTER[15];
			end
			8,16,24,32,40,48: begin // left
				filter_in_next[0] = INTER[cnt-8];
				filter_in_next[3] = INTER[cnt];
				filter_in_next[6] = INTER[cnt+8];
			end
			15,23,31,39,47,55: begin // right
				filter_in_next[2] = INTER[cnt-8];
				filter_in_next[5] = INTER[cnt];
				filter_in_next[8] = INTER[cnt+8];
			end
			56: begin // bottom-left
				filter_in_next[0] = INTER[48];
				filter_in_next[1] = INTER[48];
				filter_in_next[2] = INTER[49];
				filter_in_next[3] = INTER[56];
				filter_in_next[4] = INTER[56];
				filter_in_next[5] = INTER[57];
				filter_in_next[6] = INTER[56];
				filter_in_next[7] = INTER[56];
				filter_in_next[8] = INTER[57];
			end
			57,58,59,60,61,62: begin // bottom
				filter_in_next[6] = INTER[cnt-1];
				filter_in_next[7] = INTER[cnt];
				filter_in_next[8] = INTER[cnt+1];
			end
			63: begin
				filter_in_next[0] = INTER[54];
				filter_in_next[1] = INTER[55];
				filter_in_next[2] = INTER[55];
				filter_in_next[3] = INTER[62];
				filter_in_next[4] = INTER[63];
				filter_in_next[5] = INTER[63];
				filter_in_next[6] = INTER[62];
				filter_in_next[7] = INTER[63];
				filter_in_next[8] = INTER[63];
				i_cnt_next = 63;
			end
			endcase
		end
		2: begin
			if (i_cnt == 272) begin
				next_state = CENTER;
				i_cnt_next = 0;
				cnt_next = 0;
			end
			INTER_next[cnt-17] = filter_pipe15;
			case (cnt)
			0: begin // top-left
				filter_in_next[0] = INTER[0];
				filter_in_next[1] = INTER[0];
				filter_in_next[2] = INTER[1];
				filter_in_next[3] = INTER[0];
				filter_in_next[4] = INTER[0];
				filter_in_next[5] = INTER[1];
				filter_in_next[6] = INTER[16];
				filter_in_next[7] = INTER[16];
				filter_in_next[8] = INTER[17];
			end
			1,2,3,4,5,6,7,8,9,10,11,12,13,14: begin // top
				filter_in_next[0] = INTER[cnt-1];
				filter_in_next[1] = INTER[cnt];
				filter_in_next[2] = INTER[cnt+1];
			end
			15: begin // top-right
				filter_in_next[0] = INTER[14];
				filter_in_next[1] = INTER[15];
				filter_in_next[2] = INTER[15];
				filter_in_next[3] = INTER[14];
				filter_in_next[4] = INTER[15];
				filter_in_next[5] = INTER[15];
				filter_in_next[6] = INTER[30];
				filter_in_next[7] = INTER[31];
				filter_in_next[8] = INTER[31];
			end
			16,32,48,64,80,96,112,128,144,160,176,192,208,224: begin // left
				filter_in_next[0] = INTER[cnt-16];
				filter_in_next[3] = INTER[cnt];
				filter_in_next[6] = INTER[cnt+16];
			end
			31,47,63,79,95,111,127,143,159,175,191,207,223,239: begin // right
				filter_in_next[2] = INTER[cnt-16];
				filter_in_next[5] = INTER[cnt];
				filter_in_next[8] = INTER[cnt+16];
			end
			240: begin // bottom-left
				filter_in_next[0] = INTER[224];
				filter_in_next[1] = INTER[224];
				filter_in_next[2] = INTER[225];
				filter_in_next[3] = INTER[240];
				filter_in_next[4] = INTER[240];
				filter_in_next[5] = INTER[241];
				filter_in_next[6] = INTER[240];
				filter_in_next[7] = INTER[240];
				filter_in_next[8] = INTER[241];
			end
			241,242,243,244,245,246,247,248,249,250,251,252,253,254: begin // bottom
				filter_in_next[6] = INTER[cnt-1];
				filter_in_next[7] = INTER[cnt];
				filter_in_next[8] = INTER[cnt+1];
			end
			255: begin // bottom-right
				filter_in_next[0] = INTER[238];
				filter_in_next[1] = INTER[239];
				filter_in_next[2] = INTER[239];
				filter_in_next[3] = INTER[254];
				filter_in_next[4] = INTER[255];
				filter_in_next[5] = INTER[255];
				filter_in_next[6] = INTER[254];
				filter_in_next[7] = INTER[255];
				filter_in_next[8] = INTER[255];
				i_cnt_next = 255;
			end
			endcase
		end
		endcase
	end
	NEGATIVE: begin
		for (integer i = 0; i < 256; i = i + 1) begin
			INTER_next[i] = ~INTER[i];
		end
		next_state = CENTER;
	end
	FLIP: begin
		case (image_size_inter)
		0: begin
			for (integer i=0; i<4 ; i=i+1) begin
				INTER_next[0+i*4] = INTER[3+i*4];
				INTER_next[1+i*4] = INTER[2+i*4];
				INTER_next[2+i*4] = INTER[1+i*4];
				INTER_next[3+i*4] = INTER[0+i*4];
			end
		end
		1: begin
			for (integer i=0; i<8; i++) begin
				INTER_next[0+i*8] = INTER[7+i*8];
				INTER_next[1+i*8] = INTER[6+i*8];
				INTER_next[2+i*8] = INTER[5+i*8];
				INTER_next[3+i*8] = INTER[4+i*8];
				INTER_next[4+i*8] = INTER[3+i*8];
				INTER_next[5+i*8] = INTER[2+i*8];
				INTER_next[6+i*8] = INTER[1+i*8];
				INTER_next[7+i*8] = INTER[0+i*8];
			end
		end
		2: begin
			for (integer i = 0; i < 16; i = i + 1) begin
				INTER_next[0+i*16] = INTER[15+i*16];
				INTER_next[15+i*16] = INTER[0+i*16];
				INTER_next[1+i*16] = INTER[14+i*16];
				INTER_next[14+i*16] = INTER[1+i*16];
				INTER_next[2+i*16] = INTER[13+i*16];
				INTER_next[13+i*16] = INTER[2+i*16];
				INTER_next[3+i*16] = INTER[12+i*16];
				INTER_next[12+i*16] = INTER[3+i*16];
				INTER_next[4+i*16] = INTER[11+i*16];
				INTER_next[11+i*16] = INTER[4+i*16];
				INTER_next[5+i*16] = INTER[10+i*16];
				INTER_next[10+i*16] = INTER[5+i*16];
				INTER_next[6+i*16] = INTER[9+i*16];
				INTER_next[9+i*16] = INTER[6+i*16];
				INTER_next[7+i*16] = INTER[8+i*16];
				INTER_next[8+i*16] = INTER[7+i*16];
			end
		end
		endcase
		next_state = CENTER;
	end
	OUTPUT: begin
		cnt_next = cnt + 1;
		out_valid_next = out_valid;
		case (cnt)
			0: begin
				out_value_next = (out_valid)? conv_result[10]:0;
			end
			1: begin
				mult_b = template_array[0];
				conv0_next = mult_out;
				out_value_next = (out_valid)? conv_result[9]:0;
			end
			2: begin
				mult_b = template_array[1];
				conv1_next = mult_out;
				out_value_next = (out_valid)? conv_result[8]:0;
			end
			3: begin
				mult_b = template_array[2];
				conv2_next = mult_out;
				out_value_next = (out_valid)? conv_result[7]:0;
			end
			4: begin
				mult_b = template_array[3];
				conv3_next = mult_out;
				out_value_next = (out_valid)? conv_result[6]:0;
			end
			5: begin
				mult_b = template_array[4];
				conv4_next = mult_out;
				out_value_next = (out_valid)? conv_result[5]:0;
			end
			6: begin
				mult_b = template_array[5];
				conv5_next = mult_out;
				out_value_next = (out_valid)? conv_result[4]:0;
			end
			7: begin
				mult_b = template_array[6];
				conv6_next = mult_out;
				out_value_next = (out_valid)? conv_result[3]:0;
			end
			8: begin
				mult_b = template_array[7];
				conv7_next = mult_out;
				out_value_next = (out_valid)? conv_result[2]:0;
			end
			9: begin
				mult_b = template_array[8];
				conv8_next = mult_out;
				out_value_next = (out_valid)? conv_result[1]:0;
			end
			10: begin
				conv_result_next = add9_out;
				out_value_next = (out_valid)? conv_result[0]:0;
				if (image_size_inter == 0 && i_cnt == 16 || (image_size_inter == 1 && i_cnt == 64) || image_size_inter == 2 && i_cnt == 256) begin
					if (set_cnt == 7) begin
						next_state = IDLE;
						set_cnt_next = 0;
						cnt_next = 0;
						i_cnt_next = 0;
						number_of_action_next = 0;
						image_size_inter_next = 0;
						rgb_cnt_next = 0;
						actual_size_next = 0;
						act_cnt_next = 0;
						max_flag_next = 0;
					end
					else begin
						next_state = READ_ACT;
						set_cnt_next = set_cnt + 1;
						cnt_next = 0;
						i_cnt_next = 0;
						act_cnt_next = 0;
						number_of_action_next = 0;
					end
				end
				
			end
			11: begin
				out_valid_next = 1;
				out_value_next = conv_result[19];
			end
			12: begin
				out_value_next = conv_result[18];
			end
			13: begin
				out_value_next = conv_result[17];
			end
			14: begin
				out_value_next = conv_result[16];
			end
			15: begin
				out_value_next = conv_result[15];
			end
			16: begin
				out_value_next = conv_result[14];
			end
			17: begin
				out_value_next = conv_result[13];
			end
			18: begin
				out_value_next = conv_result[12];
			end
			19: begin
				out_value_next = conv_result[11];
				i_cnt_next = i_cnt + 1;
				cnt_next = 0;
			end
		endcase

		mult_a = conv_input0;
		case (image_size_inter)
		0: begin
			case (cnt)
				0: conv_input0_next = INTER[11];
				1: conv_input0_next = INTER[12];
				2: conv_input0_next = INTER[13];
				3: conv_input0_next = INTER[15];
				4: conv_input0_next = INTER[0];
				5: conv_input0_next = INTER[1];
				6: conv_input0_next = INTER[3];
				7: conv_input0_next = INTER[4];
				8: conv_input0_next = INTER[5];
				10: begin
					INTER_next[0:14] = INTER[1:15];
					INTER_next[15] = INTER[0];
				end
			endcase
		end
		1: begin
			case (cnt)
				0: conv_input0_next = INTER[55];
				1: conv_input0_next = INTER[56];
				2: conv_input0_next = INTER[57];
				3: conv_input0_next = INTER[63];
				4: conv_input0_next = INTER[0];
				5: conv_input0_next = INTER[1];
				6: conv_input0_next = INTER[7];
				7: conv_input0_next = INTER[8];
				8: conv_input0_next = INTER[9];
				10: begin
					INTER_next[0:62] = INTER[1:63];
					INTER_next[63] = INTER[0];
				end
			endcase
		end
		2: begin
			case (cnt)
				0: conv_input0_next = INTER[239];
				1: conv_input0_next = INTER[240];
				2: conv_input0_next = INTER[241];
				3: conv_input0_next = INTER[255];
				4: conv_input0_next = INTER[0];
				5: conv_input0_next = INTER[1];
				6: conv_input0_next = INTER[15];
				7: conv_input0_next = INTER[16];
				8: conv_input0_next = INTER[17];
				10: begin
					INTER_next[0:254] = INTER[1:255];
					INTER_next[255] = INTER[0];
				end
			endcase
		end
		endcase
		
		case(image_size_inter)
		0: begin
			case (i_cnt)
			0: begin // top-left
				case (cnt)
				0: conv_input0_next = 0;
				1: conv_input0_next = 0;
				2: conv_input0_next = 0;
				3: conv_input0_next = 0;
				6: conv_input0_next = 0;
				endcase
			end
			1,2: begin // top
				case (cnt)
				0: conv_input0_next = 0;
				1: conv_input0_next = 0;
				2: conv_input0_next = 0;
				endcase
			end
			3: begin // top-right
				case (cnt)
				0: conv_input0_next = 0;
				1: conv_input0_next = 0;
				2: conv_input0_next = 0;
				5: conv_input0_next = 0;
				8: conv_input0_next = 0;
				endcase
			end
			4,8: begin // left
				case (cnt)
				0: conv_input0_next = 0;
				3: conv_input0_next = 0;
				6: conv_input0_next = 0;
				endcase
			end
			7,11: begin // right
				case (cnt)
				2: conv_input0_next = 0;
				5: conv_input0_next = 0;
				8: conv_input0_next = 0;
				endcase
			end
			12: begin // bottom-left
				case (cnt)
				0: conv_input0_next = 0;
				3: conv_input0_next = 0;
				6: conv_input0_next = 0;
				7: conv_input0_next = 0;
				8: conv_input0_next = 0;
				endcase
			end
			13,14: begin // bottom
				case (cnt)
				6: conv_input0_next = 0;
				7: conv_input0_next = 0;
				8: conv_input0_next = 0;
				endcase
			end
			15: begin // bottom-right
				case (cnt)
				2: conv_input0_next = 0;
				5: conv_input0_next = 0;
				6: conv_input0_next = 0;
				7: conv_input0_next = 0;
				8: conv_input0_next = 0;
				endcase
			end
			endcase
		end
        1: begin
			case (i_cnt)
			// top-left
			0: begin
				case (cnt)
				0: conv_input0_next = 0;
				1: conv_input0_next = 0;
				2: conv_input0_next = 0;
				3: conv_input0_next = 0;
				6: conv_input0_next = 0;
				endcase
			end
			// top
			1,2,3,4,5,6: begin
				case (cnt)
				0:conv_input0_next = 0;
				1:conv_input0_next = 0;
				2:conv_input0_next = 0;
				endcase
			end
			// top-right
			7: begin
				case (cnt)
				0: conv_input0_next = 0;
				1: conv_input0_next = 0;
				2: conv_input0_next = 0;
				5: conv_input0_next = 0;
				8: conv_input0_next = 0;
				endcase
			end
			// left
			8,16,24,32,40,48: begin
				case (cnt)
				0: conv_input0_next = 0;
				3: conv_input0_next = 0;
				6: conv_input0_next = 0;
				endcase
			end
			// right
			15,23,31,39,47,55: begin
				case (cnt)
				2: conv_input0_next = 0;
				5: conv_input0_next = 0;
				8: conv_input0_next = 0;
				endcase
			end
			// bottom-left
			56: begin
				case (cnt)
				0: conv_input0_next = 0;
				3: conv_input0_next = 0;
				6: conv_input0_next = 0;
				7: conv_input0_next = 0;
				8: conv_input0_next = 0;
				endcase
			end
			// bottom
			57,58,59,60,61,62: begin
				case (cnt)
				6: conv_input0_next = 0;
				7: conv_input0_next = 0;
				8: conv_input0_next = 0;
				endcase
			end
			// bottom-right
			63: begin
				case (cnt)
				2: conv_input0_next = 0;
				5: conv_input0_next = 0;
				6: conv_input0_next = 0;
				7: conv_input0_next = 0;
				8: conv_input0_next = 0;
				endcase
			end
			endcase
		end
		2: begin
			case (i_cnt)
			// top-left
			0: begin	
				case (cnt)
				0: conv_input0_next = 0;
				1: conv_input0_next = 0;
				2: conv_input0_next = 0;
				3: conv_input0_next = 0;
				6: conv_input0_next = 0;
				endcase
			end
			// top
			1,2,3,4,5,6,7,8,9,10,11,12,13,14: begin
				case (cnt)
				0: conv_input0_next = 0;
				1: conv_input0_next = 0;
				2: conv_input0_next = 0;
				endcase
			end
			// top-right
			15: begin
				case (cnt)
				0: conv_input0_next = 0;
				1: conv_input0_next = 0;
				2: conv_input0_next = 0;
				5: conv_input0_next = 0;
				8: conv_input0_next = 0;
				endcase
			end
			// left
			16,32,48,64,80,96,112,128,144,160,176,192,208,224: begin
				case (cnt)
				0: conv_input0_next = 0;
				3: conv_input0_next = 0;
				6: conv_input0_next = 0;
				endcase
			end
			// right
			31,47,63,79,95,111,127,143,159,175,191,207,223,239: begin
				case (cnt)
				2: conv_input0_next = 0;
				5: conv_input0_next = 0;
				8: conv_input0_next = 0;
				endcase
			end
				// bottom-left
			240: begin
				case (cnt)
				0: conv_input0_next = 0;
				3: conv_input0_next = 0;
				6: conv_input0_next = 0;
				7: conv_input0_next = 0;
				8: conv_input0_next = 0;
				endcase
			end
			// bottom
			241,242,243,244,245,246,247,248,249,250,251,252,253,254: begin
				case (cnt)
				6: conv_input0_next = 0;
				7: conv_input0_next = 0;
				8: conv_input0_next = 0;
				endcase
			end
			// bottom-right
			255: begin	
				case (cnt)
				2: conv_input0_next = 0;
				5: conv_input0_next = 0;
				6: conv_input0_next = 0;
				7: conv_input0_next = 0;
				8: conv_input0_next = 0;
				endcase
			end
			endcase
		end
		endcase
    end
    endcase
end
endmodule

module max4(
	input [7:0] a,
	input [7:0] b,
	input [7:0] c,
	input [7:0] d,
	output reg [7:0] out
);	
	reg [7:0] inter1, inter2;

	function is_bigger;
		input [7:0] a, b;
		reg [8:0] diff;
		begin
			diff = b-a;
			is_bigger = diff[8];
		end
	endfunction
	
	always @(*) begin
		inter1 = (is_bigger(a, b)) ? a : b;
		inter2 = (is_bigger(c, d)) ? c : d;
		out = (is_bigger(inter1, inter2)) ? inter1 : inter2;
	end
endmodule