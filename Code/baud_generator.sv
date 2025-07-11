module baud_gen #(
    parameter CLK_FREQ = 50_000_000, // Input clock frequency
    parameter BAUD_RATE = 115200
)(
    input  logic clk,
    input  logic rst,
    input  logic [15:0] divisor, // Configurable divisor for baud rate
    output logic baud_tick
);
    logic [15:0] count;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 0;
            baud_tick <= 0;
        end else if (count == divisor) begin
            count <= 0;
            baud_tick <= 1;
        end else begin
            count <= count + 1;
            baud_tick <= 0;
        end
    end
endmodule
