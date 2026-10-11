class tx_agent extends uvm_agent;
	`uvm_component_utils(tx_agent)

	uart_sequencer sequencer;
	tx_driver driver;
	tx_monitor monitor;

	function new(string name = "tx_agent",uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		if(get_is_active() == UVM_ACTIVE) begin
			driver = tx_driver::type_id::create("driver",this);
			sequencer = uart_sequencer::type_id::create("sequencer",this);
		end
		monitor = tx_monitor::type_id::create("monitor",this);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		if(get_is_active()==UVM_ACTIVE) begin
			driver.seq_item_port.connect(sequencer.seq_item_export);
		end
	endfunction
endclass
