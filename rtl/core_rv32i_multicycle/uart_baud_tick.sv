`timescale 1ns / 1ps

module uart_baud_tick #(
    parameter int CLK_FREQ  = 100_000_000,
    parameter int BAUD_RATE = 9600
) (
    input  logic clk,
    input  logic reset,
    output logic tick
);

    localparam CLK_DIV = CLK_FREQ / (BAUD_RATE * 16) - 1;
    localparam CNT_W = $clog2(CLK_DIV + 1);
    logic [CNT_W-1:0] cnt;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            cnt  <= 1'b0;
            tick <= 1'b0;
        end else begin
            if (cnt == CLK_DIV) begin
                cnt  <= 0;
                tick <= 1'b1;
            end else begin
                cnt  <= cnt + 1;
                tick <= 1'b0;
            end
        end
    end
endmodule
