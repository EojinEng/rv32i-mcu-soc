`timescale 1ns / 1ps
import rv32i_pkg::*;

module datapath_unit (
    input                   clk,
    input                   reset,
    //instruct signal
    input            [31:0] instr_data,
    ////// control_unit //////
    //register control
    input            [ 2:0] rfwdsrc_sel,
    input                   rf_we,
    //main alu control
    input                   alusrc_sel,
    input            [ 3:0] alu_control,
    //pc control
    input                   jalr_sel,
    input                   branch,
    ////// data_mem //////
    //data mem input
    input            [31:0] drdata,
    //data mem output
    output logic     [31:0] daddr,
    output logic     [31:0] dwdata,
    //instruct output
    output logic     [31:0] instr_addr,
    input                   jump,
    // Decoded Instruction Fields
    output op_code_e        opcode_o,
    output logic     [ 2:0] funct3_o,
    output logic     [ 6:0] funct7_o
);

    //-------------------------------------
    // Instruction Decode
    //-------------------------------------
    op_code_e opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    logic [4:0] rd;
    logic [4:0] rs1;
    logic [4:0] rs2;

    assign opcode = op_code_e'(instr_data[6:0]);
    assign rd     = instr_data[11:7];
    assign funct3 = instr_data[14:12];
    assign rs1    = instr_data[19:15];
    assign rs2    = instr_data[24:20];
    assign funct7 = instr_data[31:25];
    //-------------------------------------
    //-------------------------------------

    logic [31:0] rd1, rd2, alu_result, imm_data, alusrc_data;
    logic [31:0] pcalu_4_out, pcalu_imm_out;
    logic [31:0] rf_wd;
    logic b_taken;

    assign opcode_o = opcode;
    assign funct3_o = funct3;
    assign funct7_o = funct7;

    //data_mem
    assign daddr    = alu_result;
    assign dwdata   = rd2;

    register_file U_REGISTER_FILE (
        .clk  (clk),
        .reset(reset),
        .WA   (rd),
        .RA1  (rs1),
        .RA2  (rs2),
        .Wdata(rf_wd),
        .rf_we(rf_we),
        .RD1  (rd1),
        .RD2  (rd2)
    );

    rv32i_imm_extender U_IMM_EXTEND (
        .opcode    (opcode),
        .instr_data(instr_data),
        .imm_data  (imm_data)
    );

    mux_2x1 U_ALUSRC_MUX (
        .in0    (rd2),
        .in1    (imm_data),
        .mux_sel(alusrc_sel),
        .out_mux(alusrc_data)
    );

    alu U_ALU (
        .rd1        (rd1),
        .rd2        (alusrc_data),
        .alu_control(alu_control),
        .alu_result (alu_result)
    );

    comparator U_COMP (
        .funct3 (funct3),
        .rd1    (rd1),
        .rd2    (rd2),
        .b_taken(b_taken)
    );

    mux_8x1 U_RF_WD_MUX (
        .in0    (alu_result),
        .in1    (drdata),
        .in2    (imm_data),       //imm
        .in3    (pcalu_imm_out),  //imm + pc
        .in4    (pcalu_4_out),    //pc + 4
        .mux_sel(rfwdsrc_sel),
        .out_mux(rf_wd)
    );

    program_counter U_PC (
        .clk            (clk),
        .reset          (reset),
        .rs1            (rd1),
        .pcsrc_sel      ((b_taken && branch) || jump),
        .jalr_sel       (jalr_sel),
        .imm_data       (imm_data),
        .alu_4_out      (pcalu_4_out),
        .alu_imm_out    (pcalu_imm_out),
        .program_counter(instr_addr)
    );
endmodule

module register_file (
    input               clk,
    input               reset,
    input        [ 4:0] WA,
    input        [ 4:0] RA1,
    input        [ 4:0] RA2,
    input               rf_we,
    input        [31:0] Wdata,
    output logic [31:0] RD1,
    output logic [31:0] RD2
);

    logic [31:0] register_file[1:31];

    always_ff @(posedge clk) begin
        if (!reset & rf_we & (WA != 5'd0)) begin
            register_file[WA] <= Wdata;
        end
    end

    assign RD1 = (RA1) ? register_file[RA1] : 0;
    assign RD2 = (RA2) ? register_file[RA2] : 0;

endmodule

module rv32i_imm_extender (
    input  op_code_e        opcode,
    input            [31:0] instr_data,
    output logic     [31:0] imm_data
);

    always_comb begin
        imm_data = '0;

        case (opcode)
            S_TYPE: begin
                imm_data = {
                    {20{instr_data[31]}}, instr_data[31:25], instr_data[11:7]
                };
            end

            IL_TYPE: begin
                imm_data = {{20{instr_data[31]}}, instr_data[31:20]};
            end

            I_TYPE: begin
                imm_data = {{20{instr_data[31]}}, instr_data[31:20]};
            end

            B_TYPE: begin
                imm_data = {
                    {19{instr_data[31]}},
                    instr_data[31],
                    instr_data[7],
                    instr_data[30:25],
                    instr_data[11:8],
                    1'b0
                };
            end

            UL_TYPE, UA_TYPE: begin
                imm_data = {instr_data[31:12], 12'b0};
            end

            JL_TYPE: begin
                imm_data = {{20{instr_data[31]}}, instr_data[31:20]};
            end

            J_TYPE: begin
                imm_data = {
                    {11{instr_data[31]}},
                    instr_data[31],
                    instr_data[19:12],
                    instr_data[20],
                    instr_data[30:21],
                    1'b0
                };
            end
            default: imm_data = '0;
        endcase
    end
endmodule

module alu (
    input        [31:0] rd1,          //RD1
    input        [31:0] rd2,          //RD2
    input        [ 3:0] alu_control,  //funct7[[5], funct3
    output logic [31:0] alu_result
);
    always_comb begin
        alu_result = 32'd0;
        case (alu_control)
            ALU_ADD: begin
                alu_result = rd1 + rd2;  //ADD
            end
            ALU_SUB: begin
                alu_result = rd1 - rd2;  //SUB
            end
            ALU_SLL: begin
                alu_result = rd1 << rd2[4:0];  //SLL
            end
            ALU_SRL: begin
                alu_result = rd1 >> rd2[4:0];  //SRL
            end
            ALU_SRA: begin
                alu_result = $signed(rd1) >>> rd2[4:0];  //SRA
            end
            ALU_SLT: begin
                alu_result = ($signed(rd1) < $signed(rd2)) ? 1 : 0;  //SLT
            end
            ALU_SLTU: begin
                alu_result = ($unsigned(rd1) < $unsigned(rd2)) ? 1 : 0;  //SLTU
            end
            ALU_XOR: begin
                alu_result = rd1 ^ rd2;  //XOR
            end
            ALU_OR: begin
                alu_result = rd1 | rd2;  //OR
            end
            ALU_AND: begin
                alu_result = rd1 & rd2;  //AND
            end
        endcase
    end
endmodule

module comparator (
    input        [ 2:0] funct3,
    input        [31:0] rd1,
    input        [31:0] rd2,
    output logic        b_taken
);

    branch_type_e funct3_type;
    assign funct3_type = branch_type_e'(funct3);

    always_comb begin
        b_taken = 1'b0;
        case (funct3)
            BR_BEQ: begin
                b_taken = (rd1 == rd2) ? 1'b1 : 1'b0;
            end
            BR_BNE: begin
                b_taken = (rd1 != rd2) ? 1'b1 : 1'b0;
            end
            BR_BLT: begin
                b_taken = ($signed(rd1) < $signed(rd2)) ? 1'b1 : 1'b0;
            end
            BR_BGE: begin
                b_taken = ($signed(rd1) >= $signed(rd2)) ? 1'b1 : 1'b0;
            end
            BR_BLTU: begin
                b_taken = ($unsigned(rd1) < $unsigned(rd2)) ? 1'b1 : 1'b0;
            end
            BR_BGEU: begin
                b_taken = ($unsigned(rd1) >= $unsigned(rd2)) ? 1'b1 : 1'b0;
            end
        endcase
    end
endmodule

module program_counter (
    input               clk,
    input               reset,
    input        [31:0] rs1,
    input               pcsrc_sel,
    input               jalr_sel,
    input        [31:0] imm_data,
    output logic [31:0] alu_4_out,
    output logic [31:0] alu_imm_out,
    output logic [31:0] program_counter
);

    logic [31:0] pc_4_alu_out, pc_imm_alu_out, pcsrc_mux_out, alusrc_mux_out;
    assign alu_4_out   = pc_4_alu_out;
    assign alu_imm_out = pc_imm_alu_out;

    mux_2x1 U_ALUSRC_MUX (
        .in0    (program_counter),
        .in1    (rs1),
        .mux_sel(jalr_sel),
        .out_mux(alusrc_mux_out)
    );

    pc_alu U_PC_4_ALU (
        .a         (32'd4),
        .b         (program_counter),
        .pc_alu_out(pc_4_alu_out)
    );

    pc_alu U_PC_imm_ALU (
        .a         (imm_data),
        .b         (alusrc_mux_out),
        .pc_alu_out(pc_imm_alu_out)
    );

    mux_2x1 U_PCSRC_MUX (
        .in0    (pc_4_alu_out),
        .in1    (pc_imm_alu_out),
        .mux_sel(pcsrc_sel),
        .out_mux(pcsrc_mux_out)
    );

    pc_register U_PC_REG (
        .clk     (clk),
        .reset   (reset),
        .data_in (pcsrc_mux_out & 32'hFFFFFFFE),
        .data_out(program_counter)
    );

endmodule

module pc_register (
    input         clk,
    input         reset,
    input  [31:0] data_in,
    output [31:0] data_out
);

    logic [31:0] register;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            register <= 32'd0;
        end else begin
            register <= data_in;
        end
    end

    assign data_out = register;
endmodule

module pc_alu (
    input        [31:0] a,
    input        [31:0] b,
    output logic [31:0] pc_alu_out
);
    assign pc_alu_out = a + b;
endmodule

module mux_2x1 (
    input        [31:0] in0,
    input        [31:0] in1,
    input               mux_sel,
    output logic [31:0] out_mux
);
    assign out_mux = (mux_sel) ? in1 : in0;
endmodule

module mux_8x1 (
    input        [31:0] in0,
    input        [31:0] in1,
    input        [31:0] in2,
    input        [31:0] in3,
    input        [31:0] in4,
    input        [31:0] in5,
    input        [31:0] in6,
    input        [31:0] in7,
    input        [ 2:0] mux_sel,
    output logic [31:0] out_mux
);
    always_comb begin
        out_mux = in0;
        case (mux_sel)
            3'b000:  out_mux = in0;
            3'b001:  out_mux = in1;
            3'b010:  out_mux = in2;
            3'b011:  out_mux = in3;
            3'b100:  out_mux = in4;
            3'b101:  out_mux = in5;
            3'b110:  out_mux = in6;
            3'b111:  out_mux = in7;
            default: out_mux = in0;
        endcase
    end
endmodule
