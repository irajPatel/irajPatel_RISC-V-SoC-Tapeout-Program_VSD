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
| [**Task 0**](Week0/Task0/README.md) | 🛠️ [Tools Installation](Week0/Task0/README.md) — Installed **Iverilog**, **Yosys**, and **gtkWave** | ✅ Done |



### 🌟 Key Learnings from Week 0
- Installed and verified **open-source EDA tools** successfully.  
- Learned about **basic environment setup** for RTL design and synthesis.  
- Prepared the system for upcoming **RTL → GDSII flow experiments**.


Absolutely! Here’s a **Week 1 summary** in the same clean, structured style as your Week 0, covering **Tasks 1–5** from your `Test_Synth.ys` and GLS work.

---

## 📅 Week 1 — RTL Synthesis & Gate-Level Simulation (GLS)

| Task       | Description                                                                                                                                                                       | Status |
| ---------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| **Task 1** | 🔧 [RTL Synthesis — MUX Example](Week1/README.md#-task-1--rtl-synthesis-mux-example) — Loaded `mux_generate.v`, synthesized using **Yosys**, mapped to Sky130 cells, and generated **GLS netlist**             | ✅ Done |
| **Task 2** | 🎯 [Constant DFF Mapping & GLS](Week1/README.md#-task-2--constant-dff-mapping--gls) — Synthesized `const4.v` and `const5.v`, mapped constant-driven DFFs, and validated functionality using **Icarus Verilog** | ✅ Done |
| **Task 3** | 💻 [MUX Using `for-generate`](Week1/README.md#-task-3--mux-using-for-generate) — Simulated and synthesized multiplexer with `for-generate`, verified RTL vs GLS match                                       | ✅ Done |
| **Task 4** | 💻 [DEMUX Using `generate`](Week1/README.md#-task-4--demux-using-generate) — Synthesized and simulated DEMUX using generate constructs, verified RTL vs GLS outputs                                       | ✅ Done |
| **Task 5** | ➕ [Ripple Carry Adder (RCA) Synthesis & GLS](Week1/README.md#-task-5--ripple-carry-adder-rca) — Synthesized and simulated RCA, verified arithmetic correctness in GLS vs RTL                                | ✅ Done |

---

### 🌟 Key Learnings from Week 1

* Learned **loading liberty files** and performing **generic synthesis** in Yosys.
* Understood **flattening, DFF/latch mapping, and ABC-based technology mapping**.
* Observed **GLS outputs match RTL simulations**, confirming functional correctness.
* Explored **`for-generate` and `generate` constructs** for scalable hardware design.
* Synthesized and validated **arithmetic circuits** like RCA using Sky130 cells.
* Gained experience in **Icarus Verilog simulation workflow** (`iverilog → vvp → GTKWave`).

---




## 🙏 Acknowledgment  

I am thankful to [**Kunal Ghosh**](https://github.com/kunalg123) and Team **[VLSI System Design (VSD)](https://vsdiat.vlsisystemdesign.com/)** for the opportunity to participate in the ongoing **RISC-V SoC Tapeout Program**.  

I also acknowledge the support of **RISC-V International**, **India Semiconductor Mission (ISM)**, **VLSI Society of India (VSI)**, and [**Efabless**](https://github.com/efabless) for making this initiative possible.  

## 📈 **Weekly Progress Tracker**

[![Week0](https://img.shields.io/badge/Week%200-Tools%20Setup-success?style=flat-square)](Week0)
![Week 1](https://img.shields.io/badge/Week%201-Coming%20Soon-lightgrey?style=flat-square)
![Week 2](https://img.shields.io/badge/Week%202-Upcoming-lightgrey?style=flat-square)



**🔗 Program Links:**
[![VSD Website](https://img.shields.io/badge/VSD-Official%20Website-blue?style=flat-square)](https://vsdiat.vlsisystemdesign.com/)
[![RISC-V](https://img.shields.io/badge/RISC--V-International-green?style=flat-square)](https://riscv.org/)
[![Efabless](https://img.shields.io/badge/Efabless-Platform-orange?style=flat-square)](https://efabless.com/)





---

