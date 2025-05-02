`timescale 1ns/100ps

module pc(
    input clk, 
    input reset, 
    input [31:0] pc_in, 
    output reg [31:0] pc_out
);

    always @(posedge clk or posedge reset) begin
        
        if (reset) begin
            pc_out <= 32'b0; // Reset PC to 0
        end else begin
            #2 pc_out <= pc_in; // Update PC with new value
        end
    end
endmodule