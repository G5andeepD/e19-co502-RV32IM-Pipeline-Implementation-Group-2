`timescale 1ns/100ps

module hazard_control_unit(
    // Hazard detection inputs
    input stall_pipeline,        // Stall signal from hazard detection unit
    input [1:0] branch_jump_ex,  // Branch/jump signal from EX stage
    input pc_sel_ex,             // PC selection signal from EX stage (branch taken)
    
    // Pipeline control outputs
    output reg if_id_enable,     // Enable signal for IF/ID register
    output reg id_ex_enable,     // Enable signal for ID/EX register
    output reg pc_enable,        // Enable signal for PC register
    output reg flush_if_id,      // Flush signal for IF/ID register
    output reg flush_id_ex       // Flush signal for ID/EX register
);

    always @(*) begin
        // Default values
        if_id_enable = 1'b1;
        id_ex_enable = 1'b1;
        pc_enable = 1'b1;
        flush_if_id = 1'b0;
        flush_id_ex = 1'b0;
        
        // Handle data hazards (stalls)
        if (stall_pipeline) begin
            if_id_enable = 1'b0;  // Stall IF/ID register
            id_ex_enable = 1'b0;  // Stall ID/EX register
            pc_enable = 1'b0;     // Stall PC
        end
        
        // Handle control hazards (branches/jumps)
        if (branch_jump_ex != 2'b00 && pc_sel_ex) begin
            flush_if_id = 1'b1;   // Flush IF/ID register
            flush_id_ex = 1'b1;   // Flush ID/EX register
        end
    end

endmodule 