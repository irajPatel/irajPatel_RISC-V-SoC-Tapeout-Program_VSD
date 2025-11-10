

# 🧠 OpenLANE VLSI Design Flow – Complete Practical Guide

> **A step-by-step cheat sheet + reference for OpenLANE RTL-to-GDSII flow using Sky130 PDK**
> Perfect for interview prep and real project debugging.

---

## 📘 Table of Contents

* [🧩 Environment Setup](#-environment-setup)
* [⚙️ OpenLANE Interactive Flow](#️-openlane-interactive-flow)
* [🏗️ Synthesis & Floorplanning](#-synthesis--floorplanning)
* [📦 Placement](#-placement)
* [🌳 Clock Tree Synthesis (CTS)](#-clock-tree-synthesis-cts)
* [🛣️ Routing & DRC](#️-routing--drc)
* [📐 Magic & Layout Visualization](#-magic--layout-visualization)
* [📊 Static Timing Analysis (OpenSTA)](#-static-timing-analysis-opensta)
* [🧮 Parasitic Extraction & LVS](#-parasitic-extraction--lvs)
* [💾 GDSII Generation](#-gdsii-generation)
* [🧰 Troubleshooting & Tips](#-troubleshooting--tips)
* [📚 File Format Reference](#-file-format-reference)
* [⚡ Quick Reference Commands](#-quick-reference-commands)

---

## 🧩 Environment Setup

### 🔧 Setting Up OpenLANE Docker

```bash
sudo docker run -it --rm \
  -v /home/iraj/VLSI/openlane_working_dir/openlane:/openLANE_flow \
  -v /home/iraj/VLSI/openlane_working_dir/openlane/pdks:/home/iraj/VLSI/openlane_working_dir/openlane/pdks \
  -e PDK_ROOT=/home/iraj/VLSI/openlane_working_dir/openlane/pdks \
  -u 0:0 efabless/openlane:v0.15
```

💡 **Purpose:** Launches OpenLANE container with Sky130 PDK mounted.
🧠 Always verify `$PDK_ROOT` path before launch.

---

## ⚙️ OpenLANE Interactive Flow

### Start the Flow

```bash
./flow.tcl -interactive
package require openlane 0.9
```

### Prepare Your Design

```tcl
prep -design picorv32a -tag 04-07_04-38 -overwrite
```

* `-design`: design folder name
* `-tag`: run timestamp label
* `-overwrite`: replace existing run if it exists

---

## 🏗️ Synthesis & Floorplanning

### 🧠 Synthesis Commands

```tcl
set ::env(SYNTH_STRATEGY) "AREA 1"
set ::env(SYNTH_MAX_FANOUT) 4
run_synthesis
```

🔹 Use `"DELAY 0"` for performance, `"AREA 1"` for compact layout.
🔹 Check results in:
`results/synthesis/` → `*.synthesis.v`, `*.stat.rpt`

---

### 🧱 Floorplanning Steps

```tcl
init_floorplan
place_io
tap_decap_or
```

**Key Switches:**

| Variable          | Description        | Typical |
| ----------------- | ------------------ | ------- |
| `FP_CORE_UTIL`    | Core utilization   | 50–70%  |
| `FP_ASPECT_RATIO` | Height/Width ratio | 1.0     |
| `FP_IO_MODE`      | I/O placement mode | 1       |

---

## 📦 Placement

```tcl
run_placement
```

🧩 **Output:** `results/placement/picorv32a.placement.def`
🔍 **Use:** Check cell distribution and overlap before CTS.

---

## 🌳 Clock Tree Synthesis (CTS)

```tcl
run_cts
```

**Key CTS Variables**

```tcl
echo $::env(CTS_CLK_BUFFER_LIST)
```

To modify buffer list:

```tcl
set ::env(CTS_CLK_BUFFER_LIST) [lreplace $::env(CTS_CLK_BUFFER_LIST) 0 0]
```

📁 Results:
`results/cts/picorv32a.cts.def`
`reports/cts/cts.rpt`

---

## 🛣️ Routing & DRC

### Run Power Distribution Network

```tcl
gen_pdn
```

### Detailed Routing

```tcl
run_routing
```

📁 Output:

```
results/routing/picorv32a.def
reports/routing/drc.rpt
```

### Run DRC Check in Magic

```bash
magic -T sky130A.tech lef read ../../tmp/merged.lef def read picorv32a.def
drc check
drc count
drc why
```

💡 **Tip:** Fix common spacing or enclosure errors before exporting GDS.

---

## 📐 Magic & Layout Visualization

### Open DEF in Magic

```bash
cd runs/04-07_04-38/results/placement
magic -T /pdks/sky130A/libs.tech/magic/sky130A.tech \
  lef read ../../tmp/merged.lef \
  def read picorv32a.placement.def &
```

### Explore Layout

Inside Magic console:

```bash
expand
select top cell
what
box
```

**Zoom shortcuts:**
`z` = zoom in | `Shift+Z` = zoom out | `Ctrl+LeftClick` = select cell

---

## 📊 Static Timing Analysis (OpenSTA)

### Open OpenROAD

```bash
openroad
```

### Load Design

```tcl
read_lef ../../tmp/merged.lef
read_def results/cts/picorv32a.cts.def
read_verilog results/synthesis/picorv32a.synthesis_cts.v
link_design picorv32a
```

### Load Libraries

```tcl
read_liberty -max $::env(LIB_SLOWEST)
read_liberty -min $::env(LIB_FASTEST)
```

### Load Constraints

```tcl
read_sdc src/my_base.sdc
set_propagated_clock [all_clocks]
```

### Generate Timing Reports

```tcl
report_checks -path_delay min_max -digits 4
report_clock_tree
report_power
report_worst_slack
```

---

## 🧮 Parasitic Extraction & LVS

### SPEF Extraction (Parasitics)

```tcl
extract_parasitics -spef results/routing/picorv32a.spef
report_net -capacitance
```

### Run LVS using Netgen

```bash
netgen -batch lvs \
  "layout.spice layout" \
  "schematic.spice schematic" \
  sky130A_setup.tcl \
  report_lvs.txt
```

✅ Checks layout vs schematic connectivity
📄 Output: `report_lvs.txt`

---

## 💾 GDSII Generation

```tcl
run_magic_drc
run_magic_spice_export
run_magic_gds
run_klayout_gds
```

🧱 **Output:**

* `results/magic/picorv32a.gds`
* `results/magic/picorv32a.spice`

### View in KLayout

```bash
klayout results/magic/picorv32a.gds &
```

---

## 🧰 Troubleshooting & Tips

| Issue                               | Cause                     | Solution                      |
| ----------------------------------- | ------------------------- | ----------------------------- |
| `ENOENT: no such file or directory` | Wrong PDK or path         | Verify `$PDK_ROOT`            |
| Magic DRC errors                    | Overlap or spacing issues | `drc why` → fix coordinates   |
| Setup/Hold violations               | Improper CTS              | Re-tune CTS buffer list       |
| Slow synthesis                      | High fanout               | Set `SYNTH_MAX_FANOUT` = 4    |
| DEF not loading                     | Missing merged.lef        | Re-run floorplan or merge_lef |

---

## 📚 File Format Reference

| File    | Type                        | Description                  |
| ------- | --------------------------- | ---------------------------- |
| `.lef`  | Library Exchange Format     | Macro geometry & layers      |
| `.def`  | Design Exchange Format      | Placement/routing data       |
| `.v`    | Verilog                     | Gate-level netlist           |
| `.sdc`  | Synopsys Design Constraints | Timing definitions           |
| `.lib`  | Liberty                     | Cell timing models           |
| `.mag`  | Magic                       | Layout view                  |
| `.spef` | Parasitic Extraction        | RC data                      |
| `.gds`  | GDSII                       | Final layout for fabrication |

---

## ⚡ Quick Reference Commands

| Stage      | Command                    | Tool        |
| ---------- | -------------------------- | ----------- |
| Synthesis  | `run_synthesis`            | Yosys       |
| Floorplan  | `init_floorplan`           | OpenROAD    |
| Placement  | `run_placement`            | RePlAce     |
| CTS        | `run_cts`                  | TritonCTS   |
| PDN        | `gen_pdn`                  | OpenROAD    |
| Routing    | `run_routing`              | TritonRoute |
| DRC        | `run_magic_drc`            | Magic       |
| GDS Export | `run_magic_gds`            | Magic       |
| STA        | `openroad → report_checks` | OpenSTA     |
| LVS        | `netgen lvs`               | Netgen      |

---

## 💡 Pro Tips for Interviews

🧩 Mention that you:

* Understand **RTL-to-GDSII** flow stages
* Use **OpenROAD** for placement, CTS, and STA
* Validate with **Magic** (DRC) and **Netgen** (LVS)
* Know how to interpret **timing reports and violations**

🗂️ Always mention your project directory hierarchy and use of **Sky130 PDK**.

---

**🧠 Made with ❤️ for VLSI Enthusiasts & Interview Prep**
📅 *Last Updated: October 2025*
✉️ *Author: Ravi Patel*

---

Would you like me to make this visually styled with **icons, code color highlights, and collapsible `<details>` sections** (like a modern GitHub-style study guide)? It’ll look perfect for your portfolio or interview notes.
