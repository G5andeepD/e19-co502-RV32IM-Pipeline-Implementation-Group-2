`timescale 1ns/100ps

module imem(
    input clk, 
    input reset, 
    input [31:0] pc, 
    output reg [31:0] instruction
);

    reg [31:0] mem[0:1023]; // Memory array

    initial begin
        $readmemh("imem2.mem", mem); // Load hexadecimal instructions
    end

    always @(negedge clk) begin
        if (reset) begin
            instruction <= 32'b0; // Clear instruction
        end else begin
            instruction <= mem[pc[31:2]]; // Fetch instruction
        end
    end

endmodule
