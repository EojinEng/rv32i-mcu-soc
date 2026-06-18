`timescale 1ns / 1ps
import rv32i_pkg::*;

module control_unit (
    //instruct input
    input [6:0] funct7,
    input [2:0] funct3,
    input op_code_e opcode,

    //reg file control
    output logic [2:0] rfwdsrc_sel,
    output logic       rf_we,

    //main alu control
    output logic       alusrc_sel,
    alu_type_e alu_control,

    //pc control
    output logic jalr_sel,
    output logic branch,
    output logic jump,

    //data mem control
    output logic       dwe
);

    always_comb begin
        //reg file control
        rf_we       = 1'b0;
        rfwdsrc_sel = 3'b000;
        //main alu control
        alusrc_sel  = 1'b0;
        alu_control = ALU_ADD;
        //pc control
        jalr_sel    = 1'b0;
        branch      = 1'b0;
        jump        = 1'b0;
        //data mem control
        dwe         = 1'b0;

        case (opcode)
            R_TYPE: begin
                rf_we       = 1'b1;
                rfwdsrc_sel = 3'b000;
                alusrc_sel  = 1'b0;
                alu_control = alu_type_e'({funct7[5], funct3});
                jalr_sel    = 1'b0;
                branch      = 1'b0;
                jump        = 1'b0;
                dwe         = 1'b0;     
            end

            B_TYPE: begin
                rf_we       = 1'b0;
                rfwdsrc_sel = 3'b000;
                alusrc_sel  = 1'b0;
                alu_control = ALU_ADD;
                jalr_sel    = 1'b0;
                branch      = 1'b1;
                jump        = 1'b0;
                dwe         = 1'b0;
            end

            S_TYPE: begin
                rf_we       = 1'b0;
                rfwdsrc_sel = 3'b000;
                alusrc_sel  = 1'b1;
                alu_control = ALU_ADD;
                jalr_sel    = 1'b0;
                branch      = 1'b0;
                jump        = 1'b0;
                dwe         = 1'b1;               
            end

            IL_TYPE: begin
                rf_we       = 1'b1;
                rfwdsrc_sel = 3'b001;
                alusrc_sel  = 1'b1;
                alu_control = ALU_ADD;
                jalr_sel    = 1'b0;
                branch      = 1'b0;
                jump        = 1'b0;
                dwe         = 1'b0;
            end

            I_TYPE: begin
                rf_we       = 1'b1;
                rfwdsrc_sel = 3'b000;
                alusrc_sel  = 1'b1;
                if (funct3 == 3'b101) begin
                    alu_control = alu_type_e'({funct7[5], funct3});
                end else begin
                    alu_control = alu_type_e'({1'b0, funct3});
                end
                branch   = 1'b0;
                jalr_sel = 1'b0;
                jump     = 1'b0;
                dwe      = 1'b0;
            end

            UL_TYPE: begin  //rd = imm
                rf_we       = 1'b1;
                rfwdsrc_sel = 3'b010;
                alusrc_sel  = 1'b0;
                alu_control = ALU_ADD;
                jalr_sel    = 1'b0;
                branch      = 1'b0;
                jump        = 1'b0;
                dwe         = 1'b0;
                
            end

            UA_TYPE: begin  //rd = pc + imm
                rf_we       = 1'b1;
                rfwdsrc_sel = 3'b011;
                alusrc_sel  = 1'b0;
                alu_control = ALU_ADD;
                jalr_sel    = 1'b0;
                branch      = 1'b0;
                jump        = 1'b0;
                dwe         = 1'b0;
                
            end

            JL_TYPE: begin  //rd=pc+4 //pc=rs1+imm
                rf_we       = 1'b1;
                rfwdsrc_sel = 3'b100;
                alusrc_sel  = 1'b0;
                alu_control = ALU_ADD;
                jalr_sel    = 1'b1;
                branch      = 1'b0;
                jump        = 1'b1;
                dwe         = 1'b0;
                
            end
            J_TYPE: begin  //rd=pc+4 //pc=pc+imm
                rf_we       = 1'b1;
                rfwdsrc_sel = 3'b100;
                alusrc_sel  = 1'b0;
                alu_control = ALU_ADD;
                jalr_sel    = 1'b0;
                branch      = 1'b0;
                jump        = 1'b1;
                dwe         = 1'b0;            
            end
        endcase
    end
endmodule
