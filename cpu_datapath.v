`timescale 1ns / 1ps

module cpu_datapath (
    input         clk,
    input         reset,
    input         en,
    output [7:0]  pc_out,        
    output [15:0] dbg_reg_out    //mirror R3
);
    wire [7:0]   pc, jump_addr;
    wire         halted;
    wire         pc_src, inc_PC;
    wire [15:0]  instr_mem_out;
    reg  [15:0]  instruction;

    // RF control signals
    wire [2:0]   reg_dst, reg_src1, reg_src2;
    wire         reg_write;
    wire [15:0]  write_data, read_data1, read_data2;

    // ALU
    wire [2:0]   alu_op;
    wire         alu_src;
    wire [15:0]  alu_b_in, alu_result;
    wire         zero_flag;

    // Data memory
    wire         mem_read, mem_write, mem_to_reg;
    wire [15:0]  mem_data_out;

    // Immd from cont unit
    wire [15:0]  immediate;

    // PC
    PC pc_inst (
        .clk      (clk),
        .reset    (reset),
        .halt     (halted),
        .pc_src   (pc_src),
        .inc_PC   (inc_PC),
        .next_addr(jump_addr),
        .pc       (pc)
    );
    assign pc_out = pc;

    // Instruction fetch + pipeline register
    ins_mem instr_mem (
        .addr        (pc),
        .instruction (instr_mem_out)
    );
    always @(posedge clk or posedge reset) begin
        if (reset)
            instruction <= 16'd0;
        else if (inc_PC)
            instruction <= instr_mem_out;
    end

    // Control Unit
    control_unit ctrl (
        .clk         (clk),
        .reset       (reset),
        .en          (en),
        .pc_in       (pc),
        .instruction (instruction),
        .zero_flag   (zero_flag),
        .reg_write   (reg_write),
        .mem_write   (mem_write),
        .mem_read    (mem_read),
        .mem_to_reg  (mem_to_reg),
        .alu_op      (alu_op),
        .alu_src     (alu_src),
        .pc_src      (pc_src),
        .inc_PC      (inc_PC),
        .reg_dst     (reg_dst),
        .reg_src1    (reg_src1),
        .reg_src2    (reg_src2),
        .immediate   (immediate),
        .jump_addr   (jump_addr),
        .halted      (halted)
    );

    // Register File
    reg_file rf (
        .clk        (clk),
        .reset      (reset),
        .reg_write  (reg_write),
        .reg_dst    (reg_dst),
        .reg_src1   (reg_src1),
        .reg_src2   (reg_src2),
        .write_data (write_data),
        .read_data1 (read_data1),
        .read_data2 (read_data2)
    );

    // ALU B Mux
    alu_b_mux muxB (
        .reg_data2 (read_data2),
        .immediate (immediate),
        .alu_src   (alu_src),
        .alu_b_in  (alu_b_in)
    );

    // ALU
    ALU alu_inst (
        .a         (read_data1),
        .b         (alu_b_in),
        .alu_op    (alu_op),
        .result    (alu_result),
        .zero_flag (zero_flag)
    );

    // Data Memory
    Data_mem data_mem (
        .clk       (clk),
        .mem_write (mem_write),
        .mem_read  (mem_read),
        .addr      (alu_result[7:0]),
        .data_in   (read_data2),
        .data_out  (mem_data_out)
    );

    // Write-Back Mux
    writeback_mux wb (
        .alu_result (alu_result),
        .mem_data   (mem_data_out),
        .mem_to_reg (mem_to_reg),
        .write_data (write_data)
    );

    // Debug port for R3 
    assign dbg_reg_out = rf.registers[3];

endmodule
