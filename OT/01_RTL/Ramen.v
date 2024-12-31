module Ramen(
    // Input Registers
    input clk, 
    input rst_n, 
    input in_valid,
    input selling,
    input portion, 
    input [1:0] ramen_type,

    // Output Signals
    output reg out_valid_order,
    output reg success,

    output reg out_valid_tot,
    output reg [27:0] sold_num,
    output reg [14:0] total_gain
);


//==============================================//
//             Parameter and Integer            //
//==============================================//

// ramen_type
parameter TONKOTSU = 0;
parameter TONKOTSU_SOY = 1;
parameter MISO = 2;
parameter MISO_SOY = 3;

// initial ingredient
parameter NOODLE_INIT = 12000;
parameter BROTH_INIT = 41000;
parameter TONKOTSU_SOUP_INIT =  9000;
parameter MISO_INIT = 1000;
parameter SOY_SAUSE_INIT = 1500;

//fsm
parameter IDLE = 0, READ = 1, CAL = 2, OUTPUT = 3;
//==============================================//
//                 reg declaration              //
//==============================================// 

reg [2:0] current_state, next_state;
reg [20:0] NOODLE_left, NOODLE_left_next;
reg [20:0] BROTH_left, BROTH_left_next;
reg [20:0] TONKOTSU_SOUP_left, TONKOTSU_SOUP_left_next;
reg [20:0] MISO_left, MISO_left_next;
reg [20:0] SOY_SAUSE_left, SOY_SAUSE_left_next;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= 0;
        NOODLE_left <= NOODLE_INIT;
        BROTH_left <= BROTH_INIT;
        TONKOTSU_SOUP_left <= TONKOTSU_SOUP_INIT;
        SOY_SAUSE_left <= SOY_SAUSE_INIT;
        MISO_left <= MISO_INIT;
    end
    else begin
        current_state <= next_state;
        NOODLE_left <= NOODLE_left_next;
        BROTH_left <= BROTH_left_next;
        TONKOTSU_SOUP_left <= TONKOTSU_SOUP_left_next;
        SOY_SAUSE_left <= SOY_SAUSE_left_next;
        MISO_left <= MISO_left_next;
    end
end

reg out_valid_order_next;
reg success_next;
reg out_valid_tot_next;
reg [27:0] sold_num_buf_next, sold_num_buf;
reg [14:0] total_gain_buf, total_gain_buf_next;
reg [27:0] sold_num_next;
reg [14:0] total_gain_next;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid_order <= 0;
        success <= 0;
        out_valid_tot <= 0;
        sold_num_buf <= 0;
        total_gain_buf <= 0;

        sold_num <= 0;
        total_gain <= 0;
    
    end else begin
        out_valid_order <= out_valid_order_next;
        success <= success_next;
        out_valid_tot <= out_valid_tot_next;

        sold_num_buf <= sold_num_buf_next;
        total_gain_buf <= total_gain_buf_next;

        sold_num <= sold_num_next;
        total_gain <= total_gain_next;
    end
end

reg in_valid_buf;
reg selling_buf;
reg selling_buf_buf;
reg portion_buf; 
reg [1:0] ramen_type_buf;
reg [1:0] ramen_type_buf_buf;
reg [1:0] ramen_type_buf_buf_buf;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_valid_buf <= 0;
        selling_buf <= 0;
        selling_buf_buf <= 0;
        portion_buf <= 0;
        ramen_type_buf <= 0;
        ramen_type_buf_buf <= 0;
        ramen_type_buf_buf_buf <= 0;
    end
    else begin
        in_valid_buf <= in_valid;
        selling_buf <= selling;
        selling_buf_buf <= selling_buf;
        portion_buf <= portion;
        ramen_type_buf <= ramen_type;
        ramen_type_buf_buf <= ramen_type_buf;
        ramen_type_buf_buf_buf <= ramen_type_buf_buf;
    end
end

reg [9:0] NOODLE_minus, NOODLE_minus_next;
reg [9:0] BROTH_minus, BROTH_minus_next;
reg [9:0] TONKOTSU_SOUP_minus, TONKOTSU_SOUP_minus_next;
reg [9:0] SOY_SAUSE_minus, SOY_SAUSE_minus_next;
reg [9:0] MISO_minus, MISO_minus_next;

always @(posedge clk) begin
    NOODLE_minus <= NOODLE_minus_next;
    BROTH_minus <= BROTH_minus_next;
    TONKOTSU_SOUP_minus <= TONKOTSU_SOUP_minus_next;
    SOY_SAUSE_minus <= SOY_SAUSE_minus_next;
    MISO_minus <= MISO_minus_next;
end

reg [9:0] price, price_next;
always @(posedge clk) begin
    price <= price_next;
