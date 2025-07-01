// Intermediate pipeline register module for in between Instruction Decode and Execute stages

// This module is used to hold the control signals and register values between the ID and EX stages
// of the pipeline. It is a simple register that captures the values on the rising edge of the clock.
// It also has a reset signal to clear the values when needed.

`timescale 1ns/100ps

module ID_EX_reg (
    DEST_REG, // Input destination register address from ID stage
    PC_PLUS_4, // Input PC+4 value from ID stage
    READ_DATA1, // Input read data 1 from ID stage
    READ_DATA2, // Input read data 2 from ID stage
    IMMEDIATE, // Input immediate value from ID stage
    ALU_OP, // Input ALU operation code from ID stage
    BRANCH_JUMP, // Input branch/jump signal from ID stage
    OP_SEL, // Input second operand select signal from ID stage
    MEM_WRITE, // Input memory write signal from ID stage
    MEM_READ, // Input memory read signal from ID stage
    REG_WRITE_SEL, // Input register write select signal from ID stage
    REG_WRITE_ENABLE, // Input register write enable signal from ID stage
    IS_LOAD, // Input: is this a load instruction?
    CLK, // Clock signal
    RESET, // Reset signal
    ENABLE, // Enable signal for pipeline stalling
    OUT_DEST_REG, // Output destination register address to EX stage
    OUT_PC_PLUS_4, // Output PC+4 value to EX stage
    OUT_READ_DATA1, // Output read data 1 to EX stage
    OUT_READ_DATA2, // Output read data 2 to EX stage
    OUT_IMMEDIATE, // Output immediate value to EX stage
    OUT_ALU_OP, // Output ALU operation code to EX stage
    OUT_BRANCH_JUMP, // Output branch/jump signal to EX stage
    OUT_OP_SEL, // Output second operand select signal to EX stage
    OUT_MEM_WRITE, // Output memory write signal to EX stage
    OUT_MEM_READ, // Output memory read signal to EX stage
    OUT_REG_WRITE_SEL, // Output register write select signal to EX stage
    OUT_REG_WRITE_ENABLE, // Output register write enable signal to EX stage
    OUT_IS_LOAD // Output: is this a load instruction to EX stage
);

    // Defining input/output ports
    input [4:0] DEST_REG; // Input destination register address
    input [31:0] PC_PLUS_4; // Input PC+4 value
    input [31:0] READ_DATA1; // Input read data 1
    input [31:0] READ_DATA2; // Input read data 2
    input [31:0] IMMEDIATE; // Input immediate value
    input [4:0] ALU_OP; // Input ALU operation code
    input [1:0] BRANCH_JUMP; // Input branch/jump signal
    input OP_SEL; // Input second operand select signal
    input [1:0] MEM_WRITE; // Input memory write signal
    input [1:0] MEM_READ; // Input memory read signal
    input [1:0] REG_WRITE_SEL; // Input register write select signal
    input REG_WRITE_ENABLE; // Input register write enable signal
    input IS_LOAD; // Input: is this a load instruction?
    input CLK; // Clock signal
    input RESET; // Reset signal
    input ENABLE; // Enable signal for pipeline stalling

    output reg [4:0] OUT_DEST_REG; // Output destination register address
    output reg [31:0] OUT_PC_PLUS_4; // Output PC+4 value
    output reg [31:0] OUT_READ_DATA1; // Output read data 1
    output reg [31:0] OUT_READ_DATA2; // Output read data 2
    output reg [31:0] OUT_IMMEDIATE; // Output immediate value
    output reg [4:0] OUT_ALU_OP; // Output ALU operation code
    output reg [1:0] OUT_BRANCH_JUMP; // Output branch/jump signal
    output reg OUT_OP_SEL; // Output second operand select signal
    output reg [1:0] OUT_MEM_WRITE; // Output memory write signal
    output reg [1:0] OUT_MEM_READ; // Output memory read signal
    output reg [1:0] OUT_REG_WRITE_SEL; // Output register write select signal
    output reg OUT_REG_WRITE_ENABLE; // Output register write enable signal
    output reg OUT_IS_LOAD; // Output: is this a load instruction to EX stage

    // On the rising edge of the clock or when reset is high
    always @ (posedge CLK or posedge RESET) begin
        if (RESET) begin
            // If reset is high, clear the output registers
            OUT_DEST_REG <= 5'd0;
            OUT_PC_PLUS_4 <= 32'd0;
            OUT_READ_DATA1 <= 32'd0;
            OUT_READ_DATA2 <= 32'd0;
            OUT_IMMEDIATE <= 32'd0;
            OUT_ALU_OP <= 5'd0;
            OUT_BRANCH_JUMP <= 2'b00;
            OUT_OP_SEL <= 1'b0;
            OUT_MEM_WRITE <= 2'b00;
            OUT_MEM_READ <= 2'b00;
            OUT_REG_WRITE_SEL <= 2'b00;
            OUT_REG_WRITE_ENABLE <= 1'b0;
            OUT_IS_LOAD <= 1'b0;
        end else if (ENABLE) begin
            // If enable is high, capture the input values
            OUT_DEST_REG <= DEST_REG;
            OUT_PC_PLUS_4 <= PC_PLUS_4;
            OUT_READ_DATA1 <= READ_DATA1;
            OUT_READ_DATA2 <= READ_DATA2;
            OUT_IMMEDIATE <= IMMEDIATE;
            OUT_ALU_OP <= ALU_OP;
            OUT_BRANCH_JUMP <= BRANCH_JUMP;
            OUT_OP_SEL <= OP_SEL;
            OUT_MEM_WRITE <= MEM_WRITE;
            OUT_MEM_READ <= MEM_READ;
            OUT_REG_WRITE_SEL <= REG_WRITE_SEL;
            OUT_REG_WRITE_ENABLE <= REG_WRITE_ENABLE;
            OUT_IS_LOAD <= IS_LOAD;
        end
        // If enable is low, keep the current values (stall)
    end
endmodule