	`uvm_analysis_imp_decl(_tx_drv)
	`uvm_analysis_imp_decl(_tx_mon)
	`uvm_analysis_imp_decl(_rx_drv)
	`uvm_analysis_imp_decl(_rx_mon)
class uart_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(uart_scoreboard)

	uvm_analysis_imp_rx_drv #(uart_sequence_item,uart_scoreboard) rx_drv_imp;
	uvm_analysis_imp_tx_drv #(uart_sequence_item,uart_scoreboard) tx_drv_imp;
	uvm_analysis_imp_rx_mon #(uart_sequence_item,uart_scoreboard) rx_mon_imp;
	uvm_analysis_imp_tx_mon #(uart_sequence_item,uart_scoreboard) tx_mon_imp;

	bit [7:0] tx_exp_q[$];
	bit [7:0] tx_act_q[$];
	bit [7:0] rx_exp_q[$];
	bit [7:0] rx_act_q[$];



	int tx_pass,tx_fail;
	int rx_pass,rx_fail;
	
	function new(string name = "uart_scoreboard",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		rx_drv_imp = new("rx_drv_imp",this);
		tx_drv_imp = new("tx_drv_imp",this);
		rx_mon_imp = new("rx_mon_imp",this);
		tx_mon_imp = new("tx_mon_imp",this);

		tx_pass = 0;tx_fail=0;
		rx_pass = 0;rx_fail=0;
	endfunction

	virtual function void write_tx_drv(uart_sequence_item tr);
		tx_exp_q.push_back(tr.tx_data);
		compare_tx();
	endfunction

	virtual function void write_tx_mon(uart_sequence_item tr);
		tx_act_q.push_back(tr.tx_data_obs);
		compare_tx();
	endfunction

	virtual function void write_rx_drv(uart_sequence_item tr);
		rx_exp_q.push_back(tr.rx_load);
		compare_rx();
	endfunction

	virtual function void write_rx_mon(uart_sequence_item tr);
		rx_act_q.push_back(tr.rx_data);
		compare_rx();
	endfunction

	virtual function void compare_tx();
		bit [7:0] exp;
		bit [7:0] act;
		while(tx_exp_q.size()>0 && tx_act_q.size()>0) begin
		exp = tx_exp_q.pop_front();
		act = tx_act_q.pop_front();
		if(exp === act) begin
			tx_pass++;

			`uvm_info("scb_tx",$sformatf("[PASS] exp=0x%0h act=0x%0h",exp,act),UVM_MEDIUM)
		end else begin
			tx_fail++;
			`uvm_info("scb_tx",$sformatf("[FAIL] exp=0x%0h act=0x%0h",exp,act),UVM_MEDIUM)
		end
	end
	endfunction

	virtual function void compare_rx();
		bit [7:0] exp;
		bit [7:0] act;
		while(rx_exp_q.size()>0 && rx_act_q.size()>0) begin
		exp = rx_exp_q.pop_front();
		act = rx_act_q.pop_front();
		if(exp === act) begin
			rx_pass++;

			`uvm_info("scb_rx",$sformatf("[PASS] exp=0x%0h act=0x%0h",exp,act),UVM_MEDIUM)
		end else begin
			rx_fail++;

			`uvm_info("scb_rx",$sformatf("[FAIL] exp=0x%0h act=0x%0h",exp,act),UVM_MEDIUM)
		end
	end
	endfunction

	function void report_phase(uvm_phase phase);
		super.report_phase(phase);

		`uvm_info("SCB","------------------------SCB Report-----------------------------",UVM_MEDIUM)
		`uvm_info("SCB", $sformatf("  TX: PASS=%0d, FAIL=%0d, Leftover exp=%0d, act=%0d",
                tx_pass, tx_fail, tx_exp_q.size(), tx_act_q.size()), UVM_MEDIUM)
        	`uvm_info("SCB", $sformatf("  RX: PASS=%0d, FAIL=%0d, Leftover exp=%0d, act=%0d",
                rx_pass, rx_fail, rx_exp_q.size(), rx_act_q.size()), UVM_MEDIUM)
       		`uvm_info("SCB", "--------------------------------------------------------------", UVM_MEDIUM)
		if (tx_exp_q.size() != 0) `uvm_error("SCB", "TX exp queue leftover! DUT may have lost transmission")
		if (tx_act_q.size() != 0) `uvm_error("SCB", "TX act queue leftover! Monitor captured extra data")
		if (rx_exp_q.size() != 0) `uvm_error("SCB", "RX exp queue leftover! DUT may not have received")
		if (rx_act_q.size() != 0) `uvm_error("SCB", "RX act queue leftover! Monitor captured extra data")

	endfunction
endclass

	
