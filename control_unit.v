`timescale 1ns / 1ps

module control_unit (
    input         clk,
    input         reset,
    input         en,
    input  [7:0]  pc_in,
    input  [15:0] instruction,
    input         zero_flag,

    output reg    reg_write,
    output reg    mem_write, mem_read,
    output reg    mem_to_reg,
    output reg [2:0] alu_op,
    output reg    alu_src, pc_src,
    output reg    inc_PC,
    output reg [2:0] reg_dst,
    output reg [2:0] reg_src1, reg_src2,
    output reg [15:0] immediate,
    output reg [7:0]  jump_addr,
    output        halted
);
  
    localparam FETCH   = 2'b00,
               DECODE  = 2'b01,
               EXECUTE = 2'b10;

    reg [1:0] state, next_state;
    reg       halted_reg;

    // Instruction fields
    wire [3:0]  opcode  = instruction[15:12];
    wire [2:0]  rt      = instruction[11:9];
    wire [2:0]  rs      = instruction[8:6];
    wire [2:0]  rd      = instruction[5:3];
    wire [2:0]  funct   = instruction[2:0];
    wire [5:0]  imm6    = instruction[5:0];
    wire [11:0] addr12  = instruction[11:0];
    wire [15:0] imm_ext = {{10{imm6[5]}}, imm6};

    // State register + HALT latch
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state      <= FETCH;
            halted_reg <= 1'b0;
        end else if (en) begin
            state <= next_state;
            if (state == DECODE && opcode == 4'b1111)
                halted_reg <= 1'b1;
        end
    end
    assign halted = halted_reg;

    // Combinational outputs + next_state
    always @(*) begin
        // defaults
        reg_write  = 1'b0;
        mem_write  = 1'b0;
        mem_read   = 1'b0;
        mem_to_reg = 1'b0;
        alu_op     = 3'b000;
        alu_src    = 1'b0;
        pc_src     = 1'b0;
        inc_PC     = 1'b0;
        reg_dst    = 3'd0;
        reg_src1   = 3'd0;
        reg_src2   = 3'd0;
        immediate  = 16'd0;
        jump_addr  = 8'd0;
        next_state = FETCH;

        case (state)
        FETCH: begin
            inc_PC     = 1'b1;
            next_state = DECODE;
        end

        DECODE: begin
            case (opcode)
                4'b0000,4'b0001,4'b0010,4'b0011, //I-type
                4'b0100,4'b0101,4'b0110,4'b0111,
                4'b1000, //R-type
                4'b1001, //ldr
                4'b1010://str
                    next_state = EXECUTE;

                4'b1011: begin //jump
                    jump_addr  = addr12[7:0];
                    pc_src     = 1'b1;
                    next_state = FETCH;
                end

                4'b1100: begin //BEQZ
                    jump_addr  = pc_in + imm_ext[7:0] + 8'd1;
                    next_state = EXECUTE;
                end

                4'b1111:// HALT
                    next_state = FETCH;

                default:
                    next_state = FETCH;
            endcase
        end

        EXECUTE: begin
            case (opcode)
                4'b0000,4'b0001,4'b0010,4'b0011, //I-type
                4'b0100,4'b0101,4'b0110,4'b0111: begin
                    alu_op     = opcode[2:0];
                    reg_src1   = rs;
                    reg_dst    = rt;
                    alu_src    = 1'b1;
                    immediate  = imm_ext;
                    reg_write  = 1'b1;
                    next_state = FETCH;
                end

                4'b1000: begin //R-type
                    alu_op     = funct;
                    reg_src1   = rs;
                    reg_src2   = rd;
                    reg_dst    = rt;
                    alu_src    = 1'b0;
                    reg_write  = 1'b1;
                    next_state = FETCH;
                end

                4'b1001: begin //ldr
                    alu_op     = 3'b000;
                    reg_src1   = rs;
                    reg_dst    = rt;
                    alu_src    = 1'b1;
                    immediate  = imm_ext;
                    mem_read   = 1'b1;
                    mem_to_reg = 1'b1;
                    reg_write  = 1'b1;
                    next_state = FETCH;
                end

                4'b1010: begin //store
                    alu_op     = 3'b000;
                    reg_src1   = rs;
                    reg_src2   = rt;
                    alu_src    = 1'b1;
                    immediate  = imm_ext;
                    mem_write  = 1'b1;
                    next_state = FETCH;
                end

                4'b1100: begin //BZEQ
                    alu_op     = 3'b001;
                    reg_src1   = rt;
                    alu_src    = 1'b0;
                    immediate  = imm_ext;
                    if (zero_flag)
                        pc_src = 1'b1;
                    next_state = FETCH;
                end
                4'b1111:// HALT
                    next_state = FETCH;
                default:
                    next_state = FETCH;
            endcase
        end

        endcase
    end
endmodule
