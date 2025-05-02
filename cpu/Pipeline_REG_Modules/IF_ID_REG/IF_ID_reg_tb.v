// Testbench for IF_ID_REG

`timescale 1ns/100ps
`include "IF_ID_reg.v" // Include the module definition

module IF_ID_reg_tb;
    
    // Defining input/output ports
    reg [31:0] INSTRUCTION; // Input instruction
    reg [31:0] PC_PLUS_4;   // Input PC+4 value
    reg CLK;               // Clock signal
    reg RESET;             // Reset signal
    wire [31:0] OUT_INSTRUCTION; // Output instruction
    wire [31:0] OUT_PC_PLUS_4;   // Output PC+4 value

    // Instantiate the IF_ID_REG module
    IF_ID_reg if_id_reg_t(
        .INSTRUCTION(INSTRUCTION),
        .PC_PLUS_4(PC_PLUS_4),
        .CLK(CLK),
        .RESET(RESET),
        .OUT_INSTRUCTION(OUT_INSTRUCTION),
        .OUT_PC_PLUS_4(OUT_PC_PLUS_4)
    );

    // Clock generation
    initial begin
        CLK = 1;
        forever #4 CLK = ~CLK; // Toggle clock every 4 time units
    end

    // Testbench logic
    initial begin

        // generate files needed to plot the waveform using GTKWave
        $dumpfile("IF_ID_reg_tb.vcd");
        $dumpvars(0, IF_ID_reg_tb);
        $monitor("Time: %0t | INSTRUCTION: %d | PC_PLUS_4: %d | OUT_INSTRUCTION: %d | OUT_PC_PLUS_4: %d", 
                 $time, INSTRUCTION, PC_PLUS_4, OUT_INSTRUCTION, OUT_PC_PLUS_4);

    
        // Initialize inputs
        RESET = 1; // Assert reset
        INSTRUCTION = 32'd0;
        PC_PLUS_4 = 32'd0;

        // Wait for a few clock cycles
        #8;

        // Deassert reset
        RESET = 0;
        #8;

        // Test writing to the register file
        INSTRUCTION = 32'd100; // Write instruction 100
        PC_PLUS_4 = 32'd104; // Write PC+4 value 104
        #8; // Wait for a clock cycle
        INSTRUCTION = 32'd200; // Write instruction 200
        PC_PLUS_4 = 32'd204; // Write PC+4 value 204
        #8; // Wait for a clock cycle

        INSTRUCTION = 32'd300; // Write instruction 300
        PC_PLUS_4 = 32'd304; // Write PC+4 value 304
        #8; // Wait for a clock cycle

        INSTRUCTION = 32'd400; // Write instruction 400
        PC_PLUS_4 = 32'd404; // Write PC+4 value 404
        #8; // Wait for a clock cycle

        $finish; // End the simulation
    end
endmodule
