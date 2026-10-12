class tx_subscriber extends uvm_subscriber #(uart_sequence_item);
	`uvm_component_utils(tx_subsciber)

	covergroup cg_tx;
		option.per_instance = 1;

		cp_tx_data:coverpoint item.tx_data {
			bins zero = {8'h00};
			bins low = {[8'h01:8'h3F]};
			bins mid = {[8'h40:8'hBF]};
			bins high ={[8'hC0:8'hFE]};
			bins max = {8'hFF};
			}
		cp_tx_one_hot: coverpoint item.tx_data_obs {
         	         wildcard bins bit0 = {8'b****_***1};
         		 wildcard bins bit1 = {8'b****_**1*};
           		 wildcard bins bit2 = {8'b****_*1**};
        		 wildcard bins bit3 = {8'b****_1***};
           		 wildcard bins bit4 = {8'b***1_****};
         		 wildcard bins bit5 = {8'b**1*_****};
           		 wildcard bins bit6 = {8'b*1**_****};
           		 wildcard bins bit7 = {8'b1***_****};
       			 }
		 endgroup

	uart_sequence_item item;
	
	function new(string name = "tx_coverage",uvm_component parent);
	super.new(name,parent);
	cg_tx = new();
	virtual function void write(uart_sequence_item t);
		item = t;
		cg_tx.sample();
	endfunction
endclass
		
