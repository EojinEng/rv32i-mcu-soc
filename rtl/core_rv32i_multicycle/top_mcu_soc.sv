// 이것이 진짜 칩의 껍데기가 될 '최상위 모듈'입니다.
module top_mcu_soc (
    input wire clk,
    input wire reset
);

    logic [31:0] core_instr_data;
    logic [31:0] core_instr_addr;
    logic [31:0] core_drdata;
    logic [31:0] core_daddr;
    logic [31:0] core_dwdata;
    logic        core_dwe;
    logic [ 2:0] core_funct3;

    // CPU core
    top_unit U_CPU_CORE (
        .clk       (clk),
        .reset     (reset),
        .instr_data(core_instr_data),
        .instr_addr(core_instr_addr),
        .drdata    (core_drdata),
        .dwe       (core_dwe),
        .funct3_o  (core_funct3),
        .daddr     (core_daddr),
        .dwdata    (core_dwdata)
    );

    // 명령어 메모리
    instruction_mem U_IMEM (
        .instr_addr(core_instr_addr),
        .instr_data(core_instr_data)
    );

    // 데이터 메모리
    data_mem U_DMEM (
        .clk   (clk),
        .dwe   (core_dwe),
        .funct3(core_funct3),
        .daddr  (core_daddr),
        .dwdata(core_dwdata),
        .drdata(core_drdata)
    );

endmodule
