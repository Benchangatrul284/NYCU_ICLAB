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
          CENTER = 4'b0010, MAXPOOL = 4'b0011, FILTER = 4'b0100,
		  READ_SRAM = 4'b0101, OUTPUT = 4'b1111;

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

//==================================================================
// reg & wire
//==================================================================
reg [7:0] template_array [0:8];
reg [7:0] template_array_next [0:8];
reg [3:0] current_state, next_state;
reg [9:0] cnt, cnt_next;
reg [7:0] i_cnt, i_cnt_next;
reg [1:0] rgb_cnt, rgb_cnt_next;
reg [2:0] set_cnt, set_cnt_next;
reg [2:0] act_cnt, act_cnt_next;

reg [7:0] image_reg;
reg [7:0] gs_max_next, gs_max;
reg [9:0] gs_avg_next, gs_avg;
reg [7:0] gs_wavg_next, gs_wavg;

reg [1:0] image_size_next, image_size_reg;

reg out_valid_next, out_value_next;

reg max_flag, max_flag_next; // indicate whether it is the first cycle reading the image
reg first_act_flag, first_act_flag_next;
reg flip_flag, flip_flag_next;
reg negative_flag, negative_flag_next;

reg in_valid2_reg;
reg [2:0] action_reg;

reg [2:0] action_list [0:7];
reg [2:0] action_list_next [0:7];
reg [2:0] number_of_action, number_of_action_next;

reg [7:0] INTER [0:255];
reg [7:0] INTER_next [0:255];

//==================================================================
// design
//==================================================================

always @(posedge clk) begin
    if (cnt < 8 && (current_state == IDLE || current_state == READ_IMG)) begin
        template_array[8] <= template;
        template_array[0:7] <= template_array[1:8];
    end
end

always @(posedge clk) begin
    image_size_reg <= image_size_next;
    in_valid2_reg <= in_valid2;
    image_reg <= image;
    action_reg <= action;

	max_flag <= max_flag_next;
    action_list <= action_list_next;
    number_of_action <= number_of_action_next;
    first_act_flag <= first_act_flag_next;
	flip_flag <= flip_flag_next;
	negative_flag <= negative_flag_next;
	INTER <= INTER_next;
end


always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        current_state <= IDLE;
        cnt <= 0;
        i_cnt <= 8'b1111_1111;
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
    begin
        is_bigger = (a>b)? a:b;
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
    first_act_flag_next = first_act_flag;
	flip_flag_next = flip_flag;
	negative_flag_next = negative_flag;
	
    number_of_action_next = number_of_action;
	action_list_next = action_list;
	
    case (current_state)
    IDLE: begin
        if (in_valid) begin
            rgb_cnt_next = 0;
            cnt_next = 0;
            next_state = READ_IMG;
            image_size_next = image_size;
        end
    end
    READ_IMG: begin
        rgb_cnt_next = rgb_cnt + 1;
        cnt_next = cnt + 1;
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
        if (in_valid2_reg) begin
			action_list_next[number_of_action] = action_reg;
			number_of_action_next = number_of_action + 1;
			if (action_reg == 7) begin
				number_of_action_next = number_of_action;
				next_state = READ_SRAM;
				act_cnt_next = 1;
				i_cnt_next = 0;
				cnt_next = 0;
			end
        end
    end
	CENTER: begin
		if (act_cnt < number_of_action) begin
			case (action_list[act_cnt])
			3: begin
				next_state = MAXPOOL;
			end
			6: begin
				next_state = FILTER;
			end
			endcase
		end 
		else begin
			next_state = OUTPUT;
			cnt_next = 0;
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
				print_INTER_reg;
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
				print_INTER_reg;
			end
		end
		2: begin
			if (cnt < 257) begin
				INTER_next[255] = CENTER;
				INTER_next[0:254] = INTER[1:255];
			end
			else begin
				next_state = OUTPUT;
				act_cnt_next = 1;
				print_INTER_reg;
			end
		end
		endcase
		case (action_list[0])
		0:	MEM_MAX_addr = MEM_addr_src;
		1:	MEM_AVG_addr = MEM_addr_src;
		2:	MEM_WAVG_addr = MEM_addr_src;
		endcase
	end
    OUTPUT: begin
        // print_WAVG_MEM;
        out_valid_next = 1;
        out_value_next = INTER[cnt][7] + INTER[cnt][6] + INTER[cnt][5] + INTER[cnt][4] + INTER[cnt][3] + INTER[cnt][2] + INTER[cnt][1] + INTER[cnt][0];
        next_state = IDLE;
    end
    endcase
end

