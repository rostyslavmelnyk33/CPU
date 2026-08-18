// Data Memory
// - Synchronous write
// - Combinational read
module dmem (
    input  logic        clk,
    input  logic        mem_write,
    input  logic [31:0] addr,
    input  logic [31:0] write_data,
    output logic [31:0] read_data
);

    localparam int DMEM_WORDS = 64;

    logic [31:0] mem [0:DMEM_WORDS-1];

    integer i;

    initial begin
        for (i = 0; i < DMEM_WORDS; i++) begin
            mem[i] = 32'h0000_0000;
        end
    end

    always_ff @(posedge clk) begin
        if (mem_write) begin
            mem[addr[7:2]] <= write_data;
        end
    end

    // Combinational read for single-cycle operation.
    assign read_data = mem[addr[7:2]];

endmodule
