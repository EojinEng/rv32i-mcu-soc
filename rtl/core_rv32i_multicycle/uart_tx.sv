`timescale 1ns / 1ps

module uart_tx (
    input  logic       clk,
    input  logic       reset,
    input  logic       tick,
    input  logic       tx_start,
    input  logic [7:0] tx_data,
    output logic       tx,
    output logic       tx_busy,
    output logic       tx_done
);

    logic [3:0] tick_cnt;
    logic [2:0] bit_cnt;
    logic [7:0] shift_reg;

    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        START,
        DATA,
        STOP
    } tx_state_e;

    tx_state_e state;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state     <= IDLE;
            tick_cnt  <= '0;
            bit_cnt   <= '0;
            shift_reg <= '0;
            tx        <= '1;
            tx_busy   <= '0;
            tx_done   <= '0;
        end else begin
            tx_done <= 1'b0;
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    if (tx_start) begin
                        shift_reg <= tx_data;
                        tick_cnt  <= '0;
                        bit_cnt   <= '0;
                        tx_busy   <= 1'b1;
                        state     <= START;
                    end
                end

                START: begin
                    tx <= 1'b0;
                    if (tick) begin
                        if (tick_cnt == 15) begin
                            tick_cnt <= 0;
                            state    <= DATA;
                        end else begin
                            tick_cnt <= tick_cnt + 1;
                        end
                    end
                end

                DATA: begin
                    tx <= shift_reg[0];  //LSB first
                    if (tick) begin
                        if (tick_cnt == 15) begin
                            tick_cnt  <= '0;
                            shift_reg <= {1'b0, shift_reg[7:1]};
                            if (bit_cnt == 7) begin
                                bit_cnt <= 0;
                                state   <= STOP;
                            end else begin
                                bit_cnt <= bit_cnt + 1;
                            end
                        end else begin
                            tick_cnt <= tick_cnt + 1;
                        end
                    end
                end

                STOP: begin
                    tx <= 1'b1;
                    if (tick) begin
                        if (tick_cnt == 15) begin
                            tick_cnt <= '0;
                            tx_busy  <= 1'b0;
                            tx_done  <= 1'b1;
                            state    <= IDLE;
                        end else begin
                            tick_cnt <= tick_cnt + 1;
                        end
                    end
                end

                default: begin
                    state <= IDLE;
                    tx    <= 1'b1;
                end
            endcase
        end
    end
endmodule
