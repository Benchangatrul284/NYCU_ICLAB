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
          CENTER = 4'b0011, MAXPOOL = 4'b0100, FILTER = 4'b0101, CROSS = 4'b0111, OUTPUT = 4'b1000;

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

reg [7:0] MEM_INTER3_addr, MEM_INTER3_in;
wire [7:0] MEM_INTER3_out;
reg MEM_INTER3_web;
MEM_256_8 MEM_INTER3 (.DO0(MEM_INTER3_out[0]),.DO1(MEM_INTER3_out[1]),.DO2(MEM_INTER3_out[2]),.DO3(MEM_INTER3_out[3]),
                   .DO4(MEM_INTER3_out[4]),.DO5(MEM_INTER3_out[5]),.DO6(MEM_INTER3_out[6]),.DO7(MEM_INTER3_out[7]),
                   .DI0(MEM_INTER3_in[0]),.DI1(MEM_INTER3_in[1]),.DI2(MEM_INTER3_in[2]),.DI3(MEM_INTER3_in[3]),
                   .DI4(MEM_INTER3_in[4]),.DI5(MEM_INTER3_in[5]),.DI6(MEM_INTER3_in[6]),.DI7(MEM_INTER3_in[7]),
                   .A0(MEM_INTER3_addr[0]),.A1(MEM_INTER3_addr[1]),.A2(MEM_INTER3_addr[2]),.A3(MEM_INTER3_addr[3]),
                   .A4(MEM_INTER3_addr[4]),.A5(MEM_INTER3_addr[5]),.A6(MEM_INTER3_addr[6]),.A7(MEM_INTER3_addr[7]),
                   .WEB(MEM_INTER3_web),.CK(clk),.CS(1'b1),.OE(1'b1));

reg [7:0] MEM_INTER4_addr, MEM_INTER4_in;
wire [7:0] MEM_INTER4_out;
reg MEM_INTER4_web;
MEM_256_8 MEM_INTER4 (.DO0(MEM_INTER4_out[0]),.DO1(MEM_INTER4_out[1]),.DO2(MEM_INTER4_out[2]),.DO3(MEM_INTER4_out[3]),
                   .DO4(MEM_INTER4_out[4]),.DO5(MEM_INTER4_out[5]),.DO6(MEM_INTER4_out[6]),.DO7(MEM_INTER4_out[7]),
                   .DI0(MEM_INTER4_in[0]),.DI1(MEM_INTER4_in[1]),.DI2(MEM_INTER4_in[2]),.DI3(MEM_INTER4_in[3]),
                   .DI4(MEM_INTER4_in[4]),.DI5(MEM_INTER4_in[5]),.DI6(MEM_INTER4_in[6]),.DI7(MEM_INTER4_in[7]),
                   .A0(MEM_INTER4_addr[0]),.A1(MEM_INTER4_addr[1]),.A2(MEM_INTER4_addr[2]),.A3(MEM_INTER4_addr[3]),
                   .A4(MEM_INTER4_addr[4]),.A5(MEM_INTER4_addr[5]),.A6(MEM_INTER4_addr[6]),.A7(MEM_INTER4_addr[7]),
                   .WEB(MEM_INTER4_web),.CK(clk),.CS(1'b1),.OE(1'b1));

reg [7:0] MEM_OUTPUT_addr;
reg [19:0] MEM_OUTPUT_in;
wire [19:0] MEM_OUTPUT_out;
reg MEM_OUTPUT_web;
MEM_256_20 MEM_OUTPUT (.A0(MEM_OUTPUT_addr[0]),.A1(MEM_OUTPUT_addr[1]),.A2(MEM_OUTPUT_addr[2]),.A3(MEM_OUTPUT_addr[3]),
					   .A4(MEM_OUTPUT_addr[4]),.A5(MEM_OUTPUT_addr[5]),.A6(MEM_OUTPUT_addr[6]),.A7(MEM_OUTPUT_addr[7]),
					   .DO0(MEM_OUTPUT_out[0]),.DO1(MEM_OUTPUT_out[1]),.DO2(MEM_OUTPUT_out[2]),.DO3(MEM_OUTPUT_out[3]),
					   .DO4(MEM_OUTPUT_out[4]),.DO5(MEM_OUTPUT_out[5]),.DO6(MEM_OUTPUT_out[6]),.DO7(MEM_OUTPUT_out[7]),
					   .DO8(MEM_OUTPUT_out[8]),.DO9(MEM_OUTPUT_out[9]),.DO10(MEM_OUTPUT_out[10]),.DO11(MEM_OUTPUT_out[11]),
					   .DO12(MEM_OUTPUT_out[12]),.DO13(MEM_OUTPUT_out[13]),.DO14(MEM_OUTPUT_out[14]),.DO15(MEM_OUTPUT_out[15]),
					   .DO16(MEM_OUTPUT_out[16]),.DO17(MEM_OUTPUT_out[17]),.DO18(MEM_OUTPUT_out[18]),.DO19(MEM_OUTPUT_out[19]),
					   .DI0(MEM_OUTPUT_in[0]),.DI1(MEM_OUTPUT_in[1]),.DI2(MEM_OUTPUT_in[2]),.DI3(MEM_OUTPUT_in[3]),
					   .DI4(MEM_OUTPUT_in[4]),.DI5(MEM_OUTPUT_in[5]),.DI6(MEM_OUTPUT_in[6]),.DI7(MEM_OUTPUT_in[7]),
					   .DI8(MEM_OUTPUT_in[8]),.DI9(MEM_OUTPUT_in[9]),.DI10(MEM_OUTPUT_in[10]),.DI11(MEM_OUTPUT_in[11]),
					   .DI12(MEM_OUTPUT_in[12]),.DI13(MEM_OUTPUT_in[13]),.DI14(MEM_OUTPUT_in[14]),.DI15(MEM_OUTPUT_in[15]),
					   .DI16(MEM_OUTPUT_in[16]),.DI17(MEM_OUTPUT_in[17]),.DI18(MEM_OUTPUT_in[18]),.DI19(MEM_OUTPUT_in[19]),
					   .CK(clk),.WEB(MEM_OUTPUT_web),.OE(1'b1),.CS(1'b1));

// mux for MEM
reg [7:0] MEM_addr_src, MEM_addr_dest;
reg [7:0] MEM_in, MEM_out;
reg MEM_web;

// cross-correlation
reg [19:0] conv0, conv1, conv2, conv3, conv4, conv5, conv6, conv7, conv8;
reg [19:0] conv0_next, conv1_next, conv2_next, conv3_next, conv4_next, conv5_next, conv6_next, conv7_next, conv8_next;
reg [19:0] conv_result, conv_result_next;

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
reg [4:0] ans_cnt, ans_cnt_next;

reg [7:0] image_reg;
reg [7:0] gs_max_next, gs_max;
reg [9:0] gs_avg_next, gs_avg;
reg [7:0] gs_wavg_next, gs_wavg;

reg [1:0] image_size_next, image_size_reg;

reg out_valid_next, out_value_next;

reg read_image_flag, read_image_flag_next; // indicate whether it is the first cycle reading the image
reg first_act_flag, first_act_flag_next;

reg in_valid2_reg;

reg [2:0] action_reg;
reg [2:0] action_list [0:7];
reg [2:0] action_list_next [0:7];
reg [2:0] number_of_action, number_of_action_next;


reg negative_flag, negative_flag_next;
reg flip_flag, flip_flag_next;

reg [2:0] data_source, data_source_next;
reg [2:0] data_dest, data_dest_next;
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
    read_image_flag <= read_image_flag_next;
    action_list <= action_list_next;
    number_of_action <= number_of_action_next;
    first_act_flag <= first_act_flag_next;
    action_reg <= action;
    negative_flag <= negative_flag_next;
    flip_flag <= flip_flag_next;
    data_source <= data_source_next;
    data_dest <= data_dest_next;
end


always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        current_state <= IDLE;
        cnt <= 0;
        i_cnt <= 8'b1111_1111;
        rgb_cnt <= 0;
        set_cnt <= 0;
        act_cnt <= 0;
		ans_cnt <= 0;

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
		ans_cnt <= ans_cnt_next;

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
	out_valid_next = 0;
	out_value_next = 0;
	if (current_state == CROSS) begin
		if (i_cnt == 0 && cnt == 12)
	end
