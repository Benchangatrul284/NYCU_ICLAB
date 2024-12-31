module Handshake_syn #(parameter WIDTH=8) (
    sclk,
    dclk,
    rst_n,
    sready,
    din,
    dbusy,
    sidle,
    dvalid,
    dout,

    flag_handshake_to_clk1,
    flag_clk1_to_handshake,

    flag_handshake_to_clk2,
    flag_clk2_to_handshake
);

input sclk, dclk;
input rst_n;
input sready;
input [WIDTH-1:0] din; // sender
input dbusy; // receiver
output reg sidle; // sender
output reg dvalid; // receiver
output reg [WIDTH-1:0] dout; // receiver

// You can change the input / output of the custom flag ports
output reg flag_handshake_to_clk1;
input flag_clk1_to_handshake;

output flag_handshake_to_clk2;
input flag_clk2_to_handshake;

// Remember:
//   Don't modify the signal name
reg sreq;
wire dreq;
reg dack;
wire sack;

// sready: indicate if sender want to send data.
// sidle: indicate if handshake synchronizer is idle.
// dbusy: indicate if receiver want to receive data.
// dvalid: indicate if handshake synchronizer want to send data.

NDFF_syn N0 (.D(sreq), .Q(dreq), .clk(dclk), .rst_n(rst_n));
NDFF_syn N1 (.D(dack), .Q(sack), .clk(sclk), .rst_n(rst_n));

reg [WIDTH-1:0] data;

parameter s_IDLE = 0, s_BUSY = 1;
parameter d_IDLE = 0, d_BUSY = 1;
reg s_current_state, d_current_state;


always @(*) begin
    sidle = (sreq || sack) ? 0 : 1 ;
end

always @(posedge sclk or negedge rst_n) begin
    if (!rst_n) begin
        s_current_state <= s_IDLE;
        sreq <= 0;
        data <= 0;
        // sidle <= 1;
    end
    else begin
        case (s_current_state)
        s_IDLE: begin // wait for sready signal
            // sidle <= 1;
            if (sready) begin
                sreq <= 1;
                data <= din;
                s_current_state <= s_BUSY;
            end
        end
        s_BUSY: begin
            // sidle <= 0;
            if (sack) begin // wait for receiver ack
                sreq <= 0;
                s_current_state <= s_IDLE;
            end
        end
        endcase
    end
end

always @(posedge dclk or negedge rst_n) begin
    if (!rst_n) begin
        dvalid <= 0;
        dack <= 0;
        dout <= 0;
        d_current_state <= d_IDLE;
    end
    else begin
        case (d_current_state)
        d_IDLE: begin // wait for request signal
            if (dreq && ~dbusy) begin // if request signal is high and receiver is not busy
                dack <= 1; // send ack signal to sender
                dvalid <= 1;
                dout <= data;
                d_current_state <= d_BUSY;
            end
        end
        d_BUSY: begin // wait for the sender to ack so dreq is low
            dvalid <= 0;
            if (dreq == 0) begin // if sender ack
                dack <= 0; 
                d_current_state <= d_IDLE;
            end
        end
        endcase
    end
end

endmodule