`timescale 1ns/100ps

module reg_file (WRITE_DATA, DATA_OUT1, DATA_OUT2, WRITE_ADDR, OUT_ADDR1, OUT_ADDR2, WRITE_ENABLE, CLK, RESET);

    // Defining input/output ports
    input WRITE_ENABLE, CLK, RESET;
    input [4:0] WRITE_ADDR, OUT_ADDR1, OUT_ADDR2;
    input [31:0] WRITE_DATA;
    output [31:0] DATA_OUT1, DATA_OUT2;

    // The register file is a 32x32 array of registers
    // Each register is 32 bits wide, and there are 32 registers
    reg [31:0] REGISTERS [31:0];

    // Reading the registers
    // Assychronous read, this runs when the register values changes
    assign #2 DATA_OUT1 = REGISTERS[OUT_ADDR1];
    assign #2 DATA_OUT2 = REGISTERS[OUT_ADDR2];

    // Writes must happen on the negative clock edge
    integer i;
    always @ (negedge CLK) 
    begin
        if (RESET)
            for (i = 0; i < 32; i = i + 1)
                REGISTERS[i] <= #1 32'd0;       // Write zero to all the registers
        else
            if (WRITE_ENABLE && (WRITE_ADDR !== 5'd0))     // Register x0 cannot be written to
                REGISTERS[IN_ADDR] <= #1 WRITE_DATA;
        end
    end

endmodule