// synopsys translate_off
task print_MAX_MEM;
    $display("===============MAX_MEM memory==================");
    if (image_size_reg == 2) begin
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_MAX.Memory[0], MEM_MAX.Memory[1], MEM_MAX.Memory[2], MEM_MAX.Memory[3],
                MEM_MAX.Memory[4],MEM_MAX.Memory[5], MEM_MAX.Memory[6], MEM_MAX.Memory[7],
                MEM_MAX.Memory[8], MEM_MAX.Memory[9], MEM_MAX.Memory[10], MEM_MAX.Memory[11],
                MEM_MAX.Memory[12], MEM_MAX.Memory[13], MEM_MAX.Memory[14], MEM_MAX.Memory[15]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_MAX.Memory[16], MEM_MAX.Memory[17], MEM_MAX.Memory[18], MEM_MAX.Memory[19],
                MEM_MAX.Memory[20],MEM_MAX.Memory[21], MEM_MAX.Memory[22], MEM_MAX.Memory[23],
                MEM_MAX.Memory[24], MEM_MAX.Memory[25], MEM_MAX.Memory[26], MEM_MAX.Memory[27],
                MEM_MAX.Memory[28], MEM_MAX.Memory[29], MEM_MAX.Memory[30], MEM_MAX.Memory[31]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_MAX.Memory[32], MEM_MAX.Memory[33], MEM_MAX.Memory[34], MEM_MAX.Memory[35],
                MEM_MAX.Memory[36],MEM_MAX.Memory[37], MEM_MAX.Memory[38], MEM_MAX.Memory[39],
                MEM_MAX.Memory[40], MEM_MAX.Memory[41], MEM_MAX.Memory[42], MEM_MAX.Memory[43],
                MEM_MAX.Memory[44], MEM_MAX.Memory[45], MEM_MAX.Memory[46], MEM_MAX.Memory[47]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_MAX.Memory[48], MEM_MAX.Memory[49], MEM_MAX.Memory[50], MEM_MAX.Memory[51],
                MEM_MAX.Memory[52],MEM_MAX.Memory[53], MEM_MAX.Memory[54], MEM_MAX.Memory[55],
                MEM_MAX.Memory[56], MEM_MAX.Memory[57], MEM_MAX.Memory[58], MEM_MAX.Memory[59],
                MEM_MAX.Memory[60], MEM_MAX.Memory[61], MEM_MAX.Memory[62], MEM_MAX.Memory[63]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_MAX.Memory[64], MEM_MAX.Memory[65], MEM_MAX.Memory[66], MEM_MAX.Memory[67],
                MEM_MAX.Memory[68],MEM_MAX.Memory[69], MEM_MAX.Memory[70], MEM_MAX.Memory[71],
                MEM_MAX.Memory[72], MEM_MAX.Memory[73], MEM_MAX.Memory[74], MEM_MAX.Memory[75],
                MEM_MAX.Memory[76], MEM_MAX.Memory[77], MEM_MAX.Memory[78], MEM_MAX.Memory[79]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_MAX.Memory[80], MEM_MAX.Memory[81], MEM_MAX.Memory[82], MEM_MAX.Memory[83],
                MEM_MAX.Memory[84],MEM_MAX.Memory[85], MEM_MAX.Memory[86], MEM_MAX.Memory[87],
                MEM_MAX.Memory[88], MEM_MAX.Memory[89], MEM_MAX.Memory[90], MEM_MAX.Memory[91],
                MEM_MAX.Memory[92], MEM_MAX.Memory[93], MEM_MAX.Memory[94], MEM_MAX.Memory[95]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_MAX.Memory[96], MEM_MAX.Memory[97], MEM_MAX.Memory[98], MEM_MAX.Memory[99],
                MEM_MAX.Memory[100],MEM_MAX.Memory[101], MEM_MAX.Memory[102], MEM_MAX.Memory[103],
                MEM_MAX.Memory[104], MEM_MAX.Memory[105], MEM_MAX.Memory[106], MEM_MAX.Memory[107],
                MEM_MAX.Memory[108], MEM_MAX.Memory[109], MEM_MAX.Memory[110], MEM_MAX.Memory[111]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_MAX.Memory[112], MEM_MAX.Memory[113], MEM_MAX.Memory[114], MEM_MAX.Memory[115],
                MEM_MAX.Memory[116],MEM_MAX.Memory[117], MEM_MAX.Memory[118], MEM_MAX.Memory[119],
                MEM_MAX.Memory[120], MEM_MAX.Memory[121], MEM_MAX.Memory[122], MEM_MAX.Memory[123],
                MEM_MAX.Memory[124], MEM_MAX.Memory[125], MEM_MAX.Memory[126], MEM_MAX.Memory[127]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_MAX.Memory[128], MEM_MAX.Memory[129], MEM_MAX.Memory[130], MEM_MAX.Memory[131],
                MEM_MAX.Memory[132],MEM_MAX.Memory[133], MEM_MAX.Memory[134], MEM_MAX.Memory[135],
                MEM_MAX.Memory[136], MEM_MAX.Memory[137], MEM_MAX.Memory[138], MEM_MAX.Memory[139],
                MEM_MAX.Memory[140], MEM_MAX.Memory[141], MEM_MAX.Memory[142], MEM_MAX.Memory[143]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_MAX.Memory[144], MEM_MAX.Memory[145], MEM_MAX.Memory[146], MEM_MAX.Memory[147],
                MEM_MAX.Memory[148],MEM_MAX.Memory[149], MEM_MAX.Memory[150], MEM_MAX.Memory[151],
                MEM_MAX.Memory[152], MEM_MAX.Memory[153], MEM_MAX.Memory[154], MEM_MAX.Memory[155],
                MEM_MAX.Memory[156], MEM_MAX.Memory[157], MEM_MAX.Memory[158], MEM_MAX.Memory[159]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_MAX.Memory[160], MEM_MAX.Memory[161], MEM_MAX.Memory[162], MEM_MAX.Memory[163],
                MEM_MAX.Memory[164],MEM_MAX.Memory[165], MEM_MAX.Memory[166], MEM_MAX.Memory[167],
                MEM_MAX.Memory[168], MEM_MAX.Memory[169], MEM_MAX.Memory[170], MEM_MAX.Memory[171],
                MEM_MAX.Memory[172], MEM_MAX.Memory[173], MEM_MAX.Memory[174], MEM_MAX.Memory[175]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_MAX.Memory[176], MEM_MAX.Memory[177], MEM_MAX.Memory[178], MEM_MAX.Memory[179],
                MEM_MAX.Memory[180],MEM_MAX.Memory[181], MEM_MAX.Memory[182], MEM_MAX.Memory[183],
                MEM_MAX.Memory[184], MEM_MAX.Memory[185], MEM_MAX.Memory[186], MEM_MAX.Memory[187],
                MEM_MAX.Memory[188], MEM_MAX.Memory[189], MEM_MAX.Memory[190], MEM_MAX.Memory[191]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_MAX.Memory[192], MEM_MAX.Memory[193], MEM_MAX.Memory[194], MEM_MAX.Memory[195],
                MEM_MAX.Memory[196],MEM_MAX.Memory[197], MEM_MAX.Memory[198], MEM_MAX.Memory[199],
                MEM_MAX.Memory[200], MEM_MAX.Memory[201], MEM_MAX.Memory[202], MEM_MAX.Memory[203],
                MEM_MAX.Memory[204], MEM_MAX.Memory[205], MEM_MAX.Memory[206], MEM_MAX.Memory[207]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_MAX.Memory[208], MEM_MAX.Memory[209], MEM_MAX.Memory[210], MEM_MAX.Memory[211],
                MEM_MAX.Memory[212],MEM_MAX.Memory[213], MEM_MAX.Memory[214], MEM_MAX.Memory[215],
                MEM_MAX.Memory[216], MEM_MAX.Memory[217], MEM_MAX.Memory[218], MEM_MAX.Memory[219],
                MEM_MAX.Memory[220], MEM_MAX.Memory[221], MEM_MAX.Memory[222], MEM_MAX.Memory[223]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_MAX.Memory[224], MEM_MAX.Memory[225], MEM_MAX.Memory[226], MEM_MAX.Memory[227],
                MEM_MAX.Memory[228],MEM_MAX.Memory[229], MEM_MAX.Memory[230], MEM_MAX.Memory[231],
                MEM_MAX.Memory[232], MEM_MAX.Memory[233], MEM_MAX.Memory[234], MEM_MAX.Memory[235],
                MEM_MAX.Memory[236], MEM_MAX.Memory[237], MEM_MAX.Memory[238], MEM_MAX.Memory[239]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_MAX.Memory[240], MEM_MAX.Memory[241], MEM_MAX.Memory[242], MEM_MAX.Memory[243],
                MEM_MAX.Memory[244],MEM_MAX.Memory[245], MEM_MAX.Memory[246], MEM_MAX.Memory[247],
                MEM_MAX.Memory[248], MEM_MAX.Memory[249], MEM_MAX.Memory[250], MEM_MAX.Memory[251],
                MEM_MAX.Memory[252], MEM_MAX.Memory[253], MEM_MAX.Memory[254], MEM_MAX.Memory[255]);
    end
    else if (image_size_reg == 1) begin
        $display("%d %d %d %d %d %d %d %d ",
                MEM_MAX.Memory[0], MEM_MAX.Memory[1], MEM_MAX.Memory[2], MEM_MAX.Memory[3],
                MEM_MAX.Memory[4],MEM_MAX.Memory[5], MEM_MAX.Memory[6], MEM_MAX.Memory[7]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_MAX.Memory[8], MEM_MAX.Memory[9], MEM_MAX.Memory[10], MEM_MAX.Memory[11],
                MEM_MAX.Memory[12],MEM_MAX.Memory[13], MEM_MAX.Memory[14], MEM_MAX.Memory[15]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_MAX.Memory[16], MEM_MAX.Memory[17], MEM_MAX.Memory[18], MEM_MAX.Memory[19],
                MEM_MAX.Memory[20],MEM_MAX.Memory[21], MEM_MAX.Memory[22], MEM_MAX.Memory[23]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_MAX.Memory[24], MEM_MAX.Memory[25], MEM_MAX.Memory[26], MEM_MAX.Memory[27],
                MEM_MAX.Memory[28],MEM_MAX.Memory[29], MEM_MAX.Memory[30], MEM_MAX.Memory[31]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_MAX.Memory[32], MEM_MAX.Memory[33], MEM_MAX.Memory[34], MEM_MAX.Memory[35],
                MEM_MAX.Memory[36],MEM_MAX.Memory[37], MEM_MAX.Memory[38], MEM_MAX.Memory[39]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_MAX.Memory[40], MEM_MAX.Memory[41], MEM_MAX.Memory[42], MEM_MAX.Memory[43],
                MEM_MAX.Memory[44],MEM_MAX.Memory[45], MEM_MAX.Memory[46], MEM_MAX.Memory[47]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_MAX.Memory[48], MEM_MAX.Memory[49], MEM_MAX.Memory[50], MEM_MAX.Memory[51],
                MEM_MAX.Memory[52],MEM_MAX.Memory[53], MEM_MAX.Memory[54], MEM_MAX.Memory[55]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_MAX.Memory[56], MEM_MAX.Memory[57], MEM_MAX.Memory[58], MEM_MAX.Memory[59],
                MEM_MAX.Memory[60],MEM_MAX.Memory[61], MEM_MAX.Memory[62], MEM_MAX.Memory[63]);
    end
    else if (image_size_reg == 0) begin
        $display("%d %d %d %d", MEM_MAX.Memory[0], MEM_MAX.Memory[1], MEM_MAX.Memory[2], MEM_MAX.Memory[3]);
        $display("%d %d %d %d", MEM_MAX.Memory[4], MEM_MAX.Memory[5], MEM_MAX.Memory[6], MEM_MAX.Memory[7]);
        $display("%d %d %d %d", MEM_MAX.Memory[8], MEM_MAX.Memory[9], MEM_MAX.Memory[10], MEM_MAX.Memory[11]);
        $display("%d %d %d %d", MEM_MAX.Memory[12], MEM_MAX.Memory[13], MEM_MAX.Memory[14], MEM_MAX.Memory[15]);
    end
    $display("===============MAX_MEM memory==================");
