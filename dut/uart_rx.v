// Simple UART transmitter
// Sends 8-bit data serially: start bit (0), 8 data bits (LSB first), stop bit (1)
// Uses a baud_tick from an external generator for timing (16x oversampling)
// FSM states: idle, start, data, stop
// tx_done goes high when transmission is complete

module uart_rx (
    input rx,
    input clk, rst, baud_tick,
    output reg rx_done,
    output reg [7:0] data_out
);
// FSM states - one-hot encoding (just for fun, does not have any significance untiil the code is not being executed on an FPGA)
    parameter [3:0] idle = 4'b0001,
                    start = 4'b0010,
                    data = 4'b0100,
                    stop = 4'b1000;

    reg [3:0] ps, ns;
    reg [3:0] tick_counter;     // Counts 0-15 for 16x oversampling
    reg [3:0] bit_index;
    reg [7:0] rx_data;

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
                if (~rx) begin
                    ns = start;
                end else begin
                    ns = idle;
                end
            end
            start : begin
                if (baud_tick) begin
                    if (tick_counter == 7) begin
                        ns = data;
                    end else begin
                        ns = start;
                    end
                end
            end
            data : begin
                if (baud_tick) begin
                    if (bit_index > 7) begin
                        ns = stop;
                    end else begin
                        ns = data;                        
                    end
                end else begin
                    ns = data; 
                end
            end
            stop : begin
                if (baud_tick) begin
                    if (tick_counter ==7) begin
                            ns = idle;
                    end else begin
                            ns = stop;
                        end
                end else begin
                    ns = stop;
                end
            end
            default : ns = idle;
        endcase
    end
    // Output logic - determines module outputs based on current state
    always @(posedge clk ) begin
        if (rst) begin
            tick_counter <=0;
            bit_index <= 0 ;
            rx_done <= 0;
            rx_data <= 0;
            data_out <= 0;
        end else begin
            case (ps)
            idle: begin
                if (baud_tick) begin
                    rx_done <= 0;
                    tick_counter <=0;
                    bit_index <= 0 ;
                    rx_data <= 'bz;
                end
            end 
            start : begin
                rx_done <=0;
                if (baud_tick) begin
                    if (tick_counter ==7) begin
                        tick_counter <= 0;
                    end else begin
                        tick_counter <= tick_counter + 1;
                    end
                end
            end
            data : begin
                if (baud_tick) begin
                    if (bit_index < 8) begin
                        if (tick_counter == 7) begin
                            rx_data [bit_index] <= rx;
                            tick_counter <= tick_counter + 1;
                    end
                    if (tick_counter == 15) begin
                        bit_index <= bit_index + 1;
                        tick_counter <=0;
                    end else begin
                        tick_counter <= tick_counter + 1;
                    end
                    end else begin
                        tick_counter <= 0;
                        bit_index <= 0;
                    end
                end    
            end
            stop : begin
                rx_done <= 0 ;
                if (baud_tick) begin
                    if(tick_counter==7) begin
                        data_out <= rx_data;
                        rx_done <= 1;                        
                        tick_counter<=0;                        
                    end else begin
                        tick_counter <= tick_counter + 1;
                    end
                end
            end
            default: begin
                rx_done <= 0;
                bit_index <= 0;
                tick_counter<=0;
            end
        endcase
        end
    end
endmodule