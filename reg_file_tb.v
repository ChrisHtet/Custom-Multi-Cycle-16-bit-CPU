`timescale 1ns / 1ps

module reg_file_tb();
    reg         clk, reset, reg_write;
    reg  [2:0]  reg_dst;
    reg  [2:0]  reg_src1, reg_src2;
    reg  [15:0] write_data;
    wire [15:0] read_data1, read_data2;

    reg_file uut (
        .clk(clk), .reset(reset), .reg_write(reg_write),
        .reg_dst(reg_dst), .reg_src1(reg_src1), .reg_src2(reg_src2),
        .write_data(write_data), .read_data1(read_data1), .read_data2(read_data2)
    );
    always #5 clk = ~clk; // 10ns period

    initial begin
        clk         = 0;
        reset       = 0;
        reg_write   = 0;
        reg_dst     = 0;
        reg_src1    = 0;
        reg_src2    = 0;
        write_data  = 0;

        @(posedge clk)  reset = 1;
        @(posedge clk)  reset = 0;
        @(posedge clk)  $display("After reset: read_data1 = %h, read_data2 = %h", read_data1, read_data2);

        //Test1: Write to reg1 and read from it
                        reg_write = 1;
                        reg_dst = 3'd1;
                        write_data = 16'hABCD;
        @(posedge clk)  reg_write = 0;
        @(posedge clk)  reg_src1 = 3'd1;
                        reg_src2 = 3'd0;
        @(posedge clk)  $display("Test 1: Write %h to R1, read R1 = %h, R0 = %h", 16'hABCD, read_data1, read_data2);

        //Test2: Write to reg2 and read from both R1 and R2
                        reg_write = 1;
                        reg_dst = 3'd2;
                        write_data = 16'h1234;
        @(posedge clk)  reg_write = 0;
        @(posedge clk)  reg_src1 = 3'd1;
                        reg_src2 = 3'd2;
        @(posedge clk)  $display("Test 2: Write %h to R2, read R1 = %h, R2 = %h", 16'h1234, read_data1, read_data2);

        //Test3: write to reg0 but should remain 0
                        reg_write = 1;
                        reg_dst = 3'd0;
                        write_data = 16'hFFFF;
        @(posedge clk)  reg_write = 0;
        @(posedge clk)  reg_src1 = 3'd0;
                        reg_src2 = 3'd1;
        @(posedge clk)  $display("Test 3: Attempt write %h to R0, read R0 = %h, R1 = %h", 16'hFFFF, read_data1, read_data2);

        //Test4: Write to reg7 and read from it
                        reg_write = 1;
                        reg_dst = 3'd7;
                        write_data = 16'h7890;
        @(posedge clk)  reg_write = 0;
        @(posedge clk)  reg_src1 = 3'd7;
                        reg_src2 = 3'd0;
        @(posedge clk)  $display("Test 4: Write %h to R7, read R7 = %h, R0 = %h", 16'h7890, read_data1, read_data2);

        //Test5: Reset to check all registers
                        reset = 1;
        @(posedge clk)  reset = 0;
        @(posedge clk)  reg_src1 = 3'd1;
                        reg_src2 = 3'd7;
        @(posedge clk)  $display("Test 5: After reset, read R1 = %h, R7 = %h", read_data1, read_data2);
        $finish;
    end
endmodule
