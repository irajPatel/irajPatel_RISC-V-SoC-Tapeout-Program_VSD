`timescale 1ns / 1ps

module FIR_Filters(
    input clk,
    input reset,
    input  signed [15:0] data_in,   // signed input
    output reg signed [15:0] data_out // signed output
);

    parameter N = 16;   // input/output width
    parameter TAPS = 4; // 4-tap Moving Average FIR
    parameter COEFF_WIDTH = 6; // coefficient bit width
    parameter SCALE = 128;     // scaling factor for fixed-point

    // --------------------------------------------------
    // Coefficients (Moving Average 3rd order → 4 taps)
    // Value: 1/4 = 0.25 → scaled by 128 = 32
    // --------------------------------------------------
    wire signed [COEFF_WIDTH-1:0] b [0:TAPS-1];
    assign b[0] = 32;
    assign b[1] = 32;
    assign b[2] = 32;
    assign b[3] = 32;

    // --------------------------------------------------
    // Delay line for input samples
    // --------------------------------------------------
    wire signed [N-1:0] x [0:TAPS-1];

    assign x[0] = data_in; // current input

    genvar i;
    generate
        for (i = 1; i < TAPS; i = i + 1) begin : delay_line
            DFF #(N) dff_inst (
                .clk(clk),
                .reset(reset),
                .data_in(x[i-1]),
                .data_delayed(x[i])
            );
        end
    endgenerate

    // --------------------------------------------------
    // Multiply-Accumulate
    // Each product = 16-bit * 6-bit = 22-bit
    // --------------------------------------------------
    wire signed [21:0] mul [0:TAPS-1];
    assign mul[0] = x[0] * b[0];
    assign mul[1] = x[1] * b[1];
    assign mul[2] = x[2] * b[2];
    assign mul[3] = x[3] * b[3];

    // --------------------------------------------------
    // Final sum (extra 2 bits growth for addition safety)
    // --------------------------------------------------
    wire signed [23:0] sum;
    assign sum = mul[0] + mul[1] + mul[2] + mul[3];

    // --------------------------------------------------
    // Scale down to 16-bit output
    // Shift right by log2(SCALE) = 7 (since SCALE=128)
    // --------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset)
            data_out <= 0;
        else
            data_out <= sum[23:7]; // properly scaled to signed 16-bit
    end

endmodule

// --------------------------------------------------
// Parameterized D Flip-Flop (signed friendly)
// --------------------------------------------------
module DFF #(parameter N = 16)(
    input clk,
    input reset,
    input signed [N-1:0] data_in,
    output reg signed [N-1:0] data_delayed
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            data_delayed <= 0;
        else
            data_delayed <= data_in;
    end

endmodule
