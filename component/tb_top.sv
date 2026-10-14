`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"

`include "uart_interface.sv"
import uart_pkg::*;

module tb_top;
	logic clk =0;
	always #10 clk = ~clk;

	uart_interface u_if(.CLK(clk));

 	uart dut (
        .clk     (u_if.CLK),
        .rst_n   (u_if.RST_n),
        .tx      (u_if.TX),
        .rx      (u_if.RX),
        .tx_data (u_if.TX_DATA),
        .tx_start(u_if.TX_START),
        .tx_busy (u_if.TX_BUSY),
        .rx_data (u_if.RX_DATA),
        .rx_ready(u_if.RX_READY)
    );

    initial begin
	    uvm_config_db#(virtual uart_interface)::set(null,"*","vif",u_if);
	    run_test();
    end

    initial begin
	    #1_000_000;
	    `uvm_fatal("TIMEOUT", "Simulation stuck! Forced exit.")
end
    endmodule
