`timescale 1ns / 1ps

module tb_top_rv32i_single;

    // 1. 테스트벤치 내부 신호 선언
    logic          clk;
    logic          reset;
    integer        errors;

    // Instruction Memory Interface
    logic   [31:0] instr_addr;
    logic   [31:0] instr_data;

    logic          dwe;
    logic   [31:0] daddr;
    logic   [31:0] dwdata;
    logic   [31:0] drdata;

    // DUT (Device Under Test) 인스턴스화
    top_unit u_dut (
        .clk       (clk),
        .reset     (reset),
        .instr_data(instr_data),
        .instr_addr(instr_addr),
        .dwe       (dwe),
        .daddr     (daddr),
        .dwdata    (dwdata),
        .drdata    (drdata)
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

    //Clock Generation (10ns period -> 100MHz)
    always #5 clk = ~clk;

    //시뮬레이션 시나리오 및 검증
    initial begin

        clk   = 0;
        reset = 1;
        #20; 
        reset = 0;

        #200;
        $finish;
    end
endmodule