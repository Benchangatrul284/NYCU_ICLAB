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
// parameter FIRST_UP = 3'b001;
// parameter FIRST_DOWN = 3'b010;
// parameter SECOND_UP = 3'b011;
// parameter SECOND_DOWN = 3'b100;
// parameter THIRD_UP = 3'b101;
// parameter THIRD_DOWN = 3'b110;

parameter IDLE = 2'b00;
parameter TEAM_A = 2'b01;
parameter TEAM_B = 2'b10;
parameter OUTPUT = 2'b11;

//==============================================//
//                 reg declaration              //
//==============================================//

reg [2:0] base, base_next; 
reg [3:0] score_A_next;
reg [2:0] score_B_next;
reg [1:0] out, out_next;
reg out_valid_next;
reg [2:0] score_to_add;
reg [2:0] runners;
reg [1:0] current_state, next_state;
reg secure_win, secure_win_next;
reg [2:0] action_reg;

reg [2:0] walk_base_next, walk_score_to_add, 
          triple_base_next, triple_score_to_add,
          hr_base_next, hr_score_to_add;
reg [1:0] add1_out;

function [1:0] count_number_of_1s;
    input [2:0] in;
    begin
        // count_number_of_1s = (in[0] + in[1]) + in[2];
        case(in)
            3'b000: count_number_of_1s = 2'b00;
            3'b001: count_number_of_1s = 2'b01;
            3'b010: count_number_of_1s = 2'b01;
            3'b011: count_number_of_1s = 2'b10;
            3'b100: count_number_of_1s = 2'b01;
            3'b101: count_number_of_1s = 2'b10;
            3'b110: count_number_of_1s = 2'b10;
            3'b111: count_number_of_1s = 2'b11;
        endcase
    end
endfunction

function [1:0] cmp;
    input [3:0] a, b;
    begin
        cmp = (a==b) + (a<=b);
    end
endfunction

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;

        base <= 3'b000;
        action_reg <= 3'b000;
        out <= 2'b00;

        score_A <= 4'b0;
        score_B <= 3'b0;
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

function [2:0] walk_base;
    input [2:0] base;
    begin
        case(base)
            3'b000: walk_base = 3'b001;
            3'b001: walk_base = 3'b011;
            3'b010: walk_base = 3'b011;
            3'b011: walk_base = 3'b111;
            3'b100: walk_base = 3'b101;
            3'b101: walk_base = 3'b111;
            3'b110: walk_base = 3'b111;
            3'b111: walk_base = 3'b111;
        endcase
    end
endfunction 

always @(*) begin
    base_next = base;
    score_A_next = score_A;
    score_B_next = score_B;
    out_next = out;
    out_valid= 0;
    result = 0;
    score_to_add = 0;
    runners = 0;
    secure_win_next = secure_win;


    walk_base_next = walk_base(base);
    walk_score_to_add = (base == 3'b111) ? 1'b1 : 1'b0;

    triple_base_next = 3'b100;
    triple_score_to_add = count_number_of_1s(base);

    hr_base_next = 3'b000;
    hr_score_to_add = triple_score_to_add + 1'b1;
    
    add1_out = out + 1'b1;

    case (out)
        2'd0, 2'd1: begin
            case(action_reg)
                // walk
                3'd0: begin
                    base_next = walk_base_next;
                    score_to_add = walk_score_to_add;
                end
                // single hit
                3'd1: begin
                    {runners, base_next} = {2'b00,base,1'b1};
                    score_to_add = count_number_of_1s(runners);
                end
                // double hit
                3'd2: begin
                    {runners, base_next} = {1'b0,base,2'b10};
                    score_to_add = count_number_of_1s(runners);
                end
                // triple hit
                3'd3: begin
                    base_next = triple_base_next;
                    score_to_add = triple_score_to_add;
                end
                // home run
                3'd4: begin
                    base_next = hr_base_next;
                    score_to_add = hr_score_to_add;
                end
                // bunt
                3'd5: begin
                    {runners, base_next} = {2'b00,base,1'b0};
                    score_to_add = count_number_of_1s(runners);
                    out_next = add1_out;
                end
                // ground ball
                3'd6: begin
                    if (base[0] == 1'b1) begin
                        out_next = add1_out + 1'b1; // dp
                        {runners, base_next} = {2'b00,base[2:1],2'b00};
                        score_to_add = count_number_of_1s(runners);
                    end
                    else begin
                        out_next = add1_out;
                        {runners, base_next} = {2'b00,base,1'b0};
                        score_to_add = count_number_of_1s(runners);
                    end
                end
                // fly ball
                3'd7: begin
                    out_next = add1_out;
                    if (base[2] == 1'b1) begin
                        score_to_add = 1'b1; // sf
                        base_next[2] = 1'b0;
                    end
                end
            endcase
        end

        2'd2: begin
            case(action_reg)
                // walk
                3'd0: begin
                    base_next = walk_base_next;
                    score_to_add = walk_score_to_add;
                end
                // single hit
                3'd1: begin
                    {runners, base_next} = {1'b0,base,2'b01};
                    score_to_add = count_number_of_1s(runners);
                end
                // double hit
                3'd2: begin
                    {runners, base_next} = {base,3'b010};
                    score_to_add = count_number_of_1s(runners);
                end
                // triple hit
                3'd3: begin
                    base_next = triple_base_next;
                    score_to_add = triple_score_to_add;
                end
                // home run
                3'd4: begin
                    base_next = hr_base_next;
                    score_to_add = hr_score_to_add;
                end
                // bunt
                3'd5: begin
                    // base_next = base;
                    // score_to_add = 0;
                end
                // ground ball
                3'd6: begin
                    // out_next = 2'd3;
                end
                // fly ball
                3'd7: begin
                    // out_next = 2'd3;
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

    end
    TEAM_A: begin
        if (half == 1'd1) begin
            // next_state = TEAM_B;
            base_next = 0;
            out_next = 0;
            if (inning == 2'd3) begin
                secure_win_next = (score_B_next > score_A_next);
            end
        end else
            score_A_next = score_A + score_to_add;
    end
    TEAM_B: begin
        if (half == 1'd0) begin
            // next_state = TEAM_A;
            base_next = 0;
            out_next = 0;
        end 
        else
            score_B_next = (secure_win)? score_B: score_B + score_to_add;
    end
    OUTPUT: begin
        out_valid = 1'd1;
        result = cmp(score_A, score_B);
    end
    endcase
end

always @(*) begin
    next_state = current_state;
    case (current_state)
    IDLE: begin
        if (in_valid) begin
            next_state = TEAM_A;
        end else begin
            next_state = IDLE;
        end

    end
    TEAM_A: begin
        if (half == 1'd1) begin
            next_state = TEAM_B;
        end else begin
            next_state = TEAM_A;
        end
    end
    TEAM_B: begin
        if (half == 1'd0) begin
            next_state = TEAM_A;
        end
        if (in_valid == 1'd0) begin
            next_state = OUTPUT;
        end
    end
    OUTPUT: begin
        next_state = IDLE;
    end
    endcase
end

endmodule
