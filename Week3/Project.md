
---

<h1 align="center">🏗️ Yosys Synthesis Flow using IHP SG13G2 PDK 🏗️</h1>
<p align="center">
  <b>Gate-Level Synthesis Report for VSDBabySoC</b><br>
  🔬 <i>Featuring PLL and DAC Integration using IHP SG13G2 Standard Cell Library</i>
</p>

---

## 🧠 Overview

This guide documents the **RTL-to-Gate-Level Synthesis** of `VSDBabySoC` using **Yosys** and **IHP SG13G2** (130 nm CMOS) standard cell library.
It covers library loading, RTL synthesis, ABC mapping, post-processing, and final netlist generation — along with synthesis results.

---
---
### 🛠️ How to Reproduce

To reproduce the synthesis and GLS workflow with **IHP PDK**, follow these steps:

1. **Prepare the Source Folder** 📂

   * Navigate to the `week3/code` folder.
   * Inside, locate the `src` folder.
   * Replace its contents with the **BabySoC source files** from this repository.
---
## ⚙️ Step-by-Step Yosys Flow

### 🔹 1️⃣ Load IHP Standard Cell Libraries

```tcl
read_liberty -lib /home/iraj/VLSI/VSDBabySoC/src/lib/avsdpll.lib        # PLL cell library
read_liberty -lib /home/iraj/VLSI/VSDBabySoC/src/lib/avsddac.lib        # DAC cell library
read_liberty -lib /home/iraj/esimMarathon/VSDBabySoC/src/lib/ihp13g2_stdcell_typ_1p20V_25C.lib
```

---

### 🔹 2️⃣ Read Design Sources

```tcl
read_verilog /home/iraj/esimMarathon/VSDBabySoC/src/module/vsdbabysoc.v
read_verilog -I /home/iraj/esimMarathon/VSDBabySoC/src/include \
              /home/iraj/esimMarathon/VSDBabySoC/src/module/rvmyth.v
read_verilog -I /home/iraj/esimMarathon/VSDBabySoC/src/include \
              /home/iraj/esimMarathon/VSDBabySoC/src/module/clk_gate.v
read_verilog /home/iraj/esimMarathon/VSDBabySoC/src/module/avsddac.v
read_verilog /home/iraj/esimMarathon/VSDBabySoC/src/module/avsdpll.v
```

---

### 🔹 3️⃣ Generic Synthesis

```tcl
synth -top vsdbabysoc
dfflibmap -liberty /home/iraj/esimMarathon/VSDBabySoC/src/lib/ihp13g2_stdcell_typ_1p20V_25C.lib
opt
```

---

### 🔹 4️⃣ Logic Optimization (ABC Mapping)

```tcl
abc -liberty /home/iraj/esimMarathon/VSDBabySoC/src/lib/ihp13g2_stdcell_typ_1p20V_25C.lib \
    -script +strash;scorr;ifraig;retime;{D};strash;dch,-f;map,-M,1,{D}
```

---

### 🔹 5️⃣ Post-Processing

```tcl
flatten
setundef -zero
clean -purge
rename -enumerate
```

---

### 🔹 6️⃣ Output Netlist and Reports

```tcl
stat
write_verilog -noattr /home/iraj/esimMarathon/VSDBabySoC/output/post_synth_sim/vsdbabysoc_ihp.synth.v
```

---

## 📊 Synthesis Results Summary

### 🔸 Step 7.25 — Printing Statistics

| Module         | Wires | Wire Bits | Ports | Cells    | Notes                         |
| -------------- | ----- | --------- | ----- | -------- | ----------------------------- |
| **clk_gate**   | 5     | 5         | 5     | 0        | Gating logic                  |
| **rvmyth**     | 3948  | 6635      | 3     | **5165** | Includes 962 SDFFE_PP0P cells |
| **vsdbabysoc** | 9     | 18        | 7     | 3        | Top-level with DAC, PLL, CPU  |

**Hierarchy:**

```
vsdbabysoc
 └── rvmyth
     └── clk_gate × 7
```

**Total:**

* **Wires:** 3992
* **Wire bits:** 6688
* **Cells:** 5160
* **Main primitives:** AND/OR/NAND/NOR/XOR/XNOR, Flip-flops, and Analog IPs

---

### 🔸 Step 10.2.2 — ABC Mapping Results

