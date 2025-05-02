// extend the immediate value to 32 bits

`timescale 1ns/100ps

module sign_extender(
    input [24:0] imm12, // 24-bit immediate value
    output reg [31:0] imm32 // 32-bit extended immediate value
);
    always @(*) begin
    // Sign-extend the immediate value
        if (imm12[24] == 1'b1) begin
            imm32 = {7'b1111111, imm12}; // If the sign bit is 1, extend with 1s
        end else begin
            imm32 = {7'b0000000, imm12}; // If the sign bit is 0, extend with 0s
        end
    end