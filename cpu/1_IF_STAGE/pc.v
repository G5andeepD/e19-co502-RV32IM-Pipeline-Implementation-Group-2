`timescale 1ns/100ps

module pc(
    input clk, 
    input reset, 
    input enable,    // Enable signal for pipeline stalling
    input [31:0] pc_in, 
    output reg [31:0] pc_out
);

    always @(posedge clk or posedge reset) begin
        
        if (reset) begin
            pc_out <= 32'b0; // Reset PC to 0
        end else if (enable) begin
            #2 pc_out <= pc_in; // Update PC with new value
        end
        // If enable is low, keep the current value (stall)
    end
endmodule