`timescale 1ns / 1ps

module recognizer_100(
    input clk,
    input reset,
    input x,
    output y
);

reg q0,q1;
wire g0,g1,g2,g3,g4,g5;
wire d0,d1;

assign g0 = ~x;
assign g1 = q1 ^ q0;
assign g2 = g0 & g1;
assign g3 = ~q1;
assign g4 = g3 & q0;
assign g5 = g4 | x;

assign d0 = g5;
assign d1 = g2;
assign y = q0 & q1;

always @ (posedge clk) begin
    if (~reset) begin
        q0 <= 1'b0;
        q1 <= 1'b0;
    end
    else begin
        q0 <= d0;
        q1 <= d1;
    end
end
endmodule
