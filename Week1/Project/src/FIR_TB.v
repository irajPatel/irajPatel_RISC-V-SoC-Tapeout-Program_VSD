`timescale 1ns / 1ps

module FIR_TB;

    parameter N = 16;

    // Clock, reset, input, output
    reg clk;
    reg reset;
    reg [N-1:0] data_in;
    wire [N-1:0] data_out;

    // Instantiate FIR filter
    FIR_Filters inst0(
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .data_out(data_out)
    );

    // -------------------------------
    // Create RAM for input signal
    // -------------------------------
    reg [N-1:0] RAMM [0:99]; // 32 samples

    initial begin
        $readmemb("signal.data", RAMM); // read signal file
    end

    // -------------------------------
    // Clock generation (50 MHz)
    // -------------------------------
    initial clk = 0;
    always #10 clk = ~clk; // 20ns period -> 50 MHz

    // -------------------------------
    // Reset
    // -------------------------------
    initial begin
        reset = 1;
        #25;           // hold reset for some cycles
        reset = 0;
    end

    // -------------------------------
    // Address counter to read RAM
    // -------------------------------
    reg [4:0] Address; // 5-bit for 32 samples

    initial Address = 0;
    always @(posedge clk) begin
        if (reset)
            Address <= 0;
        else if (Address == 99)
            Address <= 0;
        else
            Address <= Address + 1;
    end

    // -------------------------------
    // Apply RAMM data to data_in
    // -------------------------------
    always @(posedge clk) begin
        if (~reset)
            data_in <= RAMM[Address];
        else
            data_in <= 0;
    end

    // -------------------------------
    // GTKWave dump (limited duration)
    // -------------------------------
    initial begin
        $dumpfile("FIR_TB.vcd");
        $dumpvars(0, FIR_TB);  // dump all signals in this module

        // Stop dumping after 2000 ns (file size remains manageable)
        #4000;
        $display("Finished dumping VCD at time %0t ns", $time);
        $finish; // stop dumping but simulation continues
    end

    // -------------------------------
    // Optional: monitor signals
    // -------------------------------
    initial begin
        $display("Time\tclk\treset\tAddress\tdata_in\tdata_out");
        $monitor("%0t\t%b\t%b\t%d\t%h\t%h", $time, clk, reset, Address, data_in, data_out);
    end

endmodule
