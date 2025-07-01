`timescale 1ns/100ps

module hazard_test_with_real_values();

    // Test signals
    reg clk, reset;
    reg [31:0] instr_if, dmem_data_out;
    wire [31:0] pc_out, dmem_data_in, alu_result_ma;
    wire [1:0] mem_write_ma, mem_read_ma;

    // Hazard handling signals (for monitoring)
    wire [4:0] rs1_id, rs2_id;
    wire [31:0] rs_data_forwarded_id, rt_data_forwarded_id;
    wire [1:0] forward_rs1, forward_rs2;
    wire stall_pipeline;
    wire if_id_enable, id_ex_enable, pc_enable;
    wire flush_if_id, flush_id_ex;

    // Register file monitoring signals
    wire [31:0] reg_data_out1, reg_data_out2;
    wire [4:0] reg_write_addr;
    wire [31:0] reg_write_data;
    wire reg_write_enable;

    // Instantiate the CPU with hazard handling
    cpu cpu_inst(
        .clk(clk),
        .reset(reset),
        .instr_if(instr_if),
        .dmem_data_out(dmem_data_out),
        .pc_out(pc_out),
        .dmem_data_in(dmem_data_in),
        .alu_result_ma(alu_result_ma),
        .mem_write_ma(mem_write_ma),
        .mem_read_ma(mem_read_ma),
        .rs1_id(rs1_id),
        .rs2_id(rs2_id),
        .rs_data_forwarded_id(rs_data_forwarded_id),
        .rt_data_forwarded_id(rt_data_forwarded_id),
        .forward_rs1(forward_rs1),
        .forward_rs2(forward_rs2),
        .stall_pipeline(stall_pipeline),
        .if_id_enable(if_id_enable),
        .id_ex_enable(id_ex_enable),
        .pc_enable(pc_enable),
        .flush_if_id(flush_if_id),
        .flush_id_ex(flush_id_ex)
    );

    // Connect to register file for monitoring
    assign reg_data_out1 = cpu_inst.reg_file_inst.DATA_OUT1;
    assign reg_data_out2 = cpu_inst.reg_file_inst.DATA_OUT2;
    assign reg_write_addr = cpu_inst.reg_file_inst.WRITE_ADDR;
    assign reg_write_data = cpu_inst.reg_file_inst.WRITE_DATA;
    assign reg_write_enable = cpu_inst.reg_file_inst.WRITE_ENABLE;

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Function to decode instruction type
    function [31:0] decode_instruction;
        input [31:0] instr;
        begin
            case (instr[6:0])
                7'b0110011: decode_instruction = "R-type"; // ADD, SUB, etc.
                7'b0010011: decode_instruction = "I-type"; // ADDI, LW, etc.
                7'b0100011: decode_instruction = "S-type"; // SW
                7'b1100011: decode_instruction = "B-type"; // BEQ, BNE, etc.
                7'b1101111: decode_instruction = "J-type"; // JAL
                7'b1100111: decode_instruction = "I-type"; // JALR
                default: decode_instruction = "Unknown";
            endcase
        end
    endfunction

    // Function to get instruction name
    function [31:0] get_instruction_name;
        input [31:0] instr;
        begin
            case (instr[6:0])
                7'b0110011: begin // R-type
                    case (instr[14:12])
                        3'b000: get_instruction_name = "ADD";
                        3'b001: get_instruction_name = "SLL";
                        3'b010: get_instruction_name = "SLT";
                        3'b011: get_instruction_name = "SLTU";
                        3'b100: get_instruction_name = "XOR";
                        3'b101: get_instruction_name = "SRL";
                        3'b110: get_instruction_name = "OR";
                        3'b111: get_instruction_name = "AND";
                    endcase
                end
                7'b0010011: begin // I-type
                    case (instr[14:12])
                        3'b000: get_instruction_name = "ADDI";
                        3'b010: get_instruction_name = "SLTI";
                        3'b011: get_instruction_name = "SLTIU";
                        3'b100: get_instruction_name = "XORI";
                        3'b110: get_instruction_name = "ORI";
                        3'b111: get_instruction_name = "ANDI";
                        3'b001: get_instruction_name = "SLLI";
                        3'b101: begin
                            if (instr[31:25] == 7'b0000000) get_instruction_name = "SRLI";
                            else get_instruction_name = "SRAI";
                        end
                    endcase
                end
                7'b0000011: begin // Load
                    case (instr[14:12])
                        3'b000: get_instruction_name = "LB";
                        3'b001: get_instruction_name = "LH";
                        3'b010: get_instruction_name = "LW";
                        3'b100: get_instruction_name = "LBU";
                        3'b101: get_instruction_name = "LHU";
                    endcase
                end
                7'b0100011: begin // Store
                    case (instr[14:12])
                        3'b000: get_instruction_name = "SB";
                        3'b001: get_instruction_name = "SH";
                        3'b010: get_instruction_name = "SW";
                    endcase
                end
                7'b1100011: begin // Branch
                    case (instr[14:12])
                        3'b000: get_instruction_name = "BEQ";
                        3'b001: get_instruction_name = "BNE";
                        3'b100: get_instruction_name = "BLT";
                        3'b101: get_instruction_name = "BGE";
                        3'b110: get_instruction_name = "BLTU";
                        3'b111: get_instruction_name = "BGEU";
                    endcase
                end
                7'b1101111: get_instruction_name = "JAL";
                7'b1100111: get_instruction_name = "JALR";
                default: get_instruction_name = "UNKNOWN";
            endcase
        end
    endfunction

    // Function to get forwarding source description
    function [31:0] get_forwarding_source;
        input [1:0] forward_signal;
        begin
            case (forward_signal)
                2'b00: get_forwarding_source = "None";
                2'b01: get_forwarding_source = "EX Stage";
                2'b10: get_forwarding_source = "MA Stage";
                2'b11: get_forwarding_source = "WB Stage";
                default: get_forwarding_source = "Unknown";
            endcase
        end
    endfunction

    // Monitor hazard handling and register values
    always @(posedge clk) begin
        if (!reset) begin
            $display("=== Clock Cycle %0d ===", $time/10);
            
            // Print instruction information
            if (instr_if != 32'h0) begin
                $display("Instruction: %h (%s %s)", instr_if, get_instruction_name(instr_if), decode_instruction(instr_if));
                $display("  rs1: x%0d, rs2: x%0d, rd: x%0d", 
                        instr_if[19:15], instr_if[24:20], instr_if[11:7]);
            end
            
            // Print register file read values
            if (rs1_id != 0 || rs2_id != 0) begin
                $display("Register File Read:");
                $display("  x%0d = %h (%0d)", rs1_id, reg_data_out1, reg_data_out1);
                $display("  x%0d = %h (%0d)", rs2_id, reg_data_out2, reg_data_out2);
            end
            
            // Print hazard detection results
            if (rs1_id != 0 || rs2_id != 0) begin
                $display("Hazard Detection:");
                $display("  rs1_id: x%0d, rs2_id: x%0d", rs1_id, rs2_id);
                $display("  Forward rs1: %s", get_forwarding_source(forward_rs1));
                $display("  Forward rs2: %s", get_forwarding_source(forward_rs2));
                
                if (forward_rs1 != 2'b00 || forward_rs2 != 2'b00) begin
                    $display("  *** DATA HAZARD DETECTED - FORWARDING ACTIVATED ***");
                end
            end
            
            // Print forwarded data values
            if (forward_rs1 != 2'b00 || forward_rs2 != 2'b00) begin
                $display("Forwarded Data:");
                if (forward_rs1 != 2'b00) begin
                    $display("  x%0d (forwarded) = %h (%0d)", rs1_id, rs_data_forwarded_id, rs_data_forwarded_id);
                end
                if (forward_rs2 != 2'b00) begin
                    $display("  x%0d (forwarded) = %h (%0d)", rs2_id, rt_data_forwarded_id, rt_data_forwarded_id);
                end
            end
            
            // Print register write information
            if (reg_write_enable && reg_write_addr != 0) begin
                $display("Register Write:");
                $display("  x%0d = %h (%0d)", reg_write_addr, reg_write_data, reg_write_data);
            end
            
            // Print pipeline control
            $display("Pipeline Control:");
            $display("  Stall: %b, IF/ID Enable: %b, ID/EX Enable: %b, PC Enable: %b", 
                    stall_pipeline, if_id_enable, id_ex_enable, pc_enable);
            $display("  Flush IF/ID: %b, Flush ID/EX: %b", flush_if_id, flush_id_ex);
            
            if (stall_pipeline) begin
                $display("  *** PIPELINE STALLED - Load-Use Hazard ***");
            end
            
            if (flush_if_id || flush_id_ex) begin
                $display("  *** PIPELINE FLUSHED - Control Hazard ***");
            end
            
            $display("");
        end
    end

    // Test stimulus with real values
    initial begin
        $display("=== RV32IM Pipeline Hazard Handling Test with Real Values ===");
        $display("Loading initial values into registers, then testing hazards...");
        $display("");
        
        // Initialize
        reset = 1;
        instr_if = 32'h00000000;
        dmem_data_out = 32'h00000000;
        
        // Reset for 2 clock cycles
        #20;
        reset = 0;
        $display("Reset completed. Loading initial values...");
        $display("");
        
        // Phase 1: Load initial values into registers
        $display("=== Phase 1: Loading Initial Values ===");
        
        // Load immediate values into registers
        instr_if = 32'h00000093; // addi x1, x0, 0  (x1 = 0)
        #10;
        
        instr_if = 32'h00100093; // addi x1, x0, 1  (x1 = 1)
        #10;
        
        instr_if = 32'h00200113; // addi x2, x0, 2  (x2 = 2)
        #10;
        
        instr_if = 32'h00300193; // addi x3, x0, 3  (x3 = 3)
        #10;
        
        instr_if = 32'h00400213; // addi x4, x0, 4  (x4 = 4)
        #10;
        
        instr_if = 32'h00500293; // addi x5, x0, 5  (x5 = 5)
        #10;
        
        instr_if = 32'h00600313; // addi x6, x0, 6  (x6 = 6)
        #10;
        
        instr_if = 32'h00700393; // addi x7, x0, 7  (x7 = 7)
        #10;
        
        instr_if = 32'h00800413; // addi x8, x0, 8  (x8 = 8)
        #10;
        
        instr_if = 32'h00900493; // addi x9, x0, 9  (x9 = 9)
        #10;
        
        instr_if = 32'h00A00513; // addi x10, x0, 10 (x10 = 10)
        #10;
        
        // Phase 2: Test data hazards with real values
        $display("=== Phase 2: Data Hazard Tests ===");
        
        // Test 1: Simple data hazard - ADD x11, x1, x2 (x11 = x1 + x2 = 1 + 2 = 3)
        instr_if = 32'h002080B3; // add x11, x1, x2
        #10;
        
        // Test 2: Immediate data hazard - ADD x12, x11, x3 (x12 = x11 + x3 = 3 + 3 = 6)
        instr_if = 32'h00358633; // add x12, x11, x3
        #10;
        
        // Test 3: Multiple data hazards - ADD x13, x12, x4 (x13 = x12 + x4 = 6 + 4 = 10)
        instr_if = 32'h004606B3; // add x13, x12, x4
        #10;
        
        // Phase 3: Test load-use hazard
        $display("=== Phase 3: Load-Use Hazard Test ===");
        
        // Simulate memory data for load
        dmem_data_out = 32'h000000FF; // Memory data to be loaded
        
        // Load word from memory - LW x14, 0(x5) (load from address in x5)
        instr_if = 32'h0002A703; // lw x14, 0(x5)
        #10;
        
        // Use loaded value immediately - ADD x15, x14, x6 (x15 = x14 + x6 = 0xFF + 6 = 0x105)
        instr_if = 32'h006707B3; // add x15, x14, x6
        #10;
        
        // Phase 4: Test complex forwarding chain
        $display("=== Phase 4: Complex Forwarding Chain ===");
        
        // Chain of dependent operations
        instr_if = 32'h00780833; // add x16, x16, x7 (x16 = x16 + 7)
        #10;
        
        instr_if = 32'h01080833; // add x16, x16, x16 (x16 = x16 + x16)
        #10;
        
        instr_if = 32'h01080833; // add x16, x16, x16 (x16 = x16 + x16)
        #10;
        
        instr_if = 32'h01080833; // add x16, x16, x16 (x16 = x16 + x16)
        #10;
        
        // Phase 5: Test arithmetic with immediate values
        $display("=== Phase 5: Arithmetic with Immediates ===");
        
        instr_if = 32'h00A08113; // addi x2, x1, 10 (x2 = x1 + 10 = 1 + 10 = 11)
        #10;
        
        instr_if = 32'h01410113; // addi x2, x2, 20 (x2 = x2 + 20 = 11 + 20 = 31)
        #10;
        
        instr_if = 32'h002081B3; // add x3, x1, x2 (x3 = x1 + x2 = 1 + 31 = 32)
        #10;
        
        // Phase 6: Test control hazard
        $display("=== Phase 6: Control Hazard Test ===");
        
        // Set up registers for branch comparison
        instr_if = 32'h00100113; // addi x2, x0, 1 (x2 = 1)
        #10;
        
        instr_if = 32'h00100193; // addi x3, x0, 1 (x3 = 1)
        #10;
        
        // Branch if equal - BEQ x2, x3, 8 (should branch since x2 == x3)
        instr_if = 32'h00310663; // beq x2, x3, 8
        #10;
        
        // This instruction may be flushed if branch is taken
        instr_if = 32'h00A00293; // addi x5, x0, 10
        #10;
        
        // Continue with more instructions
        instr_if = 32'h00000000; // NOP
        #50;
        
        $display("=== Hazard Handling Test with Real Values Completed ===");
        $display("Check the output above to verify hazard detection and resolution with actual data.");
        $finish;
    end

    // Generate VCD file for waveform viewing
    initial begin
        $dumpfile("hazard_test_with_real_values.vcd");
        $dumpvars(0, hazard_test_with_real_values);
    end

endmodule 