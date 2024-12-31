module CLK_1_MODULE (
    clk,
    rst_n,
    in_valid,
	in_row,
    in_kernel,
    out_idle,
    handshake_sready,
    handshake_din,

    flag_handshake_to_clk1,
    flag_clk1_to_handshake,

	fifo_empty,
    fifo_rdata,
    fifo_rinc,
    out_valid,
    out_data,

    flag_clk1_to_fifo,
    flag_fifo_to_clk1
);
input clk; // pattern <->
input rst_n; // pattern <->
input in_valid; // pattern <->
input [17:0] in_row; // pattern <->
input [11:0] in_kernel; // pattern <->
input out_idle; // handshake <->
output reg handshake_sready; // handshake <->
output reg [29:0] handshake_din; // handshake <->
// You can use the the custom flag ports for your design
input  flag_handshake_to_clk1;
output flag_clk1_to_handshake;

input fifo_empty;
input [7:0] fifo_rdata;
output reg fifo_rinc;
output reg out_valid;
output reg [7:0] out_data;
// You can use the the custom flag ports for your design
output reg flag_clk1_to_fifo;
input flag_fifo_to_clk1;



// FSM
parameter IDLE = 0, STORE_IN = 1, SEND = 2, RECEIVE = 3;
reg [1:0] current_state, next_state;
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end

reg [17:0] in_row_buf;
reg [11:0] in_kernel_buf;
reg in_valid_buf;
always @(posedge clk) begin
    in_row_buf <= in_row;
    in_kernel_buf <= in_kernel;
    in_valid_buf <= in_valid;
end

reg [17:0] image [0:5];
reg [11:0] kernel [0:5];
reg [17:0] image_next [0:5];
reg [11:0] kernel_next [0:5];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        image <= {0,0,0,0,0,0};
        kernel <= {0,0,0,0,0,0};
    end 
    else begin
        image <= image_next;
        kernel <= kernel_next;
    end
end

// ========= hand shake ==========
reg out_idle_buf;
reg out_idle_buf_buf;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_idle_buf <= 0;
        out_idle_buf_buf <= 0;
    end
    else begin
        out_idle_buf_buf <= out_idle_buf;
        out_idle_buf <= out_idle;
    end
end
// cnt to remember how many data has been sent
reg [3:0] cnt, cnt_next;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 0;
    end else begin
        cnt <= cnt_next;
    end
end

reg handshake_sready_next;
reg [29:0] handshake_din_next;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        handshake_sready <= 0;
        handshake_din <= 0;
    end else begin
        handshake_sready <= handshake_sready_next;
        handshake_din <= handshake_din_next;
    end
end

// ========= FIFO ==========
reg fifo_rinc_buf, fifo_rinc_buf_buf;
always @(posedge clk) begin
    fifo_rinc_buf_buf <= fifo_rinc_buf;
    fifo_rinc_buf <= fifo_rinc;
end

always @(*) begin
    image_next = image;
    kernel_next = kernel;
    next_state = current_state;

    out_valid = 0;
    out_data = 0;

    cnt_next = cnt;

    handshake_sready_next = handshake_sready;
    handshake_din_next = handshake_din;

    fifo_rinc = 0;

    case (current_state)
    IDLE: begin
        if (in_valid) begin
            next_state = STORE_IN;
        end
    end
    STORE_IN: begin
        image_next[0:4] = image[1:5];
        kernel_next[0:4] = kernel[1:5];
        image_next[5] = in_row_buf;
        kernel_next[5] = in_kernel_buf;
        if (!in_valid) begin
            next_state = SEND;
        end
    end
    SEND: begin
        if (out_idle_buf_buf && out_idle_buf) begin
            if (cnt < 6) begin
                // send data
                handshake_sready_next = 1;
                handshake_din_next = {image[0], kernel[0]};
            end
        end
        else if (out_idle_buf_buf && !out_idle_buf) begin
            handshake_sready_next = 0;
            handshake_din_next = handshake_din;
            image_next[0:4] = image[1:5];
            kernel_next[0:4] = kernel[1:5];
            cnt_next = cnt + 1;
        end
        if (cnt == 6) begin
            cnt_next = 0;
            next_state = RECEIVE;
        end
    end
    RECEIVE: begin
        fifo_rinc = !fifo_empty;
        if (in_valid) begin
            out_valid = 0;
            out_data = 0;
            next_state = STORE_IN;
        end
        if (fifo_rinc_buf_buf) begin
            out_valid = 1;
            out_data = fifo_rdata;
        end
    end
    endcase
end

endmodule

module CLK_2_MODULE (
    clk,
    rst_n,
    in_valid,
    fifo_full,
    in_data,
    out_valid,
    out_data,
    busy,

    flag_handshake_to_clk2,
    flag_clk2_to_handshake,

    flag_fifo_to_clk2,
    flag_clk2_to_fifo
);

input clk; // pattern <->
input rst_n; // pattern <->
input in_valid; // handshake <->
input fifo_full; // fifo <->
input [29:0] in_data; // handshake <->
output reg out_valid; // fifo <->
output reg [7:0] out_data; // fifo <->
output busy; // handshake <->

