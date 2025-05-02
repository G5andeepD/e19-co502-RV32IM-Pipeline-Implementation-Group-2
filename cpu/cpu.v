`include "1_IF_STAGE/pc.v"
// `include "1_IF_STAGE/imem.v"
`include "2_ID_RF_STAGE/reg_file.v"
`include "2_ID_RF_STAGE/control_unit.v"
`include "3_EX_STAGE/alu.v"
`include "muxes/mux_32b_2to1.v"
`include "muxes/mux_32b_4to1.v"
`include "adders/pc_adder_32b.v"
`include "Pipeline_REG_Modules/IF_ID_REG/IF_ID_reg.v"
`include "Pipeline_REG_Modules/ID_EX_REG/ID_EX_reg.v"
`include "Pipeline_REG_Modules/EX_MA_REG/EX_MA_reg.v"
`include "Pipeline_REG_Modules/MA_WB_REG/MA_WB_reg.v"

`timescale 1ns/100ps

module cpu(
    input clk, // Clock signal
    input reset, // Reset signal
    input [31:0] instr_if, // Instruction input
    input [31:0] dmem_data_out, // Data input from memory
    output [31:0] pc_out, // Program counter output
    output [31:0] dmem_data_in, // Data output from MA stage
    output [31:0] alu_result_ma, // Address output from MA stage
    output [1:0] mem_write_ma, // Memory write signal output from MA stage
    output [1:0] mem_read_ma // Memory read signal output from MA stage
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
wire [1:0] reg_write_select_id; // Register write selection signal from ID stage
wire op1_sel_id, op2_sel_id, reg_write_enable_id; // Register write enable signal from ID stage

//EX
wire [4:0] instr_ex;
wire [31:0] pc_ex; // Program counter output from EX stage
wire [31:0] rs_data_ex, rt_data_ex; // Register data outputs from EX stage
wire [4:0] alu_op_ex; // ALU operation code from EX stage
wire [31:0] alu_result_ex; // ALU result output from EX stage
wire [31:0] alu_input1_ex, alu_input2_ex; // ALU input values from EX stage
wire [31:0] imm_ex; // Immediate value from EX stage
wire op1_sel_ex, op2_sel_ex; // Operand selection signals from EX stage
wire [1:0] mem_write_ex, mem_read_ex; // Memory write/read signals from EX stage
wire [1:0] reg_write_select_ex; // Register write selection signal from EX stage
wire reg_write_enable_ex; // Register write enable signal from EX stage
wire [2:0] branch_jump_ex; // Branch/jump signal from EX stage

//MA
wire [31:0] pc_ma; // Program counter output from MA stage
wire [31:0] alu_result_ma;
wire [4:0] instr_ma; // Instruction output from MA stage
wire [1:0] reg_write_select_ma; // Register write selection signal from MA stage
wire reg_write_enable_ma; // Register write enable signal from MA stage
wire [31:0] pc_plus_4_ma; // PC+4 value from MA stage

//WB
wire [31:0] dmem_out_wb; // Data input to memory from WB stage
wire [1:0] reg_write_select_wb; // Register write selection signal from WB stage
wire reg_write_enable_wb; // Register write enable signal from WB stage
wire [31:0] alu_result_wb; // ALU result output from WB stage
wire [31:0] pc_plus_4_wb; // PC+4 value from WB stage
wire [4:0] instr_wb; // Instruction output from WB stage
wire [31:0] reg_write_data_wb; // Register write data output from WB stage

//------------------------//
// IF Stage


//PC mux
mux_32b_2to1 pc_mux(
    .in0(pc_plus_4_if), // Current PC value
    .in1(alu_result_ex), // Next PC value
    .sel(1'b0), // Select signal (0 for in0, 1 for in1)
    .out(pc_initial_if) // Output PC value
);

//PC adder
pc_adder_32b pc_adder(
    .pc_in(pc_out), // Input PC value
    .pc_out(pc_plus_4_if) // Output PC+4 value
);

//Program counter
pc pc(
    .clk(clk), // Clock signal
    .reset(reset), // Reset signal
    .pc_in(pc_initial_if), // Input PC value
    .pc_out(pc_out) // Output PC value
);


//------------------------//
// IF_ID Stage
//Pipeline register IF_ID
IF_ID_reg if_id_reg(
    .INSTRUCTION(instr_if), // Input instruction from IF stage
    .PC_PLUS_4(pc_out), // Input PC+4 value from IF stage
    .CLK(clk), // Clock signal
    .RESET(reset), // Reset signal
    .OUT_INSTRUCTION(instr_id), // Output instruction to ID stage
    .OUT_PC_PLUS_4(pc_id) // Output PC+4 value to ID stage
);

//-------------------------//
// ID Stage

//Register file
reg_file reg_file(
        .WRITE_ENABLE(reg_write_enable_wb), // Register write enable signal
        .CLK(clk),
        .RESET(reset),
        .WRITE_ADDR(instr_wb),
        .OUT_ADDR1(instr_id[19:15]), // rs
        .OUT_ADDR2(instr_id[24:20]), // rt
        .WRITE_DATA(reg_write_data_wb),
        .DATA_OUT1(rs_data_id),
        .DATA_OUT2(rt_data_id)
    );

//Control unit
control_unit control_unit(
    .opcode(instr_id[6:0]), // Opcode from instruction
    .funct3(instr_id[14:12]), // Function code from instruction
    .funct7(instr_id[31:25]), // Function code from instruction
    .imm_sel(imm_sel_id), // Immediate selection signal output
    .aluop(aluop_id), // ALU operation code output
    .branch_jump(branch_jump_id), // Branch/jump signal output
    .mem_write(mem_write_id), // Memory write signal output
    .mem_read(mem_read_id), // Memory read signal output
    .reg_write_select(reg_write_select_id), // Register write selection signal output
    .op1_sel(op1_sel_id), // Operand 1 selection signal output
    .op2_sel(op2_sel_id), // Operand 2 selection signal output
    .reg_write_enable(reg_write_enable_id) // Register write enable signal output
);

  

//--------------------------//
//ID_EX Stage
//Pipeline register ID_EX
ID_EX_reg id_ex_reg(
    .DEST_REG(instr_id[11:7]), // Destination register address from instruction
    .PC_PLUS_4(pc_id), // PC+4 value from IF_ID stage
    .READ_DATA1(rs_data_id), // Read data 1 from register file
    .READ_DATA2(rt_data_id), // Read data 2 from register file
    .IMMEDIATE(32'b0), // Immediate value from instruction
    .ALU_OP(aluop_id), // ALU operation code from control unit
    .BRANCH_JUMP(branch_jump_id), // Branch/jump signal from control unit
    .OP1_SEL(op1_sel_id), // Operand 1 selection signal from control unit
    .OP2_SEL(op2_sel_id), // Operand 2 selection signal from control unit
    .MEM_WRITE(mem_write_id), // Memory write signal from control unit
    .MEM_READ(mem_read_id), // Memory read signal from control unit
    .REG_WRITE_SEL(reg_write_select_id), // Register write selection signal from control unit
    .REG_WRITE_ENABLE(reg_write_enable_id), // Register write enable signal from control unit
    .CLK(clk), // Clock signal
    .RESET(reset), // Reset signal
    .OUT_DEST_REG(instr_ex), // Output destination register address to EX stage
    .OUT_PC_PLUS_4(pc_ex), // Output PC+4 value to EX stage
    .OUT_READ_DATA1(rs_data_ex), // Output read data 1 to EX stage
    .OUT_READ_DATA2(rt_data_ex), // Output read data 2 to EX stage
    .OUT_IMMEDIATE(imm_ex), // Output immediate value to EX stage
    .OUT_ALU_OP(alu_op_ex), // Output ALU operation code to EX stage
    .OUT_BRANCH_JUMP(branch_jump_ex), // Output branch/jump signal to EX stage
    .OUT_OP1_SEL(op1_sel_ex), // Output operand 1 selection signal to EX stage
    .OUT_OP2_SEL(op2_sel_ex), // Output operand 2 selection signal to EX stage
    .OUT_MEM_WRITE(mem_write_ex), // Output memory write signal to EX stage
    .OUT_MEM_READ(mem_read_ex), // Output memory read signal to EX stage
    .OUT_REG_WRITE_SEL(reg_write_select_ex), // Output register write selection signal to EX stage
    .OUT_REG_WRITE_ENABLE(reg_write_enable_ex) // Output register write enable signal to EX stage
);

//--------------------------//
// EX Stage

//MUXes
mux_32b_2to1 alu_input1_mux(
    .in0(rs_data_ex), // Input 0 (rs_data_ex)
    .in1(imm_ex), // Input 1 (immediate value)
    .sel(op1_sel_ex), // Select signal (0 for in0, 1 for in1)
    .out(alu_input1_ex) // Output ALU input 1
);
mux_32b_2to1 alu_input2_mux(
    .in0(rt_data_ex), // Input 0 (rt_data_ex)
    .in1(imm_ex), // Input 1 (immediate value)
    .sel(op2_sel_ex), // Select signal (0 for in0, 1 for in1)
    .out(alu_input2_ex) // Output ALU input 2
);

//ALU
alu alu(
    .SELECT(alu_op_ex), // ALU operation code
    .DATA1(alu_input1_ex), // ALU input 1
    .DATA2(alu_input2_ex), // ALU input 2
    .RESULT(alu_result_ex) // ALU result output
);


//---------------------------//
// EX_MA stage
//Pipeline register EX_MA
EX_MA_reg ex_ma_reg(
    .ALU_RESULT(alu_result_ex), // ALU result from EX stage
    .DEST_REG(instr_ex), // Destination register address from EX stage
    .PC_PLUS_4(pc_ex), // PC+4 value from EX stage
    .IMMEDIATE(imm_ex),
    .MEM_WRITE(mem_write_ex),
    .MEM_READ(mem_read_ex),
    .REG_WRITE_SEL(reg_write_select_ex),
    .REG_WRITE_ENABLE(reg_write_enable_ex),
    .CLK(clk),
    .RESET(reset),
    .OUT_ALU_RESULT(alu_result_ma), // Output ALU result to MA stage
    .OUT_DEST_REG(instr_ma),
    .OUT_PC_PLUS_4(pc_ma), // Output PC+4 value to MA stage
    .OUT_IMMEDIATE(dmem_data_in),
    .OUT_MEM_WRITE(mem_write_ma),
    .OUT_MEM_READ(mem_read_ma),
    .OUT_REG_WRITE_SEL(reg_write_select_ma),
    .OUT_REG_WRITE_ENABLE(reg_write_enable_ma)
);

//---------------------------//
// MA Stage
// Adder for PC+4
pc_adder_32b pc_adder_ma(
    .pc_in(pc_ma), // Input PC value
    .pc_out(pc_plus_4_ma) // Output PC+4 value
);

// Data memory (for MA stage)


//---------------------------//
// MA_WB stage
//Pipeline register MA_WB
MA_WB_reg ma_wb_reg(
    .ALU_RESULT(alu_result_ma), // ALU result from MA stage
    .DEST_REG(instr_ma), // Destination register address from MA stage
    .PC_PLUS_4(pc_plus_4_ma), // PC+4 value from MA stage
    .DATA_OUT(dmem_data_out), // Data output from memory
    .REG_WRITE_SEL(reg_write_select_ma), // Register write selection signal from MA stage
    .REG_WRITE_ENABLE(reg_write_enable_ma), // Register write enable signal from MA stage
    .CLK(clk), // Clock signal
    .RESET(reset), // Reset signal
    .OUT_ALU_RESULT(alu_result_wb), // Output ALU result to WB stage
    .OUT_DEST_REG(instr_wb),
    .OUT_PC_PLUS_4(pc_plus_4_wb), // Output PC+4 value to WB stage
    .OUT_DATA_OUT(dmem_out_wb), // Output data output to WB stage
    .OUT_REG_WRITE_SEL(reg_write_select_wb),
    .OUT_REG_WRITE_ENABLE(reg_write_enable_wb)
);

//---------------------------//
// WB Stage

// MUX for data selection
mux_32b_4to1 data_mux(
    .in0(pc_plus_4_wb), // Input 2 (PC+4 value)
    .in1(alu_result_wb), // Input 0 (ALU result)
    .in2(dmem_out_wb), // Input 1 (Data output from memory)
    .in3(32'b0), // Input 3 (Unused)
    .sel(reg_write_select_wb), // Select signal
    .out(reg_write_data_wb) // Output data to memory
);

endmodule