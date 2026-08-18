// Instruction Memory
// - Read-only memory for the processor instruction stream
// - Initialized with a small educational program
module imem (
        input  logic [31:0] addr,
        output logic [31:0] instr
    );

    localparam int IMEM_WORDS = 64;

    logic [31:0] mem [0:IMEM_WORDS-1];

    // Helper encoders keep the memory initialization easy to trace.
    function automatic logic [31:0] encode_rtype(
            input logic [6:0] funct7,
            input logic [4:0] rs2,
            input logic [4:0] rs1,
            input logic [2:0] funct3,
            input logic [4:0] rd,
            input logic [6:0] opcode
        );
        encode_rtype = {funct7, rs2, rs1, funct3, rd, opcode};
    endfunction

    function automatic logic [31:0] encode_itype(
            input logic signed [11:0] imm,
            input logic [4:0] rs1,
            input logic [2:0] funct3,
            input logic [4:0] rd,
            input logic [6:0] opcode
        );
        encode_itype = {imm[11:0], rs1, funct3, rd, opcode};
    endfunction

    function automatic logic [31:0] encode_stype(
            input logic signed [11:0] imm,
            input logic [4:0] rs2,
            input logic [4:0] rs1,
            input logic [2:0] funct3,
            input logic [6:0] opcode
        );
        encode_stype = {imm[11:5], rs2, rs1, funct3, imm[4:0], opcode};
    endfunction

    function automatic logic [31:0] encode_btype(
            input logic signed [12:0] imm,
            input logic [4:0] rs2,
            input logic [4:0] rs1,
            input logic [2:0] funct3,
            input logic [6:0] opcode
        );
        // Branch immediates are encoded with bit 0 omitted.
        encode_btype = {imm[12], imm[10:5], rs2, rs1, funct3, imm[4:1], imm[11], opcode};
    endfunction

    integer i;

    initial begin
        // Fill unused locations with ADDI x0, x0, 0 (NOP).
        for (i = 0; i < IMEM_WORDS; i++) begin
            mem[i] = 32'h0000_0013;
        end
        // --- PROGRAM: 10th Fibonacci number ---

        // Initialization:
        // mem[0]: addi x2, x0, 10 (Loop counter n = 10)
        mem[0] = encode_itype(12'sd10, 5'd0, 3'b000, 5'd2, 7'b0010011);

        // mem[1]: addi x3, x0, 0 (x3 - current Fibonacci number F_n, starts at 0)
        mem[1] = encode_itype(12'sd0,  5'd0, 3'b000, 5'd3, 7'b0010011);

        // mem[2]: addi x4, x0, 1 (x4 - next Fibonacci number F_{n+1}, starts at 1)
        mem[2] = encode_itype(12'sd1,  5'd0, 3'b000, 5'd4, 7'b0010011);

        // --- Loop Body ---

        // mem[3]: add x5, x3, x4 (x5 = F_n + F_{n+1} -> temporary sum)
        mem[3] = encode_rtype(7'b0000000, 5'd4, 5'd3, 3'b000, 5'd5, 7'b0110011);

        // mem[4]: add x3, x0, x4 (x3 = x4 -> shift F_n forward)
        mem[4] = encode_rtype(7'b0000000, 5'd4, 5'd0, 3'b000, 5'd3, 7'b0110011);

        // mem[5]: add x4, x0, x5 (x4 = x5 -> shift F_{n+1} forward)
        mem[5] = encode_rtype(7'b0000000, 5'd5, 5'd0, 3'b000, 5'd4, 7'b0110011);

        // mem[6]: addi x2, x2, -1 (Counter n = n - 1)
        mem[6] = encode_itype(-12'sd1, 5'd2, 3'b000, 5'd2, 7'b0010011);

        // mem[7]: bne x2, x0, -16 (If counter x2 != 0, branch back to mem[3])
        // Offset explanation: from current instruction (mem[7]) to target (mem[3]) is exactly 4 instructions back.
        // Since each instruction is 4 bytes, the offset is 4 * (-4) = -16.
        // opcode for bne - 7'b1100011, funct3 - 3'b001.
        mem[7] = encode_btype(-13'sd16, 5'd0, 5'd2, 3'b001, 7'b1100011);

        // --- Program End ---

        // mem[8]: beq x0, x0, 0 (Infinite loop to park the processor)
        mem[8] = encode_btype(13'sd0, 5'd0, 5'd0, 3'b000, 7'b1100011);

        /*
         // Small demo program:
         // x1 = 5
         // x2 = 10
         // x3 = x1 + x2 = 15
         // mem[0] = x3
         // x4 = mem[0]
         // if (x4 == x3) skip the next instruction
         // x5 = 1 (skipped)
         // x5 = 2
         // self-loop
         mem[0] = encode_itype(12'sd5,  5'd0, 3'b000, 5'd1, 7'b0010011); // addi x1, x0, 5
         mem[1] = encode_itype(12'sd10, 5'd0, 3'b000, 5'd2, 7'b0010011); // addi x2, x0, 10
         mem[2] = encode_rtype(7'b0000000, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011); // add x3, x1, x2
         mem[3] = encode_stype(12'sd0, 5'd3, 5'd0, 3'b010, 7'b0100011); // sw x3, 0(x0)
         mem[4] = encode_itype(12'sd0,  5'd0, 3'b010, 5'd4, 7'b0000011); // lw x4, 0(x0)
         mem[5] = encode_btype(13'sd8,   5'd3, 5'd4, 3'b000, 7'b1100011); // beq x4, x3, +8
         mem[6] = encode_itype(12'sd1,   5'd0, 3'b000, 5'd5, 7'b0010011); // addi x5, x0, 1
         mem[7] = encode_itype(12'sd2,   5'd0, 3'b000, 5'd5, 7'b0010011); // addi x5, x0, 2
         mem[8] = encode_btype(13'sd0,   5'd0, 5'd0, 3'b000, 7'b1100011); // beq x0, x0, 0 (self-loop)
         */


    end

    // Combinational instruction fetch.
    assign instr = mem[addr[7:2]];

endmodule
