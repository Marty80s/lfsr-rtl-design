`timescale 1ns/1ps
module programmable_lfsr (
    clk,
    rst_n,
    en,
    tap_in,
    seed_in,
    state,
    out_bit
);
    parameter N = 3;

    input  clk;
    input  rst_n;
    input  en;
    input  [N-1:0] tap_in;   // bit = 1 → that stage gets feedback
    input  [N-1:0] seed_in;  // initial seed
    output [N-1:0] state;    // current state
    output out_bit;

    reg [N-1:0] state_r;
    reg fb;
    integer i;

    assign state   = state_r;
    assign out_bit = state_r[0];  // LSB output

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state_r <= seed_in;  // load seed
        else if (en) begin
            fb = state_r[0];  // store feedback (LSB)
            state_r[N-1] <= fb;  // feedback into MSB

            for (i = 0; i < N-1; i = i + 1) begin
                if (tap_in[i])
                    state_r[i] <= state_r[i+1] ^ fb;
                else
                    state_r[i] <= state_r[i+1];
            end
        end
    end
endmodule

