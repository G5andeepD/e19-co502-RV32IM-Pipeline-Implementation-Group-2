`timescale 1ns / 1ps

module branch_selector (
    input  [1:0] BRANCH_SEL, // From control unit
    input        ZERO,       // From ALU
    output reg   PC_SEL      // Output: 1 if branch is taken
);

    always @(*) begin
        case (BRANCH_SEL)
            2'b00: PC_SEL = 1'b0;       // No branch
            2'b01: PC_SEL =  ZERO;      // Branch if ZERO == 1 (e.g., BEQ, BGE, BGEU)
            2'b10: PC_SEL = ~ZERO;      // Branch if ZERO == 0 (e.g., BNE, BLT, BLTU)
            2'b11: PC_SEL = 1'b1;       // Unconditional branch (e.g., JAL, JALR)
            default: PC_SEL = 1'b0;     // Safe default
        endcase
    end

endmodule
