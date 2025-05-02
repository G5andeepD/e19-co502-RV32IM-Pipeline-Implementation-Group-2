// -------------------------
// Instruction Opcodes (7-bit)
// -------------------------
`define OPCODE_R_TYPE     7'b0110011  // R-type: Register-Register ALU
`define OPCODE_I_TYPE     7'b0010011  // I-type: Immediate ALU
`define OPCODE_LOAD       7'b0000011  // I-type: Load
`define OPCODE_STORE      7'b0100011  // S-type: Store
`define OPCODE_BRANCH     7'b1100011  // B-type: Branch
`define OPCODE_LUI        7'b0110111  // U-type: Load Upper Immediate
`define OPCODE_AUIPC      7'b0010111  // U-type: Add Upper Immediate to PC
`define OPCODE_JAL        7'b1101111  // J-type: Jump and Link
`define OPCODE_JALR       7'b1100111  // I-type: Jump and Link Register

// -------------------------
// ALU Function Select Codes (5-bit)
// -------------------------
`define ADD     5'b00000
`define SUB     5'b10000
`define SLL     5'b00001
`define SLT     5'b00010
`define SLTU    5'b00011
`define XOR     5'b00100
`define SRL     5'b00101
`define SRA     5'b10001
`define OR      5'b00110
`define AND     5'b00111

// -------------------------
// Multiplication & Division (5-bit)
// -------------------------
`define MUL     5'b01000
`define MULH    5'b01001
`define MULHSU  5'b01010
`define MULHU   5'b01011
`define DIV     5'b01100
`define DIVU    5'b01101
`define REM     5'b01110
`define REMU    5'b01111
