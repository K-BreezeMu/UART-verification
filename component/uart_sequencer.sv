class uart_sequencer extends uvm_sequencer #(uart_sequence_item);
	`uvm_component_utils(uart_sequencer)

	function new(string name ="uart_sequencer",uvm_component parent);
		super.new(name,parent);
	endfunction
endclass
