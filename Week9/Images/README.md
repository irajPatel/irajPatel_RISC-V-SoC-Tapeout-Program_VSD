# Week 9 Images - Complete Asset Library

## 📊 Image Inventory

This folder contains **54 images and 1 CSV file** used throughout the Week 9 VSDBabySoC comprehensive documentation. All images are organized by their source week.

### 📈 Total Asset Count
- **54 PNG Images**
- **1 DOT File** (Graphviz)
- **1 CSV File** (Data)
- **Total: 56 files**

---

## 📁 Image Breakdown by Source

### **Week 1: RTL Design & Simulation (3 files)**
| File | Purpose |
|------|---------|
| Applied_filter.png | FIR Filter RTL simulation waveform |
| Applied_filter_GLS.png | FIR Filter gate-level simulation waveform |
| FIR_Filters_GLS_show.dot | Synthesized netlist visualization |

### **Week 2: SoC Architecture (2 files)**
| File | Purpose |
|------|---------|
| BabySoC_block.png | Block diagram showing RVMYTH, PLL, DAC integration |
| Task2_Ravi_pre_synth_simualtion_final.png | Pre-synthesis behavioral simulation |

### **Week 3: Synthesis & Timing (7 files)**
| File | Purpose |
|------|---------|
| Task1_vsdbaby_stat.png | Synthesis statistics - standard cell distribution |
| Task1_Pre_Post_simualtionCompare.png | RTL vs gate-level waveform comparison |
| sta6.png | Static timing analysis timing diagram |
| flow.png | STA flow architecture |
| opensta.png | OpenSTA tool architecture |
| paths.png | Timing path types and analysis |

### **Week 5: Physical Design Setup (6 files)**
| File | Purpose |
|------|---------|
| After_setup.png | OpenROAD installation verification |
| make_report1.png | Floorplan completion report |
| make_report2.png | Placement completion report |
| make_Gui.png | Physical design GUI main layout view |
| pin_density.png | I/O pin spatial distribution |
| routing_conjection.png | Predicted routing congestion analysis |

### **Week 6: Design Flow Theory (11 files)**
| File | Purpose |
|------|---------|
| simplified_rtl_gds.png | Complete RTL-to-GDSII flow diagram |
| Y_chart.png | Design abstraction Y-chart |
| vsd_baby_1.png | IC design components diagram 1 |
| vsd_baby_2.png | IC design components diagram 2 |
| openlane_asic.png | OpenLANE architecture overview |
| soc-google.png | Google Strive SoC family |
| code_to_desing.png | Synthesis stage: Code to gates |
| floor_planning.png | Floorplanning stage illustration |
| placement.png | Placement stage illustration |
| cts.png | Clock tree synthesis illustration |
| routing.png | Routing stage illustration |

### **Week 7: Physical Design - Complete Flow (21 files)** ⭐ **CORE CONTENT**

#### **Compilation & Synthesis (4 files)**
| File | Purpose |
|------|---------|
| First_make_cmd_compile.png | Initial make command compilation output |
| Yosy_synth_module.png | Yosys synthesis module hierarchy |
| yosys_stat_print.png | Synthesis statistics page 1 |
| yosys_stat_print2.png | Synthesis statistics page 2 |

#### **Floorplanning (4 files)**
| File | Purpose |
|------|---------|
| make_gui_floorPlan.png | Floorplan GUI dialog |
| Floor_plan1.png | Core area and boundary definition |
| floor_plan2.png | Macro placement (AVSDPLL, AVSDDAC) |
| Final_floorPlan.png | Complete floorplan with I/O pads |

#### **Placement (4 files)**
| File | Purpose |
|------|---------|
| Make_Placement.png | Placement phase execution log |
| make_gui_place_1.png | Overall placement view (~150K cells) |
| make_gui_place_zoom.png | Zoomed cell placement detail |
| make_gui_heat_map.png | Power distribution heat map |

#### **Clock Tree Synthesis (5 files)**
| File | Purpose |
|------|---------|
| make_cts.png | CTS phase execution |
| cts_rpt1.png | Clock tree metrics report |
| cts_rpt2.png | Timing impact report |
| cts_rpt3.png | Clock power consumption |
| gui_cts_clk1.png | Clock tree visualization 1 |
| gui_cts_clk2.png | Clock tree visualization 2 |

#### **Routing (2 files)**
| File | Purpose |
|------|---------|
| make_route.png | Routing phase execution |
| final_step_v_file.png | Post-route netlist (Verilog) |
| final_step_spef_fileview.png | SPEF parasitics extraction |

### **Week 8: Post-Layout Timing (6 files)** ⭐ **TIMING ANALYSIS**
| File | Purpose |
|------|---------|
| WNS_all_stages.png | Worst negative slack progression |
| TNS_all_stages.png | Total negative slack progression |
| Worst_Setup_Slack_all_stages.png | Setup slack by PVT corner |
| Worst_Hold_Slack_all_stages.png | Hold slack verification |
| Combined_All_Metrics.png | Combined timing dashboard |
| sta_analysis_all_corners.csv | Complete STA data (16 PVT corners) |

---

## 🎯 Image Usage in Week 9 README

### **Part 1: The Foundation**
- Step 1 (Setup): *No images*
- Step 2 (Design): Applied_filter.png, Applied_filter_GLS.png, FIR_Filters_GLS_show.dot, BabySoC_block.png, Task2_Ravi_pre_synth_simualtion_final.png

### **Part 2: From RTL to Gates**
- Step 3 (Synthesis): Yosys_stat, task1_vsdbaby_stat
- Step 4 (Verification): Task1_Pre_Post_simualtionCompare, sta6.png, flow.png, opensta.png, paths.png

### **Part 3: Physical Design Journey**
- Step 5-8 (Floorplan→Placement→CTS→Routing): All 21 Week 7 images

### **Part 4: Verification & Optimization**
- Step 9 (Post-Layout): All 6 Week 8 timing images

---

## 📊 Statistics

| Category | Count |
|----------|-------|
| PNG Images | 54 |
| Design Flow Diagrams | 8 |
| Physical Design Screenshots | 21 |
| Timing Analysis Charts | 6 |
| Simulation Waveforms | 5 |
| System Architecture | 4 |
| Other (DOT, CSV) | 2 |
| **TOTAL** | **56** |

---

## 🔗 File Structure

```
Week9/
├── README.md                          ← Main VSDBabySoC narrative
├── Images/                            ← This folder
│   ├── README.md                      ← This inventory
│   ├── [54 PNG files]
│   ├── [1 DOT file]
│   └── [1 CSV file]
```

---

## ✅ Verification

All images referenced in Week 9 README are present in this folder:
- ✅ Applied_filter.png (from Week1)
- ✅ BabySoC_block.png (from Week2)
- ✅ All synthesis & timing images (from Week3)
- ✅ All physical design images (from Week7) 
- ✅ All timing analysis visualizations (from Week8)
- ✅ All architecture & flow diagrams (from Week5, Week6)

---

## 📝 Last Updated
Generated: November 24, 2025

All images are organized for easy reference and are used throughout the comprehensive Week 9 VSDBabySoC documentation.
