class rx_subscriber extends uvm_subscriber #(uart_sequence_item);
	`uvm_component_utils(rx_subscriber)

	function new(string name ="rx_subscriber",uvm_component parent);
		super.new(name,parent);
		cg_rx = new();
	endfunction

	covergroup cg_rx;
		option.per_instance = 1;

		cp_rx_data:coverpoint item.rx_data {
			bins zero = {8'h00};
			bins low = {[8'h01:8'h3F]};
			bins mid = {[8'h40:8'hBF]};
			bins high ={[8'hC0:8'hFE]};
			bins max = {8'hFF};
			}
	endgroup
	
	uart_sequence_item item;
	virtual function void write(uart_sequence_item t);
		item = t;
		cg_rx.sample();
	endfunction
endclass
	
