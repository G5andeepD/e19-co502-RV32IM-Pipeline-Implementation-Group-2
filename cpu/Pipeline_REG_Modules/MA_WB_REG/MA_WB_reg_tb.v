// Testbench for EX_MA_reg

`timescale 1ns / 1ps
`include "MA_WB_reg.v" // Include the module definition

module MA_WB_reg_tb;

    // Defining input/output ports
    reg [31:0] ALU_RESULT; // Input ALU result
    reg [4:0] DEST_REG; // Input destination register address
    reg [31:0] PC_PLUS_4; // Input PC+4 value
    reg [31:0] DATA_OUT; // Input data output from MA stage
    reg [1:0] REG_WRITE_SEL; // Input register write select signal
    reg REG_WRITE_ENABLE; // Input register write enable signal
    reg CLK; // Clock signal
    reg RESET; // Reset signal

    wire [31:0] OUT_ALU_RESULT; // Output ALU result
    wire [4:0] OUT_DEST_REG; // Output destination register address
    wire [31:0] OUT_PC_PLUS_4; // Output PC+4 value
    wire [31:0] OUT_DATA_OUT; // Output data output to WB stage
    wire [1:0] OUT_REG_WRITE_SEL; // Output register write select signal to WB stage
    wire OUT_REG_WRITE_ENABLE; // Output register write enable signal to WB stage

    // Instantiate the MA_WB_reg module
    MA_WB_reg ma_wb_reg_t(
        .ALU_RESULT(ALU_RESULT),
        .DEST_REG(DEST_REG),
        .PC_PLUS_4(PC_PLUS_4),
        .DATA_OUT(DATA_OUT),
        .REG_WRITE_SEL(REG_WRITE_SEL),
        .REG_WRITE_ENABLE(REG_WRITE_ENABLE),
        .CLK(CLK),
        .RESET(RESET),
        .OUT_ALU_RESULT(OUT_ALU_RESULT),
        .OUT_DEST_REG(OUT_DEST_REG),
        .OUT_PC_PLUS_4(OUT_PC_PLUS_4),
        .OUT_DATA_OUT(OUT_DATA_OUT),
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
        $dumpfile("MA_WB_reg_tb.vcd");
        $dumpvars(0, MA_WB_reg_tb);

        // Initialize inputs
        ALU_RESULT = 32'h00000000;
        DEST_REG = 5'b00000;
        PC_PLUS_4 = 32'h00000000;
        DATA_OUT = 32'h00000000;
        REG_WRITE_SEL = 2'b00;
        REG_WRITE_ENABLE = 1'b0;
        RESET = 1;

        // Wait for a few clock cycles
        #8;

        // Deassert reset
        RESET = 0;
        #8; // Wait for a clock cycle


        // Test case 1: Write to the register file
        ALU_RESULT = 32'h00000001; // Write ALU result 1
        DEST_REG = 5'b00001; // Write to register 1
        PC_PLUS_4 = 32'h00000004; // Write PC+4 value 4
        DATA_OUT = 32'h00000008; // Write data output 8
        REG_WRITE_SEL = 2'b01; // Select register write
        REG_WRITE_ENABLE = 1'b1; // Enable register write
        #8; // Wait for a clock cycle

        // Check outputs
        $display("Time: %0t | ALU_RESULT: %h | DEST_REG: %d | PC_PLUS_4: %h | DATA_OUT: %h | REG_WRITE_SEL: %b | REG_WRITE_ENABLE: %b | OUT_ALU_RESULT: %h | OUT_DEST_REG: %d | OUT_PC_PLUS_4: %h | OUT_DATA_OUT: %h | OUT_REG_WRITE_SEL: %b | OUT_REG_WRITE_ENABLE: %b", 
                 $time, ALU_RESULT, DEST_REG, PC_PLUS_4, DATA_OUT, REG_WRITE_SEL, REG_WRITE_ENABLE, OUT_ALU_RESULT, OUT_DEST_REG, OUT_PC_PLUS_4, OUT_DATA_OUT, OUT_REG_WRITE_SEL, OUT_REG_WRITE_ENABLE);
        if (OUT_ALU_RESULT !== ALU_RESULT || OUT_DEST_REG !== DEST_REG || OUT_PC_PLUS_4 !== PC_PLUS_4 || OUT_DATA_OUT !== DATA_OUT || OUT_REG_WRITE_SEL !== REG_WRITE_SEL || OUT_REG_WRITE_ENABLE !== REG_WRITE_ENABLE) begin
            $display("Test case 1 failed!");
        end else begin
            $display("Test case 1 passed!");
        end

        // Wait for a few clock cycles
        #8;

        // Test case 2: Reset the register file
        RESET = 1; // Assert reset
        #16; // Wait for a clock cycle
        RESET = 0; // Deassert reset
        #8; // Wait for a clock cycle

        // Check outputs after reset
        $display("Time: %0t | ALU_RESULT: %h | DEST_REG: %d | PC_PLUS_4: %h | DATA_OUT: %h | REG_WRITE_SEL: %b | REG_WRITE_ENABLE: %b | OUT_ALU_RESULT: %h | OUT_DEST_REG: %d | OUT_PC_PLUS_4: %h | OUT_DATA_OUT: %h | OUT_REG_WRITE_SEL: %b | OUT_REG_WRITE_ENABLE: %b", 
                 $time, ALU_RESULT, DEST_REG, PC_PLUS_4, DATA_OUT, REG_WRITE_SEL, REG_WRITE_ENABLE, OUT_ALU_RESULT, OUT_DEST_REG, OUT_PC_PLUS_4, OUT_DATA_OUT, OUT_REG_WRITE_SEL, OUT_REG_WRITE_ENABLE);
        if (OUT_ALU_RESULT !== 32'h00000000 || OUT_DEST_REG !== 5'b00000 || OUT_PC_PLUS_4 !== 32'h00000000 || OUT_DATA_OUT !== 32'h00000000 || OUT_REG_WRITE_SEL !== 2'b00 || OUT_REG_WRITE_ENABLE !== 1'b0) begin
            $display("Test case 2 failed!");
        end else begin
            $display("Test case 2 passed!");
        end

        $finish; // End the simulation
    end
endmodule
