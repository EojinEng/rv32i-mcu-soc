`timescale 1ns / 1ps

module apb_mux (
    //apb_decoder -> apb_mux
    input  logic        PSEL_UART,
    input  logic        PSEL_GPIO,
    input  logic        PSEL_FND,
    //apb_slave -> apb_mux
    //uart
    input  logic [31:0] uart_prdata,
    input  logic        uart_pready,
    //gpio
    input  logic [31:0] gpio_prdata,
    input  logic        gpio_pready,
    //fnd
    input  logic [31:0] fnd_prdata,
    input  logic        fnd_pready,
    //apb_mux -> apb_master
    output logic [31:0] PRDATA,
    output logic        PREADY
);

    always_comb begin
        PRDATA  = 32'b0;
        PREADY  = 1'b0;
        if (PSEL_UART) begin
            PRDATA = uart_prdata;
            PREADY = uart_pready;
        end else if (PSEL_GPIO) begin
            PRDATA = gpio_prdata;
            PREADY = gpio_pready;
        end else if (PSEL_FND) begin
            PRDATA = fnd_prdata;
            PREADY = fnd_pready;
        end else begin
            PRDATA = 32'b0;
            PREADY = 1'b0;
        end
    end

endmodule
