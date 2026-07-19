`timescale 1ns / 1ps
import rv32i_pkg::*;

module control_unit (
    input logic           clk, 
    input logic           reset,
    //instruct input
    input op_code_e       opcode,
    input           [6:0] funct7,
    input           [2:0] funct3,

    //fetch enable
    output logic fetch_en,

    //reg file control
    output logic       decode_en,
    output logic [2:0] rfwdsrc_sel,
    output logic       rf_we,

    //main alu control
    output logic      execute_en,
    output alu_type_e alu_control,
    output logic      alusrc_sel,

    //pc control
    output logic pc_en,
    output logic jalr_sel,
    output logic branch,
    output logic jump,

    //data mem control
    output logic dwe
);

  typedef enum logic [2:0] {
    FETCH,
    DECODE,
    EXECUTE,
    MEM,
    WB
  } state_e;

  state_e c_state, n_state;

  // current state logic
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      c_state <= FETCH;
    end else begin
      c_state <= n_state;
    end
  end

  // next state logic
  always_comb begin
    n_state = c_state;
    case (c_state)
      FETCH: begin
        n_state = DECODE;
      end
      DECODE: begin
        n_state = EXECUTE;
      end
      EXECUTE: begin
        case (opcode)
          R_TYPE:  n_state = WB;
          B_TYPE:  n_state = WB;
          S_TYPE:  n_state = MEM;
          IL_TYPE: n_state = MEM;
          I_TYPE:  n_state = WB;
          UL_TYPE: n_state = WB;
          UA_TYPE: n_state = WB;
          JL_TYPE: n_state = WB;
          J_TYPE:  n_state = WB;
          default: n_state = FETCH;
        endcase
      end
      MEM: begin
        case (opcode)
          S_TYPE:  n_state = FETCH;
          IL_TYPE: n_state = WB;
          default: n_state = FETCH;
        endcase

      end
      WB: begin
        n_state = FETCH;
      end
      default: begin
        n_state = c_state;
      end
    endcase
  end

  //output logic
  always_comb begin
    fetch_en    = 1'b0;
    //reg file control
    decode_en   = 1'b0;
    rf_we       = 1'b0;
    rfwdsrc_sel = 3'b000;
    //main alu control
    execute_en  = 1'b0;
    alusrc_sel  = 1'b0;
    alu_control = ALU_ADD;
    //pc control
    pc_en       = 1'b0;
    jalr_sel    = 1'b0;
    branch      = 1'b0;
    jump        = 1'b0;
    //data mem control
    dwe         = 1'b0;
    case (c_state)
      FETCH: begin
        fetch_en = 1'b1;
      end
      DECODE: begin
        decode_en = 1'b1;
      end
      EXECUTE: begin
        pc_en      = 1;
        execute_en = 1;
        case (opcode)
          R_TYPE: begin
            alusrc_sel  = 1'b0;
            alu_control = alu_type_e'({funct7[5], funct3});
            jalr_sel    = 1'b0;
            branch      = 1'b0;
            jump        = 1'b0;
          end
          B_TYPE: begin
            alusrc_sel  = 1'b0;
            alu_control = ALU_ADD;
            jalr_sel    = 1'b0;
            branch      = 1'b1;
            jump        = 1'b0;
          end
          S_TYPE: begin
            alusrc_sel  = 1'b1;
            alu_control = ALU_ADD;
            jalr_sel    = 1'b0;
            branch      = 1'b0;
            jump        = 1'b0;
          end
          IL_TYPE: begin
            alusrc_sel  = 1'b1;
            alu_control = ALU_ADD;
            jalr_sel    = 1'b0;
            branch      = 1'b0;
            jump        = 1'b0;
          end
          I_TYPE: begin
            alusrc_sel = 1'b1;
            if (funct3 == 3'b101) begin
              alu_control = alu_type_e'({funct7[5], funct3});
            end else begin
              alu_control = alu_type_e'({1'b0, funct3});
            end
            branch   = 1'b0;
            jalr_sel = 1'b0;
            jump     = 1'b0;
          end
          UL_TYPE: begin  //rd = imm
            alusrc_sel  = 1'b0;
            alu_control = ALU_ADD;
            jalr_sel    = 1'b0;
            branch      = 1'b0;
            jump        = 1'b0;
          end
          UA_TYPE: begin  //rd = pc + imm
            alusrc_sel  = 1'b0;
            alu_control = ALU_ADD;
            jalr_sel    = 1'b0;
            branch      = 1'b0;
            jump        = 1'b0;
          end
          JL_TYPE: begin  //rd=pc+4 //pc=rs1+imm
            alusrc_sel  = 1'b0;
            alu_control = ALU_ADD;
            jalr_sel    = 1'b1;
            branch      = 1'b0;
            jump        = 1'b1;
          end
          J_TYPE: begin  //rd=pc+4 //pc=pc+imm
            alusrc_sel  = 1'b0;
            alu_control = ALU_ADD;
            jalr_sel    = 1'b0;
            branch      = 1'b0;
            jump        = 1'b1;
          end
          default: begin
          end
        endcase
      end
      MEM: begin
        // alusrc_sel = 1'b1;
        case (opcode)
          S_TYPE: begin
            pc_en = 1;
            dwe   = 1;
          end
          IL_TYPE: begin
            dwe = 0;
          end
        endcase
      end
      WB: begin
        rf_we = 1'b1;
        case (opcode)
          R_TYPE: begin
            rfwdsrc_sel = 3'b000;
          end
          IL_TYPE: begin
            rfwdsrc_sel = 3'b001;
          end
          I_TYPE: begin
            rfwdsrc_sel = 3'b000;
          end
          UL_TYPE: begin
            rfwdsrc_sel = 3'b010;
          end
          UA_TYPE: begin
            rfwdsrc_sel = 3'b011;
          end
          JL_TYPE: begin
            rfwdsrc_sel = 3'b100;
          end
          J_TYPE: begin
            rfwdsrc_sel = 3'b100;
          end
        endcase
      end
      default: begin
      end
    endcase
  end
endmodule
