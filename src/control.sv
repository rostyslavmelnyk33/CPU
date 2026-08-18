// Control Unit
// - Decodes opcode, funct3, and funct7
// - Generates datapath and memory control signals
module control (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic       reg_write,
    output logic       mem_write,
    output logic       mem_read,
    output logic       alu_src,
    output logic       mem_to_reg,
    output logic       branch,
    output logic [1:0] imm_src,
    output logic [2:0] alu_ctrl
);

    // Opcode encodings used by the basic RV32I subset.
    localparam logic [6:0] OP_RTYPE = 7'b0110011;
    localparam logic [6:0] OP_ITYPE = 7'b0010011;
    localparam logic [6:0] OP_LOAD  = 7'b0000011;
    localparam logic [6:0] OP_STORE = 7'b0100011;
    localparam logic [6:0] OP_BRANCH= 7'b1100011;

    // Immediate format selector.
    localparam logic [1:0] IMM_I = 2'b00;
    localparam logic [1:0] IMM_S = 2'b01;
    localparam logic [1:0] IMM_B = 2'b10;

    // ALU control encoding.
    localparam logic [2:0] ALU_ADD = 3'b000;
    localparam logic [2:0] ALU_SUB = 3'b001;
    localparam logic [2:0] ALU_AND = 3'b010;
    localparam logic [2:0] ALU_OR  = 3'b011;
    localparam logic [2:0] ALU_SLT = 3'b100;

    always_comb begin
        // Default values avoid latches and give harmless NOP behavior.
        reg_write = 1'b0;
        mem_write = 1'b0;
        mem_read  = 1'b0;
        alu_src   = 1'b0;
        mem_to_reg= 1'b0;
        branch    = 1'b0;
        imm_src   = IMM_I;
        alu_ctrl  = ALU_ADD;

        unique case (opcode)
            OP_RTYPE: begin
                reg_write = 1'b1;
                alu_src   = 1'b0;
                imm_src   = IMM_I;

                unique case ({funct7, funct3})
                    {7'b0000000, 3'b000}: alu_ctrl = ALU_ADD; // add
                    {7'b0100000, 3'b000}: alu_ctrl = ALU_SUB; // sub
                    {7'b0000000, 3'b111}: alu_ctrl = ALU_AND; // and
                    {7'b0000000, 3'b110}: alu_ctrl = ALU_OR;  // or
                    {7'b0000000, 3'b010}: alu_ctrl = ALU_SLT; // slt
                    default:              alu_ctrl = ALU_ADD;
                endcase
            end

            OP_ITYPE: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                imm_src   = IMM_I;
                mem_to_reg= 1'b0;

                unique case (funct3)
                    3'b000: alu_ctrl = ALU_ADD; // addi
                    3'b111: alu_ctrl = ALU_AND; // andi
                    3'b110: alu_ctrl = ALU_OR;  // ori
                    3'b010: alu_ctrl = ALU_SLT; // slti
                    default: alu_ctrl = ALU_ADD;
                endcase
            end

            OP_LOAD: begin
                reg_write = 1'b1;
                mem_read  = 1'b1;
                alu_src   = 1'b1;
                mem_to_reg= 1'b1;
                imm_src   = IMM_I;
                alu_ctrl  = ALU_ADD; // address calculation
            end

            OP_STORE: begin
                mem_write = 1'b1;
                alu_src   = 1'b1;
                imm_src   = IMM_S;
                alu_ctrl  = ALU_ADD; // address calculation
            end

            OP_BRANCH: begin
                branch    = 1'b1;
                imm_src   = IMM_B;
                alu_ctrl  = ALU_SUB; // compare for equality
            end

            default: begin
                // Keep default NOP-like values.
            end
        endcase
    end

endmodule
