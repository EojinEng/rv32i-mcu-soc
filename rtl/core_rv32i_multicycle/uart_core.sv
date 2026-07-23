`timescale 1ns / 1ps

module uart_core #(
    parameter CLK_FREQ  = 100_000_000,
    parameter BAUD_RATE = 9600
) (
    input  logic       clk,
    input  logic       reset,
    //tx port
    input  logic       tx_start,
    input  logic [7:0] tx_data,
    output logic       tx,
    output logic       tx_done,
    output logic       tx_busy,
    //rx port
    input  logic       rx,
    output logic [7:0] rx_data,
    output logic       rx_done
);

    logic tick;
    logic rx_sync_out;

    uart_baud_tick #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) U_UART_BAUD_TICK (
        .clk  (clk),
        .reset(reset),
        .tick (tick)
    );

    uart_synchronize U_UART_SYNCHRONIZE (
        .clk     (clk),
        .reset   (reset),
        .async_in(rx),
        .sync_out(rx_sync_out)
    );

    uart_tx U_UART_TX (
        .clk     (clk),
        .reset   (reset),
        .tick    (tick),
        .tx_start(tx_start),
        .tx_data (tx_data),
        .tx      (tx),
        .tx_busy (tx_busy),
        .tx_done (tx_done)
    );

    uart_rx U_UART_RX (
        .clk    (clk),
        .reset  (reset),
        .tick   (tick),
        .rx     (rx_sync_out),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

endmodule
