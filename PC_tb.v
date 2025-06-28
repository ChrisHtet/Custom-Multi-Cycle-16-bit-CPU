`timescale 1ns / 1ps
module PC_tb();
    reg clk, reset, halt, pc_src, inc_PC;
    reg [7:0] next_addr;
    wire [7:0] pc;
    
    PC uut(
        .clk(clk),      .reset(reset),
        .halt(halt),    .pc_src(pc_src),
        .pc(pc),        .inc_PC(inc_PC),
        .next_addr(next_addr)
    );
    initial clk = 0;
    always #5 clk = ~clk; // 10ns period
        
    initial begin
        inc_PC      = 0;
        reset       = 0;
        halt        = 0;
        pc_src      = 0;
        next_addr   = 0;
        
        // Test1: Reset
        #2              reset  = 1;
        @(posedge clk)  reset  = 0;
        @(posedge clk)  $display("After Reset: PC = %d", pc);
        
        //Test2: inc_PC
                        inc_PC = 1;
        @(posedge clk) @(posedge clk) @(posedge clk)  
        $display("Aft 3 inc: PC = %d", pc);
        
        //Test3: Halt while inc_PC
            halt = 1;
        @(posedge clk)  $display("HAlt: PC = %d", pc);
        @(posedge clk)  $display("HAlt: PC = %d", pc);
        @(posedge clk)  inc_PC    = 0; halt =0;
               
        //Test3: Branch
                        next_addr = 8'd10;
                        pc_src = 1;
        @(posedge clk)  $display("Branch to address 10: PC = %d", pc);
        #10 $finish;         
    end
    
endmodule
