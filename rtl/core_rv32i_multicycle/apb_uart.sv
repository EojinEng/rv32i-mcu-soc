`timescale 1ns / 1ps

module apb_uart (
    input  logic        PCLK,
    input  logic        PRESETn,
    //APB CPU → Peripheral
    input  logic [31:0] PADDR,
    input  logic        PWRITE,
    input  logic [31:0] PWDATA,
    input  logic        PSEL,
    input  logic        PENABLE,
    //APB Peripheral → CPU
    output logic [31:0] PRDATA,
    output logic        PREADY,
    output logic        PSLVERR,
    //CORE UART TX
    output logic        tx,
    //CORE UART RX
    input  logic        rx
);
    // UART_BASE = 0x4000_0000
    // UART_REG  = 0x4000_0000 TX_DATA
    // UART_REG  = 0x4000_0004 RX_DATA
    // UART_REG  = 0x4000_0008 STATUS
    // UART_REG  = 0x4000_000C CTRL
    // UART_REG  = 0x4000_0010 BAUD

    assign PREADY  = 1'b1;
    assign PSLVERR = 1'b0;

    localparam [11:0] TXDATA_ADDR = 8'h00;
    localparam [11:0] RXDATA_ADDR = 8'h04;
    localparam [11:0] STATUS_ADDR = 8'h08;
    localparam [11:0] CTL_ADDR = 8'h0C;
    localparam [11:0] BAUD_ADDR = 8'h10;

    //uart core logic
    logic       tx_start;
    logic       tx_busy;
    logic       tx_done;
    logic [7:0] rx_data;
    logic       rx_done;

    //register
    logic [7:0] tx_data_reg, rx_data_reg, status_reg, baud_reg;
    logic [31:0] ctrl_reg;

    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            rx_data_reg <= 8'b0;
        end else if (rx_done) begin
            rx_data_reg <= rx_data;
        end
    end

    always_comb begin
        status_reg = {5'b0, rx_done, tx_done, tx_busy};
    end

    //apb read
    always_comb begin
        PRDATA = 32'h0;
        if (!PSEL || PWRITE) begin
            PRDATA = 32'd0;
        end else begin
            case (PADDR[7:0])
                8'h00: begin
                    PRDATA = {24'd0, tx_data_reg};
                end  // TX_DATA    
                8'h04: begin
                    PRDATA = {24'd0, rx_data_reg};
                end  // RX_DATA    
                8'h08: begin
                    PRDATA = {24'd0, status_reg};
                end  // STATUS  
                8'h0C: begin
                    PRDATA = {ctrl_reg};
                end  // CTRL  
                8'h10: begin
                    PRDATA = {24'd0, baud_reg};
                end  // CTRL  
                default: PRDATA = 32'h0;
            endcase
        end
    end

    //apb write
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            tx_start    <= 1'b0;
            tx_data_reg <= 8'd0;
            ctrl_reg    <= 8'd0;
            baud_reg    <= 8'd0;
        end else if (PSEL && PENABLE && PWRITE) begin
            case (PADDR[7:0])
                TXDATA_ADDR: begin
                    tx_start    <= 1'b1;
                    tx_data_reg <= PWDATA[7:0];
                end
                CTL_ADDR: begin
                    ctrl_reg <= PWDATA[7:0];
                end
                BAUD_ADDR: begin
                    baud_reg <= PWDATA[7:0];
                end
            endcase
        end else begin
            tx_start <= 1'b0;
        end
    end

    uart_core #(
        .CLK_FREQ (100_000_000),
        .BAUD_RATE(9600)
    ) U_UART_CORE (
        .clk     (PCLK),
        .reset   (~PRESETn),
        //tx port
        .tx_start(tx_start),
        .tx_data (tx_data_reg),
        .tx      (tx),
        .tx_done (tx_done),
        .tx_busy (tx_busy),
        //rx port
        .rx      (rx),
        .rx_data (rx_data),
        .rx_done (rx_done)
    );

endmodule