end
always @(*) begin
    next_state = current_state;
    rgb_cnt_next = rgb_cnt;
    i_cnt_next = i_cnt;
    cnt_next = cnt + 1;
    set_cnt_next = set_cnt;
    act_cnt_next = act_cnt;
	ans_cnt_next = ans_cnt;

    image_size_next = image_size_reg;

    // read mode
    MEM_MAX_web = 1;
    MEM_AVG_web = 1;
    MEM_WAVG_web = 1;
    MEM_INTER3_web = 1;
	MEM_INTER4_web = 1;
	MEM_OUTPUT_web = 1;

    MEM_MAX_addr = 0;
    MEM_AVG_addr = 0;
    MEM_WAVG_addr = 0;
    MEM_INTER3_addr = 0;
	MEM_INTER4_addr = 0;
	MEM_OUTPUT_addr = 0;

    MEM_AVG_in = 0;
    MEM_WAVG_in = 0;
    MEM_MAX_in = 0;
    MEM_INTER3_in = 0;
	MEM_INTER4_in = 0;
	MEM_OUTPUT_in = 0;

	// MUX
	MEM_addr_src = 0;
	MEM_addr_dest = 0;
	MEM_in = 0; 
	MEM_out = 0;
	MEM_web = 0;

    gs_max_next = gs_max;
    gs_avg_next = gs_avg;
    gs_wavg_next = gs_wavg;


    read_image_flag_next = read_image_flag;
	action_list_next = action_list;

    number_of_action_next = number_of_action;

    negative_flag_next = negative_flag;
    flip_flag_next = flip_flag;
    data_source_next = data_source;
    data_dest_next = data_dest;


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

                read_image_flag_next = 1;
                // check if go to next_state
                if (image_size_reg == 2 && i_cnt == 255 && read_image_flag == 1) begin
                    next_state = READ_ACT;
                    i_cnt_next = 0;
                    cnt_next = 0;
                    number_of_action_next = 0;
                    negative_flag_next = 0;
                    flip_flag_next = 0;
                end
                else if (image_size_reg == 1 && i_cnt == 63) begin
                    next_state = READ_ACT;
                    i_cnt_next = 0;
                    cnt_next = 0;
                    number_of_action_next = 0;
                    negative_flag_next = 0;
                    flip_flag_next = 0;
                end
                else if (image_size_reg == 0 && i_cnt == 15) begin
                    next_state = READ_ACT;
                    i_cnt_next = 0;
                    cnt_next = 0;
                    number_of_action_next = 0;
                    negative_flag_next = 0;
                    flip_flag_next = 0;
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
			case (action_reg)
			0: begin
				data_source_next = 0;
				data_dest_next = 3;
			end
			1: begin
				data_source_next = 1;
				data_dest_next = 3;
			end
			2: begin
				data_source_next = 2;
				data_dest_next = 3;
			end
			3,6: begin
				action_list_next[number_of_action] = action_reg;
				number_of_action_next = number_of_action + 1;
			end
			4: begin
				negative_flag_next = !negative_flag;
			end
			5: begin
				flip_flag_next = !flip_flag;
			end
			7: begin
				next_state = CENTER;
				// print_MAX_MEM;
				// print_AVG_MEM;
				// print_WAVG_MEM;
				$display("data_source = %d, data_dest = %d act_cnt = %d", data_source, data_dest, act_cnt);
			end
			endcase
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
			next_state = CROSS;
			cnt_next = 0;
		end
	end
	MAXPOOL: begin
		act_cnt_next = act_cnt + 1;
		next_state = CENTER;
		data_source_next = data_dest;
	end
	FILTER: begin
		act_cnt_next = act_cnt + 1;
		next_state = CENTER;
		data_source_next = data_dest;
	end
    CROSS: begin
		// get the output from dedicated sram
		case (data_source)
		0: MEM_out = MEM_MAX_out;
		1: MEM_out = MEM_AVG_out;
		2: MEM_out = MEM_WAVG_out;
		3: MEM_out = MEM_INTER3_out;
		4: MEM_out = MEM_INTER4_out;
		endcase

		cnt_next = cnt + 1;
		case(image_size_reg) 
		0: begin // 4*4
			case (i_cnt)
			0: begin
				case (cnt)
				0: begin
					MEM_addr_src = 0;
				end
				1: begin
					conv0_next = MEM_out;
					MEM_addr_src = 1;
				end
				2: begin
					conv1_next = MEM_out;
					conv0_next = conv0 * template_array[4];
					MEM_addr_src = 4;
				end
				3: begin
					conv4_next = MEM_out;
					conv1_next = conv1 * template_array[5];
					MEM_addr_src = 5;
				end
				4: begin
					conv5_next = MEM_out;
					conv4_next = conv4 * template_array[7];
				end
				5: begin
					conv5_next = conv5 * template_array[8];
				end
				6: begin
					conv_result_next = (conv0 + conv1) + (conv4 + conv5);
				end
				7: begin
					$display("i_cnt %d conv_result = %d", i_cnt, conv_result);
				end
				12: begin
					i_cnt_next = i_cnt + 1;
					cnt_next = 0;
				end
				endcase
			end
			1: begin
				case (cnt)
				0: begin
					MEM_addr_src = 0;
				end
				1: begin
					conv0_next = MEM_out;
					MEM_addr_src = 1;
				end
				2: begin
					conv1_next = MEM_out;
					MEM_addr_src = 2;
					conv0_next = conv0 * template_array[3];
				end
				3: begin
					conv2_next = MEM_out;
					MEM_addr_src = 4;
					conv1_next = conv1 * template_array[4];
				end
				4: begin
					conv4_next = MEM_out;
					MEM_addr_src = 5;
					conv2_next = conv2 * template_array[5];
				end
				5: begin
					conv5_next = MEM_out;
					MEM_addr_src = 6;
					conv4_next = conv4 * template_array[6];
				end
				6: begin
					conv6_next = MEM_out;
					conv5_next = conv5 * template_array[7];
				end
				7: begin
					conv6_next = conv6 * template_array[8];
					
				end
				8: begin
					conv_result_next = (conv0 + conv1) + (conv2 + conv4) + (conv5 + conv6);
				end
				9: begin
					$display("i_cnt %d conv_result = %d", i_cnt, conv_result);
				end
				12: begin
					i_cnt_next = i_cnt + 1;
					cnt_next = 0;
				end
				endcase
			end
			2: begin
				case (cnt)
				0: begin
					MEM_addr_src = 1;
				end
				1: begin
					MEM_addr_src = 2;
					conv1_next = MEM_out;
				end
				2: begin
					MEM_addr_src = 3;
					conv2_next = MEM_out;
					conv1_next = conv1 * template_array[3];
				end
				3: begin
					MEM_addr_src = 5;
					conv3_next = MEM_out;
					conv2_next = conv2 * template_array[4];
				end
				4: begin
					MEM_addr_src = 6;
					conv5_next = MEM_out;
					conv3_next = conv3 * template_array[5];
				end
				5: begin
					MEM_addr_src = 7;
					conv6_next = MEM_out;
					conv5_next = conv5 * template_array[6];
				end
				6: begin
					conv7_next = MEM_out;
					conv6_next = conv6 * template_array[7];
				end
				7: begin
					conv7_next = conv7 * template_array[8];
				end
				8: begin
					conv_result_next = (conv1 + conv2) + (conv3 + conv5) + (conv6 + conv7);
				end
				9: begin
					$display("i_cnt %d conv_result = %d", i_cnt, conv_result);
				end
				12: begin
					i_cnt_next = i_cnt + 1;
					cnt_next = 0;
				end
				endcase
			end
			3: begin
				case (cnt)
				0: begin
					MEM_addr_src = 2;
				end
				1: begin
					MEM_addr_src = 3;
					conv2_next = MEM_out;
				end
				2: begin
					MEM_addr_src = 6;
					conv3_next = MEM_out;
					conv2_next = conv2 * template_array[3];
				end
				3: begin
					MEM_addr_src = 7;
					conv6_next = MEM_out;
					conv3_next = conv3 * template_array[4];
				end
				4: begin
					conv7_next = MEM_out;
					conv6_next = conv6 * template_array[6];
				end
				5: begin
					conv7_next = conv7 * template_array[7];
				end
				6: begin
					conv_result_next = (conv2 + conv3) + (conv6 + conv7);
				end
				7: begin
					$display("i_cnt %d conv_result = %d", i_cnt, conv_result);
				end
				12: begin
					i_cnt_next = i_cnt + 1;
					cnt_next = 0;
				end
				endcase
			end
			4: begin
				case (cnt)
				0: begin
					MEM_addr_src = 0;
				end
				1: begin
					MEM_addr_src = 1;
					conv1_next = MEM_out;
				end
				2: begin
					MEM_addr_src = 4;
					conv2_next = MEM_out;
					conv1_next = conv1 * template_array[1];
				end
				3: begin
					MEM_addr_src = 5;
					conv4_next = MEM_out;
					conv2_next = conv2 * template_array[2];
				end
				4: begin
					MEM_addr_src = 8;
					conv5_next = MEM_out;
					conv4_next = conv4 * template_array[4];
				end
				5: begin
					MEM_addr_src = 9;
					conv7_next = MEM_out;
					conv5_next = conv5 * template_array[5];
				end
				6: begin
					conv8_next = MEM_out;
					conv7_next = conv7 * template_array[7];
				end
				7: begin
					conv8_next = conv8 * template_array[8];
				end
				8: begin
					conv_result_next = (conv1 + conv2) + (conv4 + conv5) + (conv7 + conv8);
				end
				9: begin
					$display("i_cnt %d conv_result = %d", i_cnt, conv_result);
				end
				12: begin
					i_cnt_next = i_cnt + 1;
					cnt_next = 0;
				end
				endcase
			end
			5: begin
				case (cnt)
				0: begin
					MEM_addr_src = 0;
				end
				1: begin
					MEM_addr_src = 1;
					conv0_next = MEM_out;
				end
				2: begin
					MEM_addr_src = 2;
					conv1_next = MEM_out;
					conv0_next = conv0 * template_array[0];
				end
				3: begin
					MEM_addr_src = 4;
					conv2_next = MEM_out;
					conv1_next = conv1 * template_array[1];
				end
				4: begin
					MEM_addr_src = 5;
					conv3_next = MEM_out;
					conv2_next = conv2 * template_array[2];
				end
				5: begin
					MEM_addr_src = 6;
					conv4_next = MEM_out;
					conv3_next = conv3 * template_array[3];
				end
				6: begin
					MEM_addr_src = 8;
					conv5_next = MEM_out;
					conv4_next = conv4 * template_array[4];
				end
				7: begin
					MEM_addr_src = 9;
					conv6_next = MEM_out;
					conv5_next = conv5 * template_array[5];
				end
				8: begin
					MEM_addr_src = 10;
					conv7_next = MEM_out;
					conv6_next = conv6 * template_array[6];
				end
				9: begin
					conv8_next = MEM_out;
					conv7_next = conv7 * template_array[7];
				end
				10: begin
					conv8_next = conv8 * template_array[8];
				end
				11: begin
					conv_result_next = (conv0 + conv1) + (conv2 + conv3) + (conv4 + conv5) + (conv6 + conv7) + conv8;
				end
				12: begin
					$display("i_cnt %d conv_result = %d", i_cnt, conv_result);
					cnt_next = 0;
					i_cnt_next = i_cnt + 1;
				end
				endcase
			end
			6: begin
				case (cnt)
				0: begin
					MEM_addr_src = 1;
				end
				1: begin
					MEM_addr_src = 2;
					conv0_next = MEM_out;
				end
				2: begin
					MEM_addr_src = 3;
					conv1_next = MEM_out;
					conv0_next = conv0 * template_array[0];
				end
				3: begin
					MEM_addr_src = 5;
					conv2_next = MEM_out;
					conv1_next = conv1 * template_array[1];
				end
				4: begin
					MEM_addr_src = 6;
					conv3_next = MEM_out;
					conv2_next = conv2 * template_array[2];
				end
				5: begin
					MEM_addr_src = 7;
					conv4_next = MEM_out;
					conv3_next = conv3 * template_array[3];
				end
				6: begin
					MEM_addr_src = 9;
					conv5_next = MEM_out;
					conv4_next = conv4 * template_array[4];
				end
				7: begin
					MEM_addr_src = 10;
					conv6_next = MEM_out;
					conv5_next = conv5 * template_array[5];
				end
				8: begin
					MEM_addr_src = 11;
					conv7_next = MEM_out;
					conv6_next = conv6 * template_array[6];
				end
				9: begin
					conv8_next = MEM_out;
					conv7_next = conv7 * template_array[7];
				end
				10: begin
					conv8_next = conv8 * template_array[8];
				end
				11: begin
					conv_result_next = (conv0 + conv1) + (conv2 + conv3) + (conv4 + conv5) + (conv6 + conv7) + conv8;
				end
				12: begin
					$display("i_cnt %d conv_result = %d", i_cnt, conv_result);
					cnt_next = 0;
					i_cnt_next = i_cnt + 1;
				end
				endcase
			end
			7: begin
				case (cnt)
				0: begin
					MEM_addr_src = 2;
				end
				1: begin
					MEM_addr_src = 3;
					conv0_next = MEM_out;
				end
				2: begin
					MEM_addr_src = 6;
					conv1_next = MEM_out;
					conv0_next = conv0 * template_array[0];
				end
				3: begin
					MEM_addr_src = 7;
					conv3_next = MEM_out;
					conv1_next = conv1 * template_array[1];
				end
				4: begin
					MEM_addr_src = 10;
					conv4_next = MEM_out;
					conv3_next = conv3 * template_array[3];
				end
				5: begin
					MEM_addr_src = 11;
					conv6_next = MEM_out;
					conv4_next = conv4 * template_array[4];
				end
				6: begin
					conv7_next = MEM_out;
					conv6_next = conv6 * template_array[6];
				end
				7: begin
					conv7_next = conv7 * template_array[7];
				end
				8: begin
					conv_result_next = (conv0 + conv1) + (conv3 + conv4) + (conv6 + conv7);
				end
				9: begin
					$display("i_cnt %d conv_result = %d", i_cnt, conv_result);
				end
				12: begin
					i_cnt_next = i_cnt + 1;
					cnt_next = 0;
				end
				endcase
			end
			8: begin
				case (cnt)
				0: begin
					MEM_addr_src = 4;
				end
				1: begin
					MEM_addr_src = 5;
					conv1_next = MEM_out;
				end
				2: begin
					MEM_addr_src = 8;
					conv2_next = MEM_out;
					conv1_next = conv1 * template_array[1];
				end
				3: begin
					MEM_addr_src = 9;
					conv4_next = MEM_out;
					conv2_next = conv2 * template_array[2];
				end
				4: begin
					MEM_addr_src = 12;
					conv5_next = MEM_out;
					conv4_next = conv4 * template_array[4];
				end
				5: begin
					MEM_addr_src = 13;
					conv7_next = MEM_out;
					conv5_next = conv5 * template_array[5];
				end
				6: begin
					conv8_next = MEM_out;
					conv7_next = conv7 * template_array[7];
				end
				7: begin
					conv8_next = conv8 * template_array[8];
				end
				8: begin
					conv_result_next = (conv1 + conv2) + (conv4 + conv5) + (conv7 + conv8);
				end
				9: begin
					$display("i_cnt %d conv_result = %d", i_cnt, conv_result);
				end
				12: begin
					i_cnt_next = i_cnt + 1;
					cnt_next = 0;
				end
				endcase
			end
			9: begin
				case (cnt)
				0: begin
					MEM_addr_src = 4;
				end
				1: begin
					MEM_addr_src = 5;
					conv0_next = MEM_out;
				end
				2: begin
					MEM_addr_src = 6;
					conv1_next = MEM_out;
					conv0_next = conv0 * template_array[0];
				end
				3: begin
					MEM_addr_src = 8;
					conv2_next = MEM_out;
					conv1_next = conv1 * template_array[1];
				end
				4: begin
					MEM_addr_src = 9;
					conv3_next = MEM_out;
					conv2_next = conv2 * template_array[2];
				end
				5: begin
					MEM_addr_src = 10;
					conv4_next = MEM_out;
					conv3_next = conv3 * template_array[3];
				end
				6: begin
					MEM_addr_src = 12;
					conv5_next = MEM_out;
					conv4_next = conv4 * template_array[4];
				end
				7: begin
					MEM_addr_src = 13;
					conv6_next = MEM_out;
					conv5_next = conv5 * template_array[5];
				end
				8: begin
					MEM_addr_src = 14;
					conv7_next = MEM_out;
					conv6_next = conv6 * template_array[6];
				end
				9: begin
					conv8_next = MEM_out;
					conv7_next = conv7 * template_array[7];
				end
				10: begin
					conv8_next = conv8 * template_array[8];
				end
				11: begin
					conv_result_next = (conv0 + conv1) + (conv2 + conv3) + (conv4 + conv5) + (conv6 + conv7) + conv8;
				end
				12: begin
					$display("i_cnt %d conv_result = %d", i_cnt, conv_result);
					cnt_next = 0;
					i_cnt_next = i_cnt + 1;
				end
				endcase
			end
			10: begin
				case (cnt)
				0: begin
					MEM_addr_src = 5;
				end
				1: begin
					MEM_addr_src = 6;
					conv0_next = MEM_out;
				end
				2: begin
					MEM_addr_src = 7;
					conv1_next = MEM_out;
					conv0_next = conv0 * template_array[0];
				end
				3: begin
					MEM_addr_src = 9;
					conv2_next = MEM_out;
					conv1_next = conv1 * template_array[1];
				end
				4: begin
					MEM_addr_src = 10;
					conv3_next = MEM_out;
					conv2_next = conv2 * template_array[2];
				end
				5: begin
					MEM_addr_src = 11;
					conv4_next = MEM_out;
					conv3_next = conv3 * template_array[3];
				end
				6: begin
					MEM_addr_src = 13;
					conv5_next = MEM_out;
					conv4_next = conv4 * template_array[4];
				end
				7: begin
					MEM_addr_src = 14;
					conv6_next = MEM_out;
					conv5_next = conv5 * template_array[5];
				end
				8: begin
					MEM_addr_src = 15;
					conv7_next = MEM_out;
					conv6_next = conv6 * template_array[6];
				end
				9: begin
					conv8_next = MEM_out;
					conv7_next = conv7 * template_array[7];
				end
				10: begin
					conv8_next = conv8 * template_array[8];
				end
				11: begin
					conv_result_next = (conv0 + conv1) + (conv2 + conv3) + (conv4 + conv5) + (conv6 + conv7) + conv8;
				end
				12: begin
					$display("i_cnt %d conv_result = %d", i_cnt, conv_result);
					cnt_next = 0;
					i_cnt_next = i_cnt + 1;
				end
				endcase
			end
			11: begin
				case (cnt)
				0: begin
					MEM_addr_src = 6;
				end
				1: begin
					MEM_addr_src = 7;
					conv0_next = MEM_out;
				end
				2: begin
					MEM_addr_src = 10;
					conv1_next = MEM_out;
					conv0_next = conv0 * template_array[0];
				end
				3: begin
					MEM_addr_src = 11;
					conv3_next = MEM_out;
					conv1_next = conv1 * template_array[1];
				end
				4: begin
					MEM_addr_src = 14;
					conv4_next = MEM_out;
					conv3_next = conv3 * template_array[3];
				end
				5: begin
					MEM_addr_src = 15;
					conv6_next = MEM_out;
					conv4_next = conv4 * template_array[4];
				end
				6: begin
					conv7_next = MEM_out;
					conv6_next = conv6 * template_array[6];
				end
				7: begin
					conv7_next = conv7 * template_array[7];
				end
				8: begin
					conv_result_next = (conv0 + conv1) + (conv3 + conv4) + (conv6 + conv7);
				end
				9: begin
					$display("i_cnt %d conv_result = %d", i_cnt, conv_result);
					cnt_next = 0;
					i_cnt_next = i_cnt + 1;
				end
				12: begin
					i_cnt_next = i_cnt + 1;
					cnt_next = 0;
				end
				endcase
			end
			12: begin
				case (cnt)
				0: begin
					MEM_addr_src = 8;
				end
				1: begin
					MEM_addr_src = 9;
					conv1_next = MEM_out;
				end
				2: begin
					MEM_addr_src = 12;
					conv2_next = MEM_out;
					conv1_next = conv1 * template_array[1];
				end
				3: begin
					MEM_addr_src = 13;
					conv4_next = MEM_out;
					conv2_next = conv2 * template_array[2];
				end
				4: begin
					conv5_next = MEM_out;
					conv4_next = conv4 * template_array[4];
				end
				5: begin
					conv5_next = conv5 * template_array[5];
				end
				6: begin
					conv_result_next = (conv1 + conv2) + (conv4 + conv5);
				end
				7: begin
					$display("i_cnt %d conv_result = %d", i_cnt, conv_result);
				end
				12: begin
					i_cnt_next = i_cnt + 1;
					cnt_next = 0;
				end
				endcase
			end
			13: begin
				case (cnt)
				0: begin
					MEM_addr_src = 8;
				end
				1: begin
					MEM_addr_src = 9;
					conv0_next = MEM_out;
				end
				2: begin
					MEM_addr_src = 10;
					conv1_next = MEM_out;
					conv0_next = conv0 * template_array[0];
				end
				3: begin
					MEM_addr_src = 12;
					conv2_next = MEM_out;
					conv1_next = conv1 * template_array[1];
				end
				4: begin
					MEM_addr_src = 13;
					conv3_next = MEM_out;
					conv2_next = conv2 * template_array[2];
				end
				5: begin
					MEM_addr_src = 14;
					conv4_next = MEM_out;
					conv3_next = conv3 * template_array[3];
				end
				6: begin
					conv5_next = MEM_out;
					conv4_next = conv4 * template_array[4];
				end
				7: begin
					conv5_next = conv5 * template_array[5];
				end
				8: begin
					conv_result_next = (conv0 + conv1) + (conv2 + conv3) + (conv4 + conv5);
				end
				9: begin
					$display("i_cnt %d conv_result = %d", i_cnt, conv_result);
				end
				12: begin
					i_cnt_next = i_cnt + 1;
					cnt_next = 0;
				end
				endcase
			end
			14: begin
				case (cnt)
				0: begin
					MEM_addr_src = 9;
				end
				1: begin
					MEM_addr_src = 10;
					conv0_next = MEM_out;
				end
				2: begin
					MEM_addr_src = 11;
					conv1_next = MEM_out;
					conv0_next = conv0 * template_array[0];
				end
				3: begin
					MEM_addr_src = 13;
					conv2_next = MEM_out;
					conv1_next = conv1 * template_array[1];
				end
				4: begin
					MEM_addr_src = 14;
					conv3_next = MEM_out;
					conv2_next = conv2 * template_array[2];
				end
				5: begin
					MEM_addr_src = 15;
					conv4_next = MEM_out;
					conv3_next = conv3 * template_array[3];
				end
				6: begin
					conv5_next = MEM_out;
					conv4_next = conv4 * template_array[4];
				end
				7: begin
					conv5_next = conv5 * template_array[5];
				end
				8: begin
					conv_result_next = (conv0 + conv1) + (conv2 + conv3) + (conv4 + conv5);
				end
				9: begin
					$display("i_cnt %d conv_result = %d", i_cnt, conv_result);
				end
				12: begin
					i_cnt_next = i_cnt + 1;
					cnt_next = 0;
				end
				endcase
			end
			15: begin
				case (cnt)
				0: begin
					MEM_addr_src = 10;
				end
				1: begin
					MEM_addr_src = 11;
					conv0_next = MEM_out;
				end
				2: begin
					MEM_addr_src = 14;
					conv1_next = MEM_out;
					conv0_next = conv0 * template_array[0];
				end
				3: begin
					MEM_addr_src = 15;
					conv3_next = MEM_out;
					conv1_next = conv1 * template_array[1];
				end
				4: begin
					conv4_next = MEM_out;
					conv3_next = conv3 * template_array[3];
				end
				5: begin
					conv4_next = conv4 * template_array[4];
				end
				6: begin
					conv_result_next = (conv0 + conv1) + (conv3 + conv4);
				end
				7: begin
					$display("i_cnt %d conv_result = %d", i_cnt, conv_result);
				end
				12: begin
					i_cnt_next = i_cnt + 1;
					cnt_next = 0;
				end
				endcase
			end
			endcase
		end
		endcase

		// set the address for reading SRAM
		case (data_source)
		0:	MEM_MAX_addr = MEM_addr_src;
		1:	MEM_AVG_addr = MEM_addr_src;
		2:	MEM_WAVG_addr = MEM_addr_src;
		3:	MEM_INTER3_addr = MEM_addr_src;
		4:	MEM_INTER4_addr = MEM_addr_src;
		endcase
		
	

		// set_cnt_next = set_cnt + 1;
		// if (set_cnt == 7) begin
		// 	next_state = IDLE;
		// end 
		// else begin
		// 	next_state = READ_ACT;
		// end
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

