// Datapath
// - Instantiates the PC, register file, and ALU
// - Generates immediates and selects datapath muxes
// - Resolves branch decisions for the PC update
module datapath (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] instr,
    input  logic [31:0] read_data,
    input  logic        reg_write,
    input  logic        mem_to_reg,
    input  logic        alu_src,
    input  logic        branch,
    input  logic [1:0]  imm_src,
    input  logic [3:0]  alu_ctrl,
    output logic [31:0] pc,
    output logic [31:0] alu_result,
    output logic [31:0] write_data
);

    logic [31:0] pc_next;
    logic [31:0] pc_plus4;
    logic [31:0] pc_target;
    logic [31:0] imm_ext;
    logic [31:0] src_a;
    logic [31:0] src_b;
    logic [31:0] rd1;
    logic [31:0] rd2;
    logic        alu_zero;
    logic [31:0] result_wb;
    logic        branch_taken;

    // Register addresses are taken directly from the instruction fields.
    wire [4:0] rs1 = instr[19:15];
    wire [4:0] rs2 = instr[24:20];
    wire [4:0] rd  = instr[11:7];
    wire [2:0] funct3 = instr[14:12];

    // Immediate generation for the supported instruction formats.
    function automatic logic [31:0] extend_imm(
        input logic [31:0] instruction,
        input logic [1:0]  format
    );
        logic signed [31:0] tmp;
        begin
            unique case (format)
                2'b00: tmp = {{20{instruction[31]}}, instruction[31:20]};
                2'b01: tmp = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
                2'b10: tmp = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
                default: tmp = 32'sd0;
            endcase
            extend_imm = tmp;
        end
    endfunction

    always_comb begin
        imm_ext   = extend_imm(instr, imm_src);
        pc_plus4   = pc + 32'd4;
        pc_target  = pc + imm_ext;
        src_a      = rd1;
        src_b      = alu_src ? imm_ext : rd2;
        write_data = rd2;

        // Branch decision is based on the branch type encoded in funct3.
        // Only BEQ and BNE are explicitly handled in this educational core.
        branch_taken = 1'b0;
        if (branch) begin
            unique case (funct3)
                3'b000: branch_taken = alu_zero;      // BEQ
                3'b001: branch_taken = ~alu_zero;     // BNE
                default: branch_taken = 1'b0;
            endcase
        end

        pc_next = branch_taken ? pc_target : pc_plus4;

        // Writeback selection: memory data for loads, ALU result otherwise.
        result_wb = mem_to_reg ? read_data : alu_result;
    end

    // Program Counter instance.
    pc u_pc (
        .clk    (clk),
        .rst_n  (rst_n),
        .pc_next(pc_next),
        .pc     (pc)
    );

    // Register file instance.
    regfile u_regfile (
        .clk (clk),
        .we3 (reg_write),
        .ra1 (rs1),
        .ra2 (rs2),
        .wa3 (rd),
        .wd3 (result_wb),
        .rd1 (rd1),
        .rd2 (rd2)
    );

    // ALU instance.
    alu u_alu (
        .a        (src_a),
        .b        (src_b),
        .alu_ctrl (alu_ctrl),
        .result   (alu_result),
        .zero     (alu_zero)
    );

endmodule
