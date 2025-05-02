`timescale 1ns/100ps

//
// Memory module for data memory

module dmem(
    input [31:0] address, // Address input
    input [31:0] data_in, // Data input
    input mem_write, // Memory write signal
    input mem_read, // Memory read signal
    output reg [31:0] data_out // Data output
);
    reg [31:0] memory [0:1023]; // Memory array (1024 words of 32 bits each)

    always @(*) begin
        if (mem_read) begin
            data_out = memory[address]; // Read data from memory
        end else begin
            data_out = 32'bz; // High impedance state when not reading
        end
    end

    always @(posedge mem_write) begin
        memory[address] <= data_in; // Write data to memory on write signal
    end
endmodule