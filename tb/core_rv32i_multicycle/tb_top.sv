`timescale 1ns / 1ps

module tb_top ();

    logic        clk;
    logic        reset;

    // Instruction Memory Interface
    logic [31:0] instr_addr;
    logic [31:0] instr_data;

    logic        dwe;
    logic [31:0] drdata;
    logic [ 2:0] funct3_o;
    logic [31:0] daddr;
    logic [31:0] dwdata;

    top_unit DUT (
        .clk       (clk),
        .reset     (reset),
        .instr_data(instr_data),
        .instr_addr(instr_addr),
        .drdata    (drdata),
        .dwe       (dwe),
        .funct3_o  (funct3_o),
        .daddr     (daddr),
        .dwdata    (dwdata)
    );

    instruction_mem u_inst_mem (
        .instr_addr(instr_addr),
        .instr_data(instr_data)
    );

    data_mem u_data_mem (
        .clk   (clk),
        .dwe   (dwe),
        .funct3(funct3),
        .daddr (daddr),
        .dwdata(dwdata),
        .drdata(drdata)
    );

    assign #5 clk = ~clk;

    initial begin
        #0;
        clk   = 0;
        reset = 1;

        #100;
        reset = 0;

        #100_000;
        $stop;
    end

endmodule
