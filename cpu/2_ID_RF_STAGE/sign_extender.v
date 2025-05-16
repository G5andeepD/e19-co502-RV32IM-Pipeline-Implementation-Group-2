`timescale 1ns/100ps

module sign_extender(
    input  [24:0] instr_25,  // instruction[31:7]
    input  [2:0]  imm_sel,   // From control unit
    output reg [31:0] imm_out
);

    // I-type (12 bits): [24:13] = instruction[31:20]
    wire [11:0] imm_i = instr_25[24:13];

    // S-type: [24:18] = instruction[31:25], [4:0] = instruction[11:7]
    wire [11:0] imm_s = {instr_25[24:18], instr_25[4:0]};

    // B-type: [24] = instr[31], [0] = instr[7], [23:18] = instr[30:25], [4:1] = instr[11:8], LSB=0
    wire [12:0] imm_b = {instr_25[24], instr_25[0], instr_25[23:18], instr_25[4:1], 1'b0};

    // U-type: [24:5] = instruction[31:12], LSB 12 bits = 0
    wire [31:0] imm_u = {instr_25[24:5], 12'b0};

    // J-type: [24] = instr[31], [12:5] = instr[19:12], [13] = instr[20], [23:14] = instr[30:21], LSB=0
    wire [20:0] imm_j = {
        instr_25[24],        // bit 20 (instr[31])
        instr_25[12:5],      // bits 19:12 (instr[19:12])
        instr_25[13],        // bit 11 (instr[20])
        instr_25[23:14],     // bits 10:1 (instr[30:21])
        1'b0                 // LSB always 0
    };

    always @(*) begin
        case (imm_sel)
            3'b000: imm_out = {{20{imm_i[11]}}, imm_i};  // I-type
            3'b001: imm_out = {{20{imm_s[11]}}, imm_s};  // S-type
            3'b010: imm_out = {{19{imm_b[12]}}, imm_b};  // B-type
            3'b011: imm_out = imm_u;                     // U-type
            3'b100: imm_out = {{11{imm_j[20]}}, imm_j};  // J-type
            default: imm_out = 32'b0;
        endcase
    end

endmodule
