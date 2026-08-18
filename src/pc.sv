// Program Counter
// - Stores the address of the current instruction
// - Updates on the rising clock edge
// - Resets asynchronously to 0
module pc (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] pc_next,
    output logic [31:0] pc
);

    // Asynchronous active-low reset.
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 32'h0000_0000;
        end else begin
            pc <= pc_next;
        end
    end

endmodule
