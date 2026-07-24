`timescale 1ns / 1ps

module top_mcu_soc (
    input  wire clk,
    input  wire reset,
    input       rx,
    output      tx
);

    // CPU core
    logic [31:0] core_instr_data;
    logic [31:0] core_instr_addr;
    logic [31:0] core_rdata;
    logic        core_ready;
    logic [ 2:0] core_funct3;
    logic        core_valid;
    logic        core_we;
    logic [31:0] core_addr;
    logic [31:0] core_wdata;

    logic        apb_valid;

    //RAM DATA
    logic [31:0] ram_rdata;
    logic        ram_ready;

    //APB Decoder
    logic ram_sel, PSEL_RAM, PSEL_UART, PSEL_GPIO, PSEL_FND;

    //APB Master
    logic PSEL, PENABLE, PWRITE, PREADY, apb_ready;
    logic [31:0] PADDR, PWDATA, PRDATA, apb_rdata;

    //APB Slave
    logic [31:0] uart_prdata;
    logic        uart_pready;

    logic [31:0] gpio_prdata;
    logic        gpio_pready;

    logic [31:0] fnd_prdata;
    logic        fnd_pready;

    assign core_ready = ram_sel ? ram_ready : apb_ready;
    assign core_rdata = ram_sel ? ram_rdata : apb_rdata;
    assign apb_valid  = core_valid & ~ram_sel;

    // rv32i CPU core
    top_unit U_CPU_CORE (
        .clk       (clk),
        .reset     (reset),
        .instr_data(core_instr_data),
        .instr_addr(core_instr_addr),
        //apb input
        .drdata    (core_rdata),
        .dready    (core_ready),
        //apb output
        .funct3_o  (core_funct3),
        .dwe       (core_we),
        .daddr     (core_addr),
        .dwdata    (core_wdata),
        .mem_valid (core_valid)
    );

    // 명령어 메모리
    instruction_mem U_IMEM (
        .instr_addr(core_instr_addr),
        .instr_data(core_instr_data)
    );

    apb_decoder U_APB_DECODER (
        .PSEL     (PSEL),
        .PADDR    (core_addr),
        .ram_sel  (ram_sel),
        .PSEL_UART(PSEL_UART),
        .PSEL_GPIO(PSEL_GPIO),
        .PSEL_FND (PSEL_FND)
    );

    // 데이터 메모리
    data_mem U_DMEM (
        .clk    (clk),
        .ram_sel(ram_sel),
        .funct3 (core_funct3),
        .dwe    (core_we),
        .daddr  (core_addr),
        .dwdata (core_wdata),
        .dready (ram_ready),
        .drdata (ram_rdata)
    );

    apb_master U_APB_MASTER (
        .PCLK      (clk),
        .PRESETn   (~reset),
        //cpu core -> apb master
        .core_valid(apb_valid),
        .core_we   (core_we),
        .core_addr (core_addr),
        .core_wdata(core_wdata),
        // apb master -> cpu core
        .core_rdata(apb_rdata),
        .core_ready(apb_ready),
        // APB
        // input : slave -> master
        .PRDATA    (PRDATA),
        .PREADY    (PREADY),
        // output : master -> slave
        .PSEL      (PSEL),
        .PADDR     (PADDR),
        .PWRITE    (PWRITE),
        .PWDATA    (PWDATA),
        .PENABLE   (PENABLE)
    );

    apb_mux U_APB_MUX (
        //apb_decoder -> apb_mux
        .PSEL_UART  (PSEL_UART),
        .PSEL_GPIO  (PSEL_GPIO),
        .PSEL_FND   (PSEL_FND),
        //apb_slave -> apb_mux
        //UART
        .uart_prdata(uart_prdata),
        .uart_pready(uart_pready),
        //GPIO
        .gpio_prdata(gpio_prdata),
        .gpio_pready(gpio_pready),
        //FND
        .fnd_prdata (fnd_prdata),
        .fnd_pready (fnd_pready),
        //apb_mux -> apb_master
        .PRDATA     (PRDATA),
        .PREADY     (PREADY)
    );

    //APB SLAVE(uart)
    apb_uart U_APB_UART (
        .PCLK   (clk),
        .PRESETn(~reset),
        //APB master → Peripheral
        .PSEL   (PSEL_UART),
        .PADDR  (PADDR),
        .PWRITE (PWRITE),
        .PWDATA (PWDATA),
        .PENABLE(PENABLE),
        //APB Peripheral → APB mux
        .PRDATA (uart_prdata),
        .PREADY (uart_pready),
        //CORE UART TX
        .tx     (tx),
        //CORE UART RX
        .rx     (rx)
    );

endmodule
