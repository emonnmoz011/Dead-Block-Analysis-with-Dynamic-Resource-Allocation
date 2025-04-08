

# Enhanced Dead Block Analysis with Dynamic Load Balancing and Parallel Execution

## Overview
This project advances the efficiency of dead block detection in C code by implementing dynamic load balancing and parallel execution. It uses Csmith for code generation and Program Markers for instrumentation, compiling the code across multiple versions of GCC and LLVM with various optimization flags to ensure high performance and optimal resource management.

## Key Features
- **Dynamic Load Balancing**: Adjusts the parallel workload based on system load to optimize performance.
- **Parallel Execution**: Utilizes GNU Parallel to manage multiple compilation processes simultaneously.
- **Compiler Variety**: Tests across multiple versions of GCC (9, 10, 11, 12) and LLVM (11, 12, 13, 14) with different optimization flags.
- **Automation Scripts**: Bash scripts automate the entire process from code generation to compilation and analysis.

## Installation Instructions

### Prerequisites
- Linux OS
- Git
- GNU Parallel

### Dependencies
1. **Git**: 
   Install Git using:
   ```bash
   sudo apt update && sudo apt install git

2. **Csmith**:
Installation instructions on the [Csmith GitHub page.](https://github.com/csmith-project/csmith). 

3. **Program Markers**:
Installation instructions are available on the [Program Markers Github Page](https://github.com/DeadCodeProductions/program-markers).

4. **LLVM**: 
   ```bash
   sudo apt install llvm-11 llvm-11-dev llvm-11-tools
   sudo apt install llvm-12 llvm-12-dev llvm-12-tools
   sudo apt install llvm-13 llvm-13-dev llvm-13-tools
   sudo apt install llvm-14 llvm-14-dev llvm-14-tools

5. **GCC**
   ```bash
   sudo apt install gcc-9 gcc-10 gcc-11 gcc-12

After installing all the dependencies, we need to run the scripts separately by varying the number of batches of codes and we will observe the instrumented C code, assembly files the analysis and the execution time
