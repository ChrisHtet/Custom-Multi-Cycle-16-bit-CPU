`timescale 1ns / 1ps

module Data_mem (
    input         clk,
    input         mem_write,
    input         mem_read,
    input  [7:0]  addr,
    input  [15:0] data_in,
    output reg [15:0] data_out
);
    reg [15:0] mem [0:255];

    always @(posedge clk) begin     // sync write
        if (mem_write)
            mem[addr] <= data_in;
    end

    always @(*) begin               // async read
        if (mem_read)
            data_out = mem[addr];
        else
            data_out = 16'd0;
    end
endmodule
