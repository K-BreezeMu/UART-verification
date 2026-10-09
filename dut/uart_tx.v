// Simple UART transmitter
// Sends 8-bit data serially: start bit (0), 8 data bits (LSB first), stop bit (1)
// Uses a baud_tick from an external generator for timing (16x oversampling)
// FSM states: idle, start, data, stop
// tx_done goes high when transmission is complete

module uart_tx (
    input [7:0] data_in,
    input clk, rst, start_tx, baud_tick,
    output reg tx_done,
    output reg tx_line
);
// FSM states - one-hot encoding (just for fun, does not have any significance untiil the code is not being executed on an FPGA)
    parameter [3:0] idle = 4'b0001,
                    start = 4'b0010,
                    data = 4'b0100,
                    stop = 4'b1000;

    reg [3:0] ps, ns;
    reg [3:0] tick_counter;     // Counts 0-15 for 16x oversampling
    reg [2:0] bit_index;
    reg[7:0] tx_data;

    // Sequential logic - state updates and counter management only
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ps <= idle;
            tick_counter <= 0;
            bit_index <= 0;
        end else begin
            ps <= ns;
        end
    end
   // Combinational next state logic - determines state transitions
    always @(*) begin
        case (ps)
            idle: begin
                if (start_tx) begin
                    ns = start;
                end else begin
                    ns = idle;
                end
            end
            start : begin
                if (baud_tick) begin
                    ns = data;
                end else begin
                    ns =start;
                end
            end
            data : begin
                if (baud_tick) begin
                    if (bit_index==7) begin
                        ns = stop;
                    end else begin
                        ns = data;                        
                    end
                end
            end
            stop : begin
                if (baud_tick && tx_done) begin
                    ns = idle;
                end else begin
                    ns = stop; 
                end
            end
            default : ns = ps;
        endcase
    end
    // Output logic - determines module outputs based on current state
    always @(posedge clk ) begin
        case (ps)
            idle: begin
                tx_line <= 1;
                if (start_tx) begin
                    tx_done <= 0;
                    tx_data <= data_in; 
                end else begin
                    tx_done <= 0;
                    tx_data <= 'bz;
                end
            end
            start : begin
                tx_done <= 0;
                tx_line <= 0;
                bit_index <= 0;
            end
            data : begin
            if (baud_tick) begin
                if (tick_counter==0) begin
                    tx_line <= tx_data[bit_index];
                    tick_counter <= tick_counter + 1; 
                end else begin
                    if (tick_counter == 15) begin
                        bit_index <= bit_index + 1;
                        tick_counter <=0;
                    end else begin
                        tick_counter <= tick_counter + 1;
                    end
                end
            end    
            end
            stop : begin
                if (baud_tick) begin
                    tx_line <= 1;
                    if (tick_counter == 15) begin
                        tx_done <= 1;                        
                        tick_counter <= 0;
                    end else begin
                        tick_counter <= tick_counter + 1;
                    end
                end
            end
            default: begin
                tx_done <= 1;
                tx_line <= 1;
                bit_index <= 0;
                tick_counter<=0;
            end
        endcase
    end
endmodule


