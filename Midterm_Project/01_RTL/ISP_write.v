module ISP(
    // Input Signals
    input clk,
    input rst_n,
    input in_valid,
    input [3:0] in_pic_no,
    input       in_mode,
    input [1:0] in_ratio_mode,

    // Output Signals
    output reg out_valid,
    output reg [7:0] out_data,
    
    // DRAM Signals
    // axi write address channel
    // src master
    output reg [3:0]  awid_s_inf,
    output reg [31:0] awaddr_s_inf,
    output reg [2:0]  awsize_s_inf,
    output reg [1:0]  awburst_s_inf,
    output reg [7:0]  awlen_s_inf,
    output reg        awvalid_s_inf,
    // src slave
    input         awready_s_inf,
    // -----------------------------
  
    // axi write data channel 
    // src master
    output reg [127:0] wdata_s_inf,
    output reg         wlast_s_inf,
    output reg         wvalid_s_inf,
    // src slave
    input          wready_s_inf,
  
    // axi write response channel 
    // src slave
    input [3:0]    bid_s_inf,
    input [1:0]    bresp_s_inf,
    input          bvalid_s_inf,
    // src master 
    output reg         bready_s_inf,
    // -----------------------------
  
    // axi read address channel 
    // src master
    output reg [3:0]   arid_s_inf,
    output reg [31:0]  araddr_s_inf,
    output reg [7:0]   arlen_s_inf,
    output reg [2:0]   arsize_s_inf,
    output reg [1:0]   arburst_s_inf,
    output reg         arvalid_s_inf,
    // src slave
    input          arready_s_inf,
    // -----------------------------
  
    // axi read data channel 
    // slave
    input [3:0]    rid_s_inf,
    input [127:0]  rdata_s_inf,
    input [1:0]    rresp_s_inf,
    input          rlast_s_inf,
    input          rvalid_s_inf,
    // master
    output reg         rready_s_inf
    
);

reg out_valid_next;
reg [7:0] out_data_next;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        out_data <= 0;
        out_valid <= 0;
    end
    else begin
        out_data <= out_data_next;
        out_valid <= out_valid_next;
    end
end


parameter IDLE = 3'b000, CORR = 3'b001, EXP = 3'b010, EXP_WAIT = 3'b011;
parameter EXP_COMP = 3'b100, OUTPUT = 3'b101;
reg [2:0] current_state, next_state;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end
end

reg [9:0] cnt, cnt_next;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 0;
    end
    else begin
        cnt <= cnt_next;
    end
end

always @(*) begin
    next_state = current_state;
    awid_s_inf = 4'b0;
    awaddr_s_inf = 32'b0;
    awsize_s_inf = 3'b100;
    awburst_s_inf = 2'b01;
    awlen_s_inf = 8'b0;
    awvalid_s_inf = 1'b0;
    cnt_next = cnt + 1;
    wdata_s_inf = 128'b0;
    wvalid_s_inf = 1'b0;
    wlast_s_inf = 1'b0;
    out_data_next = 8'b0;
    out_valid_next = 1'b0;
    bready_s_inf = 1'b0;

    case (current_state)
    IDLE: begin
        if (in_valid) begin
            next_state = CORR;
            cnt_next = 0;

        end
    end
    CORR: begin
        // cnt_next = cnt + 1;
        case (cnt)
        0: begin
            awvalid_s_inf = 1'b1;
            awaddr_s_inf = 32'h10000;
            awlen_s_inf = 191;
        end
        1: begin
            awvalid_s_inf = 1'b1;
            awaddr_s_inf = 32'h10000;
            awlen_s_inf = 191;
            // bready_s_inf = 1'b1;
            // wvalid_s_inf = 1'b1;
            // wdata_s_inf = 128'b1;
        end
        2: begin
            bready_s_inf = 1'b1;
            wvalid_s_inf = 1'b1;
            wdata_s_inf = 128'b1;
        end
        3 : begin
            bready_s_inf = 1'b1;
            wvalid_s_inf = 1'b1;
            wdata_s_inf = 128'b1;
        end
        4: begin
            bready_s_inf = 1'b1;
            wvalid_s_inf = 1'b1;
            wdata_s_inf = 128'b1;
        end
        5: begin
            // bready_s_inf = 1'b1;
            // wvalid_s_inf = 1'b1;
            // wdata_s_inf = 128'b1;
        end
        endcase
    end
    endcase
end

endmodule
