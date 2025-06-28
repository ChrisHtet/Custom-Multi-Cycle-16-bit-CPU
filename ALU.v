`timescale 1ns / 1ps

module ALU (
    input  [15:0] a,
    input  [15:0] b,
    input  [2:0]  alu_op,
    output reg [15:0] result,
    output reg       zero_flag
);
    always @(*) begin
        case (alu_op)
            3'b000: result = a + b;
            3'b001: result = a - b;
            3'b010: result = a & b;
            3'b011: result = a | b;
            3'b100: result = a ^ b;
            3'b101: result = ~a;
            3'b110: result = a << b[3:0];
            3'b111: result = (a < b) ? 16'd1 : 16'd0;
            default: result = 16'd0;
        endcase
        zero_flag = (result == 16'd0);
    end
endmodule
