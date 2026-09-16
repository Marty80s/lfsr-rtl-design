`timescale 1ns/1ps

module tb_prog_galois_lfsr_rt;

    parameter N = 3;   // Width of LFSR

    // DUT signals
    reg clk;
    reg rst_n;
    reg en;
    reg tap_we;
    reg seed_we;
    reg [N-1:0] tap_in;
    reg [N-1:0] seed_in;
    wire [N-1:0] state;
    wire out_bit;

    // Instantiate DUT
    programmable_lfsr #(.N(N)) DUT (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .tap_we(tap_we),
        .tap_in(tap_in),
        .seed_we(seed_we),
        .seed_in(seed_in),
        .state(state),
        .out_bit(out_bit)
    );

    // Clock generation: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        // Initialize
        rst_n   = 0;
        en      = 0;
        tap_we  = 0;
        seed_we = 0;
        tap_in  = 0;
        seed_in = 0;

        // Reset
        #12 rst_n = 1;

        // Program tap vector (runtime)
        // Example: taps at bits 3, 1, and 0
        @(posedge clk);
        tap_in <= 3'b011;
        tap_we <= 1'b1;
        @(posedge clk);
        tap_we <= 1'b0;

        // Load seed (non-zero)
        @(posedge clk);
        seed_in <= 3'b011;
        seed_we <= 1'b1;
        @(posedge clk);
        seed_we <= 1'b0;

        // Start LFSR
        @(posedge clk);
        en <= 1'b1;

        $display("\nTime\tState\tOutBit");
        $monitor("%4t\t%b\t%b", $time, state, out_bit);

        // Run for a while
        repeat(12) @(posedge clk);

        // Change taps during run
        @(posedge clk);
        tap_in <= 3'b101;   // change tap pattern
        tap_we <= 1'b1;
        @(posedge clk);
        tap_we <= 1'b0;

        // Continue running
        repeat(12) @(posedge clk);
        en <= 1'b0;

        #20;
        $display("\nSimulation complete.\n");
        $finish;
    end

endmodule



