`timescale 1ns/100ps

module forwarding_unit(
    // Register data from ID stage (original values)
    input [31:0] rs1_data_id,    // Source register 1 data from ID stage
    input [31:0] rs2_data_id,    // Source register 2 data from ID stage
    
    // Data from later pipeline stages for forwarding
    input [31:0] alu_result_ex,  // ALU result from EX stage
    input [31:0] alu_result_ma,  // ALU result from MA stage
    input [31:0] reg_write_data_wb, // Register write data from WB stage
    
    // Forwarding control signals from hazard detection unit
    input [1:0] forward_rs1,     // Forwarding control for rs1
    input [1:0] forward_rs2,     // Forwarding control for rs2
    
    // Forwarded data outputs
    output reg [31:0] rs1_data_forwarded,  // Forwarded rs1 data
    output reg [31:0] rs2_data_forwarded   // Forwarded rs2 data
);

    always @(*) begin
        // Forward rs1 data based on control signal
        case (forward_rs1)
            2'b00: rs1_data_forwarded = rs1_data_id;      // No forwarding
            2'b01: rs1_data_forwarded = alu_result_ex;    // Forward from EX
            2'b10: rs1_data_forwarded = alu_result_ma;    // Forward from MA
            2'b11: rs1_data_forwarded = reg_write_data_wb; // Forward from WB
            default: rs1_data_forwarded = rs1_data_id;
        endcase
        
        // Forward rs2 data based on control signal
        case (forward_rs2)
            2'b00: rs2_data_forwarded = rs2_data_id;      // No forwarding
            2'b01: rs2_data_forwarded = alu_result_ex;    // Forward from EX
            2'b10: rs2_data_forwarded = alu_result_ma;    // Forward from MA
            2'b11: rs2_data_forwarded = reg_write_data_wb; // Forward from WB
            default: rs2_data_forwarded = rs2_data_id;
        endcase
    end

endmodule 