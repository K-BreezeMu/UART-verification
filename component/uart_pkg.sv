package uart_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"

	`include "uart_sequence_item.sv"
	`include "uart_sequencer.sv"

	`include "tx_driver.sv"
        `include "rx_driver.sv"
        `include "tx_monitor.sv"
        `include "rx_monitor.sv"
	`include "tx_agent.sv"
	`include "rx_agent.sv"

	`include "uart_scoreboard.sv"
        `include "tx_subscriber.sv"         
	`include "rx_subscriber.sv"

	`include"uart_env.sv"

	`include"rx_sequence.sv"
	`include"rx_test.sv"
	`include"tx_sequence.sv"
	`include"tx_test.sv"
endpackage
	
