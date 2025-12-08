# FPGA AXI Interface & Memory Integration Project

This repository contains an FPGA project developed using **SystemVerilog**, focusing on memory and peripheral integration via the **AXI protocol**.

Due to the large number of source files and Vivado directory structure, the project is provided as an **archived `.zip` file**.

## 🚀 Project Overview

The primary goal of this project is to implement the AXI (Advanced eXtensible Interface) protocol for efficient data transfer and to demonstrate memory initialization using `.coe` files.

### Key Features
* **AXI Integration:** Implementation of AXI Master/Slave interfaces for robust data transfer control.
* **Memory Initialization:** Utilization of `.coe` (Coefficient) files to pre-load data into Block RAM/ROM structures.
* **SystemVerilog Design:** Modular, readable, and synthesizable `.sv` code structure.
* **Vivado Compatibility:** Designed and tested within the Xilinx Vivado environment.

## 📂 Installation & Usage

Since the project is uploaded as a `.zip` archive, please follow these steps to view or run the code:

1.  **Download:** Download the project `.zip` file from this repository.
2.  **Extract:** Unzip the contents to a local directory on your computer.
3.  **Open in Vivado:**
    * Open the `.xpr` project file (if included).
    * *Alternatively:* Create a new Vivado project and add the `.sv` files located in the `srcs` folder as design sources.
4.  **IP Core Configuration:**
    * **Important:** If you are regenerating the Block Memory Generator IP, ensure the path to the `.coe` file is updated to match your local directory structure.

## 🛠 Tech Stack

* **Language:** SystemVerilog / Verilog
* **IDE:** Xilinx Vivado
* **Hardware:** [Insert Board Model Here, e.g., Basys 3 / Nexys A7]
* **Protocols:** AXI4 / AXI-Lite

## ⚠️ Notes

* The archive includes the source code (`.srcs` directory) and necessary memory initialization files (`.coe`).
* Ensure that all IP Output Products are generated before running the simulation.

---
*Developed by [Bilgehan Dede]*
