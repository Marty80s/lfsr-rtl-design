`timescale 1ns/1ps

module programmable_lfsr #(
    parameter N = 8
)(
    input              clk,
    input              rst_n,

    // Run control
    input              en,          // assert to start shifting

    // One-time tap programming (before en=1)
    input              tap_sel_we,  // pulse high to latch taps
    input  [N-1:0]     tap_sel_in,  // e.g., 8'b0000_0011 taps last & second-last FFs

    // Optional seed load
    input              seed_we,     // pulse high to load seed_in
    input  [N-1:0]     seed_in,

    // Status / outputs
    output [N-1:0]     state,
    output             out_bit      // LSB/serial out
);

    // State and taps
    reg  [N-1:0] state_r;
    reg  [N-1:0] tap_mask;

    // Lock taps once shifting has begun
    reg          locked;

    // Feedback: XOR of the currently tapped FF outputs
    wire         feedback;

    assign state   = state_r;
    assign out_bit = state_r[0];                 // define LSB as "last" FF/serial out
    assign feedback = ^(state_r & tap_mask);     // XOR reduce of tapped bits

    // Lock goes high the first cycle en=1, and stays high until reset
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            locked <= 1'b0;
        else if (en)
            locked <= 1'b1;
    end

    // Main sequential logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_r  <= {{(N-1){1'b0}}, 1'b1};  // default non-zero seed
            tap_mask <= {N{1'b0}};              // no taps until programmed
        end else begin
            // Latch taps only before run (locked==0)
            if (tap_sel_we && !locked)
                tap_mask <= tap_sel_in;

            // Load seed (typically before en=1)
            if (seed_we)
                state_r <= seed_in;
            else if (en)
                // Shift-right; insert feedback at MSB
                state_r <= {feedback, state_r[N-1:1]};
        end
    end

endmodule

