# Crossbar-Design
Design and Evaluation of Accelerator Organizations for Binarzed Neural Networks

## Requirements
* **GHDL**
* **GTKWave**
* **VHDL**
* **VIVADO**

## Quick Instruction

### To use in VIVADO 
      
      Add the controller_tb.vhdl file as a simulation file
      Add the constraint.xdc file as a constraint file
      Add all the VHDL files to the VIVADO as source files 
      
### cloning repository

      $ git clone https://github.com/somar0/Crossbar-Design.git
      $ cd Crossbar-Design
      $ cd Strided Move
      or
      $ cd Vertical Move

### compiling VHDL code and looking on wave diagrams in GTKWave

      $ ghdl -s test_file.vhdl                 #Syntax Check  
      $ ghdl -a test_file.vhdl                 #Analyse  
      $ ghdl -e test_file.vhdl                 #Build   
      $ ghdl -r test_file --vcd=testbench.vcd  #VCD-Dump  
      $ gtkwave testbench.vcd                  #Start GTKWave  

### auto compiling the project

* In each design file there is a script to compile all the components automatically. You can use it like this:

      $ sh compile_sm.sh
      or
      $ sh compile_vm.sh


## System Model:

* pkg.vhdl

      Configuration component where we define the input, weights and threshold matrices's sizes 
      and where we can change the configurations; 
      (m, n) the number of (columns, XNORs) in the the crossbar array

* controller.vhdl
      
      Controller to control the data flow between the components

* weights_rom.vhdl & data_rom.vhdl & threshold_rom.vhdl
      
      ROMs to store the three matrices's values

* weights_bus.vhdl & data_bus.vhdl & threshold_bus.vhdl
      
      BUSs to control which rows are bieng read from the three ROMs

* SM.vhdl & VM.vhdl
      
      Components to differentiate between strided move and vertical move 

* CB.vhdl
      
      Crossbar component which has the columns and the interface circuit
      Accumulator and comparator components are also in CB components
      
* column.vhdl
      
      Column to calculate the multiplication between weights and inputs through the XNORs gates

* cb_xnor.vhdl 
      
      XNOR gate that takes two bits as inputs

* ic.vhdl
      
      Interface circuit components which has the popcount
      Accumulator and comparator aren't in the interface circuit because results in accumulator 
      and comparator need to be stored longer than in XNORs and popcount.

* popcount.vhdl
      
      Popcount to count how many ones in the resulting vector from XNOR gates.
      It has many adders and flip flops components

* cb_adder.vhdl
      
      Adder To add two vectors of a given size through generic

* cb_dff.vhdl
      
      D-flip flop to register a vector of a given size through generic

* acc.vhdl
      
      Accumulator to accumulate the popcount results (partial sums)

* comparator.vhdl
      
      Comparator to compare the final result of the accumulator with the appropriate threshold value 

* controller_tb.vhdl

      Simulation file where we can control how long will the design run 
      
## Python file:
      
      To check the correctness of the Results.
      
      The values for the input, weights, and thresholds matrices are here generated and stored in the files;
      inputs.txt, weights.txt and threshold.txt, respectively. the final results are stored in the file activations.txt
      
## P.S.:

      The inputs matrix has been transposed so the columns became rwos and the rows became columns,
      so we can deal with its columns in VHDL on VIVADO  


