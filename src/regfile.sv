// Register File
// - 32 architectural registers
// - Two asynchronous read ports
// - One synchronous write port
// - Register x0 is hardwired to zero
module regfile (
    input  logic        clk,
    input  logic        we3,
    input  logic [4:0]  ra1,
    input  logic [4:0]  ra2,
    input  logic [4:0]  wa3,
    input  logic [31:0] wd3,
    output logic [31:0] rd1,
    output logic [31:0] rd2
);

    logic [31:0] regs [0:31];

    integer i;

    initial begin
        for (i = 0; i < 32; i++) begin
            regs[i] = 32'h0000_0000;
        end
    end

    // Synchronous write. Register x0 remains zero regardless of writes.
    always_ff @(posedge clk) begin
        if (we3 && (wa3 != 5'd0)) begin
            regs[wa3] <= wd3;
        end
        regs[0] <= 32'h0000_0000;
    end

    // Asynchronous reads.
    assign rd1 = (ra1 == 5'd0) ? 32'h0000_0000 : regs[ra1];
    assign rd2 = (ra2 == 5'd0) ? 32'h0000_0000 : regs[ra2];

endmodule
