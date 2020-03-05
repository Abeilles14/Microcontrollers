University of British Columbia
CPEN 211

*Isabelle Andre, Marcus Wong

[TOC]

#Introduction to Microcontrollers

## Lab 1

This lab is an introduction to programming in Verilog and the DE1 SoC board using ModelSim and Quartus.
The circuit calculates two functions: bitwise-AND and addition. The value on the result output depends
upon the push buttons pressed. The type of hardware to implement was first identified before writing code.

## Lab 2

This lab consisted in gaining experience building digital circuits out of discrete logic components using
a breadboard, jumper wires, microchips and lab equipment. A two input OR gate was created out of NOT and
NAND gates, with a NOT gate also implemented into the circuit. An optimized circuit was then implemented
for a certain Boolean function. A flip-flop was created using NAND and NOT gates to build an R-S Latch
and a Gated D Latch followed by a Master-Slave Flip-Flop.

## Lab 3

The combinational logic for the hardware design of a Tic-Tac-Toe game was implemented on a DE1-SoC board
using Varilog and a VGA output module to display the state of the game on a monitor. The game platmore is
shown on the monitor where one controls the moves from the DE1-SoC push buttons. The code was tested
using a testbench.

## Lab 4

A state machine was designed in Verilog and connected to one of the seven segment LEDs on the DE1-SoC.
The system cycles through and displays the first five digits of a number. The clock input to the state
machine comes from a pushbutton. The direction of cycling through the digits can be changed using a
slider switch on the board and can be changed during any cycle.

## Lab 5

A datapath was built for a state machien using registers, flip flops, and Mux to set control signals.
The datapath consists of 4 Cycles. In Cycle 1, the value of in Register R3 is stored in register RB.
In Cycle 2, the value in Register R5 is stored in Register RA. In Cycle 3, The sum of Registers R3
and R5 are loaded in Register RC using two Muxs and an ALU. In the final Cycle 4, the Sum of R3 and
R5 is written to Register R2 and displayed on the 7 segment display of the DE1 SoC. We may now begin
a new operation using the new computed value.

## Lab 6

A controller was added to the Lab 5 code to automate setting control signals.An instruction
register was implemented, enabling support for adding different register together. The state
machine now supports two new "Move Instructions" and four new "ALU Instructions". A 16 bit signal
first passes through an instruction Register before the Instruction Decoder, State Machine, and
Dataphath from Lab 5.

## Lab 7

The datapath and finite-state machine controller from lab 6 was extended to include a Read-Write Memory
RAM to hold instructions. Two more instructions (LDR and STR) were added in order to use this same memory
to hold data. The interface to memory was extended to enable communication with the outside world using
memory mapped I/O. 

## Lab 8

Two types of conditional branch instructions were added to complete the Simple RISC Machine. Branching
instructions implemented included B, BEQ, BNE, BLT, BLE, and BX, and BLX. Support for function calls
and returns was added using the Branch and link BL instruction and other instructions such as BX and BLX.
This code was submitted in the Lab 8 class competition for fastest RISC Machine design and placed 14th out
of 80 teams.
 
## Lab 9

This lab provides an introduction to writing in ARM Assembly code using the ARM Cortex-A9 built into the 
Cyclone V FPGA on your DE1-SoC. A recursive binary search function was implemented in ARM assembly code
using the branch and link instruction BL and the stack to save registers used by the caller.

## Lab 10

In this lab, efficient interaction with I/O devices were supported by writing interrupt service routines
for the ARM processor in the DE1-SoC. ARM's Generic Interrupt Controller, ARM processor modes, and
masking of interrupts were explored. A periodic timer ISR was then added to increment a counter and
display its value on the read LEDs. A keyboard ISR was also implemented for the ARM Cortex-A9 processor
to respond to the keyboard. The keyboard ISR was triggered when pressing a key while the mouse cursor
was in the terminal window. The character is read by the ARM processor and sent to the Altera Monitor
Program using the JTAG UART and displayed in the terminal window. Premptive Multitasking was also
implemented to allow a single processor to run multiple programs.

## Lab 11

This lab explored factors that impact program performance with a focus on the L1 data cache. CPU
performance was analysed using hardware counter registers configured to measure the occurance of
certain events. Such events included Level 1 data cache misses, number of load instructions executed,
and CPU cycles using registers PMSELF, PMXETYPER, PMCNTENSET, PMCR and PMXEVCNTR. A Matrix multiplication
program was created, saving the result of the multiplication of matrix A and B into a two dimensional
C array stored in memory. A blocked Matrix Multiply was later added to help improve performance by ensuring
values are used multiple times after they are brought into the cache.

