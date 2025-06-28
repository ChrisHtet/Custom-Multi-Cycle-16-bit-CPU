`timescale 1ns / 1ps

module reg_file (
    input         clk, reset, reg_write,
    input  [2:0]  reg_dst, reg_src1, reg_src2,
    input  [15:0] write_data,
    output [15:0] read_data1, read_data2
);
    reg [15:0] registers [0:7];
    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i=0; i<8; i=i+1)
                registers[i] <= 16'd0;
        end else if (reg_write) begin
            if (reg_dst != 3'd0)
                registers[reg_dst] <= write_data;
            registers[0] <= 16'd0;  // keep R0 == 0
        end
    end

    assign read_data1 = (reg_src1 == 3'd0) ? 16'd0 : registers[reg_src1];
    assign read_data2 = (reg_src2 == 3'd0) ? 16'd0 : registers[reg_src2];
endmodule