| Cell Type         | Count | Cell Type            | Count |
| ----------------- | ----- | -------------------- | ----- |
| sg13g2_or2_2      | 2     | sg13g2_mux2_2        | 6     |
| sg13g2_and4_2     | 1     | sg13g2_or4_2         | 1     |
| sg13g2_nor4_1     | 79    | sg13g2_a221oi_1      | 53    |
| sg13g2_a22oi_1    | 307   | sg13g2_nand4_1       | 104   |
| sg13g2_xnor2_1    | 91    | sg13g2_xor2_1        | 37    |
| sg13g2_and3_1     | 5     | sg13g2_nand3b_1      | 7     |
| sg13g2_nor3_1     | 43    | sg13g2_nand2b_1      | 38    |
| sg13g2_nand3_1    | 55    | sg13g2_nor2b_1       | 84    |
| sg13g2_and2_2     | 2     | sg13g2_a21o_1        | 47    |
| sg13g2_nand2_1    | 300   | sg13g2_o21ai_1       | 1247  |
| sg13g2_a21oi_1    | 1220  | sg13g2_inv_1         | 752   |
| sg13g2_nor2_1     | 608   | **Internal signals** | 4774  |
| **Input signals** | 1225  | **Output signals**   | 1173  |

🧠 **ABC completed mapping successfully**
→ **Total standard cells used:** *≈ 5900*

---

### 🔸 Step 13 — Final Statistics (Post-Mapping)

| Metric          | Count    |
| --------------- | -------- |
| **Total Wires** | 4794     |
| **Wire Bits**   | 6268     |
| **Ports**       | 7        |
| **Cells**       | **5978** |

#### 🔹 Cell Breakdown

| Cell            | Count | Cell           | Count |
| --------------- | ----- | -------------- | ----- |
| sg13g2_dfrbpq_1 | 1144  | sg13g2_inv_1   | 748   |
| sg13g2_o21ai_1  | 1119  | sg13g2_a21oi_1 | 1092  |
| sg13g2_a22oi_1  | 307   | sg13g2_nor2_1  | 604   |
| sg13g2_nand2_1  | 299   | sg13g2_nor4_1  | 79    |
| sg13g2_xnor2_1  | 91    | sg13g2_xor2_1  | 37    |
| sg13g2_nand3_1  | 55    | sg13g2_a21o_1  | 47    |
| avsddac         | 1     | avsdpll        | 1     |

✅ **Final mapped netlist**:
`vsdbabysoc_ihp.synth.v`

---

## 🧪 Post-Synthesis Simulation Command

```bash
iverilog -o /home/iraj/esimMarathon/VSDBabySoC/output/post_synth_sim/post_synth_sim_ihp.out \
  -DPOST_SYNTH_SIM -DFUNCTIONAL -DUNIT_DELAY=#1 \
  -I /home/iraj/esimMarathon/VSDBabySoC/src/include \
  -I /home/iraj/esimMarathon/VSDBabySoC/src/module \
  /home/iraj/esimMarathon/VSDBabySoC/src/module/testbench.v
vvp /home/iraj/esimMarathon/VSDBabySoC/output/post_synth_sim/post_synth_sim_ihp.out
```

---

## 📦 Final Output Files

| File                     | Description                                   |
| ------------------------ | --------------------------------------------- |
| `vsdbabysoc_ihp.synth.v` | Gate-level netlist mapped to IHP SG13G2 cells |
| `post_synth_sim_ihp.out` | Compiled simulation output                    |
| `yosys.log`              | Yosys synthesis and mapping report            |
| `stat.rpt`               | Summary of hierarchy and cell usage           |

---

## 🧭 Notes

* The synthesis used **IHP SG13G2 (1.2 V, 25 °C)** typical corner.
* DAC (`avsddac`) and PLL (`avsdpll`) are treated as **black-box analog macros**.
* `rvmyth` contributes > 90 % of the total standard cells.
* Use the same `.lib` files in **OpenSTA** for accurate timing analysis.

---

## ⚙️ Current Update

During the synthesis and integration of the **BabySoC** design using the **IHP PDK**, the **Gate-Level Simulation (GLS)** stage ❌ **did not execute successfully**.
After careful analysis 🔍, I found that the failure occurred due to the **absence of PLL and DAC libraries** in the **IHP-supported `.lib` format**.

The synthesis flow currently includes the following lines:

```tcl
read_liberty -lib /home/iraj/VLSI/VSDBabySoC/src/lib/avsdpll.lib        # PLL cell library
read_liberty -lib /home/iraj/VLSI/VSDBabySoC/src/lib/avsddac.lib        # DAC cell library
```

These libraries belong to the **Sky130 (AVSD)** ecosystem 🧱, and are therefore **incompatible with the IHP standard cell** environment ⚠️.
As a result, **Yosys** could not correctly map the PLL and DAC instances during the **technology mapping** phase, leading to the GLS process failure.

---

### 🚀 Future Direction

To ensure a successful GLS flow under the IHP PDK, I plan to:

* 🧩 Develop or obtain **IHP-compatible `.lib` models** for both the PLL and DAC modules.
* 🔗 Integrate these libraries into the synthesis flow for proper cell mapping.
* ✅ Re-run **functional and timing validation** for the complete SoC under IHP conditions.

---

### 📘 Summary of Findings

The GLS failure was not due to design or synthesis issues but rather due to **library format incompatibility** between the **AVSD (Sky130)** and **IHP** ecosystems. Future updates will focus on bridging this gap for full SoC verification.









