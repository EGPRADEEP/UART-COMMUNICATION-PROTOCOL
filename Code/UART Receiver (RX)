module uart_rx #(
    parameter DATA_BITS = 8
)(
    input  logic clk,
    input  logic rst,
    input  logic rx,
    input  logic [1:0] stop_bits,
    input  logic parity_en,
    input  logic parity_odd,
    input  logic baud_tick,
    output logic [DATA_BITS-1:0] rx_data,
    output logic rx_ready,
    output logic parity_error,
    output logic stop_error
);
    typedef enum logic [2:0] {IDLE, START, DATA, PARITY, STOP} state_t;
    state_t state, next_state;

    logic [3:0] bit_idx;
    logic [DATA_BITS-1:0] shift_reg;
    logic parity_calc, parity_rx;
    logic [1:0] stop_count;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            rx_ready <= 0;
            parity_error <= 0;
            stop_error <= 0;
            bit_idx <= 0;
            stop_count <= 0;
        end else if (baud_tick) begin
            state <= next_state;
            case (state)
                IDLE: begin
                    rx_ready <= 0;
                    if (~rx) next_state = START;
                end
                START: if (~rx) next_state = DATA;
                DATA: begin
                    shift_reg <= {rx, shift_reg[DATA_BITS-1:1]};
                    bit_idx <= bit_idx + 1;
                    if (bit_idx == DATA_BITS-1) next_state = parity_en ? PARITY : STOP;
                end
                PARITY: begin
                    parity_rx <= rx;
                    parity_calc <= ^{parity_odd, shift_reg};
                    parity_error <= (parity_rx != parity_calc);
                    next_state = STOP;
                end
                STOP: begin
                    if (rx != 1'b1) stop_error <= 1;
                    stop_count <= stop_count + 1;
                    if (stop_count == stop_bits-1) begin
                        rx_data <= shift_reg;
                        rx_ready <= 1;
                        next_state = IDLE;
                    end
                end
            endcase
        end
    end
endmodule
