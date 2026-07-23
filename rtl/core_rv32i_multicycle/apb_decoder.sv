`timescale 1ns / 1ps
`include "mmio_map.vh"

module apb_decoder (
    input               PSEL,
    input        [31:0] PADDR,
    output logic        ram_sel,
    output logic        PSEL_UART,
    output logic        PSEL_GPIO,
    output logic        PSEL_FND
);

    always_comb begin
        ram_sel   = 1'b0;
        PSEL_UART = 1'b0;
        PSEL_GPIO = 1'b0;
        PSEL_FND  = 1'b0;
        if (PADDR[31:16] == `RAM_BASE) begin
            ram_sel = 1'b1;
        end else begin
            if (PSEL) begin
                case (PADDR[15:8])
                    `UART_BASE: begin
                        PSEL_UART = 1;
                    end
                    `GPIO_BASE: begin
                        PSEL_GPIO = 1;
                    end
                    `FND_BASE: begin
                        PSEL_FND = 1;
                    end
                endcase
            end else begin
                ram_sel   = 1'b0;
                PSEL_UART = 1'b0;
                PSEL_GPIO = 1'b0;
                PSEL_FND  = 1'b0;
            end
        end
    end
endmodule
