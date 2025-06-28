`timescale 1ns / 1ps

module alu_b_mux (
    input  [15:0] reg_data2,
    input  [15:0] immediate,
    input         alu_src,    // 0=reg, 1=imm
    output [15:0] alu_b_in
);
    assign alu_b_in = alu_src ? immediate : reg_data2;
endmodule
