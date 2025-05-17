`timescale 1ns/100ps

module adder_32b(
    input [31:0] a, // First operand
    input [31:0] b, // Second operand
    output [31:0] sum // Sum output
);
    assign sum = a + (b<<2); // Perform addition with a delay of 1 time unit
endmodule