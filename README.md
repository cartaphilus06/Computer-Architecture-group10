# Vector Processing Unit (VPU) & CPU Acceleration

This repository contains the RTL implementation of a custom Vector Processing Unit (VPU) integrated with a baseline CPU architecture, written entirely in Verilog. The primary goal of this project is to accelerate both scalar and vector computations at the hardware level.

## Performance & Optimization Achievements
During the evaluation and testing phases (via `tb.v`), the modified architecture demonstrated significant performance gains:
* **Scalar/Standard Workloads:** Achieved up to a **4x speedup** for standard, non-vectorized programs through architectural optimizations.
* **Vectorized Workloads:** Attained a **55% performance improvement** when executing fully vectorized instruction streams.

## Hardware Modules
* `VPU_Core.v`: The main control and datapath logic for the Vector Processing Unit.
* `FP_Adder.v`: Floating-Point Adder module designed to handle high-precision arithmetic.
* `main.v`: Top-level integration of the CPU and VPU components.
* `tb.v`: Comprehensive testbench for functional verification and performance benchmarking.

## Languages & Tools
* **Hardware Description Language:** Verilog (100%)