task print_INTER3_MEM;
    $display("===============INTER3_MEM memory==================");
    if (image_size_reg == 2) begin
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER3.Memory[0], MEM_INTER3.Memory[1], MEM_INTER3.Memory[2], MEM_INTER3.Memory[3],
                MEM_INTER3.Memory[4],MEM_INTER3.Memory[5], MEM_INTER3.Memory[6], MEM_INTER3.Memory[7],
                MEM_INTER3.Memory[8], MEM_INTER3.Memory[9], MEM_INTER3.Memory[10], MEM_INTER3.Memory[11],
                MEM_INTER3.Memory[12], MEM_INTER3.Memory[13], MEM_INTER3.Memory[14], MEM_INTER3.Memory[15]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER3.Memory[16], MEM_INTER3.Memory[17], MEM_INTER3.Memory[18], MEM_INTER3.Memory[19],
                MEM_INTER3.Memory[20],MEM_INTER3.Memory[21], MEM_INTER3.Memory[22], MEM_INTER3.Memory[23],
                MEM_INTER3.Memory[24], MEM_INTER3.Memory[25], MEM_INTER3.Memory[26], MEM_INTER3.Memory[27],
                MEM_INTER3.Memory[28], MEM_INTER3.Memory[29], MEM_INTER3.Memory[30], MEM_INTER3.Memory[31]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER3.Memory[32], MEM_INTER3.Memory[33], MEM_INTER3.Memory[34], MEM_INTER3.Memory[35],
                MEM_INTER3.Memory[36],MEM_INTER3.Memory[37], MEM_INTER3.Memory[38], MEM_INTER3.Memory[39],
                MEM_INTER3.Memory[40], MEM_INTER3.Memory[41], MEM_INTER3.Memory[42], MEM_INTER3.Memory[43],
                MEM_INTER3.Memory[44], MEM_INTER3.Memory[45], MEM_INTER3.Memory[46], MEM_INTER3.Memory[47]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER3.Memory[48], MEM_INTER3.Memory[49], MEM_INTER3.Memory[50], MEM_INTER3.Memory[51],
                MEM_INTER3.Memory[52],MEM_INTER3.Memory[53], MEM_INTER3.Memory[54], MEM_INTER3.Memory[55],
                MEM_INTER3.Memory[56], MEM_INTER3.Memory[57], MEM_INTER3.Memory[58], MEM_INTER3.Memory[59],
                MEM_INTER3.Memory[60], MEM_INTER3.Memory[61], MEM_INTER3.Memory[62], MEM_INTER3.Memory[63]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER3.Memory[64], MEM_INTER3.Memory[65], MEM_INTER3.Memory[66], MEM_INTER3.Memory[67],
                MEM_INTER3.Memory[68],MEM_INTER3.Memory[69], MEM_INTER3.Memory[70], MEM_INTER3.Memory[71],
                MEM_INTER3.Memory[72], MEM_INTER3.Memory[73], MEM_INTER3.Memory[74], MEM_INTER3.Memory[75],
                MEM_INTER3.Memory[76], MEM_INTER3.Memory[77], MEM_INTER3.Memory[78], MEM_INTER3.Memory[79]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER3.Memory[80], MEM_INTER3.Memory[81], MEM_INTER3.Memory[82], MEM_INTER3.Memory[83],
                MEM_INTER3.Memory[84],MEM_INTER3.Memory[85], MEM_INTER3.Memory[86], MEM_INTER3.Memory[87],
                MEM_INTER3.Memory[88], MEM_INTER3.Memory[89], MEM_INTER3.Memory[90], MEM_INTER3.Memory[91],
                MEM_INTER3.Memory[92], MEM_INTER3.Memory[93], MEM_INTER3.Memory[94], MEM_INTER3.Memory[95]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER3.Memory[96], MEM_INTER3.Memory[97], MEM_INTER3.Memory[98], MEM_INTER3.Memory[99],
                MEM_INTER3.Memory[100],MEM_INTER3.Memory[101], MEM_INTER3.Memory[102], MEM_INTER3.Memory[103],
                MEM_INTER3.Memory[104], MEM_INTER3.Memory[105], MEM_INTER3.Memory[106], MEM_INTER3.Memory[107],
                MEM_INTER3.Memory[108], MEM_INTER3.Memory[109], MEM_INTER3.Memory[110], MEM_INTER3.Memory[111]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER3.Memory[112], MEM_INTER3.Memory[113], MEM_INTER3.Memory[114], MEM_INTER3.Memory[115],
                MEM_INTER3.Memory[116],MEM_INTER3.Memory[117], MEM_INTER3.Memory[118], MEM_INTER3.Memory[119],
                MEM_INTER3.Memory[120], MEM_INTER3.Memory[121], MEM_INTER3.Memory[122], MEM_INTER3.Memory[123],
                MEM_INTER3.Memory[124], MEM_INTER3.Memory[125], MEM_INTER3.Memory[126], MEM_INTER3.Memory[127]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER3.Memory[128], MEM_INTER3.Memory[129], MEM_INTER3.Memory[130], MEM_INTER3.Memory[131],
                MEM_INTER3.Memory[132],MEM_INTER3.Memory[133], MEM_INTER3.Memory[134], MEM_INTER3.Memory[135],
                MEM_INTER3.Memory[136], MEM_INTER3.Memory[137], MEM_INTER3.Memory[138], MEM_INTER3.Memory[139],
                MEM_INTER3.Memory[140], MEM_INTER3.Memory[141], MEM_INTER3.Memory[142], MEM_INTER3.Memory[143]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER3.Memory[144], MEM_INTER3.Memory[145], MEM_INTER3.Memory[146], MEM_INTER3.Memory[147],
                MEM_INTER3.Memory[148],MEM_INTER3.Memory[149], MEM_INTER3.Memory[150], MEM_INTER3.Memory[151],
                MEM_INTER3.Memory[152], MEM_INTER3.Memory[153], MEM_INTER3.Memory[154], MEM_INTER3.Memory[155],
                MEM_INTER3.Memory[156], MEM_INTER3.Memory[157], MEM_INTER3.Memory[158], MEM_INTER3.Memory[159]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER3.Memory[160], MEM_INTER3.Memory[161], MEM_INTER3.Memory[162], MEM_INTER3.Memory[163],
                MEM_INTER3.Memory[164],MEM_INTER3.Memory[165], MEM_INTER3.Memory[166], MEM_INTER3.Memory[167],
                MEM_INTER3.Memory[168], MEM_INTER3.Memory[169], MEM_INTER3.Memory[170], MEM_INTER3.Memory[171],
                MEM_INTER3.Memory[172], MEM_INTER3.Memory[173], MEM_INTER3.Memory[174], MEM_INTER3.Memory[175]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER3.Memory[176], MEM_INTER3.Memory[177], MEM_INTER3.Memory[178], MEM_INTER3.Memory[179],
                MEM_INTER3.Memory[180],MEM_INTER3.Memory[181], MEM_INTER3.Memory[182], MEM_INTER3.Memory[183],
                MEM_INTER3.Memory[184], MEM_INTER3.Memory[185], MEM_INTER3.Memory[186], MEM_INTER3.Memory[187],
                MEM_INTER3.Memory[188], MEM_INTER3.Memory[189], MEM_INTER3.Memory[190], MEM_INTER3.Memory[191]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER3.Memory[192], MEM_INTER3.Memory[193], MEM_INTER3.Memory[194], MEM_INTER3.Memory[195],
                MEM_INTER3.Memory[196],MEM_INTER3.Memory[197], MEM_INTER3.Memory[198], MEM_INTER3.Memory[199],
                MEM_INTER3.Memory[200], MEM_INTER3.Memory[201], MEM_INTER3.Memory[202], MEM_INTER3.Memory[203],
                MEM_INTER3.Memory[204], MEM_INTER3.Memory[205], MEM_INTER3.Memory[206], MEM_INTER3.Memory[207]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER3.Memory[208], MEM_INTER3.Memory[209], MEM_INTER3.Memory[210], MEM_INTER3.Memory[211],
                MEM_INTER3.Memory[212],MEM_INTER3.Memory[213], MEM_INTER3.Memory[214], MEM_INTER3.Memory[215],
                MEM_INTER3.Memory[216], MEM_INTER3.Memory[217], MEM_INTER3.Memory[218], MEM_INTER3.Memory[219],
                MEM_INTER3.Memory[220], MEM_INTER3.Memory[221], MEM_INTER3.Memory[222], MEM_INTER3.Memory[223]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER3.Memory[224], MEM_INTER3.Memory[225], MEM_INTER3.Memory[226], MEM_INTER3.Memory[227],
                MEM_INTER3.Memory[228],MEM_INTER3.Memory[229], MEM_INTER3.Memory[230], MEM_INTER3.Memory[231],
                MEM_INTER3.Memory[232], MEM_INTER3.Memory[233], MEM_INTER3.Memory[234], MEM_INTER3.Memory[235],
                MEM_INTER3.Memory[236], MEM_INTER3.Memory[237], MEM_INTER3.Memory[238], MEM_INTER3.Memory[239]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER3.Memory[240], MEM_INTER3.Memory[241], MEM_INTER3.Memory[242], MEM_INTER3.Memory[243],
                MEM_INTER3.Memory[244],MEM_INTER3.Memory[245], MEM_INTER3.Memory[246], MEM_INTER3.Memory[247],
                MEM_INTER3.Memory[248], MEM_INTER3.Memory[249], MEM_INTER3.Memory[250], MEM_INTER3.Memory[251],
                MEM_INTER3.Memory[252], MEM_INTER3.Memory[253], MEM_INTER3.Memory[254], MEM_INTER3.Memory[255]);
    end
    else if (image_size_reg == 1) begin
        $display("%d %d %d %d %d %d %d %d ",
                MEM_INTER3.Memory[0], MEM_INTER3.Memory[1], MEM_INTER3.Memory[2], MEM_INTER3.Memory[3],
                MEM_INTER3.Memory[4],MEM_INTER3.Memory[5], MEM_INTER3.Memory[6], MEM_INTER3.Memory[7]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_INTER3.Memory[8], MEM_INTER3.Memory[9], MEM_INTER3.Memory[10], MEM_INTER3.Memory[11],
                MEM_INTER3.Memory[12],MEM_INTER3.Memory[13], MEM_INTER3.Memory[14], MEM_INTER3.Memory[15]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_INTER3.Memory[16], MEM_INTER3.Memory[17], MEM_INTER3.Memory[18], MEM_INTER3.Memory[19],
                MEM_INTER3.Memory[20],MEM_INTER3.Memory[21], MEM_INTER3.Memory[22], MEM_INTER3.Memory[23]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_INTER3.Memory[24], MEM_INTER3.Memory[25], MEM_INTER3.Memory[26], MEM_INTER3.Memory[27],
                MEM_INTER3.Memory[28],MEM_INTER3.Memory[29], MEM_INTER3.Memory[30], MEM_INTER3.Memory[31]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_INTER3.Memory[32], MEM_INTER3.Memory[33], MEM_INTER3.Memory[34], MEM_INTER3.Memory[35],
                MEM_INTER3.Memory[36],MEM_INTER3.Memory[37], MEM_INTER3.Memory[38], MEM_INTER3.Memory[39]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_INTER3.Memory[40], MEM_INTER3.Memory[41], MEM_INTER3.Memory[42], MEM_INTER3.Memory[43],
                MEM_INTER3.Memory[44],MEM_INTER3.Memory[45], MEM_INTER3.Memory[46], MEM_INTER3.Memory[47]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_INTER3.Memory[48], MEM_INTER3.Memory[49], MEM_INTER3.Memory[50], MEM_INTER3.Memory[51],
                MEM_INTER3.Memory[52],MEM_INTER3.Memory[53], MEM_INTER3.Memory[54], MEM_INTER3.Memory[55]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_INTER3.Memory[56], MEM_INTER3.Memory[57], MEM_INTER3.Memory[58], MEM_INTER3.Memory[59],
                MEM_INTER3.Memory[60],MEM_INTER3.Memory[61], MEM_INTER3.Memory[62], MEM_INTER3.Memory[63]);
    end
    else if (image_size_reg == 0) begin
        $display("%d %d %d %d", MEM_INTER3.Memory[0], MEM_INTER3.Memory[1], MEM_INTER3.Memory[2], MEM_INTER3.Memory[3]);
        $display("%d %d %d %d", MEM_INTER3.Memory[4], MEM_INTER3.Memory[5], MEM_INTER3.Memory[6], MEM_INTER3.Memory[7]);
        $display("%d %d %d %d", MEM_INTER3.Memory[8], MEM_INTER3.Memory[9], MEM_INTER3.Memory[10], MEM_INTER3.Memory[11]);
        $display("%d %d %d %d", MEM_INTER3.Memory[12], MEM_INTER3.Memory[13], MEM_INTER3.Memory[14], MEM_INTER3.Memory[15]);
    end
    $display("===============INTER3_MEM memory==================");
