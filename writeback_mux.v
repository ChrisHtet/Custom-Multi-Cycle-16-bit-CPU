`timescale 1ns / 1ps

module writeback_mux (
    input  [15:0] alu_result,
    input  [15:0] mem_data,
    input         mem_to_reg,
    output [15:0] write_data
);
    assign write_data = mem_to_reg ? mem_data : alu_result;
endmodule
