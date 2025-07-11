module uart_tb;
    logic clk = 0, rst = 1;
    logic tx_start;
    logic [7:0] tx_data;
    logic [15:0] baud_divisor = 434; // For 115200 baud with 50MHz clock
    logic [1:0] stop_bits = 1;
    logic parity_en = 1, parity_odd = 0;
    logic rx, tx, tx_busy;
    logic [7:0] rx_data;
    logic rx_ready, parity_error, stop_error;

    uart_top uut (
        .clk(clk), .rst(rst), .tx_start(tx_start), .tx_data(tx_data),
        .baud_divisor(baud_divisor), .stop_bits(stop_bits),
        .parity_en(parity_en), .parity_odd(parity_odd),
        .rx(rx), .tx(tx), .tx_busy(tx_busy),
        .rx_data(rx_data), .rx_ready(rx_ready),
        .parity_error(parity_error), .stop_error(stop_error)
    );

    // Clock generation
    always #10 clk = ~clk;

    // Loopback for test
    assign rx = tx;

    initial begin
        #100 rst = 0;
        tx_data = 8'hA5; tx_start = 1;
        #20 tx_start = 0;
        wait (rx_ready);
        $display("Received: %h", rx_data);
        $stop;
    end
endmodule
