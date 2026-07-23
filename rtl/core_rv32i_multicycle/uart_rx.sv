`timescale 1ns/1ps

module uart_rx (
    input  logic       clk,
    input  logic       reset,
    input  logic       tick,
    input  logic       rx,
    output logic [7:0] rx_data,
    output logic       rx_done
);

    typedef enum logic [1:0] {
        IDLE = 2'b00,
        START,
        DATA,
        STOP
    } rx_state_e;

    rx_state_e state;
    logic [3:0] tick_cnt;
    logic [2:0] bit_cnt;
    logic [7:0] shift_reg;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state     <= IDLE;
            tick_cnt  <= '0;
            bit_cnt   <= '0;
            shift_reg <= '0;
            rx_data   <= '0;
            rx_done   <= '0;
        end else begin
            case (state)
                IDLE: begin
                    rx_done <= 1'b0;
                    if (rx == 1'b0) begin
                        tick_cnt <= '0;
                        state    <= START;
                    end
                end
               
               START: begin
                    if (tick) begin 
                        if (tick_cnt == 7) begin
                            if (rx == 1'b0) begin
                                tick_cnt <= '0;
                                bit_cnt  <= '0;
                                state    <= DATA;
                            end
                        end else begin
                            tick_cnt <= tick_cnt + 1;
                        end
                    end
                end
               
               DATA: begin
                    if (tick) begin
                        if (tick_cnt == 15) begin
                            tick_cnt  <= '0;
                            shift_reg <= {rx, shift_reg[7:1]};
                            if (bit_cnt == 7) begin
                                bit_cnt <= '0;
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
                    if (tick) begin
                        if (tick_cnt == 15) begin
                            tick_cnt <= '0;
                            state    <= IDLE;
                            rx_data  <= shift_reg;
                            rx_done  <= 1'b1;
                        end else begin
                            tick_cnt <= tick_cnt + 1;
                        end
                    end
                end
               
               default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
