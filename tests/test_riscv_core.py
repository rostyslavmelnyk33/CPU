"""
Top-level Cocotb testbench for the single-cycle RV32I core (src/riscv_core.sv).

The instruction memory (src/imem.sv) is hardcoded with a small program that
computes the 10th Fibonacci number using registers x2 (loop counter),
x3 (F_n) and x4 (F_n+1), then parks the core in a self-loop (beq x0, x0, 0).

This test:
  1. Drives a free-running clock on `clk`.
  2. Applies an initial asynchronous, active-low reset on `rst_n`.
  3. Lets the core run for at least 100 clock cycles (the Fibonacci loop
     itself completes in ~53 cycles, so 100 cycles leaves plenty of margin
     for the core to settle into its terminal self-loop).
  4. Reaches into the register file through the datapath hierarchy
     (riscv_core -> u_datapath -> u_regfile -> regs[3]) and checks that
     x3 holds 55.
"""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

CLOCK_PERIOD_NS = 10
RESET_CYCLES = 5
RUN_CYCLES = 100
EXPECTED_X3 = 55


@cocotb.test()
async def test_riscv_core_x3_fibonacci(dut):
    """Run the core and confirm x3 ends up holding the 10th Fibonacci number."""

    # 1. Generate a free-running clock.
    cocotb.start_soon(Clock(dut.clk, CLOCK_PERIOD_NS, "ns").start())

    # 2. Apply an initial reset (active-low, per src/pc.sv).
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, RESET_CYCLES)
    dut.rst_n.value = 1

    # 3. Run for at least 100 clock cycles.
    await ClockCycles(dut.clk, RUN_CYCLES)

    # 4. Reach into the register file via the datapath hierarchy.
    regfile = dut.u_datapath.u_regfile
    x3 = int(regfile.regs[3].value)

    dut._log.info(
        "After %d cycles: pc=0x%08x  x2=%d  x3=%d  x4=%d",
        RESET_CYCLES + RUN_CYCLES,
        int(dut.pc_out.value),
        int(regfile.regs[2].value),
        x3,
        int(regfile.regs[4].value),
    )

    assert x3 == EXPECTED_X3, (
        f"Expected register x3 to hold {EXPECTED_X3} "
        f"(10th Fibonacci number), got {x3} instead"
    )