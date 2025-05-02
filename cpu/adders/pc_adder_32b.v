// Adder for the program counter

`timescale 1ns/100ps

module pc_adder_32b(
    input [31:0] pc_in, // Input program counter value
    output [31:0] pc_out // Output program counter value
);
    assign #1 pc_out = pc_in + 4; // Increment the program counter by 4
endmodule