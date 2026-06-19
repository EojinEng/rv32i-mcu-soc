//`define SIMULATION
package rv32i_pkg;

    // ==========================================
    // 1. 명령어 오프코드 정의 (7-bit)
    // ==========================================
    typedef enum logic [6:0] {
        R_TYPE  = 7'b0110011,
        S_TYPE  = 7'b0100011,
        IL_TYPE = 7'b0000011,
        I_TYPE  = 7'b0010011,
        B_TYPE  = 7'b1100011,
        UL_TYPE = 7'b0110111,
        UA_TYPE = 7'b0010111,
        JL_TYPE = 7'b1100111,
        J_TYPE  = 7'b1101111
    } op_code_e;

    // ==========================================
    // 2. 통합 ALU 연산 코드 정의 (4-bit)
    // ==========================================
    typedef enum logic [3:0] {
        ALU_ADD  = 4'b0_000,
        ALU_SUB  = 4'b1_000,
        ALU_SLL  = 4'b0_001,
        ALU_SLT  = 4'b0_010,
        ALU_SLTU = 4'b0_011,
        ALU_XOR  = 4'b0_100,
        ALU_SRL  = 4'b0_101,
        ALU_SRA  = 4'b1_101,
        ALU_OR   = 4'b0_110,
        ALU_AND  = 4'b0_111
    } alu_type_e;

    // ==========================================
    // 3. 로드(Load) 명령어 타입 정의 (3-bit funct3)
    // ==========================================
    typedef enum logic [2:0] {
        LD_LB  = 3'b000,
        LD_LH  = 3'b001,
        LD_LW  = 3'b010,
        LD_LBU = 3'b100,
        LD_LHU = 3'b101
    } load_type_e;

    // ==========================================
    // 4. 스토어(Store) 명령어 타입 정의 (3-bit funct3)
    // ==========================================
    typedef enum logic [2:0] {
        ST_SB  = 3'b000,
        ST_SH  = 3'b001,
        ST_SW  = 3'b010
    } store_type_e;

    // ==========================================
    // 5. 분기(Branch) 명령어 타입 정의 (3-bit funct3)
    // ==========================================
    typedef enum logic [2:0] {
        BR_BEQ  = 3'b000,
        BR_BNE  = 3'b001,
        BR_BLT  = 3'b100,
        BR_BGE  = 3'b101,
        BR_BLTU = 3'b110,
        BR_BGEU = 3'b111
    } branch_type_e;

    // 3비트 크기의 logic 타입을 기반으로 하는 열거형(enum) 정의
    typedef enum logic [2:0] {
        // J-type / I-type jump
        JALR  = 3'b000,
        
        // U-type & J-type 명령어 구분을 위한 예시 (필요 시 비트값 조정)
        JAL   = 3'b001,
        LUI   = 3'b010,
        AUIPC = 3'b011
    } op_funct3_t;

endpackage
