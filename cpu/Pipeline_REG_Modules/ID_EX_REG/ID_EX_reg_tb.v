// Testbench for ID_EX_reg

`timescale 1ns/100ps
`include "ID_EX_reg.v" // Include the module definition

module ID_EX_reg_tb;

    // Defining input/output ports
    reg [4:0] DEST_REG; // Input destination register address
    reg [31:0] PC_PLUS_4; // Input PC+4 value
    reg [31:0] READ_DATA1; // Input read data 1
    reg [31:0] READ_DATA2; // Input read data 2
    reg [31:0] IMMEDIATE; // Input immediate value
    reg [4:0] ALU_OP; // Input ALU operation code
    reg [1:0] BRANCH_JUMP; // Input branch/jump signal
    reg OP_SEL; // Input second operand select signal
    reg [1:0] MEM_WRITE; // Input memory write signal
    reg [1:0] MEM_READ; // Input memory read signal
    reg [1:0] REG_WRITE_SEL; // Input register write select signal
    reg REG_WRITE_ENABLE; // Input register write enable signal
    reg CLK; // Clock signal
    reg RESET; // Reset signal

    wire [4:0] OUT_DEST_REG; // Output destination register address
    wire [31:0] OUT_PC_PLUS_4; // Output PC+4 value
    wire [31:0] OUT_READ_DATA1; // Output read data 1
    wire [31:0] OUT_READ_DATA2; // Output read data 2
    wire [31:0] OUT_IMMEDIATE; // Output immediate value
    wire [4:0] OUT_ALU_OP; // Output ALU operation code
    wire [1:0] OUT_BRANCH_JUMP; // Output branch/jump signal
    wire OUT_OP_SEL; // Output second operand select signal
    wire [1:0] OUT_MEM_WRITE; // Output memory write signal
    wire [1:0] OUT_MEM_READ; // Output memory read signal
    wire [1:0] OUT_REG_WRITE_SEL; // Output register write select signal
    wire OUT_REG_WRITE_ENABLE; // Output register write enable signal

    // Instantiate the ID_EX_reg module
    ID_EX_reg id_ex_reg_t(
        .DEST_REG(DEST_REG),
        .PC_PLUS_4(PC_PLUS_4),
        .READ_DATA1(READ_DATA1),
        .READ_DATA2(READ_DATA2),
        .IMMEDIATE(IMMEDIATE),
        .ALU_OP(ALU_OP),
        .BRANCH_JUMP(BRANCH_JUMP),
        .OP_SEL(OP_SEL),
        .MEM_WRITE(MEM_WRITE),
        .MEM_READ(MEM_READ),
        .REG_WRITE_SEL(REG_WRITE_SEL),
        .REG_WRITE_ENABLE(REG_WRITE_ENABLE),
        .CLK(CLK),
        .RESET(RESET),
        .OUT_DEST_REG(OUT_DEST_REG),
        .OUT_PC_PLUS_4(OUT_PC_PLUS_4),
        .OUT_READ_DATA1(OUT_READ_DATA1),
        .OUT_READ_DATA2(OUT_READ_DATA2),
        .OUT_IMMEDIATE(OUT_IMMEDIATE),
        .OUT_ALU_OP(OUT_ALU_OP),
        .OUT_BRANCH_JUMP(OUT_BRANCH_JUMP),
        .OUT_OP_SEL(OUT_OP_SEL),
        .OUT_MEM_WRITE(OUT_MEM_WRITE),
        .OUT_MEM_READ(OUT_MEM_READ),
        .OUT_REG_WRITE_SEL(OUT_REG_WRITE_SEL),
        .OUT_REG_WRITE_ENABLE(OUT_REG_WRITE_ENABLE)
    );

    // Clock generation
    initial begin
        CLK = 1;
        forever #4 CLK = ~CLK; // Toggle clock every 4 time units
    end

    // Testbench logic
    initial begin

        // generate files needed to plot the waveform using GTKWave
        $dumpfile("ID_EX_reg_tb.vcd");
        $dumpvars(0, ID_EX_reg_tb);
        $monitor("Time: %0t | DEST_REG: %d | PC_PLUS_4: %d | READ_DATA1: %d | READ_DATA2: %d | IMMEDIATE: %d | ALU_OP: %d | BRANCH_JUMP: %b | OP_SEL: %b | MEM_WRITE: %b | MEM_READ: %b | REG_WRITE_SEL: %b | REG_WRITE_ENABLE: %b", 
                 $time, DEST_REG, PC_PLUS_4, READ_DATA1, READ_DATA2, IMMEDIATE, ALU_OP, BRANCH_JUMP, OP_SEL, MEM_WRITE, MEM_READ, REG_WRITE_SEL, REG_WRITE_ENABLE);

    
        // Initialize inputs
        RESET = 1; // Assert reset
        DEST_REG = 5'd0;
        PC_PLUS_4 = 32'd0;
        READ_DATA1 = 32'd0;
        READ_DATA2 = 32'd0;
        IMMEDIATE = 32'd0;
        ALU_OP = 5'd0;
        BRANCH_JUMP = 2'b00;
        OP_SEL = 1'b0;
        MEM_WRITE = 2'b00;
        MEM_READ = 2'b00;
        REG_WRITE_SEL = 2'b00;
        REG_WRITE_ENABLE = 1'b0;

        // Wait for a few clock cycles
        #8;

        // Deassert reset
        RESET = 0;
        #8;

        // Test writing to the register file
        DEST_REG = 5'd1; // Write to register 1
        PC_PLUS_4 = 32'd104; // Write PC+4 value 104
        READ_DATA1 = 32'd42; // Write value 42
        READ_DATA2 = 32'd84; // Write value 84
        IMMEDIATE = 32'd100; // Write immediate value 100
        ALU_OP = 5'd2; // Write ALU operation code 2
        BRANCH_JUMP = 2'b01; // Write branch/jump signal 1
        OP_SEL = 1'b0; // Write second operand select signal 0
        MEM_WRITE = 2'b01; // Write memory write signal 01
        MEM_READ = 2'b10; // Write memory read signal 10
        REG_WRITE_SEL = 2'b11; // Write register write select signal 11
        REG_WRITE_ENABLE = 1'b1; // Write register write enable signal 1
        #8; // Wait for a clock cycle

        DEST_REG = 5'd2; // Write to register 2
        PC_PLUS_4 = 32'd204; // Write PC+4 value 204
        READ_DATA1 = 32'd200; // Write value 200
        READ_DATA2 = 32'd400; // Write value 400
        IMMEDIATE = 32'd300; // Write immediate value 300
        ALU_OP = 5'd3; // Write ALU operation code 3
        BRANCH_JUMP = 2'b00; // Write branch/jump signal 0
        OP_SEL = 1'b1; // Write second operand select signal 1
        MEM_WRITE = 2'b10; // Write memory write signal 10
        MEM_READ = 2'b01; // Write memory read signal 01
        REG_WRITE_SEL = 2'b00; // Write register write select signal 00
        REG_WRITE_ENABLE = 1'b0; // Write register write enable signal 0
        #8; // Wait for a clock cycle

        $finish; // End the simulation
    end
endmodule