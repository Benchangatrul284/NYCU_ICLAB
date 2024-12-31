
// `include "../00_TESTBED/pseudo_DRAM.sv"
`include "Usertype.sv"

program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;
//================================================================
// parameters & integer
//================================================================
parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";
parameter MAX_CYCLE=1000;
integer SEED = 714;
integer PATNUM = 20000;
parameter OFFSET = 'h10000;
//================================================================
// wire & registers 
//================================================================
logic [7:0] golden_DRAM [((65536+8*256)-1):(65536+0)];  // 32 box

//================================================================
// class random
//================================================================

/**
 * Class representing a random action.
 */

class random_act;
    function new(int seed);
        this.srandom(seed);
    endfunction
    rand Action act_id;
    constraint range{
        this.act_id inside{Index_Check, Update, Check_Valid_Date};
        // this.act_id inside{Index_Check};
        // this.act_id inside {Update};
    }
endclass

class rand_formula;
    function new(int seed);
        this.srandom(seed);
    endfunction
    randc Formula_Type formula;
    constraint range{
        this.formula inside {Formula_A, Formula_B, Formula_C, Formula_D, Formula_E, Formula_F, Formula_G, Formula_H};
    }
endclass

class rand_mode;
    function new(int seed);
        this.srandom(seed);
    endfunction

    randc Mode mode;
    constraint range{
        this.mode inside {Insensitive, Normal, Sensitive};
    }
endclass

class rand_date;
    function new(int seed);
        this.srandom(seed);
    endfunction
    randc Date date;
    constraint date_constraint{
        date.M inside {[1:12]};
        (date.M==1 || date.M==3 || date.M==5 || date.M==7 || date.M==8 || date.M==10 || date.M==12) -> date.D inside {[1:31]};
        (date.M==4 || date.M==6 || date.M==9 || date.M==11) -> date.D inside {[1:30]};
        (date.M==2) -> date.D inside {[1:28]};
    }
endclass

class rand_index;
    function new(int seed);
        this.srandom(seed);
    endfunction
    randc Index index;
    constraint range{
        this.index inside {[0:(2**$bits(Index)-1)]};
    }
endclass

class rand_DataNo;
    function new(int seed);
        this.srandom(seed);
    endfunction
    randc Data_No data_no;
    constraint range{
        this.data_no inside {[0:(2**$bits(Data_No)-1)]};
    }
endclass


// modport PATTERN(
//         input out_valid, warn_msg, complete,
//         AR_VALID, AR_ADDR, R_READY, AW_VALID, AW_ADDR, W_VALID, W_DATA, B_READY,
//         output rst_n, sel_action_valid, formula_valid, mode_valid, date_valid, data_no_valid, index_valid, D,
//         AR_READY, R_VALID, R_RESP, R_DATA, AW_READY, W_READY, B_VALID, B_RESP
//     );

random_act ra = new(SEED);
rand_formula rf = new(SEED);
rand_mode rm = new(SEED);
rand_date rd = new(SEED);
rand_index ri = new(SEED);
rand_DataNo rdn = new(SEED);

// global variable
Action InputAction;
Mode InputMode;
Formula_Type InputFormula;
Date InputDate;
Index InputIndexA, InputIndexB, InputIndexC, InputIndexD;
Data_No InputDataNo;

Warn_Msg warn_msg_golden;
logic complete_golden;

Index result;
Index threshold;

initial begin
    $readmemh(DRAM_p_r, golden_DRAM);
    reset_task;
    for (integer pat_num=0 ; pat_num < PATNUM ; pat_num++) begin
        input_task;
        // $display("InputDataNo : %d", InputDataNo);
        wait_task;
        verify_task;
        $display("                  PASS PATTERN NO.%d", pat_num);
        @(negedge clk);
    end
    $display("===============================================================");
    $display("                      Congratulations                          ");
    $display("===============================================================");
    $finish;
end



task reset_task; begin
    inf.sel_action_valid = 0;
    inf.formula_valid = 0;
    inf.mode_valid = 0;
    inf.date_valid = 0;
    inf.data_no_valid = 0;
    inf.index_valid = 0;
    inf.D = 'x;
    
    inf.rst_n=1;
    #(1);
    inf.rst_n=0;
    #(100);
    inf.rst_n=1;
    // if (inf.out_valid !==0 || inf.warn_msg !== No_Warn || inf.complete !==0) begin
    //     $display("====================================================================");
    //     $display("                 Output from BEV should be 0 after rst              ");
    //     $display("====================================================================");
    //     $finish;
    // end
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
end 
endtask

task input_task;
    Data InputData;

    // randomize
    ra.randomize();
    InputAction = ra.act_id;
    rf.randomize();
    InputFormula = rf.formula;
    rm.randomize();
    InputMode = rm.mode;
    // $display("InputMode : %d", InputMode);
    rd.randomize();
    InputDate = rd.date;
    ri.randomize();
    InputIndexA = ri.index;
    ri.randomize();
    InputIndexB = ri.index;
    ri.randomize();
    InputIndexC = ri.index;
    ri.randomize();
    InputIndexD = ri.index;
    rdn.randomize();
    InputDataNo = rdn.data_no;
    // $display("InputDataNo : %d", InputDataNo);

    // repeat ({$random(SEED)} % 4) @(negedge clk);

    inf.sel_action_valid = 1;
    inf.D.d_act[0] = InputAction;
    @(negedge clk);
    inf.sel_action_valid = 0;
    inf.D = 'x;
    @(negedge clk); 
    
    case (InputAction)
    Index_Check: begin
        inf.formula_valid = 1;
        inf.D.d_formula[0] = InputFormula;
        @(negedge clk);
        inf.formula_valid = 0;
        inf.D = 'x;
        @(negedge clk);

        inf.mode_valid = 1;
        inf.D.d_mode[0] = rm.mode;
        @(negedge clk);
        inf.mode_valid = 0;
        inf.D = 'x;
        @(negedge clk);

        inf.date_valid = 1;
        inf.D.d_date[0] = InputDate;
        @(negedge clk);
        inf.date_valid = 0;
        inf.D = 'x;
        @(negedge clk);

        inf.data_no_valid = 1;
        inf.D.d_data_no[0] = InputDataNo;
        @(negedge clk);
        inf.data_no_valid = 0;
        inf.D = 'x;
        @(negedge clk);

        inf.index_valid = 1;
        inf.D.d_index[0] = InputIndexA;
        @(negedge clk);
        inf.index_valid = 0;
        inf.D = 'x;
        @(negedge clk);

        inf.index_valid = 1;
        inf.D.d_index[0] = InputIndexB;
        @(negedge clk);
        inf.index_valid = 0;
        inf.D = 'x;
        @(negedge clk);

        inf.index_valid = 1;
        inf.D.d_index[0] = InputIndexC;
        @(negedge clk);
        inf.index_valid = 0;
        inf.D = 'x;
        @(negedge clk);

        inf.index_valid = 1;
        inf.D.d_index[0] = InputIndexD;
        @(negedge clk);
        inf.index_valid = 0;
        inf.D = 'x;
    end
    Update: begin
        inf.date_valid = 1;
        inf.D.d_date[0] = InputDate;
        @(negedge clk);
        inf.date_valid = 0;
        inf.D = 'x;
        @(negedge clk);

        inf.data_no_valid = 1;
        inf.D.d_data_no[0] = InputDataNo;
        @(negedge clk);
        inf.data_no_valid = 0;
        inf.D = 'x;
        @(negedge clk);

        inf.index_valid = 1;
        inf.D.d_index[0] = InputIndexA;
        @(negedge clk);
        inf.index_valid = 0;
        inf.D = 'x;
        @(negedge clk);

        inf.index_valid = 1;
        inf.D.d_index[0] = InputIndexB;
        @(negedge clk);
        inf.index_valid = 0;
        inf.D = 'x;
        @(negedge clk);

        inf.index_valid = 1;
        inf.D.d_index[0] = InputIndexC;
        @(negedge clk);
        inf.index_valid = 0;
        inf.D = 'x;
        @(negedge clk);

        inf.index_valid = 1;
        inf.D.d_index[0] = InputIndexD;
        @(negedge clk);
        inf.index_valid = 0;
        inf.D = 'x;
    end
    Check_Valid_Date: begin
        inf.date_valid = 1;
        inf.D.d_date[0] = InputDate;
        @(negedge clk);
        inf.date_valid = 0;
        inf.D = 'x;
        @(negedge clk);

        inf.data_no_valid = 1;
        inf.D.d_data_no[0] = InputDataNo;
        @(negedge clk);
        inf.data_no_valid = 0;
        inf.D = 'x;
    end
    endcase

endtask

task wait_task; begin
    while(inf.out_valid === 0) begin
        @(negedge clk);
    end
end
endtask


task verify_task;
    Date DRAM_Date;
    Index DRAM_IndexA, DRAM_IndexB, DRAM_IndexC, DRAM_IndexD;
    integer DRAM_addr = 'h10000 + (InputDataNo << 3);
    logic data_warn;

    DRAM_IndexA = {golden_DRAM[DRAM_addr+7], golden_DRAM[DRAM_addr+6][7:4]};
    DRAM_IndexB = {golden_DRAM[DRAM_addr+6][3:0], golden_DRAM[DRAM_addr+5]};
    DRAM_IndexC = {golden_DRAM[DRAM_addr+3], golden_DRAM[DRAM_addr+2][7:4]};
    DRAM_IndexD = {golden_DRAM[DRAM_addr+2][3:0], golden_DRAM[DRAM_addr+1]};
    DRAM_Date.M = golden_DRAM[DRAM_addr+4];
    DRAM_Date.D = golden_DRAM[DRAM_addr];

    // $display("InputDataNo : %d", InputDataNo);
    // $display("DRAM_addr : %h", DRAM_addr);
    // $display("DRAM IndexA : %d, IndexB : %d, IndexC : %d, IndexD : %d, Month : %d, Day : %d", DRAM_IndexA, DRAM_IndexB, DRAM_IndexC, DRAM_IndexD, DRAM_Date.M, DRAM_Date.D);
    // $finish;
    // $display("formula : %d, mode : %d", InputFormula, InputMode);
    // warn_msg, complete
    case (InputAction)
    Index_Check: begin
        threshold = get_threshold(InputFormula, InputMode);
        result = get_result(InputFormula, DRAM_IndexA, DRAM_IndexB, DRAM_IndexC, DRAM_IndexD, InputIndexA, InputIndexB, InputIndexC, InputIndexD);
        if (InputDate.M < DRAM_Date.M || (InputDate.M == DRAM_Date.M && InputDate.D < DRAM_Date.D)) begin
            warn_msg_golden = Date_Warn;
            complete_golden = 0;
        end
        else begin
            if (result >= threshold) begin
                warn_msg_golden = Risk_Warn;
                complete_golden = 0;
            end
            else begin
                warn_msg_golden = No_Warn;
                complete_golden = 1;
            end
        end
        // $display("result : %d, threshold : %d", result, threshold);
    end
    Update: begin
        // compute new value
        logic signed [20:0] new_IndexA, new_IndexB, new_IndexC, new_IndexD;
        new_IndexA = $signed({1'b0,DRAM_IndexA}) + $signed(InputIndexA);
        new_IndexB = $signed({1'b0,DRAM_IndexB}) + $signed(InputIndexB);
        new_IndexC = $signed({1'b0,DRAM_IndexC}) + $signed(InputIndexC);
        new_IndexD = $signed({1'b0,DRAM_IndexD}) + $signed(InputIndexD);
        // $display("InputIndexA : %d, InputIndexB : %d, InputIndexC : %d, InputIndexD : %d", $signed(InputIndexA), $signed(InputIndexB), $signed(InputIndexC), $signed(InputIndexD));
        // $display("DRAM_IndexA : %d, DRAM_IndexB : %d, DRAM_IndexC : %d, DRAM_IndexD : %d", DRAM_IndexA, DRAM_IndexB, DRAM_IndexC, DRAM_IndexD);
        // $display("new_IndexA : %d, new_IndexB : %d, new_IndexC : %d, new_IndexD : %d", new_IndexA, new_IndexB, new_IndexC, new_IndexD);
        data_warn = (new_IndexA > 4095) || (new_IndexB > 4095) || (new_IndexC > 4095) || (new_IndexD > 4095) || (new_IndexA < 0) || (new_IndexB < 0) || (new_IndexC < 0) || (new_IndexD < 0);
        // $display("data_warn : %d", data_warn);
        if (new_IndexA > 4095) begin
            new_IndexA = 4095;
        end
        else if (new_IndexA < 0) begin
            new_IndexA = 0;
        end

        if (new_IndexB > 4095) begin
            new_IndexB = 4095;
        end
        else if (new_IndexB < 0) begin
            new_IndexB = 0;
        end

        if (new_IndexC > 4095) begin
            new_IndexC = 4095;
        end
        else if (new_IndexC < 0) begin
            new_IndexC = 0;
        end

        if (new_IndexD > 4095) begin
            new_IndexD = 4095;
        end
        else if (new_IndexD < 0) begin
            new_IndexD = 0;
        end

        // $display("new_IndexA : %d, new_IndexB : %d, new_IndexC : %d, new_IndexD : %d", new_IndexA, new_IndexB, new_IndexC, new_IndexD);
        
        if (data_warn) begin
            warn_msg_golden = Data_Warn;
            complete_golden = 0;
        end
        else begin
            warn_msg_golden = No_Warn;
            complete_golden = 1;
        end

        // write to golden DRAM
        {golden_DRAM[DRAM_addr+7], golden_DRAM[DRAM_addr+6][7:4]} = new_IndexA[11:0];
        {golden_DRAM[DRAM_addr+6][3:0], golden_DRAM[DRAM_addr+5]} = new_IndexB[11:0];
        {golden_DRAM[DRAM_addr+3], golden_DRAM[DRAM_addr+2][7:4]} = new_IndexC[11:0];
        {golden_DRAM[DRAM_addr+2][3:0], golden_DRAM[DRAM_addr+1]} = new_IndexD[11:0];
        golden_DRAM[DRAM_addr+4] = InputDate.M;
        golden_DRAM[DRAM_addr] = InputDate.D;

    end
    Check_Valid_Date: begin
        if (InputDate.M < DRAM_Date.M || (InputDate.M == DRAM_Date.M && InputDate.D < DRAM_Date.D)) begin
            warn_msg_golden = Date_Warn;
            complete_golden = 0;
        end
        else begin
            warn_msg_golden = No_Warn;
            complete_golden = 1;
        end
    end
    endcase

    if (inf.warn_msg !== warn_msg_golden || inf.complete !== complete_golden) begin
        $display("====================================================================");
        $display("                 Wrong Answer                     ");
        // $display(" Your Output : warn_msg : %d, complete : %d", inf.warn_msg, inf.complete);
        // $display(" Golden Output : warn_msg : %d, complete : %d", warn_msg_golden, complete_golden);
        $display("====================================================================");
        $finish;
    end
endtask

function Index get_threshold(Formula_Type InputFormula, Mode InputMode);
        case (InputFormula)
        Formula_A, Formula_C: begin
            case (InputMode)
            Insensitive: return 2047;
            Normal: return 1023;
            Sensitive: return 511;
            endcase
        end
        Formula_B, Formula_F, Formula_G, Formula_H: begin
            case (InputMode)
            Insensitive: return 800;
            Normal: return 400;
            Sensitive: return 200;
            endcase
        end
        Formula_D, Formula_E: begin
            case (InputMode)
            Insensitive: return 3;
            Normal: return 2;
            Sensitive: return 1;
            endcase
        end
        endcase
endfunction

function Index abs(Index a, Index b);
    if (a > b) begin
        return a - b;
    end
    else begin
        return b - a;
    end
endfunction

function Index get_result(
        Formula_Type formula,
        Index DRAM_A, Index DRAM_B, Index DRAM_C, Index DRAM_D, 
        Index Pattern_A, Index Pattern_B, Index Pattern_C, Index Pattern_D
    );
        Index DRAM_List[4] = {DRAM_A,DRAM_B,DRAM_C,DRAM_D}; // concat the DRAM value
        Index DRAM_Max[$] = DRAM_List.max(); // dynamic array to store the maximim value of DRAM List
        Index DRAM_Min[$] = DRAM_List.min();
        Index Pattern_List[4] = {Pattern_A,Pattern_B,Pattern_C,Pattern_D};
        Index abs_List[4] = {abs(DRAM_A,Pattern_A),abs(DRAM_B,Pattern_B),abs(DRAM_C,Pattern_C),abs(DRAM_D,Pattern_D)};
        logic [20:0] result = 20'b0;
        abs_List.sort();
        case(formula)
            Formula_A: begin
                // with (int'(item)) casts each element (item) of the DRAM_List array to an integer
                result = $floor((DRAM_List.sum() with (int'(item)))/4);
            end
            Formula_B: begin
                result = DRAM_Max[0] - DRAM_Min[0];
            end
            Formula_C: begin
                result = DRAM_Min[0];
            end
            Formula_D: begin
                for (int idx=0; idx<4; idx++) begin
                    if(DRAM_List[idx] >= 2047) 
                        result = result + 1;
                    end
            end
            Formula_E: begin
                for (int idx=0; idx<4; idx++) begin
                    if(DRAM_List[idx] >= Pattern_List[idx]) 
                        result = result + 1;
                    end
            end
            Formula_F: begin
                result = $floor(int'(abs_List[0] + abs_List[1] + abs_List[2])/3);
            end
            Formula_G: begin
                result = int'($floor(abs_List[0]/2) + $floor(abs_List[1]/4) + $floor(abs_List[2]/4));
            end
            Formula_H: begin
                result = $floor((abs_List.sum() with (int'(item)))/4);
            end
        endcase
        return result;
    endfunction
endprogram
