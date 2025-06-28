`timescale 1ns / 1ps

module ins_mem (
    input  [7:0]  addr,
    output reg [15:0] instruction
);
    reg [15:0] mem [0:255];
    initial begin
        $readmemh("program.hex", mem);
    end
    always @(*) begin
        instruction = mem[addr];
    end
endmodule
