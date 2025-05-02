// Intermediate pipeline register module for in between Memory Access and Write Back stages

// This module is used to hold the ALU result and control signals between the MA and WB stages
// of the pipeline. It is a simple register that captures the values on the rising edge of the clock.
// It also has a reset signal to clear the values when needed.

`timescale 1ns/100ps

module MA_WB_reg (
    ALU_RESULT, // Input ALU result from MA stage
    DEST_REG, // Input destination register address from MA stage
    PC_PLUS_4, // Input PC+4 value from MA stage
    DATA_OUT, // Input data output from MA stage
    REG_WRITE_SEL, // Input register write select signal from MA stage
    REG_WRITE_ENABLE, // Input register write enable signal from MA stage
    CLK, // Clock signal
    RESET, // Reset signal
    OUT_ALU_RESULT, // Output ALU result to WB stage
    OUT_DEST_REG, // Output destination register address to WB stage
    OUT_PC_PLUS_4, // Output PC+4 value to WB stage
    OUT_DATA_OUT, // Output data output to WB stage
    OUT_REG_WRITE_SEL, // Output register write select signal to WB stage
    OUT_REG_WRITE_ENABLE // Output register write enable signal to WB stage
);

    // Defining input/output ports
    input [31:0] ALU_RESULT; // Input ALU result
    input [4:0] DEST_REG; // Input destination register address
    input [31:0] PC_PLUS_4; // Input PC+4 value
    input [31:0] DATA_OUT; // Input data output from MA stage
    input [1:0] REG_WRITE_SEL; // Input register write select signal
    input REG_WRITE_ENABLE; // Input register write enable signal
    input CLK; // Clock signal
    input RESET; // Reset signal

    output reg [31:0] OUT_ALU_RESULT; // Output ALU result
    output reg [4:0] OUT_DEST_REG; // Output destination register address
    output reg [31:0] OUT_PC_PLUS_4; // Output PC+4 value
    output reg [31:0] OUT_DATA_OUT; // Output data output to WB stage
    output reg [1:0] OUT_REG_WRITE_SEL; // Output register write select signal to WB stage
    output reg OUT_REG_WRITE_ENABLE; // Output register write enable signal to WB stage

    // On the rising edge of the clock or when reset is high
    always @ (posedge CLK or posedge RESET) begin
        if (RESET) begin
            // If reset is high, clear the output registers
            OUT_ALU_RESULT <= 32'd0;
            OUT_DEST_REG <= 5'd0;
            OUT_PC_PLUS_4 <= 32'd0;
            OUT_DATA_OUT <= 32'd0;
            OUT_REG_WRITE_SEL <= 2'b00;
            OUT_REG_WRITE_ENABLE <= 1'b0;
        end else begin
            // Otherwise, capture the input values
            OUT_ALU_RESULT <= ALU_RESULT;
            OUT_DEST_REG <= DEST_REG;
            OUT_PC_PLUS_4 <= PC_PLUS_4;
            OUT_DATA_OUT <= DATA_OUT;
            OUT_REG_WRITE_SEL <= REG_WRITE_SEL;
            OUT_REG_WRITE_ENABLE <= REG_WRITE_ENABLE;
        end
    end
endmodule