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
            mem[0] = 32'h00000000;
            mem[1] = 32'h00000001;
            mem[2] = 32'h00000002;
            mem[3] = 32'h00000003;// Initialize memory with some values
        end else begin
            instruction <= mem[pc[31:2]]; // Fetch instruction from memory
        end
    end
endmodule