endtask;


task print_AVG_MEM;
    $display("===============AVG_MEM memory==================");
    if (image_size_reg == 2) begin
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_AVG.Memory[0], MEM_AVG.Memory[1], MEM_AVG.Memory[2], MEM_AVG.Memory[3],
                MEM_AVG.Memory[4],MEM_AVG.Memory[5], MEM_AVG.Memory[6], MEM_AVG.Memory[7],
                MEM_AVG.Memory[8], MEM_AVG.Memory[9], MEM_AVG.Memory[10], MEM_AVG.Memory[11],
                MEM_AVG.Memory[12], MEM_AVG.Memory[13], MEM_AVG.Memory[14], MEM_AVG.Memory[15]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_AVG.Memory[16], MEM_AVG.Memory[17], MEM_AVG.Memory[18], MEM_AVG.Memory[19],
                MEM_AVG.Memory[20],MEM_AVG.Memory[21], MEM_AVG.Memory[22], MEM_AVG.Memory[23],
                MEM_AVG.Memory[24], MEM_AVG.Memory[25], MEM_AVG.Memory[26], MEM_AVG.Memory[27],
                MEM_AVG.Memory[28], MEM_AVG.Memory[29], MEM_AVG.Memory[30], MEM_AVG.Memory[31]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_AVG.Memory[32], MEM_AVG.Memory[33], MEM_AVG.Memory[34], MEM_AVG.Memory[35],
                MEM_AVG.Memory[36],MEM_AVG.Memory[37], MEM_AVG.Memory[38], MEM_AVG.Memory[39],
                MEM_AVG.Memory[40], MEM_AVG.Memory[41], MEM_AVG.Memory[42], MEM_AVG.Memory[43],
                MEM_AVG.Memory[44], MEM_AVG.Memory[45], MEM_AVG.Memory[46], MEM_AVG.Memory[47]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_AVG.Memory[48], MEM_AVG.Memory[49], MEM_AVG.Memory[50], MEM_AVG.Memory[51],
                MEM_AVG.Memory[52],MEM_AVG.Memory[53], MEM_AVG.Memory[54], MEM_AVG.Memory[55],
                MEM_AVG.Memory[56], MEM_AVG.Memory[57], MEM_AVG.Memory[58], MEM_AVG.Memory[59],
                MEM_AVG.Memory[60], MEM_AVG.Memory[61], MEM_AVG.Memory[62], MEM_AVG.Memory[63]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_AVG.Memory[64], MEM_AVG.Memory[65], MEM_AVG.Memory[66], MEM_AVG.Memory[67],
                MEM_AVG.Memory[68],MEM_AVG.Memory[69], MEM_AVG.Memory[70], MEM_AVG.Memory[71],
                MEM_AVG.Memory[72], MEM_AVG.Memory[73], MEM_AVG.Memory[74], MEM_AVG.Memory[75],
                MEM_AVG.Memory[76], MEM_AVG.Memory[77], MEM_AVG.Memory[78], MEM_AVG.Memory[79]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_AVG.Memory[80], MEM_AVG.Memory[81], MEM_AVG.Memory[82], MEM_AVG.Memory[83],
                MEM_AVG.Memory[84],MEM_AVG.Memory[85], MEM_AVG.Memory[86], MEM_AVG.Memory[87],
                MEM_AVG.Memory[88], MEM_AVG.Memory[89], MEM_AVG.Memory[90], MEM_AVG.Memory[91],
                MEM_AVG.Memory[92], MEM_AVG.Memory[93], MEM_AVG.Memory[94], MEM_AVG.Memory[95]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_AVG.Memory[96], MEM_AVG.Memory[97], MEM_AVG.Memory[98], MEM_AVG.Memory[99],
                MEM_AVG.Memory[100],MEM_AVG.Memory[101], MEM_AVG.Memory[102], MEM_AVG.Memory[103],
                MEM_AVG.Memory[104], MEM_AVG.Memory[105], MEM_AVG.Memory[106], MEM_AVG.Memory[107],
                MEM_AVG.Memory[108], MEM_AVG.Memory[109], MEM_AVG.Memory[110], MEM_AVG.Memory[111]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_AVG.Memory[112], MEM_AVG.Memory[113], MEM_AVG.Memory[114], MEM_AVG.Memory[115],
                MEM_AVG.Memory[116],MEM_AVG.Memory[117], MEM_AVG.Memory[118], MEM_AVG.Memory[119],
                MEM_AVG.Memory[120], MEM_AVG.Memory[121], MEM_AVG.Memory[122], MEM_AVG.Memory[123],
                MEM_AVG.Memory[124], MEM_AVG.Memory[125], MEM_AVG.Memory[126], MEM_AVG.Memory[127]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_AVG.Memory[128], MEM_AVG.Memory[129], MEM_AVG.Memory[130], MEM_AVG.Memory[131],
                MEM_AVG.Memory[132],MEM_AVG.Memory[133], MEM_AVG.Memory[134], MEM_AVG.Memory[135],
                MEM_AVG.Memory[136], MEM_AVG.Memory[137], MEM_AVG.Memory[138], MEM_AVG.Memory[139],
                MEM_AVG.Memory[140], MEM_AVG.Memory[141], MEM_AVG.Memory[142], MEM_AVG.Memory[143]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_AVG.Memory[144], MEM_AVG.Memory[145], MEM_AVG.Memory[146], MEM_AVG.Memory[147],
                MEM_AVG.Memory[148],MEM_AVG.Memory[149], MEM_AVG.Memory[150], MEM_AVG.Memory[151],
                MEM_AVG.Memory[152], MEM_AVG.Memory[153], MEM_AVG.Memory[154], MEM_AVG.Memory[155],
                MEM_AVG.Memory[156], MEM_AVG.Memory[157], MEM_AVG.Memory[158], MEM_AVG.Memory[159]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_AVG.Memory[160], MEM_AVG.Memory[161], MEM_AVG.Memory[162], MEM_AVG.Memory[163],
                MEM_AVG.Memory[164],MEM_AVG.Memory[165], MEM_AVG.Memory[166], MEM_AVG.Memory[167],
                MEM_AVG.Memory[168], MEM_AVG.Memory[169], MEM_AVG.Memory[170], MEM_AVG.Memory[171],
                MEM_AVG.Memory[172], MEM_AVG.Memory[173], MEM_AVG.Memory[174], MEM_AVG.Memory[175]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_AVG.Memory[176], MEM_AVG.Memory[177], MEM_AVG.Memory[178], MEM_AVG.Memory[179],
                MEM_AVG.Memory[180],MEM_AVG.Memory[181], MEM_AVG.Memory[182], MEM_AVG.Memory[183],
                MEM_AVG.Memory[184], MEM_AVG.Memory[185], MEM_AVG.Memory[186], MEM_AVG.Memory[187],
                MEM_AVG.Memory[188], MEM_AVG.Memory[189], MEM_AVG.Memory[190], MEM_AVG.Memory[191]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_AVG.Memory[192], MEM_AVG.Memory[193], MEM_AVG.Memory[194], MEM_AVG.Memory[195],
                MEM_AVG.Memory[196],MEM_AVG.Memory[197], MEM_AVG.Memory[198], MEM_AVG.Memory[199],
                MEM_AVG.Memory[200], MEM_AVG.Memory[201], MEM_AVG.Memory[202], MEM_AVG.Memory[203],
                MEM_AVG.Memory[204], MEM_AVG.Memory[205], MEM_AVG.Memory[206], MEM_AVG.Memory[207]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_AVG.Memory[208], MEM_AVG.Memory[209], MEM_AVG.Memory[210], MEM_AVG.Memory[211],
                MEM_AVG.Memory[212],MEM_AVG.Memory[213], MEM_AVG.Memory[214], MEM_AVG.Memory[215],
                MEM_AVG.Memory[216], MEM_AVG.Memory[217], MEM_AVG.Memory[218], MEM_AVG.Memory[219],
                MEM_AVG.Memory[220], MEM_AVG.Memory[221], MEM_AVG.Memory[222], MEM_AVG.Memory[223]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_AVG.Memory[224], MEM_AVG.Memory[225], MEM_AVG.Memory[226], MEM_AVG.Memory[227],
                MEM_AVG.Memory[228],MEM_AVG.Memory[229], MEM_AVG.Memory[230], MEM_AVG.Memory[231],
                MEM_AVG.Memory[232], MEM_AVG.Memory[233], MEM_AVG.Memory[234], MEM_AVG.Memory[235],
                MEM_AVG.Memory[236], MEM_AVG.Memory[237], MEM_AVG.Memory[238], MEM_AVG.Memory[239]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_AVG.Memory[240], MEM_AVG.Memory[241], MEM_AVG.Memory[242], MEM_AVG.Memory[243],
                MEM_AVG.Memory[244],MEM_AVG.Memory[245], MEM_AVG.Memory[246], MEM_AVG.Memory[247],
                MEM_AVG.Memory[248], MEM_AVG.Memory[249], MEM_AVG.Memory[250], MEM_AVG.Memory[251],
                MEM_AVG.Memory[252], MEM_AVG.Memory[253], MEM_AVG.Memory[254], MEM_AVG.Memory[255]);
    end
    else if (image_size_reg == 1) begin
        $display("%d %d %d %d %d %d %d %d ",
                MEM_AVG.Memory[0], MEM_AVG.Memory[1], MEM_AVG.Memory[2], MEM_AVG.Memory[3],
                MEM_AVG.Memory[4],MEM_AVG.Memory[5], MEM_AVG.Memory[6], MEM_AVG.Memory[7]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_AVG.Memory[8], MEM_AVG.Memory[9], MEM_AVG.Memory[10], MEM_AVG.Memory[11],
                MEM_AVG.Memory[12],MEM_AVG.Memory[13], MEM_AVG.Memory[14], MEM_AVG.Memory[15]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_AVG.Memory[16], MEM_AVG.Memory[17], MEM_AVG.Memory[18], MEM_AVG.Memory[19],
                MEM_AVG.Memory[20],MEM_AVG.Memory[21], MEM_AVG.Memory[22], MEM_AVG.Memory[23]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_AVG.Memory[24], MEM_AVG.Memory[25], MEM_AVG.Memory[26], MEM_AVG.Memory[27],
                MEM_AVG.Memory[28],MEM_AVG.Memory[29], MEM_AVG.Memory[30], MEM_AVG.Memory[31]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_AVG.Memory[32], MEM_AVG.Memory[33], MEM_AVG.Memory[34], MEM_AVG.Memory[35],
                MEM_AVG.Memory[36],MEM_AVG.Memory[37], MEM_AVG.Memory[38], MEM_AVG.Memory[39]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_AVG.Memory[40], MEM_AVG.Memory[41], MEM_AVG.Memory[42], MEM_AVG.Memory[43],
                MEM_AVG.Memory[44],MEM_AVG.Memory[45], MEM_AVG.Memory[46], MEM_AVG.Memory[47]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_AVG.Memory[48], MEM_AVG.Memory[49], MEM_AVG.Memory[50], MEM_AVG.Memory[51],
                MEM_AVG.Memory[52],MEM_AVG.Memory[53], MEM_AVG.Memory[54], MEM_AVG.Memory[55]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_AVG.Memory[56], MEM_AVG.Memory[57], MEM_AVG.Memory[58], MEM_AVG.Memory[59],
                MEM_AVG.Memory[60],MEM_AVG.Memory[61], MEM_AVG.Memory[62], MEM_AVG.Memory[63]);
    end
    else if (image_size_reg == 0) begin
        $display("%d %d %d %d", MEM_AVG.Memory[0], MEM_AVG.Memory[1], MEM_AVG.Memory[2], MEM_AVG.Memory[3]);
        $display("%d %d %d %d", MEM_AVG.Memory[4], MEM_AVG.Memory[5], MEM_AVG.Memory[6], MEM_AVG.Memory[7]);
        $display("%d %d %d %d", MEM_AVG.Memory[8], MEM_AVG.Memory[9], MEM_AVG.Memory[10], MEM_AVG.Memory[11]);
        $display("%d %d %d %d", MEM_AVG.Memory[12], MEM_AVG.Memory[13], MEM_AVG.Memory[14], MEM_AVG.Memory[15]);
    end
    $display("===============AVG_MEM memory==================");
