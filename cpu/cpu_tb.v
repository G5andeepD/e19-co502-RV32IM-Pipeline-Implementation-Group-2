// Testbench for CPU
// This testbench is designed to simulate the CPU module

`timescale 1ns / 1ps
`include "cpu.v" // Include the CPU module definition
`include "./1_IF_STAGE/imem.v"
`include "./4_MA_STAGE/dmem.v"

module cpu_tb;

    // Declare signals for CPU module
    reg clk, reset;
    wire [31:0] instr_if;
    wire [31:0] dmem_data_out;
    wire [31:0] pc_out;
    wire [31:0] dmem_data_in;
    wire [31:0] alu_result_ma;
    wire [1:0] mem_write_ma;
    wire [1:0] mem_read_ma;

    // Instantiate the CPU module (Unit Under Test)
    cpu cpu_t (
        .clk(clk),
        .reset(reset),
        .instr_if(instr_if),
        .dmem_data_out(dmem_data_out),
        .pc_out(pc_out),
        .dmem_data_in(dmem_data_in),
        .alu_result_ma(alu_result_ma),
        .mem_write_ma(mem_write_ma),
        .mem_read_ma(mem_read_ma)
    );

    // Instantiate the instruction memory and data memory modules
    imem imem_t (
        .clk(clk),
        .reset(reset),
        .pc(pc_out),
        .instruction(instr_if)
    );
    dmem dmem_t (
        .clk(clk),
        .address(alu_result_ma),
        .data_in(dmem_data_in),
        .mem_write(mem_write_ma),
        .mem_read(mem_read_ma),
        .reset(reset),
        .data_out(dmem_data_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #4 clk = ~clk; // Toggle clock every 4 time units
    end

    // Testbench logic
    integer i;
    initial begin
        // Generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_tb.vcd");
        $dumpvars(0, cpu_tb);
        $monitor("Time: %0t | clk: %b | reset: %b | instr_if: %h | dmem_data_out: %h | pc_out: %h | dmem_data_in: %h | alu_result_ma: %h | mem_write_ma: %b | mem_read_ma: %b", 
                 $time, clk, reset, instr_if, dmem_data_out, pc_out, dmem_data_in, alu_result_ma, mem_write_ma, mem_read_ma);

        for (i = 0; i < 32; i = i + 1)
            $dumpvars(1, cpu_tb.cpu_t.reg_file.REGISTERS[i]); // Dump all registers in the register file
        // Initialize inputs
        reset = 1; // Assert reset
        #8; // Wait for a few clock cycles

        // Deassert reset
        reset = 0;
        #8; // Wait for a few clock cycles

        // Add more test cases as needed
        

        // Finish simulation after some time
        #100;
        $finish;
    end
endmodule
   