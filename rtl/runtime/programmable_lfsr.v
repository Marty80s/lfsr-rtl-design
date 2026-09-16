`timescale 1ns/1ps

module programmable_lfsr
#( parameter N = 3 )                       // LFSR width
(
    input  wire              clk,
    input  wire              rst_n,
    input  wire              en,           // shift enable
    // runtime programming
    input  wire              tap_we,       // 1-cycle pulse to load taps
    input  wire [N-1:0]      tap_in,       // new taps
    input  wire              seed_we,      // 1-cycle pulse to load seed
    input  wire [N-1:0]      seed_in,      // new seed (must be non-zero)
    // outputs
    output reg  [N-1:0]      state,        // current state
    output wire              out_bit       // output bit (LSB)
);

    // Hold currently selected taps
    reg [N-1:0] tap_reg;

    // LSB is the output/feedback bit for right-shift Galois
    assign out_bit = state[0];

    // In Galois form (right shift), when out_bit==1 we XOR a mask
    // into the shifted register. The caller must set the MSB tap if needed.
    wire [N-1:0] eff_taps  = tap_reg;
    wire [N-1:0] shifted   = {1'b0, state[N-1:1]};
    wire [N-1:0] next_state= out_bit ? (shifted ^ eff_taps) : shifted;

    // Sequential logic (Verilog-2001 compliant: no declarations in blocks)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state   <= {{(N-1){1'b0}}, 1'b1}; // safe non-zero default
            tap_reg <= {N{1'b0}};             // no taps until programmed
        end else begin
            if (tap_we)  tap_reg <= tap_in;
            if (seed_we) state   <= seed_in;      // make sure seed_in != 0
            else if (en) state   <= next_state;
        end
    end

endmodule

