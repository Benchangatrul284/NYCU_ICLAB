`define CYCLE_TIME 4.0

`define DRAM_PATH "../00_TESTBED/DRAM/dram.dat"
`define PATNUM 1000
`define SEED 384597

`include "../00_TESTBED/pseudo_DRAM.v"

module PATTERN(
    // Input Signals
    clk,
    rst_n,
    in_valid,
    in_pic_no,
    in_mode,
    in_ratio_mode,
    out_valid,
    out_data
);

/* Input for design */
output reg        clk, rst_n;
output reg        in_valid;

output reg [3:0] in_pic_no;
output reg [1:0] in_mode;
output reg [1:0] in_ratio_mode;

input out_valid;
input [7:0] out_data;
//////////////////////////////////////////////////////////////////////
parameter DRAM_p_r = `DRAM_PATH;
parameter CYCLE = `CYCLE_TIME;

reg [7:0] DRAM_r[0:196607];
reg [7:0] image [0:2][0:31][0:31];
integer patcount;
integer latency, total_latency;
integer file;
integer PATNUM = `PATNUM;
integer seed = `SEED;
integer dram_read;
integer focus_lat,expo_lat,focus,expo;
reg [1:0] golden_in_ratio_mode;
reg [3:0] golden_in_pic_no;
reg [1:0] golden_in_mode;
reg [8:0] golden_out_data;

reg [7:0] two_by_two [0:1][0:1];
reg [7:0] four_by_four [0:3][0:3];
reg [7:0] six_by_six [0:5][0:5];

reg [31:0] out_data_temp,smalls;
reg [31:0] D_constrate [0:2];

reg [7:0] max_R, max_G, max_B;
reg [7:0] min_R, min_G, min_B;

//////////////////////////////////////////////////////////////////////
// Write your own task here
//////////////////////////////////////////////////////////////////////
initial clk=0;
always #(CYCLE/2.0) clk = ~clk;

// Do it yourself, I believe you can!!!

/* Check for invalid overlap */
always @(*) begin
    if (in_valid && out_valid) begin
        $display("************************************************************");  
        $display("                          FAIL!                           ");    
        $display("*  The out_valid signal cannot overlap with in_valid.   *");
        $display("************************************************************");
        $finish;            
    end    
end



initial begin
    reset_task;
    $readmemh(DRAM_p_r,DRAM_r);
    file = $fopen("../00_TESTBED/debug.txt", "w");
    focus_lat = 0;
    expo_lat = 0;
    focus = 0;
    expo = 0;
    dram_read = 0;

    for(patcount = 0; patcount < PATNUM; patcount++) begin 
        repeat(2) @(negedge clk); 
        input_task;
        write_dram_file;
        calculate_ans;
        write_to_file;
        wait_out_valid_task;
        check_ans;
        $display("\033[0;34mPASS PATTERN NO.%4d,mode: %d,pic:%d,ratio:%d,\033[m,out_data:%4d \033[0;32mExecution Cycle: %3d \033[0m", patcount + 1,golden_in_mode,golden_in_pic_no,golden_in_ratio_mode,golden_out_data, latency);
    end
    display_pass;
    repeat (3) @(negedge clk);
    $finish;
end

task reset_task; begin 
    rst_n = 1'b1;
    in_valid = 1'b0;
    in_ratio_mode = 2'bx;
    in_pic_no = 4'bx;
    in_mode = 1'bx;
    total_latency = 0;

    force clk = 0;

    // Apply reset
    #CYCLE; rst_n = 1'b0; 
    #CYCLE; rst_n = 1'b1;
    #100;
    // Check initial conditions
    if (out_valid !== 1'b0 || out_data !== 'b0) begin
        $display("************************************************************");  
        $display("                          FAIL!                           ");    
        $display("*  Output signals should be 0 after initial RESET at %8t *", $time);
        $display("************************************************************");
        repeat (2) #CYCLE;
        $finish;
    end
    #CYCLE; release clk;
end endtask

// always @(*) begin
//     if (in_pic_no == 12) begin
//         $display("from always block");
//         display_image;
//     end
// end

task input_task; begin
    integer i,j;
    in_valid = 1'b1;
    
    
    in_pic_no = $random(seed) % 'd16;
    // in_mode = 2'd2;
    in_mode = $random(seed) % 'd3;
    in_ratio_mode = (in_mode == 1) ? $random(seed) % 'd4 : 2'bx;
    golden_in_ratio_mode = in_ratio_mode;
    golden_in_pic_no = in_pic_no;
    golden_in_mode = in_mode;

    // image -> 3 * 32 * 32
    for(integer i = 0; i < 3; i = i + 1)begin
        for(integer j = 0; j < 32; j = j + 1)begin
            for(integer k = 0; k < 32; k = k + 1)begin
                image[i][j][k] = DRAM_r[65536 + i * 32 * 32 + j * 32 + k + golden_in_pic_no * 32 * 32 * 3];
            end
        end
    end   
    

    @(negedge clk);

    in_valid = 1'b0;
    in_ratio_mode = 2'bx;
    in_pic_no = 4'bx;
    in_mode = 1'bx;
    
end endtask


task calculate_ans; begin
    case (golden_in_mode)
    2'd0: begin
        for(integer i = 0; i < 3; i = i + 1)begin
            D_constrate[i] = 0;
        end
        
        for(integer j = 0; j < 2; j = j + 1)begin
            for(integer k = 0; k < 2; k = k + 1)begin
                two_by_two[j][k] = (image[0][15 + j][15 + k] ) / 4 + (image[1][15 + j][15 + k]) / 2 + 
                                        (image[2][15 + j][15 + k] ) / 4 ;
            end
        end

        for(integer j = 0; j < 4; j = j + 1)begin
            for(integer k = 0; k < 4; k = k + 1)begin
                four_by_four[j][k] = (image[0][14 + j][14 + k] ) / 4 + (image[1][14 + j][14 + k]) / 2 + 
                                        (image[2][14 + j][14 + k] ) / 4 ;
            end
        end

        for(integer j = 0; j < 6; j = j + 1)begin
            for(integer k = 0; k < 6; k = k + 1)begin
                
                six_by_six[j][k] = (image[0][13 + j][13 + k] ) / 4 + (image[1][13 + j][13 + k]) / 2 + 
                                        (image[2][13 + j][13 + k] ) / 4 ;
            end
        end



        for(integer i = 0; i < 2; i = i + 1)begin
            for(integer j = 0; j < 1; j = j + 1)begin
                D_constrate[0] = D_constrate[0] + diff_abs(two_by_two[i][j + 1], two_by_two[i][j]) + diff_abs(two_by_two[j + 1][i], two_by_two[j][i]);
            end
        end

        for(integer i = 0; i < 4; i = i + 1)begin
            for(integer j = 0; j < 3; j = j + 1)begin
                D_constrate[1] = D_constrate[1] + diff_abs(four_by_four[i][j + 1], four_by_four[i][j]) + diff_abs(four_by_four[j + 1][i], four_by_four[j][i]);
            end
        end

        for(integer i = 0; i < 6; i = i + 1)begin
            for(integer j = 0; j < 5; j = j + 1)begin
                
                D_constrate[2] = D_constrate[2] + diff_abs(six_by_six[i][j + 1], six_by_six[i][j]) + diff_abs(six_by_six[j + 1][i], six_by_six[j][i]);
            end
        end

        D_constrate[0] = D_constrate[0] / (2 * 2);
        D_constrate[1] = D_constrate[1] / (4 * 4);
        D_constrate[2] = D_constrate[2] / (6 * 6);

        if(D_constrate[0] >= D_constrate[1] && D_constrate[0] >= D_constrate[2])begin
            golden_out_data = 8'b00000000;
        end
        else if(D_constrate[1] >= D_constrate[2])begin
            golden_out_data = 8'b00000001;
        end
        else begin
            golden_out_data = 8'b00000010;
        end
    end
    2'd1: begin
        for(integer i = 0; i < 3; i = i + 1)begin
            for(integer j = 0; j < 32; j = j + 1)begin
                for(integer k = 0; k < 32; k = k + 1)begin
                    if(golden_in_ratio_mode == 0)begin
                        image[i][j][k] = image[i][j][k] / 4;
                    end
                    else if(golden_in_ratio_mode == 1)begin
                        image[i][j][k] = image[i][j][k] / 2;
                    end
                    else if(golden_in_ratio_mode == 2)begin
                        image[i][j][k] = image[i][j][k];
                    end
                    else begin
                        image[i][j][k] = (image[i][j][k] * 2) < 256 ? image[i][j][k] * 2 : 255;
                    end
                    
                end
            end
        end

        for(integer i = 0; i < 3; i = i + 1)begin
            for(integer j = 0; j < 32; j = j + 1)begin
                for(integer k = 0; k < 32; k = k + 1)begin
                    DRAM_r[65536 + i * 32 * 32 + j * 32 + k + golden_in_pic_no * 32 * 32 * 3] = image[i][j][k];
                end
            end
        end
        
        out_data_temp = 0;
        for(integer i = 0; i < 32; i = i + 1)begin
            for(integer j = 0; j < 32; j = j + 1)begin
                //  $display("array[%2d][%2d]: gray is %d",i,j,image[0][i][j] / 4 + image[1][i][j] / 2 + image[2][i][j] / 4);
                out_data_temp = out_data_temp + image[0][i][j] / 4 + image[1][i][j] / 2 + image[2][i][j] / 4;
                // if(j == 15)$display("array[%2d][0-15]: sum is %d",i,out_data_temp);
            end
            // $display("array[%2d][0-31]: sum is %d",i,out_data_temp);
        end
        golden_out_data = out_data_temp / 1024;
    end
    2'd2: begin
        // $display("from calculate_ans %d", golden_in_pic_no);
        // display_image;
        max_R = 0;
        max_G = 0;
        max_B = 0;
        for (integer i = 0; i <= 31; i = i + 1)begin
            for (integer j = 0; j <= 31; j = j + 1)begin
                if (image[0][i][j] > max_R)begin
                    max_R = image[0][i][j];
                end
                if (image[1][i][j] > max_G)begin
                    max_G = image[1][i][j];
                end
                if (image[2][i][j] > max_B)begin
                    max_B = image[2][i][j];
                end
            end
        end
        
        min_R = 255;
        min_G = 255;
        min_B = 255;
        for (integer i = 0; i <= 31; i = i + 1)begin
            for (integer j = 0; j <= 31; j = j + 1)begin
                if (image[0][i][j] < min_R)begin
                    min_R = image[0][i][j];
                end
                if (image[1][i][j] < min_G)begin
                    min_G = image[1][i][j];
                end
                if (image[2][i][j] < min_B)begin
                    min_B = image[2][i][j];
                end
            end
        end
        // $display("max_R is %d, max_G is %d, max_B is %d, min_R is %d, min_G is %d, min_B is %d", max_R, max_G, max_B, min_R, min_G, min_B);
        golden_out_data = ((max_R + max_G + max_B) / 3 + (min_R + min_G + min_B) / 3) / 2;
        // $finish;
    end
    endcase
end endtask

task wait_out_valid_task; begin
    latency = 0;
    while (out_valid !== 1'b1) begin
        latency = latency + 1;
        if (latency == 2500) begin
            $display("********************************************************");     
            $display("                          FAIL!                           ");
            $display("*  The execution latency exceeded %d cycles    *",latency);
            $display("********************************************************");
            repeat (2) @(negedge clk);
            $finish;
        end
        @(negedge clk);
    end
    total_latency = total_latency + latency;
end endtask



task check_ans; begin
    // $finish;
    case (golden_in_mode)
    2'd0: begin
        if(golden_out_data !== out_data) begin
            $display("********************************************************");     
            $display("                          FAIL!                           ");
            $display("*               The golden_in_mode is %d               *", golden_in_mode);
            $display("*               The golden_in_pict is %d               *", golden_in_pic_no);
            $display("*  The golden_out_data is %d, but your out_data is %d  *", golden_out_data, out_data);
            $display("********************************************************");
            repeat (2) @(negedge clk);
            $finish;
        end
    end
    2'd1: begin
        if(golden_out_data !== out_data)begin
            $display("********************************************************");     
            $display("                FAIL error is large than 0 !                ");
            $display("*               The golden_in_mode is %d               *", golden_in_mode);
            $display("*  The golden_out_data is %d, but your out_data is %d  *", golden_out_data, out_data);
            $display("********************************************************");
            repeat (2) @(negedge clk);
            $finish;
            
        end
        if(golden_out_data == 0)begin
             if(out_data !==1 && out_data !==0)begin
                $display("********************************************************");     
                $display("                FAIL error is large than 1 !                ");
                $display("*               The golden_in_mode is %d               *", golden_in_mode);
                $display("*  The golden_out_data is %d, but your out_data is %d  *", golden_out_data, out_data);
                $display("********************************************************");
                // repeat (2) @(negedge clk);
                // $finish;
            end
        end
        else if(golden_out_data == 255)begin
             if(out_data !==255 && out_data !==254)begin
                $display("********************************************************");     
                $display("                FAIL error is large than 1 !                ");
                $display("*               The golden_in_mode is %d               *", golden_in_mode);
                $display("*  The golden_out_data is %d, but your out_data is %d  *", golden_out_data, out_data);
                $display("********************************************************");
                // repeat (2) @(negedge clk);
                // $finish;
            end

        end
        else begin
            if(out_data > golden_out_data + 1 || out_data < golden_out_data - 1)begin
                $display("********************************************************");     
                $display("                FAIL error is large than 1 !                ");
                $display("*               The golden_in_mode is %d               *", golden_in_mode);
                $display("*  The golden_out_data is %d, but your out_data is %d  *", golden_out_data, out_data);
                $display("********************************************************");
                // repeat (2) @(negedge clk);
                // $finish;
            end
        end
    end
    2'd2: begin
        if (golden_out_data !== out_data) begin
            $display("********************************************************");     
            $display("                          FAIL!                           ");
            $display("*               The golden_in_mode is %d               *", golden_in_mode);
            $display("*               The golden_in_pict is %d               *", golden_in_pic_no);
            $display("*  The golden_out_data is %d, but your out_data is %d  *", golden_out_data, out_data);
            $display("* max_R is %d, max_G is %d, max_B is %d, min_R is %d, min_G is %d, min_B is %d *", max_R, max_G, max_B, min_R, min_G, min_B);
            $display("********************************************************");
            repeat (2) @(negedge clk);
            $finish;
        end
    end
    endcase
end endtask

task write_dram_file; begin
    $fwrite(file, "===========  PATTERN NO.%4d  ==============\n", patcount+1);
    
        $fwrite(file, "==========  GOLDEN_PIC_NO.%2d  ==============\n", golden_in_pic_no);
        $fwrite(file, "===========    RED IMAGE     ==============\n");
        for(integer i = 0; i < 32; i = i + 1) begin
            for(integer j = 0; j < 32; j = j + 1) begin
                $fwrite(file, "%5d ", image[0][i][j]);
            end
            $fwrite(file, "\n");
        end
        $fwrite(file, "===========    GREEN IMAGE     ============\n");
        for(integer i = 0; i < 32; i = i + 1) begin
            for(integer j = 0; j < 32; j = j + 1) begin
                $fwrite(file, "%5d ", image[1][i][j]);
            end
            $fwrite(file, "\n");
        end
        $fwrite(file, "===========    BLUE IMAGE     ============\n");
        for(integer i = 0; i < 32; i = i + 1) begin
            for(integer j = 0; j < 32; j = j + 1) begin
                $fwrite(file, "%5d ", image[2][i][j]);
            end
            $fwrite(file, "\n");
        end
        $fwrite(file, "\n");
    if(golden_in_mode == 0)begin
        $fwrite(file, "==========  FOCUS_PIC_NO.%2d  ==============\n", golden_in_pic_no);
        $fwrite(file, "===========    RED IMAGE     ==============\n");
        for(integer i = 13; i < 19; i = i + 1) begin
            for(integer j = 13; j < 19; j = j + 1) begin
                $fwrite(file, "%5d ", image[0][i][j]);
            end
            $fwrite(file, "\n");
        end
        $fwrite(file, "===========    GREEN IMAGE     ============\n");
        for(integer i = 13; i < 19; i = i + 1) begin
            for(integer j = 13; j < 19; j = j + 1) begin
                $fwrite(file, "%5d ", image[1][i][j]);
            end
            $fwrite(file, "\n");
        end
        $fwrite(file, "===========    BLUE IMAGE     ============\n");
        for(integer i = 13; i < 19; i = i + 1) begin
            for(integer j = 13; j < 19; j = j + 1) begin
                $fwrite(file, "%5d ", image[2][i][j]);
            end
            $fwrite(file, "\n");
        end
        $fwrite(file, "\n");
    end
end endtask


task write_to_file; begin
    
    $fwrite(file, "==========  GOLDEN_IN_MODE.%b  ==============\n", golden_in_mode);   
    if(golden_in_mode == 0)begin
        $fwrite(file, "===========    TWO_BY_TWO     ============\n");
        for(integer i = 0; i < 2; i = i + 1) begin
            for(integer j = 0; j < 2; j = j + 1) begin
                $fwrite(file, "%5d ", two_by_two[i][j]);
            end
            $fwrite(file, "\n");
        end

        $fwrite(file, "===========    FOUR_BY_FOUR     ============\n");
        for(integer i = 0; i < 4; i = i + 1) begin
            for(integer j = 0; j < 4; j = j + 1) begin
                $fwrite(file, "%5d ", four_by_four[i][j]);
            end
            $fwrite(file, "\n");
        end

        $fwrite(file, "===========    SIX_BY_SIX     ============\n");
        for(integer i = 0; i < 6; i = i + 1) begin
            for(integer j = 0; j < 6; j = j + 1) begin
                $fwrite(file, "%5d ", six_by_six[i][j]);
            end
            $fwrite(file, "\n");
        end

        $fwrite(file, "===========    D_CONSTRATE     ============\n");
        for(integer i = 0; i < 3; i = i + 1) begin
            $fwrite(file, "%10d", D_constrate[i]);
        end
        $fwrite(file, "\n");
    end
    else begin
        $fwrite(file, "=========  IMAGE_AFTER_AUTO_EXPOSURE  ============\n");
        $fwrite(file, "=========  GOLDEN_RATIO is %d  ============\n",golden_in_ratio_mode);
        $fwrite(file, "===========    RED IMAGE     ==============\n");
        for(integer i = 0; i < 32; i = i + 1) begin
            for(integer j = 0; j < 32; j = j + 1) begin
                $fwrite(file, "%5d ", image[0][i][j]);
            end
            $fwrite(file, "\n");
        end
        $fwrite(file, "===========    GREEN IMAGE     ============\n");
        for(integer i = 0; i < 32; i = i + 1) begin
            for(integer j = 0; j < 32; j = j + 1) begin
                $fwrite(file, "%5d ", image[1][i][j]);
            end
            $fwrite(file, "\n");
        end
        $fwrite(file, "===========    BLUE IMAGE     ============\n");
        for(integer i = 0; i < 32; i = i + 1) begin
            for(integer j = 0; j < 32; j = j + 1) begin
                $fwrite(file, "%5d ", image[2][i][j]);
            end
            $fwrite(file, "\n");
        end
        $fwrite(file, "\n");

        $fwrite(file, "===========  DATA_SUM (not divide 1024)  ============\n");
        $fwrite(file, "%10d\n", out_data_temp);
    end
    $fwrite(file, "===========  GOLDEN_OUT_DATA  ============\n");
    $fwrite(file, "%10d\n", golden_out_data);

    $fwrite(file, "\n\n\n");
end endtask


function [7:0]diff_abs; 
    input [7:0]a;
    input [7:0]b;
    begin
        if(a > b)begin
            diff_abs = a - b;
        end
        else begin
            diff_abs = b - a;
        end
    end
endfunction


task display_pass; begin
    $display("-----------------------------------------------------------------");
    $display("                       Congratulations!                          ");
    $display("                You have passed all patterns!                     ");
    $display("                Your execution cycles = %5d cycles                ", total_latency);
    $display("                Your clock period = %.1f ns                       ", CYCLE);
    $display("                Total Latency = %.1f ns                          ", total_latency * CYCLE);
    $display("-----------------------------------------------------------------");
    repeat (2) @(negedge clk);
    $finish;
end endtask

task display_image; begin
    $display("===========    RED IMAGE     ==============\n");
    for(integer i = 0; i < 32; i = i + 1) begin
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d", image[0][i][0],image[0][i][1],image[0][i][2],image[0][i][3],image[0][i][4],image[0][i][5],image[0][i][6],image[0][i][7],image[0][i][8],image[0][i][9],image[0][i][10],image[0][i][11],image[0][i][12],image[0][i][13],image[0][i][14],image[0][i][15],image[0][i][16],image[0][i][17],image[0][i][18],image[0][i][19],image[0][i][20],image[0][i][21],image[0][i][22],image[0][i][23],image[0][i][24],image[0][i][25],image[0][i][26],image[0][i][27],image[0][i][28],image[0][i][29],image[0][i][30],image[0][i][31]);
    end
    $display("===========    GREEN IMAGE     ============\n");
    for(integer i = 0; i < 32; i = i + 1) begin
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d", image[1][i][0],image[1][i][1],image[1][i][2],image[1][i][3],image[1][i][4],image[1][i][5],image[1][i][6],image[1][i][7],image[1][i][8],image[1][i][9],image[1][i][10],image[1][i][11],image[1][i][12],image[1][i][13],image[1][i][14],image[1][i][15],image[1][i][16],image[1][i][17],image[1][i][18],image[1][i][19],image[1][i][20],image[1][i][21],image[1][i][22],image[1][i][23],image[1][i][24],image[1][i][25],image[1][i][26],image[1][i][27],image[1][i][28],image[1][i][29],image[1][i][30],image[1][i][31]);
    end
    $display("===========    BLUE IMAGE     ============\n");
    for(integer i = 0; i < 32; i = i + 1) begin
        $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d", image[2][i][0],image[2][i][1],image[2][i][2],image[2][i][3],image[2][i][4],image[2][i][5],image[2][i][6],image[2][i][7],image[2][i][8],image[2][i][9],image[2][i][10],image[2][i][11],image[2][i][12],image[2][i][13],image[2][i][14],image[2][i][15],image[2][i][16],image[2][i][17],image[2][i][18],image[2][i][19],image[2][i][20],image[2][i][21],image[2][i][22],image[2][i][23],image[2][i][24],image[2][i][25],image[2][i][26],image[2][i][27],image[2][i][28],image[2][i][29],image[2][i][30],image[2][i][31]);
    end
end endtask

endmodule