`timescale 1ns / 1ps
import rv32i_pkg::*;

module instruction_mem (
    input  [31:0] instr_addr,
    output [31:0] instr_data
);

    //rom 256 size
    logic [31:0] rom[0:255];

    initial begin
        $readmemh("test_Itype.mem", rom);
    end

    assign instr_data = rom[instr_addr[9:2]];

endmodule
