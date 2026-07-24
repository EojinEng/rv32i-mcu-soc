`timescale 1ns / 1ps

module tb_apb_uart();

    logic clk;
    logic reset;
    logic rx;
    logic tx;

    top_mcu_soc UUT (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .tx(tx)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1; 
        rx = 1;

        #20;
        reset = 0;

        #50000; 
        
        $display("Simulation Finished.");
        $finish;
    end

endmodule