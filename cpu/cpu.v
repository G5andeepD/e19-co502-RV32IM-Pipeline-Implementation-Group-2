`include "1_IF_STAGE/pc.v"
`include "1_IF_STAGE/imem.v"
`include "2_ID_RF_STAGE/reg_file.v"
`include "2_ID_RF_STAGE/control_unit.v"
`include "3_EX_STAGE/alu.v"
`include "muxes/mux_32b_2to1.v"
`include "muxes/mux_32b_4to1.v"

`timescale 1ns/100ps

module cpu(
    input clk, // Clock signal
    input reset, // Reset signal
    input [31:0] instr_if, // Instruction input
    output [31:0] pc_if, // Program counter output

);
//Wires
//IF
wire [31:0] pc_initial_if, pc_plus_4_if; // PC values

//ID
wire [31:0] instr_id; // Instruction output from IF stage
wire [31:0] pc_id; // Program counter output from ID stage
wire [31:0] rs_data_id, rt_data_id; // Register data outputs from ID stage
wire [2:0] imm_sel_id; // Immediate selection signal from ID stage
wire [4:0] aluop_id; // ALU operation code from ID stage
wire [2:0] branch_jump_id; // Branch/jump signal from ID stage
wire [1:0] mem_write_id, mem_read_id; // Memory write/read signals from ID stage
wire [4:0] reg_write_select_id; // Register write selection signal from ID stage
wire op1_sel, op2_sel, reg_write_enable_id; // Register write enable signal from ID stage

//EX
wire [31:0] instr_ex;
wire [31:0] pc_ex; // Program counter output from EX stage
wire [31:0] rs_data_ex, rt_data_ex; // Register data outputs from EX stage
wire [31:0] alu_result_ex; // ALU result output from EX stage
wire [31:0] alu_input1_ex, alu_input2_ex; // ALU input values from EX stage
wire [31:0] imm_ex; // Immediate value from EX stage


//------------------------//
// IF Stage


//PC mux
mux_32b_2to1 pc_mux(
    .in0(pc_out), // Current PC value
    .in1(pc_out + 4), // Next PC value
    .sel(1'b0), // Select signal (0 for in0, 1 for in1)
    .out(pc_out) // Output PC value
);

  

