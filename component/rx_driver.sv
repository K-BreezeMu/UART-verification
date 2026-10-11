class rx_driver extends uvm_driver #(uart_sequence_item);
	`uvm_component_utils(rx_driver)

	function new(string name = "rx_driver",uvm_component parent);
		super.new(name,parent);
	endfunction

	virtual uart_interface vif;

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual uart_interface)::get(this,"","vif",vif)) begin
			`uvm_fatal("rx_driver","no vif")
		end
	endfunction

	virtual task drive_idle();
		vif.RX <= 1'b1;
	endtask

	virtual task reset_dut();
		vif.RST_n <= 1'b0;
		drive_idle();
		repeat(5) @(vif.drv_cb);
		vif.RST_n<=1'b1;
		@(vif.drv_cb);
	endtask

	virtual task drive_bit(bit b);
		vif.drv_cb.RX<= b;
		@(vif.drv_cb);
	endtask

	virtual task drive(uart_sequence_item tr);
		wait(vif.drv_cb.RX_READY == 1'b1 || vif.drv_cb.RST_n == 1'b0);
		drive_bit(1'b0);
		
		for(int i=0;i<8;i++) begin
			drive_bit(tr.rx_load[i]);
		end

		drive_bit(1'b1);

		drive_idle();
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


