// Top-level single-cycle RV32I core
// - Instantiates control, datapath, instruction memory, and data memory
module riscv_core (
    input  logic        clk,
    input  logic        rst_n,
    output logic [31:0] pc_out,
    output logic [31:0] instr_out,
    output logic [31:0] alu_result_out,
    output logic [31:0] write_data_out,
    output logic [31:0] read_data_out,
    output logic        reg_write_out,
    output logic        mem_write_out
);

    logic [31:0] pc;
    logic [31:0] instr;
    logic [31:0] read_data;
    logic [31:0] alu_result;
    logic [31:0] write_data;

    logic        reg_write;
    logic        mem_write;
    logic        mem_read;
    logic        alu_src;
    logic        mem_to_reg;
    logic        branch;
    logic [1:0]  imm_src;
    logic [3:0]  alu_ctrl; // [2:0]

    // Control unit decodes the current instruction.
    control u_control (
        .opcode   (instr[6:0]),
        .funct3   (instr[14:12]),
        .funct7   (instr[31:25]),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .mem_read (mem_read),
        .alu_src  (alu_src),
        .mem_to_reg(mem_to_reg),
        .branch   (branch),
        .imm_src  (imm_src),
        .alu_ctrl (alu_ctrl)
    );

    // Datapath contains the PC, register file, ALU, and muxing logic.
    datapath u_datapath (
        .clk      (clk),
        .rst_n    (rst_n),
        .instr    (instr),
        .read_data(read_data),
        .reg_write(reg_write),
        .mem_to_reg(mem_to_reg),
        .alu_src  (alu_src),
        .branch   (branch),
        .imm_src  (imm_src),
        .alu_ctrl (alu_ctrl),
        .pc       (pc),
        .alu_result(alu_result),
        .write_data(write_data)
    );

    // Instruction memory is read using the current PC.
    imem u_imem (
        .addr (pc),
        .instr(instr)
    );

    // Data memory supports load/store operations.
    dmem u_dmem (
        .clk       (clk),
        .mem_write (mem_write),
        .addr      (alu_result),
        .write_data(write_data),
        .read_data (read_data)
    );

    // Debug/observability outputs — без них синтезатор видаляє всю логіку,
    // бо їй нема куди "дотягнутись" до зовнішнього порту.
    assign pc_out         = pc;
    assign instr_out      = instr;
    assign alu_result_out = alu_result;
    assign write_data_out = write_data;
    assign read_data_out  = read_data;
    assign reg_write_out  = reg_write;
    assign mem_write_out  = mem_write;

endmodule
