class rx_test extends uvm_test;
	`uvm_component_utils(rx_test)

	uart_env env;
	function new(string name = "rx_test",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env = uart_env::type_id::create("env",this);
	endfunction

	virtual task run_phase(uvm_phase phase);
		rx_sequence seq;
		phase.raise_objection(this);

		seq = rx_sequence::type_id::create("req");
		seq.start(env.rx_agt.sequencer);

		#1000;
		phase.drop_objection(this);
	endtask
endclass
