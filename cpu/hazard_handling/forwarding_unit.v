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
    
    // Add new inputs for store data forwarding
    input [4:0] rt_addr_ex, // Store data register address in EX stage
    input [31:0] store_data_ex, // Store data from EX stage (rt_data_ex)
    input [31:0] store_data_ma, // Store data from MA stage (rt_data_ma, if needed)
    input [31:0] store_data_wb, // Store data from WB stage (rt_data_wb, if needed)
    input [4:0] rd_ex, rd_ma, rd_wb, // Destination registers from EX, MA, WB
    input reg_write_enable_ex, reg_write_enable_ma, reg_write_enable_wb, // Write enables
    
    // Forwarded data outputs
    output reg [31:0] rs1_data_forwarded,  // Forwarded rs1 data
    output reg [31:0] rs2_data_forwarded,   // Forwarded rs2 data
    // New output for store data forwarding
    output reg [1:0] forward_store_data, // Forwarding control for store data
    output reg [31:0] store_data_forwarded // Forwarded store data
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

    // Forwarding control logic for store data
    always @(*) begin
        if (rt_addr_ex != 0) begin
            if (reg_write_enable_ex && rt_addr_ex == rd_ex)
                forward_store_data = 2'b01; // Forward from EX
            else if (reg_write_enable_ma && rt_addr_ex == rd_ma)
                forward_store_data = 2'b10; // Forward from MA
            else if (reg_write_enable_wb && rt_addr_ex == rd_wb)
                forward_store_data = 2'b11; // Forward from WB
            else
                forward_store_data = 2'b00; // No forwarding
        end else begin
            forward_store_data = 2'b00; // No forwarding
        end
    end

endmodule 