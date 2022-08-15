# Crossbar-Design
Design and Evaluation of Accelerator Organizations for Binarzed Neural Networks

## Requirements
* **GHDL**
* **GTKWave**
* **VHDL**
* **VIVADO**

## Quick Instruction

## To use in VIVADO 
      
      Add the controller_tb.vhdl file as a simulation file
      Add the constraint.xdc file as a constraint file
      Add all the VHDL files to the VIVADO as source files 
      
### cloning repository

      $ gh repo clone somar0/Crossbar-Design
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
In each Design file there is a script to compile all the components automatically. You can use it like this:

      $ sh compile_sm.sh
      or
      $ sh compile_vm.sh
      
## References

1. FP-BNN:  Binarized  neural  network  on  FPGA  
  https://www.sciencedirect.com/science/article/abs/pii/S0925231217315655

2. Stochastic Computing for Hardware Implementationof Binarized Neural Networks  
  https://arxiv.org/abs/1906.00915

3. FINN: A Framework for Fast, Scalable Binarized Neural Network Inference  
  https://arxiv.org/abs/1612.07119
  
4. Design and Optimization of FeFET-based Crossbars for Binary Convolution Neural Networks 
  https://ieeexplore.ieee.org/document/8342199