endtask;

task print_INTER4_MEM;
    $display("===============INTER4_MEM memory==================");
    if (image_size_reg == 2) begin
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER4.Memory[0], MEM_INTER4.Memory[1], MEM_INTER4.Memory[2], MEM_INTER4.Memory[3],
                MEM_INTER4.Memory[4],MEM_INTER4.Memory[5], MEM_INTER4.Memory[6], MEM_INTER4.Memory[7],
                MEM_INTER4.Memory[8], MEM_INTER4.Memory[9], MEM_INTER4.Memory[10], MEM_INTER4.Memory[11],
                MEM_INTER4.Memory[12], MEM_INTER4.Memory[13], MEM_INTER4.Memory[14], MEM_INTER4.Memory[15]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER4.Memory[16], MEM_INTER4.Memory[17], MEM_INTER4.Memory[18], MEM_INTER4.Memory[19],
                MEM_INTER4.Memory[20],MEM_INTER4.Memory[21], MEM_INTER4.Memory[22], MEM_INTER4.Memory[23],
                MEM_INTER4.Memory[24], MEM_INTER4.Memory[25], MEM_INTER4.Memory[26], MEM_INTER4.Memory[27],
                MEM_INTER4.Memory[28], MEM_INTER4.Memory[29], MEM_INTER4.Memory[30], MEM_INTER4.Memory[31]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER4.Memory[32], MEM_INTER4.Memory[33], MEM_INTER4.Memory[34], MEM_INTER4.Memory[35],
                MEM_INTER4.Memory[36],MEM_INTER4.Memory[37], MEM_INTER4.Memory[38], MEM_INTER4.Memory[39],
                MEM_INTER4.Memory[40], MEM_INTER4.Memory[41], MEM_INTER4.Memory[42], MEM_INTER4.Memory[43],
                MEM_INTER4.Memory[44], MEM_INTER4.Memory[45], MEM_INTER4.Memory[46], MEM_INTER4.Memory[47]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER4.Memory[48], MEM_INTER4.Memory[49], MEM_INTER4.Memory[50], MEM_INTER4.Memory[51],
                MEM_INTER4.Memory[52],MEM_INTER4.Memory[53], MEM_INTER4.Memory[54], MEM_INTER4.Memory[55],
                MEM_INTER4.Memory[56], MEM_INTER4.Memory[57], MEM_INTER4.Memory[58], MEM_INTER4.Memory[59],
                MEM_INTER4.Memory[60], MEM_INTER4.Memory[61], MEM_INTER4.Memory[62], MEM_INTER4.Memory[63]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER4.Memory[64], MEM_INTER4.Memory[65], MEM_INTER4.Memory[66], MEM_INTER4.Memory[67],
                MEM_INTER4.Memory[68],MEM_INTER4.Memory[69], MEM_INTER4.Memory[70], MEM_INTER4.Memory[71],
                MEM_INTER4.Memory[72], MEM_INTER4.Memory[73], MEM_INTER4.Memory[74], MEM_INTER4.Memory[75],
                MEM_INTER4.Memory[76], MEM_INTER4.Memory[77], MEM_INTER4.Memory[78], MEM_INTER4.Memory[79]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER4.Memory[80], MEM_INTER4.Memory[81], MEM_INTER4.Memory[82], MEM_INTER4.Memory[83],
                MEM_INTER4.Memory[84],MEM_INTER4.Memory[85], MEM_INTER4.Memory[86], MEM_INTER4.Memory[87],
                MEM_INTER4.Memory[88], MEM_INTER4.Memory[89], MEM_INTER4.Memory[90], MEM_INTER4.Memory[91],
                MEM_INTER4.Memory[92], MEM_INTER4.Memory[93], MEM_INTER4.Memory[94], MEM_INTER4.Memory[95]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER4.Memory[96], MEM_INTER4.Memory[97], MEM_INTER4.Memory[98], MEM_INTER4.Memory[99],
                MEM_INTER4.Memory[100],MEM_INTER4.Memory[101], MEM_INTER4.Memory[102], MEM_INTER4.Memory[103],
                MEM_INTER4.Memory[104], MEM_INTER4.Memory[105], MEM_INTER4.Memory[106], MEM_INTER4.Memory[107],
                MEM_INTER4.Memory[108], MEM_INTER4.Memory[109], MEM_INTER4.Memory[110], MEM_INTER4.Memory[111]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER4.Memory[112], MEM_INTER4.Memory[113], MEM_INTER4.Memory[114], MEM_INTER4.Memory[115],
                MEM_INTER4.Memory[116],MEM_INTER4.Memory[117], MEM_INTER4.Memory[118], MEM_INTER4.Memory[119],
                MEM_INTER4.Memory[120], MEM_INTER4.Memory[121], MEM_INTER4.Memory[122], MEM_INTER4.Memory[123],
                MEM_INTER4.Memory[124], MEM_INTER4.Memory[125], MEM_INTER4.Memory[126], MEM_INTER4.Memory[127]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER4.Memory[128], MEM_INTER4.Memory[129], MEM_INTER4.Memory[130], MEM_INTER4.Memory[131],
                MEM_INTER4.Memory[132],MEM_INTER4.Memory[133], MEM_INTER4.Memory[134], MEM_INTER4.Memory[135],
                MEM_INTER4.Memory[136], MEM_INTER4.Memory[137], MEM_INTER4.Memory[138], MEM_INTER4.Memory[139],
                MEM_INTER4.Memory[140], MEM_INTER4.Memory[141], MEM_INTER4.Memory[142], MEM_INTER4.Memory[143]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER4.Memory[144], MEM_INTER4.Memory[145], MEM_INTER4.Memory[146], MEM_INTER4.Memory[147],
                MEM_INTER4.Memory[148],MEM_INTER4.Memory[149], MEM_INTER4.Memory[150], MEM_INTER4.Memory[151],
                MEM_INTER4.Memory[152], MEM_INTER4.Memory[153], MEM_INTER4.Memory[154], MEM_INTER4.Memory[155],
                MEM_INTER4.Memory[156], MEM_INTER4.Memory[157], MEM_INTER4.Memory[158], MEM_INTER4.Memory[159]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER4.Memory[160], MEM_INTER4.Memory[161], MEM_INTER4.Memory[162], MEM_INTER4.Memory[163],
                MEM_INTER4.Memory[164],MEM_INTER4.Memory[165], MEM_INTER4.Memory[166], MEM_INTER4.Memory[167],
                MEM_INTER4.Memory[168], MEM_INTER4.Memory[169], MEM_INTER4.Memory[170], MEM_INTER4.Memory[171],
                MEM_INTER4.Memory[172], MEM_INTER4.Memory[173], MEM_INTER4.Memory[174], MEM_INTER4.Memory[175]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER4.Memory[176], MEM_INTER4.Memory[177], MEM_INTER4.Memory[178], MEM_INTER4.Memory[179],
                MEM_INTER4.Memory[180],MEM_INTER4.Memory[181], MEM_INTER4.Memory[182], MEM_INTER4.Memory[183],
                MEM_INTER4.Memory[184], MEM_INTER4.Memory[185], MEM_INTER4.Memory[186], MEM_INTER4.Memory[187],
                MEM_INTER4.Memory[188], MEM_INTER4.Memory[189], MEM_INTER4.Memory[190], MEM_INTER4.Memory[191]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER4.Memory[192], MEM_INTER4.Memory[193], MEM_INTER4.Memory[194], MEM_INTER4.Memory[195],
                MEM_INTER4.Memory[196],MEM_INTER4.Memory[197], MEM_INTER4.Memory[198], MEM_INTER4.Memory[199],
                MEM_INTER4.Memory[200], MEM_INTER4.Memory[201], MEM_INTER4.Memory[202], MEM_INTER4.Memory[203],
                MEM_INTER4.Memory[204], MEM_INTER4.Memory[205], MEM_INTER4.Memory[206], MEM_INTER4.Memory[207]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER4.Memory[208], MEM_INTER4.Memory[209], MEM_INTER4.Memory[210], MEM_INTER4.Memory[211],
                MEM_INTER4.Memory[212],MEM_INTER4.Memory[213], MEM_INTER4.Memory[214], MEM_INTER4.Memory[215],
                MEM_INTER4.Memory[216], MEM_INTER4.Memory[217], MEM_INTER4.Memory[218], MEM_INTER4.Memory[219],
                MEM_INTER4.Memory[220], MEM_INTER4.Memory[221], MEM_INTER4.Memory[222], MEM_INTER4.Memory[223]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER4.Memory[224], MEM_INTER4.Memory[225], MEM_INTER4.Memory[226], MEM_INTER4.Memory[227],
                MEM_INTER4.Memory[228],MEM_INTER4.Memory[229], MEM_INTER4.Memory[230], MEM_INTER4.Memory[231],
                MEM_INTER4.Memory[232], MEM_INTER4.Memory[233], MEM_INTER4.Memory[234], MEM_INTER4.Memory[235],
                MEM_INTER4.Memory[236], MEM_INTER4.Memory[237], MEM_INTER4.Memory[238], MEM_INTER4.Memory[239]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_INTER4.Memory[240], MEM_INTER4.Memory[241], MEM_INTER4.Memory[242], MEM_INTER4.Memory[243],
                MEM_INTER4.Memory[244],MEM_INTER4.Memory[245], MEM_INTER4.Memory[246], MEM_INTER4.Memory[247],
                MEM_INTER4.Memory[248], MEM_INTER4.Memory[249], MEM_INTER4.Memory[250], MEM_INTER4.Memory[251],
                MEM_INTER4.Memory[252], MEM_INTER4.Memory[253], MEM_INTER4.Memory[254], MEM_INTER4.Memory[255]);
    end
    else if (image_size_reg == 1) begin
        $display("%d %d %d %d %d %d %d %d ",
                MEM_INTER4.Memory[0], MEM_INTER4.Memory[1], MEM_INTER4.Memory[2], MEM_INTER4.Memory[3],
                MEM_INTER4.Memory[4],MEM_INTER4.Memory[5], MEM_INTER4.Memory[6], MEM_INTER4.Memory[7]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_INTER4.Memory[8], MEM_INTER4.Memory[9], MEM_INTER4.Memory[10], MEM_INTER4.Memory[11],
                MEM_INTER4.Memory[12],MEM_INTER4.Memory[13], MEM_INTER4.Memory[14], MEM_INTER4.Memory[15]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_INTER4.Memory[16], MEM_INTER4.Memory[17], MEM_INTER4.Memory[18], MEM_INTER4.Memory[19],
                MEM_INTER4.Memory[20],MEM_INTER4.Memory[21], MEM_INTER4.Memory[22], MEM_INTER4.Memory[23]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_INTER4.Memory[24], MEM_INTER4.Memory[25], MEM_INTER4.Memory[26], MEM_INTER4.Memory[27],
                MEM_INTER4.Memory[28],MEM_INTER4.Memory[29], MEM_INTER4.Memory[30], MEM_INTER4.Memory[31]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_INTER4.Memory[32], MEM_INTER4.Memory[33], MEM_INTER4.Memory[34], MEM_INTER4.Memory[35],
                MEM_INTER4.Memory[36],MEM_INTER4.Memory[37], MEM_INTER4.Memory[38], MEM_INTER4.Memory[39]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_INTER4.Memory[40], MEM_INTER4.Memory[41], MEM_INTER4.Memory[42], MEM_INTER4.Memory[43],
                MEM_INTER4.Memory[44],MEM_INTER4.Memory[45], MEM_INTER4.Memory[46], MEM_INTER4.Memory[47]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_INTER4.Memory[48], MEM_INTER4.Memory[49], MEM_INTER4.Memory[50], MEM_INTER4.Memory[51],
                MEM_INTER4.Memory[52],MEM_INTER4.Memory[53], MEM_INTER4.Memory[54], MEM_INTER4.Memory[55]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_INTER4.Memory[56], MEM_INTER4.Memory[57], MEM_INTER4.Memory[58], MEM_INTER4.Memory[59],
                MEM_INTER4.Memory[60],MEM_INTER4.Memory[61], MEM_INTER4.Memory[62], MEM_INTER4.Memory[63]);
    end
    else if (image_size_reg == 0) begin
        $display("%d %d %d %d", MEM_INTER4.Memory[0], MEM_INTER4.Memory[1], MEM_INTER4.Memory[2], MEM_INTER4.Memory[3]);
        $display("%d %d %d %d", MEM_INTER4.Memory[4], MEM_INTER4.Memory[5], MEM_INTER4.Memory[6], MEM_INTER4.Memory[7]);
        $display("%d %d %d %d", MEM_INTER4.Memory[8], MEM_INTER4.Memory[9], MEM_INTER4.Memory[10], MEM_INTER4.Memory[11]);
        $display("%d %d %d %d", MEM_INTER4.Memory[12], MEM_INTER4.Memory[13], MEM_INTER4.Memory[14], MEM_INTER4.Memory[15]);
    end
    $display("===============INTER4_MEM memory==================");
