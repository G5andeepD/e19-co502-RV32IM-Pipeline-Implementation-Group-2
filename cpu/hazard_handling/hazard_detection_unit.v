`timescale 1ns/100ps

module hazard_detection_unit(
    // Register addresses from ID stage
    input [4:0] rs1_id,      // Source register 1 from ID stage
    input [4:0] rs2_id,      // Source register 2 from ID stage
    
    // Register addresses and write enables from later stages
    input [4:0] rd_ex,       // Destination register from EX stage
    input [4:0] rd_ma,       // Destination register from MA stage
    input [4:0] rd_wb,       // Destination register from WB stage
    
    input reg_write_enable_ex,  // Register write enable from EX stage
    input reg_write_enable_ma,  // Register write enable from MA stage
    input reg_write_enable_wb,  // Register write enable from WB stage
    input is_load_ex,           // New: is the EX stage instruction a load?
    
    // Hazard detection outputs
    output reg stall_pipeline,   // Signal to stall the pipeline
    output reg [1:0] forward_rs1, // Forwarding control for rs1 (00=none, 01=EX, 10=MA, 11=WB)
    output reg [1:0] forward_rs2  // Forwarding control for rs2 (00=none, 01=EX, 10=MA, 11=WB)
);

    // Function to check if register addresses match and write is enabled
    function automatic [1:0] check_hazard;
        input [4:0] rs_addr;
        input [4:0] rd_ex, rd_ma, rd_wb;
        input reg_write_enable_ex, reg_write_enable_ma, reg_write_enable_wb;
        
        begin
            if (rs_addr != 0) begin  // Register 0 is always 0, no hazard
                if (reg_write_enable_ex && rs_addr == rd_ex)
                    check_hazard = 2'b01;  // Forward from EX
                else if (reg_write_enable_ma && rs_addr == rd_ma)
                    check_hazard = 2'b10;  // Forward from MA
                else if (reg_write_enable_wb && rs_addr == rd_wb)
                    check_hazard = 2'b11;  // Forward from WB
                else
                    check_hazard = 2'b00;  // No forwarding needed
            end else begin
                check_hazard = 2'b00;  // Register 0, no hazard
            end
        end
    endfunction

    always @(*) begin
        // Check hazards for rs1
        forward_rs1 = check_hazard(rs1_id, rd_ex, rd_ma, rd_wb, 
                                  reg_write_enable_ex, reg_write_enable_ma, reg_write_enable_wb);
        
        // Check hazards for rs2
        forward_rs2 = check_hazard(rs2_id, rd_ex, rd_ma, rd_wb, 
                                  reg_write_enable_ex, reg_write_enable_ma, reg_write_enable_wb);
        
        // Stall pipeline only for load-use hazard (EX is load and destination matches ID source)
        if (is_load_ex && rd_ex != 0 && 
            ((rs1_id == rd_ex) || (rs2_id == rd_ex))) begin
            stall_pipeline = 1'b1;
        end else begin
            stall_pipeline = 1'b0;
        end
    end

endmodule 