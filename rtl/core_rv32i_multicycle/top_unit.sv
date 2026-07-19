`timescale 1ns / 1ps
import rv32i_pkg::*;

module top_unit (
    input wire clk,
    input wire reset,

    // Instruction Memory Interface (명령어 메모리용 핀)
    input        [31:0] instr_data,  // 외부 메모리가 보내준 32비트 명령어 (Instr)
    output logic [31:0] instr_addr,  // PC (Program Counter) 값을 밖으로 출력

    // Data Memory Interface (데이터 메모리용 핀)
    input        [31:0] drdata,    // 메모리에서 읽어온 데이터 (Load 명령어용)
    output logic        dwe,       // 메모리 쓰기 신호 (MemWrite 제어신호)
    output logic [ 2:0] funct3_o,
    output logic [31:0] daddr,     // ALU 연산 결과 등으로 나온 메모리 주소
    output logic [31:0] dwdata     // 메모리에 저장할 데이터 (rs2 값)
);

  op_code_e       opcode;
  logic     [2:0] funct3;
  logic     [6:0] funct7;
  assign funct3_o = funct3;

  logic      [2:0] rfwdsrc_sel;
  logic            rf_we;
  alu_type_e       alu_control;
  logic            alusrc_sel;
  logic jalr_sel, branch, jump;
  logic fetch_en;
  logic decode_en;
  logic execute_en;
  logic pc_en;

  control_unit U_CONTROLUNIT (
      .clk   (clk),
      .reset (reset),
      //instruct input
      .opcode(opcode),
      .funct3(funct3),
      .funct7(funct7),

      //fetch enable
      .fetch_en(fetch_en),

      //reg file control
      .decode_en  (decode_en),
      .rfwdsrc_sel(rfwdsrc_sel),
      .rf_we      (rf_we),

      //main alu control
      .execute_en (execute_en),
      .alusrc_sel (alusrc_sel),
      .alu_control(alu_control),

      //pc control
      .pc_en   (pc_en),
      .jalr_sel(jalr_sel),
      .branch  (branch),
      .jump    (jump),

      //data mem control
      .dwe(dwe)
  );

  datapath U_DATAPATH (
      .clk  (clk),
      .reset(reset),

      //instruct signal
      .instr_data(instr_data),

      //fetch control
      .fetch_en(fetch_en),

      //register control
      .decode_en  (decode_en),
      .rfwdsrc_sel(rfwdsrc_sel),
      .rf_we      (rf_we),

      //main alu control
      .execute_en (execute_en),
      .alusrc_sel (alusrc_sel),
      .alu_control(alu_control),

      //pc control
      .pc_en   (pc_en),
      .jalr_sel(jalr_sel),
      .branch  (branch),
      .jump    (jump),

      //data mem input
      .drdata(drdata),

      //data mem output
      .daddr (daddr),
      .dwdata(dwdata),

      //instruct output
      .instr_addr(instr_addr),

      // Decoded Instruction Fields
      .opcode_o(opcode),
      .funct3_o(funct3),
      .funct7_o(funct7)
  );

endmodule