endtask;

task print_OUTPUT_MEM;
    $display("===============OUTPUT_MEM memory==================");
    if (image_size_reg == 2) begin
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_OUTPUT.Memory[0], MEM_OUTPUT.Memory[1], MEM_OUTPUT.Memory[2], MEM_OUTPUT.Memory[3],
                MEM_OUTPUT.Memory[4],MEM_OUTPUT.Memory[5], MEM_OUTPUT.Memory[6], MEM_OUTPUT.Memory[7],
                MEM_OUTPUT.Memory[8], MEM_OUTPUT.Memory[9], MEM_OUTPUT.Memory[10], MEM_OUTPUT.Memory[11],
                MEM_OUTPUT.Memory[12], MEM_OUTPUT.Memory[13], MEM_OUTPUT.Memory[14], MEM_OUTPUT.Memory[15]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_OUTPUT.Memory[16], MEM_OUTPUT.Memory[17], MEM_OUTPUT.Memory[18], MEM_OUTPUT.Memory[19],
                MEM_OUTPUT.Memory[20],MEM_OUTPUT.Memory[21], MEM_OUTPUT.Memory[22], MEM_OUTPUT.Memory[23],
                MEM_OUTPUT.Memory[24], MEM_OUTPUT.Memory[25], MEM_OUTPUT.Memory[26], MEM_OUTPUT.Memory[27],
                MEM_OUTPUT.Memory[28], MEM_OUTPUT.Memory[29], MEM_OUTPUT.Memory[30], MEM_OUTPUT.Memory[31]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_OUTPUT.Memory[32], MEM_OUTPUT.Memory[33], MEM_OUTPUT.Memory[34], MEM_OUTPUT.Memory[35],
                MEM_OUTPUT.Memory[36],MEM_OUTPUT.Memory[37], MEM_OUTPUT.Memory[38], MEM_OUTPUT.Memory[39],
                MEM_OUTPUT.Memory[40], MEM_OUTPUT.Memory[41], MEM_OUTPUT.Memory[42], MEM_OUTPUT.Memory[43],
                MEM_OUTPUT.Memory[44], MEM_OUTPUT.Memory[45], MEM_OUTPUT.Memory[46], MEM_OUTPUT.Memory[47]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_OUTPUT.Memory[48], MEM_OUTPUT.Memory[49], MEM_OUTPUT.Memory[50], MEM_OUTPUT.Memory[51],
                MEM_OUTPUT.Memory[52],MEM_OUTPUT.Memory[53], MEM_OUTPUT.Memory[54], MEM_OUTPUT.Memory[55],
                MEM_OUTPUT.Memory[56], MEM_OUTPUT.Memory[57], MEM_OUTPUT.Memory[58], MEM_OUTPUT.Memory[59],
                MEM_OUTPUT.Memory[60], MEM_OUTPUT.Memory[61], MEM_OUTPUT.Memory[62], MEM_OUTPUT.Memory[63]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_OUTPUT.Memory[64], MEM_OUTPUT.Memory[65], MEM_OUTPUT.Memory[66], MEM_OUTPUT.Memory[67],
                MEM_OUTPUT.Memory[68],MEM_OUTPUT.Memory[69], MEM_OUTPUT.Memory[70], MEM_OUTPUT.Memory[71],
                MEM_OUTPUT.Memory[72], MEM_OUTPUT.Memory[73], MEM_OUTPUT.Memory[74], MEM_OUTPUT.Memory[75],
                MEM_OUTPUT.Memory[76], MEM_OUTPUT.Memory[77], MEM_OUTPUT.Memory[78], MEM_OUTPUT.Memory[79]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_OUTPUT.Memory[80], MEM_OUTPUT.Memory[81], MEM_OUTPUT.Memory[82], MEM_OUTPUT.Memory[83],
                MEM_OUTPUT.Memory[84],MEM_OUTPUT.Memory[85], MEM_OUTPUT.Memory[86], MEM_OUTPUT.Memory[87],
                MEM_OUTPUT.Memory[88], MEM_OUTPUT.Memory[89], MEM_OUTPUT.Memory[90], MEM_OUTPUT.Memory[91],
                MEM_OUTPUT.Memory[92], MEM_OUTPUT.Memory[93], MEM_OUTPUT.Memory[94], MEM_OUTPUT.Memory[95]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_OUTPUT.Memory[96], MEM_OUTPUT.Memory[97], MEM_OUTPUT.Memory[98], MEM_OUTPUT.Memory[99],
                MEM_OUTPUT.Memory[100],MEM_OUTPUT.Memory[101], MEM_OUTPUT.Memory[102], MEM_OUTPUT.Memory[103],
                MEM_OUTPUT.Memory[104], MEM_OUTPUT.Memory[105], MEM_OUTPUT.Memory[106], MEM_OUTPUT.Memory[107],
                MEM_OUTPUT.Memory[108], MEM_OUTPUT.Memory[109], MEM_OUTPUT.Memory[110], MEM_OUTPUT.Memory[111]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_OUTPUT.Memory[112], MEM_OUTPUT.Memory[113], MEM_OUTPUT.Memory[114], MEM_OUTPUT.Memory[115],
                MEM_OUTPUT.Memory[116],MEM_OUTPUT.Memory[117], MEM_OUTPUT.Memory[118], MEM_OUTPUT.Memory[119],
                MEM_OUTPUT.Memory[120], MEM_OUTPUT.Memory[121], MEM_OUTPUT.Memory[122], MEM_OUTPUT.Memory[123],
                MEM_OUTPUT.Memory[124], MEM_OUTPUT.Memory[125], MEM_OUTPUT.Memory[126], MEM_OUTPUT.Memory[127]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_OUTPUT.Memory[128], MEM_OUTPUT.Memory[129], MEM_OUTPUT.Memory[130], MEM_OUTPUT.Memory[131],
                MEM_OUTPUT.Memory[132],MEM_OUTPUT.Memory[133], MEM_OUTPUT.Memory[134], MEM_OUTPUT.Memory[135],
                MEM_OUTPUT.Memory[136], MEM_OUTPUT.Memory[137], MEM_OUTPUT.Memory[138], MEM_OUTPUT.Memory[139],
                MEM_OUTPUT.Memory[140], MEM_OUTPUT.Memory[141], MEM_OUTPUT.Memory[142], MEM_OUTPUT.Memory[143]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_OUTPUT.Memory[144], MEM_OUTPUT.Memory[145], MEM_OUTPUT.Memory[146], MEM_OUTPUT.Memory[147],
                MEM_OUTPUT.Memory[148],MEM_OUTPUT.Memory[149], MEM_OUTPUT.Memory[150], MEM_OUTPUT.Memory[151],
                MEM_OUTPUT.Memory[152], MEM_OUTPUT.Memory[153], MEM_OUTPUT.Memory[154], MEM_OUTPUT.Memory[155],
                MEM_OUTPUT.Memory[156], MEM_OUTPUT.Memory[157], MEM_OUTPUT.Memory[158], MEM_OUTPUT.Memory[159]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_OUTPUT.Memory[160], MEM_OUTPUT.Memory[161], MEM_OUTPUT.Memory[162], MEM_OUTPUT.Memory[163],
                MEM_OUTPUT.Memory[164],MEM_OUTPUT.Memory[165], MEM_OUTPUT.Memory[166], MEM_OUTPUT.Memory[167],
                MEM_OUTPUT.Memory[168], MEM_OUTPUT.Memory[169], MEM_OUTPUT.Memory[170], MEM_OUTPUT.Memory[171],
                MEM_OUTPUT.Memory[172], MEM_OUTPUT.Memory[173], MEM_OUTPUT.Memory[174], MEM_OUTPUT.Memory[175]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_OUTPUT.Memory[176], MEM_OUTPUT.Memory[177], MEM_OUTPUT.Memory[178], MEM_OUTPUT.Memory[179],
                MEM_OUTPUT.Memory[180],MEM_OUTPUT.Memory[181], MEM_OUTPUT.Memory[182], MEM_OUTPUT.Memory[183],
                MEM_OUTPUT.Memory[184], MEM_OUTPUT.Memory[185], MEM_OUTPUT.Memory[186], MEM_OUTPUT.Memory[187],
                MEM_OUTPUT.Memory[188], MEM_OUTPUT.Memory[189], MEM_OUTPUT.Memory[190], MEM_OUTPUT.Memory[191]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_OUTPUT.Memory[192], MEM_OUTPUT.Memory[193], MEM_OUTPUT.Memory[194], MEM_OUTPUT.Memory[195],
                MEM_OUTPUT.Memory[196],MEM_OUTPUT.Memory[197], MEM_OUTPUT.Memory[198], MEM_OUTPUT.Memory[199],
                MEM_OUTPUT.Memory[200], MEM_OUTPUT.Memory[201], MEM_OUTPUT.Memory[202], MEM_OUTPUT.Memory[203],
                MEM_OUTPUT.Memory[204], MEM_OUTPUT.Memory[205], MEM_OUTPUT.Memory[206], MEM_OUTPUT.Memory[207]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_OUTPUT.Memory[208], MEM_OUTPUT.Memory[209], MEM_OUTPUT.Memory[210], MEM_OUTPUT.Memory[211],
                MEM_OUTPUT.Memory[212],MEM_OUTPUT.Memory[213], MEM_OUTPUT.Memory[214], MEM_OUTPUT.Memory[215],
                MEM_OUTPUT.Memory[216], MEM_OUTPUT.Memory[217], MEM_OUTPUT.Memory[218], MEM_OUTPUT.Memory[219],
                MEM_OUTPUT.Memory[220], MEM_OUTPUT.Memory[221], MEM_OUTPUT.Memory[222], MEM_OUTPUT.Memory[223]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_OUTPUT.Memory[224], MEM_OUTPUT.Memory[225], MEM_OUTPUT.Memory[226], MEM_OUTPUT.Memory[227],
                MEM_OUTPUT.Memory[228],MEM_OUTPUT.Memory[229], MEM_OUTPUT.Memory[230], MEM_OUTPUT.Memory[231],
                MEM_OUTPUT.Memory[232], MEM_OUTPUT.Memory[233], MEM_OUTPUT.Memory[234], MEM_OUTPUT.Memory[235],
                MEM_OUTPUT.Memory[236], MEM_OUTPUT.Memory[237], MEM_OUTPUT.Memory[238], MEM_OUTPUT.Memory[239]);
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",
                MEM_OUTPUT.Memory[240], MEM_OUTPUT.Memory[241], MEM_OUTPUT.Memory[242], MEM_OUTPUT.Memory[243],
                MEM_OUTPUT.Memory[244],MEM_OUTPUT.Memory[245], MEM_OUTPUT.Memory[246], MEM_OUTPUT.Memory[247],
                MEM_OUTPUT.Memory[248], MEM_OUTPUT.Memory[249], MEM_OUTPUT.Memory[250], MEM_OUTPUT.Memory[251],
                MEM_OUTPUT.Memory[252], MEM_OUTPUT.Memory[253], MEM_OUTPUT.Memory[254], MEM_OUTPUT.Memory[255]);
    end
    else if (image_size_reg == 1) begin
        $display("%d %d %d %d %d %d %d %d ",
                MEM_OUTPUT.Memory[0], MEM_OUTPUT.Memory[1], MEM_OUTPUT.Memory[2], MEM_OUTPUT.Memory[3],
                MEM_OUTPUT.Memory[4],MEM_OUTPUT.Memory[5], MEM_OUTPUT.Memory[6], MEM_OUTPUT.Memory[7]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_OUTPUT.Memory[8], MEM_OUTPUT.Memory[9], MEM_OUTPUT.Memory[10], MEM_OUTPUT.Memory[11],
                MEM_OUTPUT.Memory[12],MEM_OUTPUT.Memory[13], MEM_OUTPUT.Memory[14], MEM_OUTPUT.Memory[15]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_OUTPUT.Memory[16], MEM_OUTPUT.Memory[17], MEM_OUTPUT.Memory[18], MEM_OUTPUT.Memory[19],
                MEM_OUTPUT.Memory[20],MEM_OUTPUT.Memory[21], MEM_OUTPUT.Memory[22], MEM_OUTPUT.Memory[23]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_OUTPUT.Memory[24], MEM_OUTPUT.Memory[25], MEM_OUTPUT.Memory[26], MEM_OUTPUT.Memory[27],
                MEM_OUTPUT.Memory[28],MEM_OUTPUT.Memory[29], MEM_OUTPUT.Memory[30], MEM_OUTPUT.Memory[31]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_OUTPUT.Memory[32], MEM_OUTPUT.Memory[33], MEM_OUTPUT.Memory[34], MEM_OUTPUT.Memory[35],
                MEM_OUTPUT.Memory[36],MEM_OUTPUT.Memory[37], MEM_OUTPUT.Memory[38], MEM_OUTPUT.Memory[39]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_OUTPUT.Memory[40], MEM_OUTPUT.Memory[41], MEM_OUTPUT.Memory[42], MEM_OUTPUT.Memory[43],
                MEM_OUTPUT.Memory[44],MEM_OUTPUT.Memory[45], MEM_OUTPUT.Memory[46], MEM_OUTPUT.Memory[47]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_OUTPUT.Memory[48], MEM_OUTPUT.Memory[49], MEM_OUTPUT.Memory[50], MEM_OUTPUT.Memory[51],
                MEM_OUTPUT.Memory[52],MEM_OUTPUT.Memory[53], MEM_OUTPUT.Memory[54], MEM_OUTPUT.Memory[55]);
        $display("%d %d %d %d %d %d %d %d ",
                MEM_OUTPUT.Memory[56], MEM_OUTPUT.Memory[57], MEM_OUTPUT.Memory[58], MEM_OUTPUT.Memory[59],
                MEM_OUTPUT.Memory[60],MEM_OUTPUT.Memory[61], MEM_OUTPUT.Memory[62], MEM_OUTPUT.Memory[63]);
    end
    else if (image_size_reg == 0) begin
        $display("%d %d %d %d", MEM_OUTPUT.Memory[0], MEM_OUTPUT.Memory[1], MEM_OUTPUT.Memory[2], MEM_OUTPUT.Memory[3]);
        $display("%d %d %d %d", MEM_OUTPUT.Memory[4], MEM_OUTPUT.Memory[5], MEM_OUTPUT.Memory[6], MEM_OUTPUT.Memory[7]);
        $display("%d %d %d %d", MEM_OUTPUT.Memory[8], MEM_OUTPUT.Memory[9], MEM_OUTPUT.Memory[10], MEM_OUTPUT.Memory[11]);
        $display("%d %d %d %d", MEM_OUTPUT.Memory[12], MEM_OUTPUT.Memory[13], MEM_OUTPUT.Memory[14], MEM_OUTPUT.Memory[15]);
    end
    $display("===============OUTPUT_MEM memory==================");
endtask;
// synopsys translate_on
endmodule



	