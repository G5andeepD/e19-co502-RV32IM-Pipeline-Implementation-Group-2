`timescale 1ns/100ps

module imem(
    input clk, 
    input reset, 
    input [31:0] pc, 
    output reg [31:0] instruction);

    reg [31:0] mem[0:1023]; // Memory array

    always @(posedge clk) begin
        if (reset) begin
            instruction <= 32'b0; // Reset instruction to 0
            mem[0] = 32'h00500093; // Add immediate instruction (ADDI x1, x0, 5)
            mem[1] = 32'h00300113; // Add immediate instruction (ADDI x2, x0, 3)
            mem[2] = 32'h00000213; // Add immediate instruction (ADDI x4, x0, 0)
            mem[3] = 32'h00000293; // Add immediate instruction (ADDI x5, x0, 0)
            mem[4] = 32'h00000313; // Add immediate instruction (ADDI x6, x0, 0)
            mem[5] = 32'h00000393; // Add immediate instruction (ADDI x7, x0, 0)
            mem[6] = 32'h002081B3; // (ADD, x3, x1, x2)
        end else begin
            instruction <= mem[pc[31:2]]; // Fetch instruction from memory
        end
    end
endmodule