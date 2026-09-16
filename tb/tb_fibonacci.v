`timescale 1ns/1ps

module tb_programmable_lfsr;

    // --- Parameters ---
    parameter N = 3;  // Width of LFSR

    // --- DUT I/O ---
    reg clk;
    reg rst_n;
    reg en;
    reg [N-1:0] tap_in;   // Tap selection (set once before run)
    reg [N-1:0] seed_in;  // Initial seed
    wire [N-1:0] state;
    wire out_bit;

    // --- Instantiate DUT ---
    programmable_lfsr #(.N(N)) DUT (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .tap_in(tap_in),
        .seed_in(seed_in),
        .state(state),
        .out_bit(out_bit)
    );

    // --- Clock Generation ---
    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz

    // --- Test Procedure ---
    initial begin
        // Initialize
        rst_n = 0;
        en = 0;
        tap_in = 3'b011;   // Tap 2nd and 3rd FF outputs
        seed_in = 3'b001;  // Seed value

        // Apply reset
        #10 rst_n = 1;

        // Enable LFSR operation
        #10 en = 1;
        $display("\nTime\tState\tOutBit");
        $monitor("%4t\t%b\t%b", $time, state, out_bit);

        // Run for 20 cycles
        repeat(20) @(posedge clk);

        // Stop simulation
        en = 0;
        #10;
        $display("\nSimulation complete.");
        $finish;
    end

endmodule
