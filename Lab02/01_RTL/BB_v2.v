module BB(
    //Input Ports
    input clk,
    input rst_n,
    input in_valid,
    input [1:0] inning,   // Current inning number
    input half,           // 0: top of the inning, 1: bottom of the inning
    input [2:0] action,   // Action code

    //Output Ports
    output reg out_valid,  // Result output valid
    output reg [7:0] score_A,  // Score of team A (guest team)
    output reg [7:0] score_B,  // Score of team B (home team)
    output reg [1:0] result    // 0: Team A wins, 1: Team B wins, 2: Darw
);

//==============================================//
//             Action Memo for Students         //
// Action code interpretation:
// 3’d0: Walk (BB)
// 3’d1: 1H (single hit)
// 3’d2: 2H (double hit)
// 3’d3: 3H (triple hit)
// 3’d4: HR (home run)
// 3’d5: Bunt (short hit)
// 3’d6: Ground ball
// 3’d7: Fly ball
//==============================================//

//==============================================//
//             Parameter and Integer            //
//==============================================//
// State declaration for FSM
parameter IDLE = 3'b000;
parameter FIRST_UP = 3'b001;
parameter FIRST_DOWN = 3'b010;
parameter SECOND_UP = 3'b011;
parameter SECOND_DOWN = 3'b100;
parameter THIRD_UP = 3'b101;
parameter THIRD_DOWN = 3'b110;
parameter OUTPUT = 3'b111;
//==============================================//
//                 reg declaration              //
//==============================================//

reg [2:0] base, base_next; 
reg [3:0] score_A_next, score_B_next;
reg [1:0] out, out_next;
reg out_valid_next;
reg [1:0] result_next;
reg [3:0] score_to_add;
reg in_valid_buf;
reg [2:0] runners;
reg [2:0] current_state, next_state;
reg secure_win, secure_win_next;
reg [2:0] action_reg;

function [1:0] count_number_of_1s;
    input [2:0] in;
    begin
        count_number_of_1s = in[0] + in[1] + in[2];
    end
endfunction

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;

        base <= 3'b000;
        action_reg <= 3'b000;
        out <= 2'b00;

        score_A <= 8'b0;
        score_B <= 8'b0;
        secure_win <= 1'b0;
    end
    else begin
        current_state <= next_state;

        base <= base_next;
        action_reg <= action;
        out <= out_next;

        score_A <= score_A_next;
        score_B <= score_B_next;
        secure_win <= secure_win_next;
    end
end


always @(*) begin
    next_state = current_state;
    base_next = base;
    score_A_next = score_A;
    score_B_next = score_B;
    out_next = out;
    out_valid= 0;
    result = 0;
    score_to_add = 0;
    runners = 0;
    secure_win_next = secure_win;

    case (out)
        2'd0, 2'd1: begin
            case(action_reg)
                // walk
                3'd0: begin
                    base_next = base[0] ? {base[1:0],1'b1}:{base[2:1],1'b1};
                    score_to_add = (base == 3'b111) ? 1 : 0;
                end
                // single hit
                3'd1: begin
                    {runners, base_next} = {base,1'b1};
                    score_to_add = count_number_of_1s(runners);
                end
                // double hit
                3'd2: begin
                    {runners, base_next} = {base,2'b10};
                    score_to_add = count_number_of_1s(runners);
                end
                // triple hit
                3'd3: begin
                    base_next = 3'b100;
                    score_to_add = count_number_of_1s(base);
                end
                // home run
                3'd4: begin
                    base_next = 3'b000;
                    score_to_add = count_number_of_1s(base) + 1;
                end
                // bunt
                3'd5: begin
                    {runners, base_next} = {base,1'b0};
                    score_to_add = count_number_of_1s(runners);
                    out_next = out + 1;
                end
                // ground ball
                3'd6: begin
                    if (base[0] == 1) begin
                        out_next = out + 2; // dp
                        {runners, base_next} = {base[2:1],2'b00};
                        score_to_add = count_number_of_1s(runners);
                    end
                    else begin
                        out_next = out + 1;
                        {runners, base_next} = {base,1'b0};
                        score_to_add = count_number_of_1s(runners);
                    end
                end
                // fly ball
                3'd7: begin
                    out_next = out + 1;
                    if (base[2] == 1) begin
                        score_to_add = 1; // sf
                        base_next = {1'b0,base[1:0]};
                    end
                end
            endcase
        end

        2'd2: begin
            case(action_reg)
                // walk
                3'd0: begin
                    base_next = base[0] ? {base[1:0],1'b1}:{base[2:1],1'b1};
                    score_to_add = (base == 3'b111) ? 1 : 0;
                end
                // single hit
                3'd1: begin
                    {runners, base_next} = {base,2'b01};
                    score_to_add = count_number_of_1s(runners);
                end
                // double hit
                3'd2: begin
                    {runners, base_next} = {base,3'b010};
                    score_to_add = count_number_of_1s(runners);
                end
                // triple hit
                3'd3: begin
                    base_next = 3'b100;
                    score_to_add = count_number_of_1s(base);
                end
                // home run
                3'd4: begin
                    base_next = 3'b000;
                    score_to_add = count_number_of_1s(base) + 1;
                end
                // bunt
                3'd5: begin
                end
                // ground ball
                3'd6: begin
                    out_next = 3;
                end
                // fly ball
                3'd7: begin
                    out_next = 3;
                end
            endcase
        end
    endcase
    
    case (current_state)
    IDLE: begin
        score_A_next = 0;
        score_B_next = 0;
        base_next = 0;
        out_next = 0;
        secure_win_next = 0;
        if (in_valid) begin
            next_state = FIRST_UP;
        end

    end
    FIRST_UP: begin
        if (half == 1) begin
            next_state = FIRST_DOWN;
            base_next = 0;
            out_next = 0;
        end else
            score_A_next = score_A + score_to_add;
    end
    FIRST_DOWN: begin
        if (half == 0) begin
            next_state = SECOND_UP;
            base_next = 0;
            out_next = 0;
        end else
            score_B_next = score_B + score_to_add;
    end
    SECOND_UP: begin
        if (half == 1) begin
            next_state = SECOND_DOWN;
            base_next = 0;
            out_next = 0;
        end else
            score_A_next = score_A + score_to_add;
    end
    SECOND_DOWN: begin
        if (half == 0) begin
            next_state = THIRD_UP;
            base_next = 0;
            out_next = 0;
        end else
            score_B_next = score_B + score_to_add;
    end
    THIRD_UP: begin
        if (half == 1) begin
            next_state = THIRD_DOWN;
            base_next = 0;
            out_next = 0;
            secure_win_next = (score_B_next > score_A_next) ? 1 : 0;
        end else
            score_A_next = score_A + score_to_add;
    end

    THIRD_DOWN: begin
        if (in_valid == 0) begin
            next_state = OUTPUT;
            base_next = 0;
            out_next = 0;
        end else
            score_B_next = (secure_win)? score_B: score_B + score_to_add;
    end
    
    OUTPUT: begin
        out_valid = 1;
        next_state = IDLE;
        if (score_A > score_B) begin
            result = 2'b00;
        end
        else if (score_A < score_B) begin
            result = 2'b01;
        end
        else begin
            result = 2'b10;
        end
    end
    endcase
end


endmodule
