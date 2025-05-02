`timescale 1ns/100ps
`define ADD 5'b00000
`define SUB 5'b10000
`define SLL 5'b00001
`define SLT 5'b00010
`define SLTU 5'b00011
`define XOR 5'b00100
`define SRL 5'b00101
`define SRA 5'b10001
`define OR 5'b00110
`define AND 5'b00111

`define MUL 5'b01000
`define MULH 5'b01001
`define MULHSU 5'b01010
`define MULHU 5'b01011
`define DIV 5'b01100
`define DIVU 5'b01101
`define REM 5'b01110
`define REMU 5'b01111

module alu (
    input  [31:0] DATA1, DATA2,
    input  [4:0]  SELECT,
    output reg [31:0] RESULT
);

    // Intermediate wires
    wire [31:0] addData, subData, sllData, sltData, sltuData;
    wire [31:0] xorData, srlData, sraData, orData, andData;
    wire [31:0] mulData, mulhData, mulhsuData, mulhuData;
    wire [31:0] divData, divuData, remData, remuData;

    // #1 delay ops (shifts)
    assign #1 sllData    = DATA1 << DATA2[4:0];
    assign #1 srlData    = DATA1 >> DATA2[4:0];
    assign #1 sraData    = $signed(DATA1) >>> DATA2[4:0];

    // #2 delay ops (simple ALU)
    assign #2 addData    = DATA1 + DATA2;
    assign #2 xorData    = DATA1 ^ DATA2;
    assign #2 orData     = DATA1 | DATA2;
    assign #2 andData    = DATA1 & DATA2;
    assign #2 sltData    = ($signed(DATA1) < $signed(DATA2)) ? 32'd1 : 32'd0;
    assign #2 sltuData   = ($unsigned(DATA1) < $unsigned(DATA2)) ? 32'd1 : 32'd0;

    // #3 delay ops
    assign #3 subData    = DATA1 - DATA2;

    // #4 delay ops (mult/div)
    assign #4 mulData    = $signed(DATA1) * $signed(DATA2);
    assign #4 mulhData   = ($signed(DATA1) * $signed(DATA2)) >> 32;
    assign #4 mulhsuData = ($signed(DATA1) * $unsigned(DATA2)) >> 32;
    assign #4 mulhuData  = ($unsigned(DATA1) * $unsigned(DATA2)) >> 32;

    assign #4 divData    = (DATA2 == 0) ? 32'd0 : $signed(DATA1) / $signed(DATA2);
    assign #4 divuData   = (DATA2 == 0) ? 32'd0 : $unsigned(DATA1) / $unsigned(DATA2);
    assign #4 remData    = (DATA2 == 0) ? 32'd0 : $signed(DATA1) % $signed(DATA2);
    assign #4 remuData   = (DATA2 == 0) ? 32'd0 : $unsigned(DATA1) % $unsigned(DATA2);

    // Operation selection
    always @(*) begin
        case (SELECT)
            `ADD:    RESULT = addData;
            `SUB:    RESULT = subData;
            `SLL:    RESULT = sllData;
            `SLT:    RESULT = sltData;
            `SLTU:   RESULT = sltuData;
            `XOR:    RESULT = xorData;
            `SRL:    RESULT = srlData;
            `SRA:    RESULT = sraData;
            `OR:     RESULT = orData;
            `AND:    RESULT = andData;

            `MUL:    RESULT = mulData;
            `MULH:   RESULT = mulhData;
            `MULHSU: RESULT = mulhsuData;
            `MULHU:  RESULT = mulhuData;

            `DIV:    RESULT = divData;
            `DIVU:   RESULT = divuData;
            `REM:    RESULT = remData;
            `REMU:   RESULT = remuData;

            default: RESULT = 32'd0;
        endcase
    end

endmodule
