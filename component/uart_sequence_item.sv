class uart_sequence_item extends uvm_sequence_item;
	
	function new(string name = "uart_sequence_item");
		super.new(name);
	endfunction

	rand bit rst_n;

	bit tx;
	rand bit [7:0] tx_data;
	bit [7:0] tx_data_obs;
	rand bit tx_start;
	bit tx_busy;

	bit rx;
	rand bit [7:0] rx_load;
	bit [7:0] rx_data;
	bit rx_ready;

	`uvm_object_utils_begin(uart_sequence_item)
        `uvm_field_int(tx_data,     UVM_ALL_ON)
        `uvm_field_int(rx_load,     UVM_ALL_ON)
        `uvm_field_int(tx_data_obs, UVM_ALL_ON)
        `uvm_field_int(rx_data,     UVM_ALL_ON)
        `uvm_field_int(tx_busy,     UVM_ALL_ON)
        `uvm_field_int(rx_ready,    UVM_ALL_ON)
        `uvm_object_utils_end

endclass
