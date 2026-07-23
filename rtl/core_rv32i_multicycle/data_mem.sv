`timescale 1ns / 1ps
import rv32i_pkg::*;

module data_mem (
    input               clk,
    input               ram_sel,
    input               dwe,
    input        [ 2:0] funct3,
    input        [31:0] daddr,
    input        [31:0] dwdata,
    output logic        dready,
    output logic [31:0] drdata
);

    logic [31:0] dmem[0:255];
    funct3_type_e fuct3_type;
    assign fuct3_type = funct3_type_e'(funct3);

    // s-type (store)
    always_ff @(posedge clk) begin
        if (ram_sel && dwe) begin
            case (funct3)
                ST_SW: begin
                    dmem[daddr[31:2]] <= dwdata;
                end

                ST_SH: begin
                    case (daddr[1])
                        1'b0: dmem[daddr[31:2]][15:0] <= dwdata[15:0];
                        1'b1: dmem[daddr[31:2]][31:16] <= dwdata[15:0];
                    endcase
                end

                ST_SB: begin
                    case (daddr[1:0])
                        2'b00: begin
                            dmem[daddr[31:2]][7:0] <= dwdata[7:0];
                        end
                        2'b01: begin
                            dmem[daddr[31:2]][15:8] <= dwdata[7:0];
                        end
                        2'b10: begin
                            dmem[daddr[31:2]][23:16] <= dwdata[7:0];
                        end
                        2'b11: begin
                            dmem[daddr[31:2]][31:24] <= dwdata[7:0];
                        end
                    endcase
                end
            endcase
        end
    end

    // il-type (load)
    always_comb begin
        dready = 1'b1;
        drdata = 32'd0;
        case (funct3)
            LD_LW: begin  // LW (Word)
                drdata = dmem[daddr[31:2]];
            end

            LD_LH: begin  // LH (Half-word, Sign-extended)
                case (daddr[1])
                    1'b0:
                    drdata = {
                        {16{dmem[daddr[31:2]][15]}}, dmem[daddr[31:2]][15:0]
                    };
                    1'b1:
                    drdata = {
                        {16{dmem[daddr[31:2]][31]}}, dmem[daddr[31:2]][31:16]
                    };
                endcase
            end

            LD_LB: begin  // LB (Byte, Sign-extended)
                case (daddr[1:0])
                    2'b00:
                    drdata = {
                        {24{dmem[daddr[31:2]][7]}}, dmem[daddr[31:2]][7:0]
                    };
                    2'b01:
                    drdata = {
                        {24{dmem[daddr[31:2]][15]}}, dmem[daddr[31:2]][15:8]
                    };
                    2'b10:
                    drdata = {
                        {24{dmem[daddr[31:2]][23]}}, dmem[daddr[31:2]][23:16]
                    };
                    2'b11:
                    drdata = {
                        {24{dmem[daddr[31:2]][31]}}, dmem[daddr[31:2]][31:24]
                    };
                endcase
            end

            LD_LHU: begin  // LHU (Half-word, Zero-extended)
                case (daddr[1])
                    1'b0: drdata = {16'b0, dmem[daddr[31:2]][15:0]};
                    1'b1: drdata = {16'b0, dmem[daddr[31:2]][31:16]};
                endcase
            end

            LD_LBU: begin  // LBU (Byte, Zero-extended)
                case (daddr[1:0])
                    2'b00: drdata = {24'b0, dmem[daddr[31:2]][7:0]};
                    2'b01: drdata = {24'b0, dmem[daddr[31:2]][15:8]};
                    2'b10: drdata = {24'b0, dmem[daddr[31:2]][23:16]};
                    2'b11: drdata = {24'b0, dmem[daddr[31:2]][31:24]};
                endcase
            end
        endcase
    end
endmodule
