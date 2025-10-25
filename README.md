# 🖥️ RISC-V Reference SoC Tapeout Program VSD
<div align="center">

[![RISC-V](https://img.shields.io/badge/RISC--V-SoC%20Tapeout-blue?style=for-the-badge&logo=riscv)](https://riscv.org/)
[![VSD](https://img.shields.io/badge/VSD-Program-orange?style=for-the-badge)](https://vsdiat.vlsisystemdesign.com/)
![Participants](https://img.shields.io/badge/Participants-3500+-success?style=for-the-badge)
![India](https://img.shields.io/badge/Made%20in-India-saffron?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjI0IiBoZWlnaHQ9IjgiIGZpbGw9IiNGRjk5MzMiLz4KPHJlY3QgeT0iOCIgd2lkdGg9IjI0IiBoZWlnaHQ9IjgiIGZpbGw9IiNGRkZGRkYiLz4KPHJlY3QgeT0iMTYiIHdpZHRoPSIyNCIgaGVpZ2h0PSI4IiBmaWxsPSIjMTM4ODA4Ii8+Cjwvc3ZnPgo=)

</div>


Welcome to my journey through the **SoC Tapeout Program VSD**!  
This repository documents my **week-by-week progress** with tasks inside each week.  

"In this program, we learn to design a System-on-Chip (SoC) from basic RTL to GDSII using open-source tools. Part of India’s largest collaborative RISC-V tapeout initiative, empowering 3500+ participants to build silicon and advance the nation’s semiconductor ecosystem

---

## 📅 Week 0 — Setup & Tools

| Task | Description | Status |
|------|-------------|---------|
| [**Task 0**](Week0/README.md) | 🛠️ [Tools Installation](Week0/README.md) — Installed **Iverilog**, **Yosys**, and **gtkWave** | ✅ Done |



### 🌟 Key Learnings from Week 0
- Installed and verified **open-source EDA tools** successfully.  
- Learned about **basic environment setup** for RTL design and synthesis.  
- Prepared the system for upcoming **RTL → GDSII flow experiments**.


---
## 📅 Week 1 — RTL Synthesis & Gate-Level Simulation (GLS)

| Task       | Description                                                                 | Status |
| ---------- | --------------------------------------------------------------------------- | ------ |
| [**Task 1**](Week1/README.md#-task-1--rtl-synthesis-mux-example) | 🔧 MUX synthesis in Yosys, Sky130 mapping, GLS netlist generation         | ✅ Done |
| [**Task 2**](Week1/README.md#-task-2--constant-dff-mapping--gls) | 🎯 Constant DFF mapping (`const4.v`, `const5.v`) + GLS validation          | ✅ Done |
| [**Task 3**](Week1/README.md#-task-3--mux-using-for-generate) | 💻 MUX using `for-generate`, RTL vs GLS verification                       | ✅ Done |
| [**Task 4**](Week1/README.md#-task-4--demux-using-generate) | 💻 DEMUX using `generate`, RTL vs GLS verification                         | ✅ Done |
| [**Task 5**](Week1/README.md#-task-5--ripple-carry-adder-rca) | ➕ Ripple Carry Adder synthesis & GLS validation                           | ✅ Done |




### 🌟 Key Learnings from Week 1

* Learned **Yosys synthesis flow**, RTL vs GLS verification, and scalable Verilog constructs.
* Synthesized arithmetic circuits and optimized designs using ABC and Icarus Verilog with GTKWave.
* [**Solved synthesis error:**](Week1/README.md#-task-3--mux-using-for-generate) Fixed latch mapping by instantiating a SkyWater primitive for simulation.
* [**Applied knowledge:**](Week1/project.md) designed a Verilog Moving Average Filter, synthesized with Yosys, and verified via GLS.
* [**Future work:**](Week1/project.md##-Future-Work) Extend filter designs to higher orders and implement real-time signal processing on FPGA.
---
## 📅 Week 2 — Fundamentals of SoC Design

| Task       | Description | Status |
| ---------- | ----------- | ------ |
| [**Task 1**](Week2/README.md#-fundamentals-of-system-on-chip-soc-design) | 📘 Write-up on SoC fundamentals | ✅ Done |
| [**Task 2**](Week2/README.md#-vsdbabysoc--a-tiny-but-powerful-risc-v-soc) | 📝 VSDBabySoC  | ✅ Done |
| [**Task 3**](Week2/README.md#-the-instruction-program-driving-babysoc) | 📊 Understanding of  RVMYTH core  | ✅ Done |
| [**Task 4**](Week2/README.md#-pre_synth_sim-waveform) | ✍️Pre synthesis Waveform  & explanations | ✅ Done |



### 🌟 Key Learnings from Week 2  

* Gained conceptual understanding of **SoC fundamentals** (CPU, memory, interconnect, peripherals).  
* Learned how **BabySoC** simplifies SoC design concepts and verified its behavior using simulation + GTKWave.
* [**Future Work:**](Week2/README.md#-future-work) Add memory for instruction fetch and enable C programs to be compiled into hex for execution on BabySoC.  



---
## 📅 Week 3 — Advanced SoC Synthesis and Timing Analysis

| Task   | Description                                                                                                                    | Status    |
| ------ | ------------------------------------------------------------------------------------------------------------------------------ | --------- |
| [**Task&nbsp;1**](https://github.com/irajPatel/irajPatel_RISC-V-SoC-Tapeout-Program_VSD/tree/main/Week3#%EF%B8%8F-gate-level-simulation-gls-of-babysoc-%EF%B8%8F) | ⚡ Pre- and Post-Synthesis Simulation for BabySoC using **Sky130 PDK**; compared RTL vs gate-level waveforms                    | ✅ Done    |
| [**Task&nbsp;2**](https://github.com/irajPatel/irajPatel_RISC-V-SoC-Tapeout-Program_VSD/tree/main/Week3#%EF%B8%8F-timing-graphs-using-opensta) | 📝 Short note on **Static Timing Analysis (STA)** and **OpenROAD** flow                                                        | ✅ Done    |
| [**Task&nbsp;3**](https://github.com/irajPatel/irajPatel_RISC-V-SoC-Tapeout-Program_VSD/tree/main/Week3#%EF%B8%8F-vsdbabysoc--basic-timing-analysis-with-opensta) | 📊 Corner timing analysis with **Sky130 PDK corners** (TT, SS, FF); plotted WNS, TNS, worst slack, worst hold, and setup slack | ✅ Done    |
| [**💡&nbsp;Extra&nbsp;Mile**](https://github.com/irajPatel/irajPatel_RISC-V-SoC-Tapeout-Program_VSD/blob/main/Week3/Project.md#%EF%B8%8F-yosys-synthesis-flow-using-ihp-sg13g2-pdk-%EF%B8%8F) | 🔧 Exploring BabySoC synthesis on [**IHP PDK**](https://github.com/IHP-GmbH/IHP-Open-PDK) as a preparatory step for future PDK adaptation | ✅&nbsp;Explored |

### 🌟 Key Learnings from Week 3

* Successfully verified **functional consistency** between RTL and gate-level netlists using **pre- and post-synthesis simulations**, ensuring correct BabySoC operation after technology mapping.
* Gained a practical understanding of **Static Timing Analysis (STA)** and the **OpenROAD flow**, including timing constraints, optimization, and automated ASIC design processes.
* Performed **corner timing analysis** across multiple PDK corners (TT, SS, FF), extracting and interpreting metrics like **WNS, TNS, worst slack, worst hold, and setup slack**, providing insights into timing robustness of the design.
---

## 📅 Week 4 — CMOS Power Supply & Device Variation Robustness

| Task                                                               | Description                                                                                        | Status |
| ------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------- | ------ |
| [**Task&nbsp;1**](https://github.com/irajPatel/irajPatel_RISC-V-SoC-Tapeout-Program_VSD/tree/main/Week4#-task-1--mosfet-behavior-the-current-voltage-chronicles)         | 🔌 Simulate NMOS device, sweep Vds for different Vgs, plot Id vs Vds                               | ✅ Done |
| [**Task&nbsp;2**](https://github.com/irajPatel/irajPatel_RISC-V-SoC-Tapeout-Program_VSD/tree/main/Week4#-task-2--threshold-voltage--velocity-saturation-the-speed-demons)  | 📈 Sweep Vgs vs Id, extract threshold voltage Vt, observe velocity saturation                      | ✅ Done |
| [**Task&nbsp;3**](https://github.com/irajPatel/irajPatel_RISC-V-SoC-Tapeout-Program_VSD/tree/main/Week4#-task-3--the-vtc-quest-finding-the-perfect-balance-point) | 🖥 Build CMOS inverter, sweep Vin, plot Vout vs Vin, identify switching threshold Vm               | ✅ Done |
| [**Task&nbsp;4**](https://github.com/irajPatel/irajPatel_RISC-V-SoC-Tapeout-Program_VSD/tree/main/Week4#-task-4--transient-response-when-time-becomes-critical)               | ⏱ Apply pulse input, extract rise/fall propagation delays                                          | ✅ Done |
| [**Task&nbsp;5**](https://github.com/irajPatel/irajPatel_RISC-V-SoC-Tapeout-Program_VSD/tree/main/Week4#%EF%B8%8F-task-5--noise-margins-the-robustness-test)                  | 🛡 Determine VIL, VIH, VOL, VOH from VTC, compute noise margins (NML, NMH)                         | ✅ Done |
| [**Task&nbsp;6**](https://github.com/irajPatel/irajPatel_RISC-V-SoC-Tapeout-Program_VSD/tree/main/Week4#-task-6-cmos-power-supply--device-variation-robustness)         | ⚡ Vary Vdd and transistor sizing, observe effect on VTC, switching point, noise margins, and delay | ✅ Done |

---

### 🌟 Key Learnings from Week 4

* Explored **transistor-level behavior** under voltage and sizing variations.
* Observed **shifts in switching threshold (Vm)** and corresponding impact on **noise margins**.
* Quantified **rise/fall delays** and how supply variation affects propagation times.
* Understood **robust design principles** for CMOS inverters considering PVT variations.
* Gained insights into how **device physics translates into timing constraints**, relevant for **STA and critical path analysis**.

---

## 📅 Week 5 — OpenROAD Flow Setup & Floorplan + Placement

| Task                                                               | Description                                                                                        | Status |
| ------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------- | ------ |
| [**Task&nbsp;1**](https://github.com/irajPatel/irajPatel_RISC-V-SoC-Tapeout-Program_VSD/tree/main/Week5#-installation--execution-flow)         | 📥 Clone OpenROAD repository, run setup script, and build tools locally                               | ✅ Done |
| [**Task&nbsp;2**](https://github.com/irajPatel/irajPatel_RISC-V-SoC-Tapeout-Program_VSD/tree/main/Week5#step-4%EF%B8%8F%E2%83%A3-verify-installation)  | ✅ Verify installation using Yosys and OpenROAD command-line tools                      | ✅ Done |
| [**Task&nbsp;3**](https://github.com/irajPatel/irajPatel_RISC-V-SoC-Tapeout-Program_VSD/tree/main/Week5#step-5%EF%B8%8F%E2%83%A3-execute-floorplan--placement-%EF%B8%8F) | 📐 Execute Floorplan and Placement stages (stop before routing)               | ✅ Done |
| [**Task&nbsp;4**](https://github.com/irajPatel/irajPatel_RISC-V-SoC-Tapeout-Program_VSD/tree/main/Week5#step-6%EF%B8%8F%E2%83%A3-visualize-results-in-gui-%EF%B8%8F)               | 👁️ Launch GUI to visualize floorplan layout and placed standard cells                                          | ✅ Done |

---

### 🌟 Key Learnings from Week 5

* Transitioned from **transistor-level SPICE** to **physical backend implementation** using OpenROAD.
* Understood how **floorplanning defines chip boundaries** and **placement optimizes cell arrangement**.
* Learned to use **open-source EDA tools** for RTL-to-GDSII automation flow.
* Recognized how **physical layout impacts timing** - connecting Week 4's delay analysis to real silicon.

---










## 🙏 Acknowledgment  

I am thankful to [**Kunal Ghosh**](https://github.com/kunalg123) and Team **[VLSI System Design (VSD)](https://vsdiat.vlsisystemdesign.com/)** for the opportunity to participate in the ongoing **RISC-V SoC Tapeout Program**.  

I also acknowledge the support of **RISC-V International**, **India Semiconductor Mission (ISM)**, **VLSI Society of India (VSI)**, and [**Efabless**](https://github.com/efabless) for making this initiative possible.  

## 📈 **Weekly Progress Tracker**
<!-- Completed Weeks - All Green -->
[![Week0](https://img.shields.io/badge/📦_Week_0-Tools_Setup-10b981?style=for-the-badge&logo=windows-terminal&logoColor=white)](Week0)
[![Week1](https://img.shields.io/badge/⚡_Week_1-RTL_GLS-10b981?style=for-the-badge&logo=altium-designer&logoColor=white)](Week1/README.md)
[![Week2](https://img.shields.io/badge/🔧_Week_2-SoC_VSDBaby-10b981?style=for-the-badge&logo=microchip&logoColor=white)](Week2/README.md)
[![Week3](https://img.shields.io/badge/⏱️_Week_3-SoC_STA-10b981?style=for-the-badge&logo=clockify&logoColor=white)](Week3/README.md)
[![Week4](https://img.shields.io/badge/🔬_Week_4-CMOS_Spice-10b981?style=for-the-badge&logo=atom&logoColor=white)](https://github.com/irajPatel/irajPatel_RISC-V-SoC-Tapeout-Program_VSD/blob/main/Week4/README.md)
[![Week5](https://img.shields.io/badge/🛣️_Week_5-Open_ROAD-10b981?style=for-the-badge&logo=openstreetmap&logoColor=white)](https://github.com/irajPatel/irajPatel_RISC-V-SoC-Tapeout-Program_VSD/blob/main/Week5/README.md)

<!-- Upcoming Weeks - All Grey -->
![Week6](https://img.shields.io/badge/🔒_Week_6-Upcoming-6c757d?style=for-the-badge&logo=hourglass&logoColor=white)
![Week7](https://img.shields.io/badge/🔒_Week_7-Upcoming-6c757d?style=for-the-badge&logo=hourglass&logoColor=white)
![Week8](https://img.shields.io/badge/🔒_Week_8-Upcoming-6c757d?style=for-the-badge&logo=hourglass&logoColor=white)
![Week9](https://img.shields.io/badge/🔒_Week_9-Upcoming-6c757d?style=for-the-badge&logo=hourglass&logoColor=white)
![Week10](https://img.shields.io/badge/🔒_Week_10-Upcoming-6c757d?style=for-the-badge&logo=hourglass&logoColor=white)


**🔗 Program Links:**
[![VSD Website](https://img.shields.io/badge/VSD-Official%20Website-blue?style=flat-square)](https://vsdiat.vlsisystemdesign.com/)
[![RISC-V](https://img.shields.io/badge/RISC--V-International-green?style=flat-square)](https://riscv.org/)
[![Efabless](https://img.shields.io/badge/Efabless-Platform-orange?style=flat-square)](https://efabless.com/)





---

