`timescale 1ns/100ps

module mux_32b_4to1(
    input [31:0] in0, // First input
    input [31:0] in1, // Second input
    input [31:0] in2, // Third input
    input [31:0] in3, // Fourth input
    input [1:0] sel,  // Select signal
    output [31:0] out // Output
);

    assign #1 out = (sel == 2'b00) ? in0 : // Select in0 if sel is 00
                   (sel == 2'b01) ? in1 : // Select in1 if sel is 01
                   (sel == 2'b10) ? in2 : // Select in2 if sel is 10
                                    in3;   // Select in3 if sel is 11
endmodule