// You can use the the custom flag ports for your design
input  flag_handshake_to_clk2; 
output flag_clk2_to_handshake;

input  flag_fifo_to_clk2;
output flag_clk2_to_fifo;

assign busy = 0; // always ready to receive data

parameter IDLE = 0, CAL = 1, OUT = 2;
reg [1:0] current_state, next_state;
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end

reg [3:0] cnt, cnt_next;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 0;
    end else begin
        cnt <= cnt_next;
    end
end

reg [29:0] in_data_buf;
reg in_valid_buf, in_valid_buf_buf;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_valid_buf <= 0;
        in_valid_buf_buf <= 0;
        in_data_buf <= 0;
    end
    else begin
        in_valid_buf_buf <= in_valid_buf;
        in_valid_buf <= in_valid;
        in_data_buf <= in_data;
    end
end

reg [2:0] image [0:35];
reg [2:0] kernel [0:5][0:3]; // 6 channel, 4 element

reg [2:0] image_next [0:35];
reg [2:0] kernel_next [0:5][0:3]; // 6 channel, 4 element

always @(posedge clk) begin
    image <= image_next;
    kernel <= kernel_next;
end


reg [3:0] r_cnt, c_cnt;
reg [3:0] r_cnt_next, c_cnt_next;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        r_cnt <= 0;
        c_cnt <= 0;
    end 
    else begin
        r_cnt <= r_cnt_next;
        c_cnt <= c_cnt_next;
    end
end

// ========= fifo ==========
reg [7:0] out_cnt, out_cnt_next;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_cnt <= 0;
    end else begin
        out_cnt <= out_cnt_next;
    end
end

// reg out_valid_next;
// reg [7:0] out_data_next;

// always @(posedge clk or negedge rst_n) begin
//     if (!rst_n) begin
//         out_valid <= 0;
//         out_data <= 0;
//     end else begin
//         out_valid <= out_valid_next;
//         out_data <= out_data_next;
//     end
// end

always @(*) begin
    image_next = image;
    kernel_next = kernel;
    next_state = current_state;

    cnt_next = cnt;
    r_cnt_next = r_cnt;
    c_cnt_next = c_cnt;

    out_cnt_next = out_cnt;

    out_valid = 0;
    out_data = 0;

    case (current_state)
    IDLE: begin
        if (!in_valid && in_valid_buf) begin
            image_next[35] = in_data_buf[29:27];
            image_next[34] = in_data_buf[26:24];
            image_next[33] = in_data_buf[23:21];
            image_next[32] = in_data_buf[20:18];
            image_next[31] = in_data_buf[17:15];
            image_next[30] = in_data_buf[14:12];
            kernel_next[5][3] = in_data_buf[11:9];
            kernel_next[5][2] = in_data_buf[8:6];
            kernel_next[5][1] = in_data_buf[5:3];
            kernel_next[5][0] = in_data_buf[2:0];
            if (cnt == 5) begin
                cnt_next = 0;
                next_state = CAL;
                out_cnt_next = 0;
            end
        end
        else if (!in_valid_buf && in_valid_buf_buf) begin
            image_next[0:29] = image[6:35];
            kernel_next[0:4] = kernel[1:5];
            cnt_next = cnt + 1;
        end
    end
    CAL: begin
        out_data = image[0] * kernel[0][0] + 
                    image[1] * kernel[0][1] + 
                    image[6] * kernel[0][2] + 
                    image[7] * kernel[0][3];

        out_valid = 1;

        if (!fifo_full) begin
            out_cnt_next = out_cnt + 1;
            case (c_cnt)
            0,1,2,3: begin
                c_cnt_next = c_cnt + 1;
                // left shift one element
                image_next[0:34] = image[1:35];
                image_next[35] = image[0];
            end
            4: begin
                case (r_cnt)
                0,1,2,3: begin
                    // left shift two element
                    image_next[0:33] = image[2:35];
                    image_next[34:35] = image[0:1];
                    r_cnt_next = r_cnt + 1;
                    c_cnt_next = 0;
                end
                4: begin
                    // left shift eight element
                    image_next[0:27] = image[8:35];
                    image_next[28:35] = image[0:7];
                    kernel_next[0:4] = kernel[1:5];
                    r_cnt_next = 0;
                    c_cnt_next = 0;
                    cnt_next = cnt + 1;
                    if (cnt == 5) begin
                        cnt_next = 0;
                        r_cnt_next = 0;
                        c_cnt_next = 0;
                    end
                end
                endcase
            end
            endcase
        end
        else begin
            out_cnt_next = out_cnt;
            out_data = 0;
            out_valid = 0;
        end

        if (out_cnt == 150) begin
            next_state = IDLE;
            out_cnt_next = 0;
            cnt_next = 0;
            r_cnt_next = 0;
            c_cnt_next = 0;
            out_valid = 0;
            out_data = 0;
        end
    end
    endcase
end

endmodule