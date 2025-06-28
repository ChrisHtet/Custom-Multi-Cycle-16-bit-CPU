`timescale 1ns / 1ps

module cpu_tb();
    reg        clk   = 0;
    reg        reset = 1;
    reg        en    = 1;
    wire [7:0]  pc_out;
    wire [15:0] dbg_out;

    cpu_datapath DUT (
        .clk         (clk),
        .reset       (reset),
        .en          (en),
        .pc_out      (pc_out),
        .dbg_reg_out (dbg_out)
    );

    always #5 clk = ~clk;
    always @(posedge clk) begin
      if (pc_out == 8'd0)
        $display("%0t: FETCH@0 ? instruction = %h", $time, DUT.instruction);
      if (pc_out == 8'd1)
        $display("%0t: FETCH@1 ? instruction = %h", $time, DUT.instruction);
      if (pc_out == 8'd2)
        $display("%0t: FETCH@2 ? instruction = %h", $time, DUT.instruction);
    end
    

    initial begin
        $display("Starting CPU 1+1 testbench...");
        #10 reset = 0;
        // 1) ADDI r1, r0, #1
        DUT.instr_mem.mem[0] = 16'h0201;
        // 2) ADDI r2, r0, #1
        DUT.instr_mem.mem[1] = 16'h0401;
        // 3) ADD  r3, r1, r2
        DUT.instr_mem.mem[2] = 16'h8650;
        // 4) HALT
        DUT.instr_mem.mem[3] = 16'hF000;
    
        #10 reset = 0;
        // poke your four words…
    
        // wait six full clock edges so that
        // FETCH?DECODE?EXECUTE of each inst can happen
        repeat (20) @(posedge clk);
    
        // give the non-blocking writes a chance to settle
        #10;
    
        $display("DBG_OUT (R3) = %d (expect 2)", dbg_out);
        $stop;
    end
endmodule
