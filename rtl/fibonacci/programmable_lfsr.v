`timescale 1ns/1ps

module programmable_lfsr #(parameter N = 3) (
    input  wire clk,
    input  wire rst_n,
    input  wire en,
    input  wire [N-1:0] tap_in,   // User tap selection before start
    input  wire [N-1:0] seed_in,  // Initial seed value
    output reg  [N-1:0] state,    // Current state
    output wire out_bit           // Output bit (LSB)
);

    wire feedback;

    // Feedback = XOR of tapped bits
    assign feedback = ^(state & tap_in);

    // Output bit is LSB
    assign out_bit = state[0];

    // Sequential logic for LFSR
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= seed_in; // Load seed on reset
        else if (en)
            state <= {feedback, state[N-1:1]}; // Shift with feedback
    end

endmodule
