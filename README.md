# FPGA AXI-Based BRAM Data Processing Unit

This repository contains an FPGA design utilizing **SystemVerilog** to implement an AXI-based data processing pipeline. The system interacts with Block RAM (BRAM) to perform arithmetic operations and storage.

Due to the complex file structure, the project sources are provided in an **archived `.zip` file**.

## 🚀 Project Overview

The core functionality of this project is to manage data flow between the processor logic and memory using the AXI protocol.

### ⚙️ System Operation (Workflow)
The design performs the following cycle:
1.  **Fetch (Read):** Retrieves data from Block RAM (initialized via `.coe` files) using the AXI Read Channel.
2.  **Process (Execute):** Performs arithmetic operations (**Addition**) on the fetched data.
3.  **Store (Write):** Writes the calculated result back to a target memory address or register using the AXI Write Channel.

### Key Features
* **AXI Master/Slave Interface:** Robust protocol implementation for memory transactions.
* **BRAM Integration:** Efficient memory usage with pre-loaded coefficient files (`.coe`).
* **Data Path Logic:** Dedicated logic for reading, summing, and storing data.
* **SystemVerilog Design:** Modular and synthesizable code structure.

## 📂 Installation & Usage

1.  **Download & Extract:** Download the `.zip` file and extract it.
2.  **Vivado Setup:** Open the `.xpr` file or create a new project adding the files from the `srcs` folder.
3.  **IP Configuration:** Ensure the Block Memory Generator points to the correct `.coe` file path for initialization.

## 🛠 Tech Stack
* **Language:** SystemVerilog / Verilog
* **IDE:** Xilinx Vivado
* **Protocol:** AXI4 / AXI-Lite
---
*Developed by [Bİlgehan Dede]*
