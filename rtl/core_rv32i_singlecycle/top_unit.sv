`timescale 1ns / 1ps
import rv32i_pkg::*;

module top_unit (
    input wire clk,
    input wire reset,

    // 1. Instruction Memory Interface (명령어 메모리용 핀)
    input        [31:0] instr_data, // 외부 메모리가 보내준 32비트 명령어 (Instr)
    output logic [31:0] instr_addr,  // PC (Program Counter) 값을 밖으로 출력

    // 2. Data Memory Interface (데이터 메모리용 핀)
    input        [31:0] dmem_rdata, // 메모리에서 읽어온 데이터 (Load 명령어용)
    output logic        dwe,  // 메모리 쓰기 신호 (MemWrite 제어신호)
    output logic [31:0] dmem_addr,  // ALU 연산 결과 등으로 나온 메모리 주소
    output logic [31:0] dmem_wdata  // 메모리에 저장할 데이터 (rs2 값)
);

    logic [2:0] funct3;
    logic [6:0] funct7; 
    op_code_e  opcode;
    
    assign funct3 = instr_data[14:12];
    assign funct7 = instr_data[31:25];
    assign opcode = op_code_e'(instr_data[6:0]);

    wire [2:0]  rfwdsrc_sel;
    wire        rf_we;
    wire [3:0]  alu_control;
    wire        alusrc_sel;
    wire jalr_sel, branch, jump;

    control_unit U_CONTROLUNIT (
        //instruct input
        .funct7(funct7),
        .funct3(funct3),
        .opcode(opcode),

        //reg file control
        .rfwdsrc_sel(rfwdsrc_sel),
        .rf_we      (rf_we),

        //main alu control
        .alusrc_sel (alusrc_sel),
        .alu_control(alu_control),

        //pc control
        .jalr_sel(jalr_sel),
        .branch  (branch),
        .jump    (jump),

        //data mem control
        .dwe(dwe)
    );

    datapath_unit U_DATAPATH (
        .clk  (clk),
        .reset(reset),

        //instruct signal
        .instr_data(instr_data),

        //register control
        .rfwdsrc_sel(rfwdsrc_sel),
        .rf_we      (rf_we),

        //main alu control
        .alusrc_sel (alusrc_sel),
        .alu_control(alu_control),

        //pc control
        .jalr_sel(jalr_sel),
        .branch  (branch),
        .jump    (jump),

        //data mem input
        .drdata(dmem_rdata),

        //data mem output
        .daddr (dmem_addr),
        .dwdata(dmem_wdata),

        //instruct output
        .instr_addr(instr_addr)
    );

endmodule
