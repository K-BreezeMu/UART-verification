class tx_sequence extends uvm_sequence #(uart_sequence_item);

	`uvm_object_utils(tx_sequence)

	function new(string name = "tx_sequence");
		super.new(name);
	endfunction

	virtual task body();
		uart_sequence_item tr;
		repeat(5) begin
			tr = uart_sequence_item::type_id::create("tr");
			start_item(tr);
			if(!tr.randomize() with { tx_data inside {8'h00, 8'h55, 8'hAA, 8'hFF};})
				`uvm_fatal("TX_SEQ","random failed")
			finish_item(tr);
		end
	endtask
endclass
		
