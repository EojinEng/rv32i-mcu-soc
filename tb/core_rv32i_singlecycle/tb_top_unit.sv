`timescale 1ns / 1ps

module tb_top_rv32i_single;

    // 1. 테스트벤치 내부 신호 선언
    logic          clk;
    logic          reset;
    integer        errors;

    // Instruction Memory Interface
    logic   [31:0] instr_addr;
    logic   [31:0] instr_data;

    // 가상 메모리 모델 선언 (각각 16KB 크기 = 4096 * 32-bit)
    logic   [31:0] instr_mem  [0:1023];

    // DUT (Device Under Test) 인스턴스화
    top_unit u_dut (
        .clk       (clk),
        .reset     (reset),
        .instr_data(instr_data),
        .instr_addr(instr_addr),
        .dwe       (),
        .dmem_rdata(),
        .dmem_addr (),
        .dmem_wdata()
    );

    assign instr_data = instr_mem[instr_addr[31:2]];
    
    //Clock Generation (10ns period -> 100MHz)
    always #5 clk = ~clk;

    //시뮬레이션 시나리오 및 검증
    initial begin
    // 1. 메모리 초기화 (파일 읽어오기)
    // 경로(path)는 test.mem 파일이 있는 위치에 맞게 수정해야 합니다.
    $readmemh("test_Rtype.mem", instr_mem);

    // 2. 시스템 리셋 및 클럭 구동
    clk = 0;
    reset = 1;
    #20;            // 리셋 유지
    reset = 0;      // 리셋 해제 (이때부터 PC가 동작함)

    // 3. 시뮬레이션 종료 조건 설정
    #200;           // 명령어 6개가 모두 돌 때까지 충분한 시간 주기
    $finish;
end

endmodule
