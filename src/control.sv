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
    output logic [3:0] alu_ctrl
);

    localparam logic [6:0] OP_RTYPE = 7'b0110011;
    localparam logic [6:0] OP_ITYPE = 7'b0010011;
    localparam logic [6:0] OP_LOAD  = 7'b0000011;
    localparam logic [6:0] OP_STORE = 7'b0100011;
    localparam logic [6:0] OP_BRANCH= 7'b1100011;

    localparam logic [1:0] IMM_I = 2'b00;
    localparam logic [1:0] IMM_S = 2'b01;
    localparam logic [1:0] IMM_B = 2'b10;

    localparam logic [3:0] ALU_ADD  = 4'b0000;
    localparam logic [3:0] ALU_SUB  = 4'b1000;
    localparam logic [3:0] ALU_SLL  = 4'b0001;
    localparam logic [3:0] ALU_SLT  = 4'b0010;
    localparam logic [3:0] ALU_SLTU = 4'b0011;
    localparam logic [3:0] ALU_XOR  = 4'b0100;
    localparam logic [3:0] ALU_SRL  = 4'b0101;
    localparam logic [3:0] ALU_SRA  = 4'b1101;
    localparam logic [3:0] ALU_OR   = 4'b0110;
    localparam logic [3:0] ALU_AND  = 4'b0111;

    always_comb begin
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
                    {7'b0000000, 3'b000}: alu_ctrl = ALU_ADD;
                    {7'b0100000, 3'b000}: alu_ctrl = ALU_SUB;
                    {7'b0000000, 3'b001}: alu_ctrl = ALU_SLL;
                    {7'b0000000, 3'b010}: alu_ctrl = ALU_SLT;
                    {7'b0000000, 3'b011}: alu_ctrl = ALU_SLTU;
                    {7'b0000000, 3'b100}: alu_ctrl = ALU_XOR;
                    {7'b0000000, 3'b101}: alu_ctrl = ALU_SRL;
                    {7'b0100000, 3'b101}: alu_ctrl = ALU_SRA;
                    {7'b0000000, 3'b110}: alu_ctrl = ALU_OR;
                    {7'b0000000, 3'b111}: alu_ctrl = ALU_AND;
                    default:              alu_ctrl = ALU_ADD;
                endcase
            end

            OP_ITYPE: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                imm_src   = IMM_I;
                mem_to_reg= 1'b0;

                unique case (funct3)
                    3'b000: alu_ctrl = ALU_ADD;
                    3'b010: alu_ctrl = ALU_SLT;
                    3'b011: alu_ctrl = ALU_SLTU;
                    3'b100: alu_ctrl = ALU_XOR;
                    3'b110: alu_ctrl = ALU_OR;
                    3'b111: alu_ctrl = ALU_AND;
                    3'b001: alu_ctrl = ALU_SLL;
                    3'b101: begin
                        if (funct7[5]) alu_ctrl = ALU_SRA;
                        else           alu_ctrl = ALU_SRL;
                    end
                    default: alu_ctrl = ALU_ADD;
                endcase
            end

            OP_LOAD: begin
                reg_write = 1'b1; mem_read = 1'b1; alu_src = 1'b1; mem_to_reg = 1'b1;
                imm_src = IMM_I; alu_ctrl = ALU_ADD;
            end
            OP_STORE: begin
                mem_write = 1'b1; alu_src = 1'b1; imm_src = IMM_S; alu_ctrl = ALU_ADD;
            end
            OP_BRANCH: begin
                branch = 1'b1; imm_src = IMM_B; alu_ctrl = ALU_SUB;
            end
            default: begin end
        endcase
    end
endmodule
