`timescale 1ns/100ps

//
// Memory module for data memory

module dmem(
    input [31:0] address, // Address input
    input [31:0] data_in, // Data input
    input [1:0] mem_write, // Memory write signal
    input [1:0] mem_read, // Memory read signal
    input clk, // Clock signal
    input reset, // Reset signal
    output reg [31:0] data_out // Data output
);
    reg [31:0] memory [0:1023]; // Memory array (1024 words of 32 bits each)

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Optionally clear memory for simulation
            // integer i;
            // for (i = 0; i < 1024; i = i + 1) memory[i] <= 0;
        end else if (mem_write == 2'b01) begin
            memory[address] <= data_in;
        end
    end

    always @(*) begin
        if (mem_read == 2'b01)
            data_out = memory[address];
        else
            data_out = 32'b0;
    end
endmodule