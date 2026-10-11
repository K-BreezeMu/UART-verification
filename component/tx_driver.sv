class tx_driver extends uvm_driver #(uart_sequence_item);
	`uvm_component_utils(tx_driver)

	function new(string name = "tx_driver",uvm_component parent);
		super.new(name,parent);
	endfunction

	virtual uart_interface vif;

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual uart_interface)::get(this,"","vif",vif)) begin
			`uvm_fatal("tx_driver","no vif")
		end
	endfunction

	virtual task drive_idle();
		vif.drv_cb.TX_DATA <= 8'b0;
		vif.drv_cb.TX_START <= 1'b0;
	endtask

	virtual task reset_dut();
		vif.RST_n <= 1'b0;
		drive_idle();
		repeat(5) @(vif.drv_cb);
		vif.RST_n <= 1'b1;
		@(vif.drv_cb);
	endtask

	virtual task drive(uart_sequence_item tr);
		wait(vif.drv_cb.TX_BUSY == 1'b0);

		@(vif.drv_cb);
		vif.drv_cb.TX_DATA <= tr.tx_data;
		vif.drv_cb.TX_START <= 1'b1;

		@(vif.drv_cb);
		vif.drv_cb.TX_START <= 1'b0;
		
	endtask

	virtual task run_phase(uvm_phase phase);
		uart_sequence_item item;
		
		reset_dut();

		forever begin
			seq_item_port.get_next_item(item);
			drive(item);
			seq_item_port.item_done();
		end
	endtask
endclass

