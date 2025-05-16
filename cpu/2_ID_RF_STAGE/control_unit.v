`include "./constants/encordings.v"
`timescale 1ns/100ps

module control_unit (
    input  [6:0] opcode,
    input  [2:0] funct3,
    input  [6:0] funct7,
    output wire [2:0] imm_sel,
    output wire [4:0] alu_op,
    output wire [1:0] branch_sel,
    output wire       use_imm,
    output wire [1:0] mem_write,
    output wire [1:0] mem_read,
    output wire [1:0] write_back_sel,
    output wire       reg_write_en
);

    // ALU operation
    assign #3 alu_op =
        (opcode == `OPCODE_R_TYPE) ? {funct7[5], funct7[0], funct3} :
        (opcode == `OPCODE_I_TYPE) ? {2'b00, funct3} :
        (opcode == `OPCODE_BRANCH) ? (
            (funct3 == 3'b000 || funct3 == 3'b001) ? `SUB :            // BEQ/BNE
            (funct3 == 3'b100 || funct3 == 3'b101) ? `SLT :            // BLT/BGE
            (funct3 == 3'b110 || funct3 == 3'b111) ? `SLTU : 5'b00000  // BLTU/BGEU
        ) :
        5'b00000;

    // Register write enable
    assign #3 reg_write_en =
        (opcode == `OPCODE_STORE || opcode == `OPCODE_BRANCH) ? 1'b0 : 1'b1;

    // Use immediate instead of reg2
    assign #3 use_imm =
        (opcode == `OPCODE_I_TYPE || opcode == `OPCODE_LOAD || opcode == `OPCODE_STORE || opcode == `OPCODE_JALR) ? 1'b1 : 1'b0;

    // Immediate type selector
    assign #2 imm_sel =
        (opcode == `OPCODE_I_TYPE || opcode == `OPCODE_LOAD || opcode == `OPCODE_JALR) ? 3'b000 :
        (opcode == `OPCODE_STORE)  ? 3'b001 :
        (opcode == `OPCODE_BRANCH) ? 3'b010 :
        (opcode == `OPCODE_LUI || opcode == `OPCODE_AUIPC) ? 3'b011 :
        (opcode == `OPCODE_JAL)    ? 3'b100 :
        3'b000;

    // Memory write control
    assign #2 mem_write = (opcode == `OPCODE_STORE) ? 2'b01 : 2'b00;

    // Memory read control
    assign #2 mem_read = (opcode == `OPCODE_LOAD) ? 2'b01 : 2'b00;

    // Select source for register write-back
    assign #2 write_back_sel =
        (opcode == `OPCODE_LOAD) ? 2'b00 :
        (opcode == `OPCODE_JAL || opcode == `OPCODE_JALR) ? 2'b10 :
        2'b01;

    // Branch selector logic
    assign #2 branch_sel =
        (opcode == `OPCODE_BRANCH) ? (
            (funct3 == 3'b000 || funct3 == 3'b101 || funct3 == 3'b111) ? 2'b01 :
            (funct3 == 3'b001 || funct3 == 3'b100 || funct3 == 3'b110) ? 2'b10 :
            2'b00
        ) :
        (opcode == `OPCODE_JAL || opcode == `OPCODE_JALR) ? 2'b11 :
        2'b00;

endmodule
