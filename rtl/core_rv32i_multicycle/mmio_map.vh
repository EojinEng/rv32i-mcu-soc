`ifndef APB_DEFINES_VH
`define APB_DEFINES_VH 

// RAM Base
`define RAM_BASE 16'h2000

// Base Address
`define UART_BASE 8'h00
`define GPIO_BASE 8'h10
`define FND_BASE 8'h20

// UART Register Offset
`define UART_TXDATA 8'h00
`define UART_RXDATA 8'h04
`define UART_STATUS 8'h08
`define UART_CTRL 8'h0C
`define UART_BAUD 8'h10

`endif
