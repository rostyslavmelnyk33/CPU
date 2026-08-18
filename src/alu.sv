// Arithmetic Logic Unit
// - Executes a small RV32I subset used by the single-cycle core
// - Supports ADD, SUB, AND, OR, and SLT
module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [2:0]  alu_ctrl,
    output logic [31:0] result,
    output logic        zero
);

    localparam logic [2:0] ALU_ADD = 3'b000;
    localparam logic [2:0] ALU_SUB = 3'b001;
    localparam logic [2:0] ALU_AND = 3'b010;
    localparam logic [2:0] ALU_OR  = 3'b011;
    localparam logic [2:0] ALU_SLT = 3'b100;

    always_comb begin
        unique case (alu_ctrl)
            ALU_ADD: result = a + b;
            ALU_SUB: result = a - b;
            ALU_AND: result = a & b;
            ALU_OR : result = a | b;
            ALU_SLT: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            default: result = a + b;
        endcase
    end

    assign zero = (result == 32'h0000_0000);

endmodule
