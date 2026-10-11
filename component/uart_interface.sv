interface uart_interface(input CLK);
	logic RST_n;

	logic TX;
	logic [7:0] TX_DATA;
	logic TX_START;
	logic TX_BUSY;

	logic RX;
	logic [7:0] RX_DATA;
	logic RX_READY;

	clocking drv_cb @(posedge CLK);
		default input #1step output #1step;
		output TX_DATA,TX_START,RX;
		input TX_BUSY,RX_READY;
	endclocking

	clocking mon_cb @(posedge CLK);
		default input #1step;
		input TX,TX_DATA,TX_START,TX_BUSY;
		input RX,RX_DATA,RX_READY;
	endclocking

	modport drv_mp (clocking drv_cb,input CLK,output RST_n);
	modport mon_mp (clocking mon_cb,input CLK,input RST_n);

	
endinterface

