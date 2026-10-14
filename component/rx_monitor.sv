class rx_monitor extends uvm_monitor;
	`uvm_component_utils(rx_monitor)

	virtual uart_interface vif;
	uvm_analysis_port #(uart_sequence_item) rx_mon_ap;

	function new(string name = "rx_monitor",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		rx_mon_ap = new("rx_mon_ap",this);
		if(!uvm_config_db#(virtual uart_interface)::get(this,"","vif",vif)) begin
			`uvm_fatal("rx_monitor","no vif");
		end
	endfunction

	virtual task run_phase(uvm_phase phase);
		uart_sequence_item item;
		bit prev_rx_ready;
		prev_rx_ready = vif.mon_cb.RX_READY;

		forever begin
			@(vif.mon_cb);
			if(prev_rx_ready == 1'b0 && vif.mon_cb.RX_READY == 1'b1) begin
				item = uart_sequence_item::type_id::create("item",this);
				item.rx_data = vif.mon_cb.RX_DATA;

				rx_mon_ap.write(item);
			end
			prev_rx_ready = vif.mon_cb.RX_READY;
		end
	endtask
endclass

