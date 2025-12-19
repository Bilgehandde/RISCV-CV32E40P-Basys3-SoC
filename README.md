# 🛡️ Custom RISC-V SoC: Autonomous AXI4-Lite Boot & Memory Management Design

## 📝 Project Overview
This repository features a robust System-on-Chip (SoC) integration built around the **CV32E40P (RISC-V)** core. The primary focus of this design is the implementation of an autonomous boot sequence using a **Custom AXI4-Lite DMA Master**. This engine bridge external non-volatile storage (QSPI Flash) to high-speed internal Instruction RAM (BRAM), enabling a reliable and self-contained system startup.

---

## 🏗️ Hardware Architecture & Design Highlights

### 1. Custom AXI4-Lite DMA Controller (FSM-Based)
Rather than utilizing standard library IPs, I developed a specialized **DMA Controller** from the ground up to ensure precise control over the boot-up phase.
* **Persistent Handshaking:** The FSM is engineered to maintain `VALID` signals on the AXI bus until a hardware `READY` is asserted. bu mekanizma, yüksek gecikmeli interconnect yapılarında bile veri kaybını önler.
* **Signature-Based Logic:** The DMA monitors the data stream for a specific **"Magic Number"** (`0xBDEDE000`). Once detected, the DMA automatically completes the transfer and asserts the `cpu_fetch_enable` signal to wake the processor.
* **Hardware Autonomy:** The DMA independently manages source (QSPI) and destination (IMem) addressing, allowing the CPU to remain in a low-power wait state during the memory population process.

### 2. Strategic Memory Mapping
The SoC architecture defines a multi-stage memory map to optimize execution speed:
* **Boot ROM (0x0000):** Executes the initial hardware reset vectors and jump logic.
* **QSPI Flash (0x2000):** Acts as the primary application storage where the firmware resides.
* **Instruction RAM (0x4000):** A dedicated BRAM space where the DMA mirrors the code for single-cycle execution by the RISC-V core.

---

## 🧪 Verification & Simulation (Self-Check Testbench)
The design has been rigorously validated through a comprehensive **Self-Checking Testbench** environment:
* **Boot Flow Verification:** The simulation environment confirms the precise detection of the stop signature and the subsequent activation of the CPU.
* **PC Jump Monitoring:** I have verified the **Program Counter (PC)** transition, showing a seamless jump from the Boot ROM address (`0x0000`) to the application entry point at `0x4000`.
* **Protocol Analysis:** AXI transactions between the Master (DMA) and Slave (BRAM) were monitored to ensure full compliance with the AXI4-Lite standard during the data migration phase.

---

## 🚀 Future Roadmap (Technical Requirements Alignment)
* **Milestone 3: Peripheral Integration:** Implementing AXI-based **GPIO (32-bit)**, **Timer**, and **I2C Master (400 kHz)** peripherals as defined in the technical rules.
* **Milestone 4: LDPC Hardware Accelerator:** Developing a **5G NR compliant LDPC Encoder** with dedicated AXI-master capabilities for direct memory access.
* **Milestone 5: UART-Stream Implementation:** Integration of a high-speed UART interface for LDPC data streaming and memory population.
* **Milestone 6: UVM Verification:** Establishing a comprehensive **UVM (Universal Verification Methodology)** environment for the LDPC-AXI interface to report coverage and regression results.

**Author:** Bilgehan Dede
