#!/bin/bash

ghdl -a pkg.vhdl
ghdl -a data_rom.vhdl
ghdl -a data_bus.vhdl
ghdl -a weights_rom.vhdl
ghdl -a weights_bus.vhdl
ghdl -a threshold_rom.vhdl
ghdl -a threshold_bus.vhdl
ghdl -a cb_xnor.vhdl
ghdl -a cb_adder.vhdl
ghdl -a cb_dff.vhdl
ghdl -a popcount.vhdl
ghdl -a acc.vhdl
ghdl -a comparator.vhdl
ghdl -a ic.vhdl 
ghdl -a column.vhdl 
ghdl -a cb.vhdl 
ghdl -a sm.vhdl  
ghdl -a controller.vhdl 
ghdl -a controller_tb.vhdl
ghdl -e controller_tb
ghdl -r controller_tb --vcd=testbench.vcd
gtkwave testbench.vcd