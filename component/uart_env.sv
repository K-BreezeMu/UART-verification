class uart_env extends uvm_env;

	`uvm_component_utils(uart_env)

	tx_agent tx_agt;
	rx_agent rx_agt;
	uart_scoreboard scoreboard;
	rx_subscriber rx_sri;
	tx_subscriber tx_sri;

	function new(string name = "uart_env",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		tx_agt = tx_agent::type_id::create("tx_agt",this);
		rx_agt = rx_agent::type_id::create("rx_agt",this);
		scoreboard = uart_scoreboard::type_id::create("scoreboard",this);
		rx_sri = rx_subscriber::type_id::create("rx_sri",this);
		tx_sri = tx_subscriber::type_id::create("tx_sri",this);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);

		tx_agt.monitor.tx_mon_ap.connect(scoreboard.tx_mon_imp);
		rx_agt.monitor.rx_mon_ap.connect(scoreboard.rx_mon_imp);
		tx_agt.driver.tx_drv_ap.connect(scoreboard.tx_drv_imp);
		rx_agt.driver.rx_drv_ap.connect(scoreboard.rx_drv_imp);

		tx_agt.monitor.tx_mon_ap.connect(tx_sri.analysis_export);
		rx_agt.monitor.rx_mon_ap.connect(rx_sri.analysis_export);
	endfunction
endclass

