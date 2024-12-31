module FIFO_syn #(parameter WIDTH=8, parameter WORDS=64) (
    wclk,
    rclk,
    rst_n,
    winc,
    wdata,
    wfull,
    rinc,
    rdata,
    rempty,

    flag_fifo_to_clk2,
    flag_clk2_to_fifo,

    flag_fifo_to_clk1,
	flag_clk1_to_fifo
);

input wclk, rclk;
input rst_n;
input winc;
input [WIDTH-1:0] wdata;
output reg wfull;
input rinc;
output reg [WIDTH-1:0] rdata;
output reg rempty;

// You can change the input / output of the custom flag ports
output  flag_fifo_to_clk2;
input flag_clk2_to_fifo;

output reg flag_fifo_to_clk1;
input flag_clk1_to_fifo;

wire [WIDTH-1:0] rdata_q;

// Remember: 
//   wptr and rptr should be gray coded
//   Don't modify the signal name
wire [$clog2(WORDS):0] wptr;
wire [$clog2(WORDS):0] rptr;

reg [6:0] waddr, raddr;
reg [6:0] waddr_next, raddr_next;
reg [6:0] rq2_wptr, wq2_rptr;

reg wen;

bin2gry w_bin2gry(
    .bin(waddr),
    .gry(wptr)
);

bin2gry r_bin2gry(
    .bin(raddr),
    .gry(rptr)
);

