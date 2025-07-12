`timescale 1ns/100ps
`include "./1_IF_STAGE/imem.v"
`include "./4_MA_STAGE/dmem.v"
`include "./cpu.v"

module hazard_test_with_memory();

    // Test signals
    reg clk, reset;
    wire [31:0] instr_if, dmem_data_out;
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

    // Instruction memory
    reg [31:0] imem [0:63]; // 64 instructions max

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

    // Data memory module
    dmem dmem_t (
        .clk(clk),
        .address(alu_result_ma),
        .data_in(dmem_data_in),
        .mem_write(mem_write_ma),
        .mem_read(mem_read_ma),
        .reset(reset),
        .data_out(dmem_data_out)
    );

    // Instruction fetch from memory
    assign instr_if = imem[pc_out[31:2]];

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

    // Function to get phase description
    function [31:0] get_phase_description;
        input [31:0] pc;
        begin
            case (pc[31:2])
                5'd0: get_phase_description = "Phase 1: Load Initial Values";
                5'd5: get_phase_description = "Phase 2: Data Hazard Tests";
                5'd9: get_phase_description = "Phase 3: Load-Use Hazard";
                5'd11: get_phase_description = "Phase 4: Immediate Arithmetic";
                5'd13: get_phase_description = "Phase 5: Complex Forwarding";
                5'd18: get_phase_description = "Phase 6: Control Hazard";
                5'd21: get_phase_description = "Phase 7: Memory Operations";
                5'd26: get_phase_description = "Phase 8: Final Calculations";
                default: get_phase_description = "Unknown Phase";
            endcase
        end
    endfunction

    // Monitor hazard handling
    always @(posedge clk) begin
        if (!reset) begin
            $display("=== Clock Cycle %0d ===", $time/10);
            
            // Print instruction information
            if (instr_if != 32'h0) begin
                $display("Instruction: %h (%s %s)", instr_if, get_instruction_name(instr_if), decode_instruction(instr_if));
                $display("  rs1: x%0d, rs2: x%0d, rd: x%0d", 
                        instr_if[19:15], instr_if[24:20], instr_if[11:7]);
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
            
            // Print memory operations
            if (mem_read_ma == 2'b01) begin
                $display("Memory Read: Address=%h, Data=%h", alu_result_ma, dmem_data_out);
            end
            
            if (mem_write_ma == 2'b01) begin
                $display("Memory Write: Address=%h, Data=%h", alu_result_ma, dmem_data_in);
            end
            
            $display("");
        end
    end

    // Test stimulus
    integer k; // Declare loop variable at the top
    integer num_instructions;
    integer file, c;
    initial begin
        
        $display("=== RV32IM Pipeline Hazard Test with Memory File ===");
        $display("Loading instructions from load_use_hazard.mem...");
        $display("");
        
        // Load instruction memory from file
        $readmemh("output/control_hazard_branch.mem", imem);
        
        // automatically get the value for k with the number of instructions avaliable in imem (depend on the file number of instruction could change)
        // Automatically determine the number of instructions in imem by reading the file line count
        
        // num_instructions = 0;
        // file = $fopen("output/control_hazard_branch.mem", "r");
        // if (file) begin
        //     while (!$feof(file)) begin
        //         c = $fgetc(file);
        //         if (c == "\n" || c == "\r") num_instructions = num_instructions + 1;
        //     end
        //     $fclose(file);
        // end else begin
        //     $display("ERROR: Could not open instruction memory file.");
        //     num_instructions = 3; // fallback default
        // end
        // // Fill the rest of instruction memory with NOPs
        // for (k = num_instructions; k < 64; k = k + 1) // 3 = number of program instructions
        //     imem[k] = 32'h00000013; // addi x0, x0, 0 (NOP)
        
        // Initialize
        reset = 1;
        
        // Initialize data memory with some values
        // (Addresses are word addresses, not byte addresses)
        dmem_t.memory[10] = 32'h000000AA; // Example: address 10
        dmem_t.memory[20] = 32'h000000BB; // Example: address 14
        dmem_t.memory[30] = 32'h000000CC; // Example: address 18
        dmem_t.memory[40] = 32'h000000DD; // Example: address 20
        dmem_t.memory[50] = 32'h000000EE; // Example: address 30
        dmem_t.memory[60] = 32'h000000FF; // Example: address 40
        
        // Reset for 2 clock cycles
        #20;
        reset = 0;
        $display("Reset completed. Starting hazard tests with memory file...");
        $display("");
        
        // Run for enough cycles to complete all instructions
        #300;
        
        $display("=== Hazard Test with Memory File Completed ===");
        $display("Check the output above to verify hazard detection and resolution.");
        $display("Expected final register values:");
        $display("  x1=10, x2=20, x3=30, x4=40, x5=50");
        $display("  x6=30, x7=60, x8=100, x9=150");
        $display("  x10=0xAA, x11=0xAA+20, x12=130, x13=330");
        $display("  x14=480, x15=580, x16=640, x17=1280, x18=2560");
        $display("  x19=100, x20=100, x22=200");
        $finish;
    end

    // Generate VCD file for waveform viewing
    integer i;
    initial begin
        $dumpfile("hazard_test_with_memory.vcd");
        $dumpvars(0, hazard_test_with_memory);
        for (i = 0; i < 32; i = i + 1)
            $dumpvars(1, cpu_inst.reg_file.REGISTERS[i]);

        #300;
        $finish;
    end

endmodule 