SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# Icarus needs to be told to parse SystemVerilog-2012 constructs
# (logic, always_ff/always_comb, unique case, automatic functions, ...)
ifeq ($(SIM),icarus)
    COMPILE_ARGS += -g2012
endif

# RTL sources for the full single-cycle RISC-V core (../src)
VERILOG_SOURCES += $(PWD)/../src/alu.sv
VERILOG_SOURCES += $(PWD)/../src/control.sv
VERILOG_SOURCES += $(PWD)/../src/pc.sv
VERILOG_SOURCES += $(PWD)/../src/regfile.sv
VERILOG_SOURCES += $(PWD)/../src/dmem.sv
VERILOG_SOURCES += $(PWD)/../src/imem.sv
VERILOG_SOURCES += $(PWD)/../src/datapath.sv
VERILOG_SOURCES += $(PWD)/../src/riscv_core.sv

TOPLEVEL = riscv_core
MODULE = test_riscv_core

include $(shell cocotb-config --makefiles)/Makefile.sim