DUAL_64X8X1BM1 u_dual_sram (
    .CKA(wclk),
    .CKB(rclk),
    .WEAN(1'b0), // always enable write
    .WEBN(1'b1), // always disable write
    .CSA(wen),
    .CSB(1'b1),
    .OEA(1'b1),
    .OEB(1'b1),
	// 6 bit addr
    .A0(waddr[0]),
    .A1(waddr[1]),
    .A2(waddr[2]),
    .A3(waddr[3]),
    .A4(waddr[4]),
    .A5(waddr[5]),

    .B0(raddr[0]),
    .B1(raddr[1]),
    .B2(raddr[2]),
    .B3(raddr[3]),
    .B4(raddr[4]),
    .B5(raddr[5]),

    .DIA0(wdata[0]),
    .DIA1(wdata[1]),
    .DIA2(wdata[2]),
    .DIA3(wdata[3]),
    .DIA4(wdata[4]),
    .DIA5(wdata[5]),
    .DIA6(wdata[6]),
    .DIA7(wdata[7]),
    
    .DIB0(1'b0),
    .DIB1(1'b0),
    .DIB2(1'b0),
    .DIB3(1'b0),
    .DIB4(1'b0),
    .DIB5(1'b0),
    .DIB6(1'b0),
    .DIB7(1'b0),
    
    .DOB0(rdata_q[0]),
    .DOB1(rdata_q[1]),
    .DOB2(rdata_q[2]),
    .DOB3(rdata_q[3]),
    .DOB4(rdata_q[4]),
    .DOB5(rdata_q[5]),
    .DOB6(rdata_q[6]),
    .DOB7(rdata_q[7])
);

NDFF_BUS_syn #(7) SYNC_W2R (.D(wptr), .Q(rq2_wptr), .clk(rclk), .rst_n(rst_n));
NDFF_BUS_syn #(7) SYNC_R2W (.D(rptr), .Q(wq2_rptr), .clk(wclk), .rst_n(rst_n));

// write side
always @(*) begin
    wfull = (wptr ^ wq2_rptr) == 7'b1100000;
end

always @(*) begin
    wen = winc && !wfull;
end

always @(posedge wclk or negedge rst_n) begin
    if (!rst_n) begin
        waddr <= 0;
    end
    else begin
        waddr <= waddr;
        if ((!wfull && winc)) begin
            waddr <= waddr + 1;
        end
    end
end

// read side
always @(*) begin
    rempty = (rptr == rq2_wptr);
end

always @(posedge rclk or negedge rst_n) begin
    if (!rst_n) begin
        raddr <= 0;
        rdata <= 0;
    end
    else begin
        raddr <= raddr;
        rdata <= rdata_q;
        if (!((rptr == rq2_wptr)) && rinc) begin
            raddr <= raddr + 1;
        end
    end
end

endmodule



module bin2gry (
    input [6:0] bin,
    output reg [6:0] gry
);
    always @ (*) begin 
        case (bin) 
            0 :   gry = 7'b0000000 ;
            1 :   gry = 7'b0000001 ;
            2 :   gry = 7'b0000011 ;
            3 :   gry = 7'b0000010 ;
            4 :   gry = 7'b0000110 ;
            5 :   gry = 7'b0000111 ;
            6 :   gry = 7'b0000101 ;
            7 :   gry = 7'b0000100 ;
            8 :   gry = 7'b0001100 ;
            9 :   gry = 7'b0001101 ;
            10 :  gry = 7'b0001111 ;
            11 :  gry = 7'b0001110 ;
            12 :  gry = 7'b0001010 ;
            13 :  gry = 7'b0001011 ;
            14 :  gry = 7'b0001001 ;
            15 :  gry = 7'b0001000 ;
            16 :  gry = 7'b0011000 ;
            17 :  gry = 7'b0011001 ;
            18 :  gry = 7'b0011011 ;
            19 :  gry = 7'b0011010 ;
            20 :  gry = 7'b0011110 ;
            21 :  gry = 7'b0011111 ;
            22 :  gry = 7'b0011101 ;
            23 :  gry = 7'b0011100 ;
            24 :  gry = 7'b0010100 ;
            25 :  gry = 7'b0010101 ;
            26 :  gry = 7'b0010111 ;
            27 :  gry = 7'b0010110 ;
            28 :  gry = 7'b0010010 ;
            29 :  gry = 7'b0010011 ;
            30 :  gry = 7'b0010001 ;
            31 :  gry = 7'b0010000 ;
            32 :  gry = 7'b0110000 ;
            33 :  gry = 7'b0110001 ;
            34 :  gry = 7'b0110011 ;
            35 :  gry = 7'b0110010 ;
            36 :  gry = 7'b0110110 ;
            37 :  gry = 7'b0110111 ;
            38 :  gry = 7'b0110101 ;
            39 :  gry = 7'b0110100 ;
            40 :  gry = 7'b0111100 ;
            41 :  gry = 7'b0111101 ;
            42 :  gry = 7'b0111111 ;
            43 :  gry = 7'b0111110 ;
            44 :  gry = 7'b0111010 ;
            45 :  gry = 7'b0111011 ;
            46 :  gry = 7'b0111001 ;
            47 :  gry = 7'b0111000 ;
            48 :  gry = 7'b0101000 ;
            49 :  gry = 7'b0101001 ;
            50 :  gry = 7'b0101011 ;
            51 :  gry = 7'b0101010 ;
            52 :  gry = 7'b0101110 ;
            53 :  gry = 7'b0101111 ;
            54 :  gry = 7'b0101101 ;
            55 :  gry = 7'b0101100 ;
            56 :  gry = 7'b0100100 ;
            57 :  gry = 7'b0100101 ;
            58 :  gry = 7'b0100111 ;
            59 :  gry = 7'b0100110 ;
            60 :  gry = 7'b0100010 ;
            61 :  gry = 7'b0100011 ;
            62 :  gry = 7'b0100001 ;
            63 :  gry = 7'b0100000 ;
            64 :  gry = 7'b1100000 ;
            65 :  gry = 7'b1100001 ;
            66 :  gry = 7'b1100011 ;
            67 :  gry = 7'b1100010 ;
            68 :  gry = 7'b1100110 ;
            69 :  gry = 7'b1100111 ;
            70 :  gry = 7'b1100101 ;
            71 :  gry = 7'b1100100 ;
            72 :  gry = 7'b1101100 ;
            73 :  gry = 7'b1101101 ;
            74 :  gry = 7'b1101111 ;
            75 :  gry = 7'b1101110 ;
            76 :  gry = 7'b1101010 ;
            77 :  gry = 7'b1101011 ;
            78 :  gry = 7'b1101001 ;
            79 :  gry = 7'b1101000 ;
            80 :  gry = 7'b1111000 ;
            81 :  gry = 7'b1111001 ;
            82 :  gry = 7'b1111011 ;
            83 :  gry = 7'b1111010 ;
            84 :  gry = 7'b1111110 ;
            85 :  gry = 7'b1111111 ;
            86 :  gry = 7'b1111101 ;
            87 :  gry = 7'b1111100 ;
            88 :  gry = 7'b1110100 ;
            89 :  gry = 7'b1110101 ;
            90 :  gry = 7'b1110111 ;
            91 :  gry = 7'b1110110 ;
            92 :  gry = 7'b1110010 ;
            93 :  gry = 7'b1110011 ;
            94 :  gry = 7'b1110001 ;
            95 :  gry = 7'b1110000 ;
            96 :  gry = 7'b1010000 ;
            97 :  gry = 7'b1010001 ;
            98 :  gry = 7'b1010011 ;
            99 :  gry = 7'b1010010 ;
            100 : gry = 7'b1010110 ;
            101 : gry = 7'b1010111 ;
            102 : gry = 7'b1010101;
            103 : gry = 7'b1010100 ;
            104 : gry = 7'b1011100 ;
            105 : gry = 7'b1011101 ;
            106 : gry = 7'b1011111 ;
            107 : gry = 7'b1011110 ;
            108 : gry = 7'b1011010 ;
            109 : gry = 7'b1011011 ;
            110 : gry = 7'b1011001 ;
            111 : gry = 7'b1011000 ;
            112 : gry = 7'b1001000 ;
            113 : gry = 7'b1001001 ;
            114 : gry = 7'b1001011 ;
            115 : gry = 7'b1001010 ;
            116 : gry = 7'b1001110 ;
            117 : gry = 7'b1001111 ;
            118 : gry = 7'b1001101 ;
            119 : gry = 7'b1001100 ;
            120 : gry = 7'b1000100 ;
            121 : gry = 7'b1000101 ;
            122 : gry = 7'b1000111 ;
            123 : gry = 7'b1000110 ;
            124 : gry = 7'b1000010 ;
            125 : gry = 7'b1000011 ;
            126 : gry = 7'b1000001 ;
            127 : gry = 7'b1000000 ;
            default : gry = 7'b0000000 ;
        endcase          
end
endmodule
