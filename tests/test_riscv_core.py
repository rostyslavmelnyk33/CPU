import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

async def run_program(dut, cycles=25):
    """Допоміжна функція: генерує Clock, скидає процесор і чекає виконання програми"""
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, cycles)
    return dut.u_datapath.u_regfile

@cocotb.test()
async def test_01_basic_alu(dut):
    """Перевірка ADDI, ADD, SUB"""
    regfile = await run_program(dut)
    assert int(regfile.regs[1].value) == 15, "Помилка ADDI (x1)"
    assert int(regfile.regs[2].value) == 10, "Помилка ADDI (x2)"
    assert int(regfile.regs[3].value) == 25, "Помилка ADD (x3)"
    assert int(regfile.regs[4].value) == 5,  "Помилка SUB (x4)"

@cocotb.test()
async def test_02_logical_and_shift(dut):
    """Перевірка AND, OR, XOR, SLL"""
    regfile = await run_program(dut)
    assert int(regfile.regs[5].value) == 10,  "Помилка AND (x5)"
    assert int(regfile.regs[6].value) == 15,  "Помилка OR (x6)"
    assert int(regfile.regs[7].value) == 5,   "Помилка XOR (x7)"
    assert int(regfile.regs[8].value) == 320, "Помилка SLL (x8)"

@cocotb.test()
async def test_03_memory(dut):
    """Перевірка SW та LW"""
    regfile = await run_program(dut)
    assert int(regfile.regs[9].value) == 320, "Помилка LW/SW (x9)"

@cocotb.test()
async def test_04_branching(dut):
    """Перевірка BEQ та стрибків"""
    regfile = await run_program(dut)
    assert int(regfile.regs[10].value) == 0, "Помилка BEQ: інструкція не була пропущена (x10)"
    assert int(regfile.regs[11].value) == 1, "Помилка BEQ: не перейшли на правильну адресу (x11)"