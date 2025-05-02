`timescale 1ns/100ps

module mux_32b_2to1(
    input [31:0] in0, // First input
    input [31:0] in1, // Second input
    input sel,        // Select signal
    output [31:0] out // Output
);

    assign #1 out = (sel) ? in1 : in0; // Select between in0 and in1 based on sel
endmodule


