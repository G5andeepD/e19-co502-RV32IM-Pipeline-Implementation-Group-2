`include "../constants/encordings.v"
`timescale 1ns/100ps

module control_unit (
    input  [6:0] opcode,
    input  [2:0] funct3,
    input  [6:0] funct7,
    output wire imm_sel[2:0],
    output wire [4:0] aluop,
    output wire branch_jump[2:0],
    output wire op1_sel,
    output wire op2_sel,
    output wire mem_write[1:0],
    output wire mem_read[1:0],
    output wire reg_write_select[1:0],
    output wire reg_write_enable,

);

    assign #3 aluop = (opcode == `OPCODE_R_TYPE) ? {funct7[5], funct7[0], funct3} :
                  (opcode == `OPCODE_I_TYPE) ? {2'b00, funct3} :
                  5'b00000;
    assign #3 reg_write_enable = 1'b1; // Enable register write for all instructions
    assign #3 op1_sel = 1'b1; // Select first operand from register file
    assign #3 op2_sel = 1'b0; // Select second operand from register file
    assign #2 mem_write = 2'b00; // No memory write for all instructions
    assign #2 mem_read = 2'b00; // No memory read for all instructions
    assign #2 branch_jump = 3'b000; // No branch or jump for all instructions
    assign #2 imm_sel = 3'b000; // No immediate value for all instructions
    assign #2 reg_write_select = 2'b01; // Select register write for all instructions
endmodule