endtask;

task print_WAVG_MEM;
    $display("===============WAVG_MEM memory==================");
    if (image_size_reg == 2) begin
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_WAVG.Memory[0], MEM_WAVG.Memory[1], MEM_WAVG.Memory[2], MEM_WAVG.Memory[3],
                MEM_WAVG.Memory[4],MEM_WAVG.Memory[5], MEM_WAVG.Memory[6], MEM_WAVG.Memory[7],
                MEM_WAVG.Memory[8], MEM_WAVG.Memory[9], MEM_WAVG.Memory[10], MEM_WAVG.Memory[11],
                MEM_WAVG.Memory[12], MEM_WAVG.Memory[13], MEM_WAVG.Memory[14], MEM_WAVG.Memory[15]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_WAVG.Memory[16], MEM_WAVG.Memory[17], MEM_WAVG.Memory[18], MEM_WAVG.Memory[19],
                MEM_WAVG.Memory[20],MEM_WAVG.Memory[21], MEM_WAVG.Memory[22], MEM_WAVG.Memory[23],
                MEM_WAVG.Memory[24], MEM_WAVG.Memory[25], MEM_WAVG.Memory[26], MEM_WAVG.Memory[27],
                MEM_WAVG.Memory[28], MEM_WAVG.Memory[29], MEM_WAVG.Memory[30], MEM_WAVG.Memory[31]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_WAVG.Memory[32], MEM_WAVG.Memory[33], MEM_WAVG.Memory[34], MEM_WAVG.Memory[35],
                MEM_WAVG.Memory[36],MEM_WAVG.Memory[37], MEM_WAVG.Memory[38], MEM_WAVG.Memory[39],
                MEM_WAVG.Memory[40], MEM_WAVG.Memory[41], MEM_WAVG.Memory[42], MEM_WAVG.Memory[43],
                MEM_WAVG.Memory[44], MEM_WAVG.Memory[45], MEM_WAVG.Memory[46], MEM_WAVG.Memory[47]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_WAVG.Memory[48], MEM_WAVG.Memory[49], MEM_WAVG.Memory[50], MEM_WAVG.Memory[51],
                MEM_WAVG.Memory[52],MEM_WAVG.Memory[53], MEM_WAVG.Memory[54], MEM_WAVG.Memory[55],
                MEM_WAVG.Memory[56], MEM_WAVG.Memory[57], MEM_WAVG.Memory[58], MEM_WAVG.Memory[59],
                MEM_WAVG.Memory[60], MEM_WAVG.Memory[61], MEM_WAVG.Memory[62], MEM_WAVG.Memory[63]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_WAVG.Memory[64], MEM_WAVG.Memory[65], MEM_WAVG.Memory[66], MEM_WAVG.Memory[67],
                MEM_WAVG.Memory[68],MEM_WAVG.Memory[69], MEM_WAVG.Memory[70], MEM_WAVG.Memory[71],
                MEM_WAVG.Memory[72], MEM_WAVG.Memory[73], MEM_WAVG.Memory[74], MEM_WAVG.Memory[75],
                MEM_WAVG.Memory[76], MEM_WAVG.Memory[77], MEM_WAVG.Memory[78], MEM_WAVG.Memory[79]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_WAVG.Memory[80], MEM_WAVG.Memory[81], MEM_WAVG.Memory[82], MEM_WAVG.Memory[83],
                MEM_WAVG.Memory[84],MEM_WAVG.Memory[85], MEM_WAVG.Memory[86], MEM_WAVG.Memory[87],
                MEM_WAVG.Memory[88], MEM_WAVG.Memory[89], MEM_WAVG.Memory[90], MEM_WAVG.Memory[91],
                MEM_WAVG.Memory[92], MEM_WAVG.Memory[93], MEM_WAVG.Memory[94], MEM_WAVG.Memory[95]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_WAVG.Memory[96], MEM_WAVG.Memory[97], MEM_WAVG.Memory[98], MEM_WAVG.Memory[99],
                MEM_WAVG.Memory[100],MEM_WAVG.Memory[101], MEM_WAVG.Memory[102], MEM_WAVG.Memory[103],
                MEM_WAVG.Memory[104], MEM_WAVG.Memory[105], MEM_WAVG.Memory[106], MEM_WAVG.Memory[107],
                MEM_WAVG.Memory[108], MEM_WAVG.Memory[109], MEM_WAVG.Memory[110], MEM_WAVG.Memory[111]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_WAVG.Memory[112], MEM_WAVG.Memory[113], MEM_WAVG.Memory[114], MEM_WAVG.Memory[115],
                MEM_WAVG.Memory[116],MEM_WAVG.Memory[117], MEM_WAVG.Memory[118], MEM_WAVG.Memory[119],
                MEM_WAVG.Memory[120], MEM_WAVG.Memory[121], MEM_WAVG.Memory[122], MEM_WAVG.Memory[123],
                MEM_WAVG.Memory[124], MEM_WAVG.Memory[125], MEM_WAVG.Memory[126], MEM_WAVG.Memory[127]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_WAVG.Memory[128], MEM_WAVG.Memory[129], MEM_WAVG.Memory[130], MEM_WAVG.Memory[131],
                MEM_WAVG.Memory[132],MEM_WAVG.Memory[133], MEM_WAVG.Memory[134], MEM_WAVG.Memory[135],
                MEM_WAVG.Memory[136], MEM_WAVG.Memory[137], MEM_WAVG.Memory[138], MEM_WAVG.Memory[139],
                MEM_WAVG.Memory[140], MEM_WAVG.Memory[141], MEM_WAVG.Memory[142], MEM_WAVG.Memory[143]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_WAVG.Memory[144], MEM_WAVG.Memory[145], MEM_WAVG.Memory[146], MEM_WAVG.Memory[147],
                MEM_WAVG.Memory[148],MEM_WAVG.Memory[149], MEM_WAVG.Memory[150], MEM_WAVG.Memory[151],
                MEM_WAVG.Memory[152], MEM_WAVG.Memory[153], MEM_WAVG.Memory[154], MEM_WAVG.Memory[155],
                MEM_WAVG.Memory[156], MEM_WAVG.Memory[157], MEM_WAVG.Memory[158], MEM_WAVG.Memory[159]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_WAVG.Memory[160], MEM_WAVG.Memory[161], MEM_WAVG.Memory[162], MEM_WAVG.Memory[163],
                MEM_WAVG.Memory[164],MEM_WAVG.Memory[165], MEM_WAVG.Memory[166], MEM_WAVG.Memory[167],
                MEM_WAVG.Memory[168], MEM_WAVG.Memory[169], MEM_WAVG.Memory[170], MEM_WAVG.Memory[171],
                MEM_WAVG.Memory[172], MEM_WAVG.Memory[173], MEM_WAVG.Memory[174], MEM_WAVG.Memory[175]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_WAVG.Memory[176], MEM_WAVG.Memory[177], MEM_WAVG.Memory[178], MEM_WAVG.Memory[179],
                MEM_WAVG.Memory[180],MEM_WAVG.Memory[181], MEM_WAVG.Memory[182], MEM_WAVG.Memory[183],
                MEM_WAVG.Memory[184], MEM_WAVG.Memory[185], MEM_WAVG.Memory[186], MEM_WAVG.Memory[187],
                MEM_WAVG.Memory[188], MEM_WAVG.Memory[189], MEM_WAVG.Memory[190], MEM_WAVG.Memory[191]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_WAVG.Memory[192], MEM_WAVG.Memory[193], MEM_WAVG.Memory[194], MEM_WAVG.Memory[195],
                MEM_WAVG.Memory[196],MEM_WAVG.Memory[197], MEM_WAVG.Memory[198], MEM_WAVG.Memory[199],
                MEM_WAVG.Memory[200], MEM_WAVG.Memory[201], MEM_WAVG.Memory[202], MEM_WAVG.Memory[203],
                MEM_WAVG.Memory[204], MEM_WAVG.Memory[205], MEM_WAVG.Memory[206], MEM_WAVG.Memory[207]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_WAVG.Memory[208], MEM_WAVG.Memory[209], MEM_WAVG.Memory[210], MEM_WAVG.Memory[211],
                MEM_WAVG.Memory[212],MEM_WAVG.Memory[213], MEM_WAVG.Memory[214], MEM_WAVG.Memory[215],
                MEM_WAVG.Memory[216], MEM_WAVG.Memory[217], MEM_WAVG.Memory[218], MEM_WAVG.Memory[219],
                MEM_WAVG.Memory[220], MEM_WAVG.Memory[221], MEM_WAVG.Memory[222], MEM_WAVG.Memory[223]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_WAVG.Memory[224], MEM_WAVG.Memory[225], MEM_WAVG.Memory[226], MEM_WAVG.Memory[227],
                MEM_WAVG.Memory[228],MEM_WAVG.Memory[229], MEM_WAVG.Memory[230], MEM_WAVG.Memory[231],
                MEM_WAVG.Memory[232], MEM_WAVG.Memory[233], MEM_WAVG.Memory[234], MEM_WAVG.Memory[235],
                MEM_WAVG.Memory[236], MEM_WAVG.Memory[237], MEM_WAVG.Memory[238], MEM_WAVG.Memory[239]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_WAVG.Memory[240], MEM_WAVG.Memory[241], MEM_WAVG.Memory[242], MEM_WAVG.Memory[243],
                MEM_WAVG.Memory[244],MEM_WAVG.Memory[245], MEM_WAVG.Memory[246], MEM_WAVG.Memory[247],
                MEM_WAVG.Memory[248], MEM_WAVG.Memory[249], MEM_WAVG.Memory[250], MEM_WAVG.Memory[251],
                MEM_WAVG.Memory[252], MEM_WAVG.Memory[253], MEM_WAVG.Memory[254], MEM_WAVG.Memory[255]);
    end
    else if (image_size_reg == 1) begin
        $display("%d %d %d %d %d %d %d %d ",
                MEM_WAVG.Memory[0], MEM_WAVG.Memory[1], MEM_WAVG.Memory[2], MEM_WAVG.Memory[3],
                MEM_WAVG.Memory[4],MEM_WAVG.Memory[5], MEM_WAVG.Memory[6], MEM_WAVG.Memory[7]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_WAVG.Memory[8], MEM_WAVG.Memory[9], MEM_WAVG.Memory[10], MEM_WAVG.Memory[11],
                MEM_WAVG.Memory[12],MEM_WAVG.Memory[13], MEM_WAVG.Memory[14], MEM_WAVG.Memory[15]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_WAVG.Memory[16], MEM_WAVG.Memory[17], MEM_WAVG.Memory[18], MEM_WAVG.Memory[19],
                MEM_WAVG.Memory[20],MEM_WAVG.Memory[21], MEM_WAVG.Memory[22], MEM_WAVG.Memory[23]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_WAVG.Memory[24], MEM_WAVG.Memory[25], MEM_WAVG.Memory[26], MEM_WAVG.Memory[27],
                MEM_WAVG.Memory[28],MEM_WAVG.Memory[29], MEM_WAVG.Memory[30], MEM_WAVG.Memory[31]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_WAVG.Memory[32], MEM_WAVG.Memory[33], MEM_WAVG.Memory[34], MEM_WAVG.Memory[35],
                MEM_WAVG.Memory[36],MEM_WAVG.Memory[37], MEM_WAVG.Memory[38], MEM_WAVG.Memory[39]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_WAVG.Memory[40], MEM_WAVG.Memory[41], MEM_WAVG.Memory[42], MEM_WAVG.Memory[43],
                MEM_WAVG.Memory[44],MEM_WAVG.Memory[45], MEM_WAVG.Memory[46], MEM_WAVG.Memory[47]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_WAVG.Memory[48], MEM_WAVG.Memory[49], MEM_WAVG.Memory[50], MEM_WAVG.Memory[51],
                MEM_WAVG.Memory[52],MEM_WAVG.Memory[53], MEM_WAVG.Memory[54], MEM_WAVG.Memory[55]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_WAVG.Memory[56], MEM_WAVG.Memory[57], MEM_WAVG.Memory[58], MEM_WAVG.Memory[59],
                MEM_WAVG.Memory[60],MEM_WAVG.Memory[61], MEM_WAVG.Memory[62], MEM_WAVG.Memory[63]);
    end
    else if (image_size_reg == 0) begin
        $display("%d %d %d %d", MEM_WAVG.Memory[0], MEM_WAVG.Memory[1], MEM_WAVG.Memory[2], MEM_WAVG.Memory[3]);
        $display("%d %d %d %d", MEM_WAVG.Memory[4], MEM_WAVG.Memory[5], MEM_WAVG.Memory[6], MEM_WAVG.Memory[7]);
        $display("%d %d %d %d", MEM_WAVG.Memory[8], MEM_WAVG.Memory[9], MEM_WAVG.Memory[10], MEM_WAVG.Memory[11]);
        $display("%d %d %d %d", MEM_WAVG.Memory[12], MEM_WAVG.Memory[13], MEM_WAVG.Memory[14], MEM_WAVG.Memory[15]);
    end
    $display("===============WAVG_MEM memory==================");
