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
parameter COMPUTE = 2'b01;
parameter OUTPUT = 2'b10;

//==============================================//
//                 reg declaration              //
//==============================================//

reg [2:0] base, base_next;
reg [1:0] out, out_next;
reg [2:0] runners;
reg [2:0] score_to_add;
reg [3:0] score_A_next;
reg [2:0] score_B_next;
reg [1:0] current_state, next_state;
reg secure_win, secure_win_next;
reg [1:0] out_add1;

function [1:0] cmp;
    input [3:0] a, b;
    begin
        cmp = {a==b,b>a};
    end
endfunction


function [2:0] walk_base;
    input [2:0] base;
    begin
        case(base)
            3'b000: walk_base[2:1] = 2'b00;
            3'b001: walk_base[2:1] = 2'b01;
            3'b010: walk_base[2:1] = 2'b01;
            3'b011: walk_base[2:1] = 2'b11;
            3'b100: walk_base[2:1] = 2'b10;
            3'b101: walk_base[2:1] = 2'b11;
            3'b110: walk_base[2:1] = 2'b11;
            3'b111: walk_base[2:1] = 2'b11;
        endcase
        walk_base[0] = 1'b1;
    end
endfunction 

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

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        base <= 3'b000;
        out <= 2'b00;
        score_A <= 0;
        score_B <= 0;
        current_state <= IDLE;
        secure_win <= 0;
    end
    else begin
        base <= base_next;
        out <= out_next;
        score_A <= score_A_next;
        score_B <= score_B_next;
        current_state <= next_state;
        secure_win <= secure_win_next;
    end
end


always @(*) begin
    next_state = current_state;
    case (current_state)
    IDLE: begin
        if (in_valid)
            next_state = COMPUTE;
    end
    COMPUTE: begin
        if (!in_valid)
            next_state = OUTPUT;
    end
    OUTPUT: begin
        next_state = IDLE;
    end
    endcase
end

always @(*) begin
    result = 2'b00;
    out_valid = 1'b0;
    score_A_next = score_A;
    score_B_next = score_B;
    score_to_add = 3'b000;
    runners = 3'b000;
    out_next = out;
    base_next = base;

    secure_win_next = secure_win;
    
    out_add1 = out + 1;
    if (in_valid) begin
        case (action)
            // walk
            3'd0: begin
                base_next = walk_base(base);
                score_to_add = (base == 3'b111);
            end
            // single hit
            3'd1: begin
                if (out[1] == 1'b1) begin
                    {runners, base_next} = {1'b0,base,2'b01};
                    score_to_add = count_number_of_1s(runners);
                end
                else begin
                    {runners, base_next} = {2'b00,base,1'b1};
                    score_to_add = count_number_of_1s(runners);
                end
            end
            // double hit
            3'd2: begin
                if (out[1] == 1'b1) begin
                    {runners, base_next} = {base,3'b010};
                    score_to_add = count_number_of_1s(runners);
                end
                else begin
                    {runners, base_next} = {1'b0,base,2'b10};
                    score_to_add = count_number_of_1s(runners);
                end
            end
            // triple hit
            3'd3: begin
                base_next = 3'b100;
                score_to_add = count_number_of_1s(base);
            end
            // home run
            3'd4: begin
                base_next = 3'b000;
                score_to_add = count_number_of_1s(base) + 1'b1;
            end
            // bunt
            3'd5: begin
                out_next = out_add1;
                {runners, base_next} = {2'b00,base,1'b0};
                score_to_add = count_number_of_1s(runners);
            end
            // ground ball
            3'd6: begin 
                if (out[1] == 1'b1|| (out[0] == 1'b1 && base[0] == 1'b1)) begin
                    base_next = 3'b000;
                    out_next = 0;
                    score_to_add = 0;
                end else begin
                    if (base[0] == 1'b1) begin
                        out_next = 2; // dp
                        {runners, base_next} = {2'b00,base[2:1],2'b00};
                        score_to_add = count_number_of_1s(runners);
                    end
                    else begin
                        out_next = out_add1;
                        {runners, base_next} = {2'b00,base,1'b0};
                        score_to_add = count_number_of_1s(runners);
                    end
                end
            end
            // fly ball
            3'd7: begin
                if (out[1] == 1'b1) begin
                    out_next = 0;
                    base_next = 0;
                end
                else begin
                    out_next = out_add1;
                    if (base[2] == 1'b1) begin
                        base_next[2] = 1'b0;
                        score_to_add = 1'b1; // sf
                    end
                    
                end
            end
        endcase

        if (half == 0) begin
            score_A_next = score_A + score_to_add;
            if (inning == 3)
                secure_win_next = (score_B > score_A);
        end else if (half == 1)
            score_B_next = (secure_win)? score_B : score_B + score_to_add;
    end

    if (current_state == OUTPUT) begin
        result = cmp(score_A,score_B);
        out_valid = 1'b1;
        base_next = 0;
        out_next = 0;
        score_A_next = 0;
        score_B_next = 0;
        secure_win_next = 0;
    end
    
end
endmodule
