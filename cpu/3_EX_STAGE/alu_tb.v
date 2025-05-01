`include "alu.v"

module alu_tb;
    reg [31:0] DATA1, DATA2;
    reg [4:0] SELECT;
    wire [31:0] RESULT;

    // Instantiate the ALU module
    alu uut (
        .DATA1(DATA1),
        .DATA2(DATA2),
        .SELECT(SELECT),
        .RESULT(RESULT)
    );

    reg clk;
    always #4 clk = ~clk; // Clock generation

    initial begin

        clk = 0; // Initialize clock
        DATA1 = 0; // Initialize DATA1
        DATA2 = 0; // Initialize DATA2
        SELECT = 0; // Initialize SELECT

        //wait for global reset to finish
        #8

        // Test case 1: ADD operation
        DATA1 = 32'd10;
        DATA2 = 32'd20;
        SELECT = `ADD;
        #4; // Wait for the result to stabilize
        $display("ADD: %d + %d = %d", DATA1, DATA2, RESULT);

        // Test case 2: SUB operation
        DATA1 = 32'd30;
        DATA2 = 32'd15;
        SELECT = `SUB;
        #4; // Wait for the result to stabilize
        $display("SUB: %d - %d = %d", DATA1, DATA2, RESULT);

        // Test case 3: SLL operation
        DATA1 = 32'd5;
        DATA2 = 32'd2;
        SELECT = `SLL;
        #4; // Wait for the result to stabilize
        $display("SLL: %d << %d = %d", DATA1, DATA2, RESULT);

        // Test case 4: SLT operation
        DATA1 = 32'd5;
        DATA2 = 32'd10;
        SELECT = `SLT;
        #4; // Wait for the result to stabilize
        $display("SLT: %d < %d = %d", DATA1, DATA2, RESULT);

        $finish; // End the simulation
    end
endmodule