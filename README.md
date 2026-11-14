# IBEX-Decoder-Register-File-ALU
IBEX RISC-V Decoder and ALU
Project Overview
This project focuses on the design and implementation of a simplified RISC-V processor subsystem inspired by the IBEX architecture. It implements instruction decoding, register file operations, and ALU functionality using Verilog/SystemVerilog.
The design supports basic R-type arithmetic and logical instructions, including ADD, SUB, AND, OR, and XOR. The functionality is verified through simulation using Cadence Xcelium and waveform analysis using SimVision.
Objectives

Understand the basic RISC-V instruction format.
Design an instruction decoder using SystemVerilog.
Implement a 32-bit register file.
Perform arithmetic and logical operations.
Verify the design using a SystemVerilog testbench.
Explore RTL synthesis using Cadence Genus.

Supported Instructions

Instruction
Operation




ADD
Addition


SUB
Subtraction


AND
Bitwise AND


OR
Bitwise OR


XOR
Bitwise XOR



Architecture
The design consists of three main components:
1. Instruction Decoder

Identifies the instruction using the opcode.
Decodes the funct3 and funct7 fields.
Generates the required ALU control signals.
Determines register read and write control signals.

2. Register File

Contains 32 registers, each 32 bits wide.
Supports two asynchronous read ports.
Supports one synchronous write port.
Register x0 is hardwired to zero.

3. ALU

Performs arithmetic and logical operations.
Supports ADD, SUB, AND, OR, and XOR.
Produces a 32-bit result based on the decoded ALU control signal.

Tools and Technologies

Verilog / SystemVerilog
Cadence Xcelium – RTL Simulation
Cadence SimVision – Waveform Analysis
Cadence Genus – RTL Synthesis (planned)
Linux Environment


Adjust the filenames and folders to match your actual repository.
Verification
The design is verified using a SystemVerilog testbench in Cadence Xcelium.
The testbench checks:

Register write operations.
Register read operations.
ADD operation.
SUB operation.
AND operation.
OR operation.
XOR operation.
Zero-register (x0) functionality.

Simulation waveforms are inspected using Cadence SimVision.
Expected Results
The design successfully performs the supported arithmetic and logical operations. The testbench verifies the register file, instruction decoding, and ALU functionality.
Future Scope

Extend support to additional RISC-V instructions.
Integrate immediate-type instructions.
Implement branch and load/store instructions.
Explore synthesis and area/timing analysis using Cadence Genus.
Extend the design towards a more complete RISC-V processor.

Author
Nagaraj Narayana
Electronics and Communication Engineering
Acknowledgment
This project is developed as part of learning and exploring RISC-V processor architecture, RTL design, and digital hardware verification.
