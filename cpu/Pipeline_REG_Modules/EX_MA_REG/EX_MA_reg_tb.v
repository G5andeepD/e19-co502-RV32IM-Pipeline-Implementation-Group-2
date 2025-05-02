// Testbench for EX_MA_reg

`timescale 1ns / 1ps
`include "EX_MA_reg.v" // Include the module definition

module EX_MA_reg_tb;

    // Defining input/output ports
    reg [31:0] ALU_RESULT; // Input ALU result
    reg [4:0] DEST_REG; // Input destination register address
    reg [31:0] PC_PLUS_4; // Input PC+4 value
    reg [31:0] IMMEDIATE; // Input immediate value
    reg [1:0] MEM_WRITE; // Input memory write signal
    reg [1:0] MEM_READ; // Input memory read signal
    reg [1:0] REG_WRITE_SEL; // Input register write select signal
    reg REG_WRITE_ENABLE; // Input register write enable signal
    reg CLK; // Clock signal
    reg RESET; // Reset signal

    wire [31:0] OUT_ALU_RESULT; // Output ALU result
    wire [4:0] OUT_DEST_REG; // Output destination register address
    wire [31:0] OUT_PC_PLUS_4; // Output PC+4 value
    wire [31:0] OUT_IMMEDIATE; // Output immediate value
    wire [1:0] OUT_MEM_WRITE; // Output memory write signal
    wire [1:0] OUT_MEM_READ; // Output memory read signal
    wire [1:0] OUT_REG_WRITE_SEL; // Output register write select signal
    wire OUT_REG_WRITE_ENABLE; // Output register write enable signal

    // Instantiate the EX_MA_reg module
    EX_MA_reg ex_ma_reg_t(
        .ALU_RESULT(ALU_RESULT),
        .DEST_REG(DEST_REG),
        .PC_PLUS_4(PC_PLUS_4),
        .IMMEDIATE(IMMEDIATE),
        .MEM_WRITE(MEM_WRITE),
        .MEM_READ(MEM_READ),
        .REG_WRITE_SEL(REG_WRITE_SEL),
        .REG_WRITE_ENABLE(REG_WRITE_ENABLE),
        .CLK(CLK),
        .RESET(RESET),
        .OUT_ALU_RESULT(OUT_ALU_RESULT),
        .OUT_DEST_REG(OUT_DEST_REG),
        .OUT_PC_PLUS_4(OUT_PC_PLUS_4),
        .OUT_IMMEDIATE(OUT_IMMEDIATE),
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
        $dumpfile("EX_MA_reg_tb.vcd");
        $dumpvars(0, EX_MA_reg_tb);
        $monitor("Time: %0t | ALU_RESULT: %d | DEST_REG: %d | PC_PLUS_4: %d | IMMEDIATE: %d | MEM_WRITE: %b | MEM_READ: %b | REG_WRITE_SEL: %b | REG_WRITE_ENABLE: %b | OUT_ALU_RESULT: %d | OUT_DEST_REG: %d | OUT_PC_PLUS_4: %d | OUT_IMMEDIATE: %d | OUT_MEM_WRITE: %b | OUT_MEM_READ: %b | OUT_REG_WRITE_SEL: %b | OUT_REG_WRITE_ENABLE: %b", 
                 $time, ALU_RESULT, DEST_REG, PC_PLUS_4, IMMEDIATE, MEM_WRITE, MEM_READ, REG_WRITE_SEL, REG_WRITE_ENABLE, OUT_ALU_RESULT, OUT_DEST_REG, OUT_PC_PLUS_4, OUT_IMMEDIATE, OUT_MEM_WRITE, OUT_MEM_READ, OUT_REG_WRITE_SEL, OUT_REG_WRITE_ENABLE);

        // Initialize inputs
        RESET = 1; // Assert reset
        ALU_RESULT = 32'd0;
        DEST_REG = 5'd0;
        PC_PLUS_4 = 32'd0;
        IMMEDIATE = 32'd0;
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
        ALU_RESULT = 32'd100; // Write ALU result 100
        DEST_REG = 5'd1; // Write to register 1
        PC_PLUS_4 = 32'd104; // Write PC+4 value 104
        IMMEDIATE = 32'd200; // Write immediate value 200
        MEM_WRITE = 2'b01; // Write memory write signal
        MEM_READ = 2'b10; // Write memory read signal
        REG_WRITE_SEL = 2'b11; // Write register write select signal
        REG_WRITE_ENABLE = 1'b1; // Write register write enable signal
        #8; // Wait for a clock cycle

        ALU_RESULT = 32'd300; // Write ALU result 300
        DEST_REG = 5'd2; // Write to register 2
        PC_PLUS_4 = 32'd304; // Write PC+4 value 304
        IMMEDIATE = 32'd400; // Write immediate value 400
        MEM_WRITE = 2'b11; // Write memory write signal
        MEM_READ = 2'b01; // Write memory read signal
        REG_WRITE_SEL = 2'b10; // Write register write select signal
        REG_WRITE_ENABLE = 1'b0; // Write register write enable signal
        #8; // Wait for a clock cycle

    $finish; // End the simulation
    end

endmodule