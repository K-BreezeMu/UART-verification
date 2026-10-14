class rx_sequence extends uvm_sequence #(uart_sequence_item);

	`uvm_object_utils(rx_sequence)

	function new(string name = "rx_sequence");
		super.new(name);
	endfunction

	virtual task body();
		uart_sequence_item tr;
		repeat(5) begin
			tr = uart_sequence_item::type_id::create("tr");
			start_item(tr);
			    if (!tr.randomize() with { rx_load inside {8'h00, 8'h55, 8'hAA, 8'hFF}; })
        `uvm_fatal("RX_SEQ", "randomize failed")
			finish_item(tr);
		end
	endtask
endclass
