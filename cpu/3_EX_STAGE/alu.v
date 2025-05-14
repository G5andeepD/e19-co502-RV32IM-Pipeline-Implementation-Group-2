`include "../constants/encordings.v"

`timescale 1ns/100ps

module alu (
    input  [31:0] DATA1, DATA2,
    input  [4:0]  SELECT,
    output reg [31:0] RESULT,
    output reg ZERO
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
        begin
            // Set the zero flag
            if (RESULT == 32'd0)
                ZERO = 1'b1;
            else
                ZERO = 1'b0;
        end
    end

endmodule
