module uart_tx #(
    parameter DATA_BITS = 8
)(
    input  logic clk,
    input  logic rst,
    input  logic tx_start,
    input  logic [DATA_BITS-1:0] tx_data,
    input  logic [1:0] stop_bits, // 1 or 2 stop bits
    input  logic parity_en,
    input  logic parity_odd, // 1: odd, 0: even
    input  logic baud_tick,
    output logic tx,
    output logic tx_busy
);
    typedef enum logic [2:0] {IDLE, START, DATA, PARITY, STOP} state_t;
    state_t state, next_state;

    logic [3:0] bit_idx;
    logic parity_bit;
    logic [DATA_BITS-1:0] shift_reg;
    logic [1:0] stop_count;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            tx <= 1'b1;
            tx_busy <= 1'b0;
            bit_idx <= 0;
            stop_count <= 0;
        end else if (baud_tick) begin
            state <= next_state;
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    tx_busy <= 1'b0;
                    if (tx_start) begin
                        shift_reg <= tx_data;
                        parity_bit <= parity_en ? ^{parity_odd, tx_data} : 1'b0;
                        bit_idx <= 0;
                        tx_busy <= 1'b1;
                    end
                end
                START: tx <= 1'b0;
                DATA: begin
                    tx <= shift_reg[0];
                    shift_reg <= {1'b0, shift_reg[DATA_BITS-1:1]};
                    bit_idx <= bit_idx + 1;
                end
                PARITY: tx <= parity_bit;
                STOP: tx <= 1'b1;
            endcase
        end
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE: if (tx_start) next_state = START;
            START: next_state = DATA;
            DATA: if (bit_idx == DATA_BITS) 
                      next_state = parity_en ? PARITY : STOP;
            PARITY: next_state = STOP;
            STOP: if (stop_count == stop_bits-1) next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) stop_count <= 0;
        else if (state == STOP && baud_tick) stop_count <= stop_count + 1;
        else if (state != STOP) stop_count <= 0;
    end
endmodule