end
//==============================================//
//                    Design                    //
//==============================================//
always @(*) begin
    // output signals
    out_valid_order_next = 0;
    success_next = 0;
    out_valid_tot_next = 0;
    sold_num_next = 0;
    total_gain_next = 0;

    sold_num_buf_next = sold_num_buf;
    total_gain_buf_next = total_gain_buf;

    NOODLE_minus_next = 0;
    BROTH_minus_next = 0;
    TONKOTSU_SOUP_minus_next = 0;
    SOY_SAUSE_minus_next = 0;
    MISO_minus_next = 0;

    NOODLE_left_next = NOODLE_left;
    BROTH_left_next = BROTH_left;
    TONKOTSU_SOUP_left_next = TONKOTSU_SOUP_left;
    SOY_SAUSE_left_next = SOY_SAUSE_left;
    MISO_left_next = MISO_left;

    price_next = 0;
    next_state = current_state;

    case (current_state)
    IDLE: begin
        if (in_valid_buf) begin
            next_state = READ;
        end
    end
    READ: begin
        case (portion_buf)
            1'b0: begin
                NOODLE_minus_next = 100;
                case (ramen_type_buf_buf)
                2'b00: begin
                    BROTH_minus_next = 300;
                    TONKOTSU_SOUP_minus_next = 150;
                    price_next = 200;
                end
                2'b01: begin
                    BROTH_minus_next = 300;
                    TONKOTSU_SOUP_minus_next = 100;
                    SOY_SAUSE_minus_next = 30;
                    price_next = 250;
                end
                2'b10: begin
                    BROTH_minus_next = 400;
                    MISO_minus_next = 30;
                    price_next = 200;
                end
                2'b11: begin
                    BROTH_minus_next = 300;
                    TONKOTSU_SOUP_minus_next = 70;
                    SOY_SAUSE_minus_next = 15;
                    MISO_minus_next = 15;
                    price_next = 250;
                end
                endcase  
            end
            1'b1: begin
                NOODLE_minus_next = 150;
                case (ramen_type_buf_buf)
                2'b00: begin
                    BROTH_minus_next = 500;
                    TONKOTSU_SOUP_minus_next = 200;
                    price_next = 200;
                end
                2'b01: begin
                    BROTH_minus_next = 500;
                    TONKOTSU_SOUP_minus_next = 150;
                    SOY_SAUSE_minus_next = 50;
                    price_next = 250;
                end
                2'b10: begin
                    BROTH_minus_next = 650;
                    MISO_minus_next = 50;
                    price_next = 200;
                end
                2'b11: begin
                    BROTH_minus_next = 500;
                    TONKOTSU_SOUP_minus_next = 100;
                    SOY_SAUSE_minus_next = 25;
                    MISO_minus_next = 25;
                    price_next = 250;
                end
              endcase
            end
            endcase
        next_state = CAL;
    end
    CAL: begin
        out_valid_order_next = 1;
        // check if the ingredient is enough
        if (NOODLE_left < NOODLE_minus ||
            BROTH_left < BROTH_minus ||
            TONKOTSU_SOUP_left < TONKOTSU_SOUP_minus ||
            SOY_SAUSE_left < SOY_SAUSE_minus ||
            MISO_left < MISO_minus) begin
            success_next = 0;
        end
        else begin
            success_next = 1;
            
            NOODLE_left_next = NOODLE_left - NOODLE_minus;
            BROTH_left_next = BROTH_left - BROTH_minus;
            TONKOTSU_SOUP_left_next = TONKOTSU_SOUP_left - TONKOTSU_SOUP_minus;
            SOY_SAUSE_left_next = SOY_SAUSE_left - SOY_SAUSE_minus;
            MISO_left_next = MISO_left - MISO_minus;

            case (ramen_type_buf_buf_buf)
            2'b00: sold_num_buf_next[27:21] = sold_num_buf[27:21] + 1;
            2'b01: sold_num_buf_next[20:14] = sold_num_buf[20:14] + 1;
            2'b10: sold_num_buf_next[13:7] = sold_num_buf[13:7] + 1;
            2'b11: sold_num_buf_next[6:0] = sold_num_buf[6:0] + 1;
            endcase
            total_gain_buf_next = total_gain_buf + price;
        end
        next_state = OUTPUT;
    end
    OUTPUT: begin
        if (selling == 1) begin
            next_state = IDLE;
        end
        else begin
            out_valid_tot_next = 1;
            sold_num_next = sold_num_buf;
            total_gain_next = total_gain_buf;

            next_state = IDLE;
            NOODLE_left_next = NOODLE_INIT;
            BROTH_left_next = BROTH_INIT;
            TONKOTSU_SOUP_left_next = TONKOTSU_SOUP_INIT;
            SOY_SAUSE_left_next = SOY_SAUSE_INIT;
            MISO_left_next = MISO_INIT;
            sold_num_buf_next = 0;
            total_gain_buf_next = 0;
        end
    end
    endcase
end

endmodule
