class tx_monitor extends uvm_monitor;
	`uvm_component_utils(tx_monitor)

	virtual uart_interface vif;
	uvm_analysis_port #(uart_sequence_item) tx_mon_ap;
	
	function new(string name = "tx_monitor",uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		tx_mon_ap = new("tx_mon_ap",this);
		if(!uvm_config_db#(virtual uart_interface)::get(this,"","vif",vif)) begin
			`uvm_fatal("tx_monitor","no vif");
		end
	endfunction

	virtual task run_phase(uvm_phase phase);
		uart_sequence_item item;
		bit prev_tx;
		bit prev_tx_busy;
		bit [7:0] data;	
		
		
		prev_tx = vif.mon_cb.TX;
		prev_tx_busy = vif.mon_cb.TX_BUSY;
		forever begin
			@(vif.mon_cb);
			if(prev_tx == 1'b1 && vif.mon_cb.TX == 1'b0) begin
				for(int i=0;i<8;i++) 
				begin
				@(vif.mon_cb);
				data[i]=vif.mon_cb.TX;
				end
				prev_tx = vif.mon_cb.TX;
			end	
			if(prev_tx_busy == 1'b1 && vif.mon_cb.TX_BUSY == 1'b0) 
			begin
			item = uart_sequence_item::type_id::create("item",this);
			item.tx_busy = vif.mon_cb.TX_BUSY;
			item.tx_data_obs = data;
			tx_mon_ap.write(item);
			end
			prev_tx_busy = vif.mon_cb.TX_BUSY;
		end
		endtask
endclass

		
