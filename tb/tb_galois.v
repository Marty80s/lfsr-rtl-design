`timescale 1ns/1ps

module tb_galois_lfsr;

    // Parameters
    parameter N = 3;  // Width of LFSR

    // DUT I/O
    reg clk;
    reg rst_n;
    reg en;
    reg [N-1:0] tap_in;   // tap mask (1 = tap that bit)
    reg [N-1:0] seed_in;  // initial seed
    wire [N-1:0] state;
    wire out_bit;

    // Instantiate DUT
    programmable_lfsr #(.N(N)) DUT (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .tap_in(tap_in),
        .seed_in(seed_in),
        .state(state),
        .out_bit(out_bit)
    );

    // Clock generation (period = 10ns)
    initial clk = 0;
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        // Initialize
        rst_n = 0;
        en = 0;
        tap_in = 3'b011;   // taps at bits 1 and 0
        seed_in = 3'b001;  // starting seed

        // Apply reset
        #10 rst_n = 1;

        // Enable LFSR
        #10 en = 1;
        $display("\nTime\tState\tOutBit");
        $monitor("%4t\t%b\t%b", $time, state, out_bit);

        // Run for 16 cycles
        repeat(16) @(posedge clk);

        // Stop simulation
        en = 0;
        #10;
        $display("\nSimulation complete.");
        $finish;
    end

endmodule