endtask;

task print_INTER_reg;
	$display("===============INTER_REG memory==================");
	if (image_size_reg == 2) begin
		for (integer i = 0 ; i < 16 ; i = i + 1) begin
			$display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d",
					INTER[0 + i*16], INTER[1 + i*16], INTER[2 + i*16], INTER[3 + i*16],
					INTER[4 + i*16],INTER[5 + i*16], INTER[6 + i*16], INTER[7 + i*16],
					INTER[8 + i*16], INTER[9 + i*16], INTER[10 + i*16], INTER[11 + i*16],
					INTER[12 + i*16], INTER[13 + i*16], INTER[14 + i*16], INTER[15 + i*16]);
		end
	end
	else if (image_size_reg == 1) begin
		for (integer i = 0 ;i < 8 ; i = i + 1) begin
			$display("%d %d %d %d %d %d %d %d",
					INTER[0 + i*8], INTER[1 + i*8], INTER[2 + i*8], INTER[3 + i*8],
					INTER[4 + i*8],INTER[5 + i*8], INTER[6 + i*8], INTER[7 + i*8]);
		end
	end
	else if (image_size_reg == 0) begin
		for (integer i = 0; i < 4 ; i = i + 1) begin
			$display("%d %d %d %d",
					INTER[0 + i*4], INTER[1 + i*4], INTER[2 + i*4], INTER[3 + i*4]);
		end
	end
			
endtask;
// synopsys translate_on
endmodule