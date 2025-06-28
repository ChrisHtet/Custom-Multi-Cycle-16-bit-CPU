`timescale 1ns / 1ps

module PC (
    input           clk,
    input           reset,
    input           halt,      
    input           pc_src, // branch/jump
    input           inc_PC,     
    input  [7:0]    next_addr,
    output reg [7:0] pc
);
    always @(posedge clk or posedge reset) begin
        if (reset) 
            pc <= 8'd0;
        else if (halt)
            pc <= pc;
        else if (pc_src)
            pc <= next_addr;
        else if (!halt && inc_PC)
            pc <= pc + 8'd1;
    end
endmodule
