// Intermediate pipeline register module for in between Execute and Memory stages

//
// This module is used to hold the ALU result and control signals between the EX and MA stages
// of the pipeline. It is a simple register that captures the values on the rising edge of the clock.
// It also has a reset signal to clear the values when needed.

`timescale 1ns/100ps

module EX_MA_reg (
    ALU_RESULT, // Input ALU result from EX stage
    DEST_REG, // Input destination register address from ID stage
    PC_PLUS_4, // Input PC+4 value from ID stage
    IMMEDIATE, // Input immediate value from ID stage
    MEM_WRITE, // Input memory write signal from EX stage
    MEM_READ, // Input memory read signal from EX stage
    REG_WRITE_SEL, // Input register write select signal from EX stage
    REG_WRITE_ENABLE, // Input register write enable signal from EX stage
    PC_SEL,
    CLK, // Clock signal
    RESET, // Reset signal
    OUT_ALU_RESULT, // Output ALU result to MA stage
    OUT_DEST_REG, // Output destination register address to MA stage
    OUT_PC_PLUS_4, // Output PC+4 value to MA stage
    OUT_IMMEDIATE, // Output immediate value to MA stage
    OUT_MEM_WRITE, // Output memory write signal to MA stage
    OUT_MEM_READ, // Output memory read signal to MA stage
    OUT_REG_WRITE_SEL, // Output register write select signal to MA stage
    OUT_REG_WRITE_ENABLE, // Output register write enable signal to MA stage
    OUT_PC_SEL
);

    // Defining input/output ports
    input [31:0] ALU_RESULT; // Input ALU result
    input [4:0] DEST_REG; // Input destination register address
    input [31:0] PC_PLUS_4; // Input PC+4 value
    input [31:0] IMMEDIATE; // Input immediate value
    input [1:0] MEM_WRITE; // Input memory write signal
    input [1:0] MEM_READ; // Input memory read signal
    input [1:0] REG_WRITE_SEL; // Input register write select signal
    input REG_WRITE_ENABLE; // Input register write enable signal
    input PC_SEL;
    input CLK; // Clock signal
    input RESET; // Reset signal

    output reg [31:0] OUT_ALU_RESULT; // Output ALU result
    output reg [4:0] OUT_DEST_REG; // Output destination register address
    output reg [31:0] OUT_PC_PLUS_4; // Output PC+4 value
    output reg [31:0] OUT_IMMEDIATE; // Output immediate value
    output reg [1:0] OUT_MEM_WRITE; // Output memory write signal
    output reg [1:0] OUT_MEM_READ; // Output memory read signal
    output reg [1:0] OUT_REG_WRITE_SEL; // Output register write select signal
    output reg OUT_REG_WRITE_ENABLE; // Output register write enable signal
    output reg OUT_PC_SEL;

    // On the rising edge of the clock or when reset is high
    always @ (posedge CLK or posedge RESET) begin
        if (RESET) begin
            // If reset is high, clear the output registers
            OUT_ALU_RESULT <= 32'd0;
            OUT_DEST_REG <= 5'd0;
            OUT_PC_PLUS_4 <= 32'd0;
            OUT_IMMEDIATE <= 32'd0;
            OUT_MEM_WRITE <= 2'b00;
            OUT_MEM_READ <= 2'b00;
            OUT_REG_WRITE_SEL <= 2'b00;
            OUT_REG_WRITE_ENABLE <= 1'b0;
            OUT_PC_SEL <= 1'b0;
        end else begin
            // Otherwise, capture the input values
            OUT_ALU_RESULT <= ALU_RESULT;
            OUT_DEST_REG <= DEST_REG;
            OUT_PC_PLUS_4 <= PC_PLUS_4;
            OUT_IMMEDIATE <= IMMEDIATE;
            OUT_MEM_WRITE <= MEM_WRITE;
            OUT_MEM_READ <= MEM_READ;
            OUT_REG_WRITE_SEL <= REG_WRITE_SEL;
            OUT_REG_WRITE_ENABLE <= REG_WRITE_ENABLE;
            OUT_PC_SEL <= PC_SEL;
        end
    end
endmodule