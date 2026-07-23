`timescale 1ns / 1ps

module apb_master (
    input               PCLK,
    input               PRESETn,
    //cpu core -> apb master
    input               core_valid,
    input               core_we,
    input        [31:0] core_addr,
    input        [31:0] core_wdata,
    output logic [31:0] core_rdata,
    output logic        core_ready,
    // apb master -> apb slave
    input        [31:0] PRDATA,
    input               PREADY,
    output logic        PSEL,
    output logic        PENABLE,
    output logic [31:0] PADDR,
    output logic        PWRITE,
    output logic [31:0] PWDATA
);

    typedef enum logic [1:0] {
        IDLE,
        SETUP,
        ACCESS
    } main_state;

    main_state c_state, n_state;

    //current state
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            c_state <= IDLE;
        end else begin
            c_state <= n_state;
        end
    end

    //next state
    always_comb begin
        n_state = c_state;
        case (c_state)
            IDLE: begin
                if (core_valid) begin
                    n_state = SETUP;
                end
            end
            SETUP: begin
                n_state = ACCESS;
            end
            ACCESS: begin
                if (PREADY) begin
                    n_state = IDLE;
                end
            end
        endcase
    end

    //output ff logic
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PSEL <= 1'b0;
            PENABLE <= 1'b0;
            PWRITE <= 1'b0;
            PADDR <= 32'b0;
            PWDATA <= 32'b0;
        end else begin
            case (c_state)
                IDLE: begin
                    PSEL    <= 1'b0;
                    PENABLE <= 1'b0;
                    PWRITE  <= 1'b0;
                    PADDR   <= 32'b0;
                    PWDATA  <= 32'b0;
                    if (core_valid) begin
                        PSEL    <= 1'b1;
                        PENABLE <= 1'b0;
                        PWRITE  <= core_we;
                        PADDR   <= core_addr;
                        PWDATA  <= core_wdata;
                    end
                end
                SETUP: begin
                    PENABLE <= 1'b1;
                end
                ACCESS: begin
                    if (PREADY) begin
                        PSEL    <= 1'b0;
                        PENABLE <= 1'b0;
                        PWRITE  <= 1'b0;
                        PADDR   <= 32'b0;
                        PWDATA  <= 32'b0;
                    end
                end
            endcase
        end
    end

    assign core_ready = (c_state == ACCESS) && PREADY;
    assign core_rdata = PRDATA;

endmodule
