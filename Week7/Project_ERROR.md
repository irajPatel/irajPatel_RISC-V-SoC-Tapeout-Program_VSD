# VSDBabySoC RTL2GDS Flow - Complete Project Documentation

## Project Overview
This document describes the complete automated RTL-to-GDSII flow setup for VSDBabySoC design using OpenROAD-flow-scripts with Sky130 PDK.

---

## Table of Contents
1. [Initial Setup & Directory Structure](#1-initial-setup--directory-structure)
2. [File Organization](#2-file-organization)
3. [Configuration Setup](#3-configuration-setup)
4. [Common Errors and Solutions](#4-common-errors-and-solutions)
5. [Running the Flow](#5-running-the-flow)
6. [GUI Visualization](#6-gui-visualization)
7. [Results and Reports](#7-results-and-reports)

---

## 1. Initial Setup & Directory Structure

### Step 1.1: Create Design Directories

```bash
cd /home/iraj/OpenROAD-flow-scripts/flow

# Create design directory for Sky130
mkdir -p designs/sky130hd/vsdbabysoc

# Create source directory
mkdir -p designs/src/vsdbabysoc
```

**Location Details:**
- `designs/sky130hd/vsdbabysoc/` - Contains platform-specific configuration files
- `designs/src/vsdbabysoc/` - Contains all Verilog source files

---

## 2. File Organization

### Step 2.1: Copy Verilog Source Files

**Files to copy to `designs/src/vsdbabysoc/`:**

```bash
# Navigate to flow directory
cd /home/iraj/OpenROAD-flow-scripts/flow

# Copy main design files
cp /home/iraj/OpenROAD-flow-scripts/VSDBabySoC/src/module/vsdbabysoc.v designs/src/vsdbabysoc/
cp /home/iraj/OpenROAD-flow-scripts/VSDBabySoC/src/module/rvmyth.v designs/src/vsdbabysoc/
cp /home/iraj/OpenROAD-flow-scripts/VSDBabySoC/src/module/clk_gate.v designs/src/vsdbabysoc/
cp /home/iraj/OpenROAD-flow-scripts/VSDBabySoC/src/module/rvmyth_gen.v designs/src/vsdbabysoc/

# Copy analog macro blackbox files
cp /home/iraj/OpenROAD-flow-scripts/VSDBabySoC/src/module/avsddac.v designs/src/vsdbabysoc/
cp /home/iraj/OpenROAD-flow-scripts/VSDBabySoC/src/module/avsdpll.v designs/src/vsdbabysoc/
```

**Final structure in `designs/src/vsdbabysoc/`:**
```
vsdbabysoc.v       - Top-level module
rvmyth.v           - RISC-V core wrapper
rvmyth_gen.v       - RISC-V core implementation (included by rvmyth.v)
clk_gate.v         - Clock gating logic
avsddac.v          - DAC macro stub (blackbox)
avsdpll.v          - PLL macro stub (blackbox)
```

### Step 2.2: Copy Technology Files to `designs/sky130hd/vsdbabysoc/`

```bash
# Copy GDS files (GDSII layouts for analog macros)
cp -r /home/iraj/OpenROAD-flow-scripts/VSDBabySoC/src/gds designs/sky130hd/vsdbabysoc/

# Copy LEF files (physical abstracts)
cp -r /home/iraj/OpenROAD-flow-scripts/VSDBabySoC/src/lef designs/sky130hd/vsdbabysoc/

# Copy LIB files (timing libraries)
cp -r /home/iraj/OpenROAD-flow-scripts/VSDBabySoC/src/lib designs/sky130hd/vsdbabysoc/

# Copy include files (Verilog headers)
cp -r /home/iraj/OpenROAD-flow-scripts/VSDBabySoC/src/include designs/sky130hd/vsdbabysoc/
```

**IMPORTANT:** Remove duplicate standard cell library:
```bash
# This file should only come from the platform, not your design
rm designs/sky130hd/vsdbabysoc/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
```

**Final structure in `designs/sky130hd/vsdbabysoc/`:**
```
gds/
  ├── avsddac.gds
  └── avsdpll.gds

lef/
  ├── avsddac.lef
  └── avsdpll.lef

lib/
  ├── avsddac.lib
  └── avsdpll.lib

include/
  ├── sandpiper.vh
  ├── sandpiper_gen.vh
  ├── sp_default.vh
  └── sp_verilog.vh
```

### Step 2.3: Copy Configuration Files

```bash
# Copy SDC constraints
cp /home/iraj/OpenROAD-flow-scripts/VSDBabySoC/src/sdc/vsdbabysoc_synthesis.sdc \
   designs/sky130hd/vsdbabysoc/

# Copy macro placement file
cp /home/iraj/OpenROAD-flow-scripts/VSDBabySoC/src/layout_conf/vsdbabysoc/macro.cfg \
   designs/sky130hd/vsdbabysoc/

# Copy pin order file
cp /home/iraj/OpenROAD-flow-scripts/VSDBabySoC/src/layout_conf/vsdbabysoc/pin_order.cfg \
   designs/sky130hd/vsdbabysoc/
```

---

## 3. Configuration Setup

### Step 3.1: Fix Library Files (Power/Ground Pin Issue)

**Problem:** Liberty files had power/ground pins defined as regular pins, causing parser errors.

**Solution:** Update both `avsddac.lib` and `avsdpll.lib`

**File:** `designs/sky130hd/vsdbabysoc/lib/avsdpll.lib`

Change from:
```liberty
pin (GND) {
  direction : input;
  max_transition : 2.5;
  capacitance : 0.001;
}

pin (VDD) {
  direction : input;
  max_transition : 2.5;
  capacitance : 0.001;
}
```

To:
```liberty
pg_pin (GND) {
  voltage_name : GND;
  pg_type : primary_ground;
}

pg_pin (VDD) {
  voltage_name : VDD;
  pg_type : primary_power;
}
```

**File:** `designs/sky130hd/vsdbabysoc/lib/avsddac.lib`

Change from:
```liberty
pin (VSSA) {
  direction : input;
  max_transition : 2.5;
  capacitance : 0.001;
}

pin (VDDA) {
  direction : input;
  max_transition : 2.5;
  capacitance : 0.001;
}
```

To:
```liberty
pg_pin (VSSA) {
  voltage_name : VSSA;
  pg_type : primary_ground;
}

pg_pin (VDDA) {
  voltage_name : VDDA;
  pg_type : primary_power;
}
```

### Step 3.2: Fix Macro Placement File Format

**Problem:** Incorrect macro.cfg format causing parsing errors.

**File:** `designs/sky130hd/vsdbabysoc/macro.cfg`

Change from:
```
pll 200 950 N
dac 150 250 N
```

To (correct format: `instance_name orientation x y`):
```
pll N 200 950
dac N 150 250
```

### Step 3.3: Create config.mk

**File:** `designs/sky130hd/vsdbabysoc/config.mk`

```makefile
export DESIGN_NICKNAME = vsdbabysoc
export DESIGN_NAME = vsdbabysoc
export PLATFORM    = sky130hd

# Blackbox files for analog macros (not synthesized)
export VERILOG_FILES_BLACKBOX = $(DESIGN_HOME)/src/$(DESIGN_NICKNAME)/avsdpll.v \
                                $(DESIGN_HOME)/src/$(DESIGN_NICKNAME)/avsddac.v

# Verilog files for synthesis
export VERILOG_FILES = $(DESIGN_HOME)/src/$(DESIGN_NICKNAME)/vsdbabysoc.v \
                       $(DESIGN_HOME)/src/$(DESIGN_NICKNAME)/rvmyth.v \
                       $(DESIGN_HOME)/src/$(DESIGN_NICKNAME)/clk_gate.v

export SDC_FILE = $(DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/vsdbabysoc_synthesis.sdc

export vsdbabysoc_DIR = $(DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)

export VERILOG_INCLUDE_DIRS = $(wildcard $(vsdbabysoc_DIR)/include/)
export ADDITIONAL_GDS  = $(wildcard $(vsdbabysoc_DIR)/gds/*.gds)
export ADDITIONAL_LEFS  = $(wildcard $(vsdbabysoc_DIR)/lef/*.lef)
export ADDITIONAL_LIBS = $(wildcard $(vsdbabysoc_DIR)/lib/*.lib)

# Clock Configuration
export CLOCK_PERIOD = 20.0
export CLOCK_PORT = CLK
export CLOCK_NET = $(CLOCK_PORT)

# Floorplanning Configuration
export FP_PIN_ORDER_CFG = $(wildcard $(DESIGN_DIR)/pin_order.cfg)
# Note: FP_SIZING commented out because we use explicit DIE_AREA/CORE_AREA
# export FP_SIZING = absolute

export DIE_AREA = 0 0 2500 2500
export CORE_AREA = 20 20 2480 2480

# Placement Configuration
export MACRO_PLACEMENT = $(DESIGN_DIR)/macro.cfg
export PLACE_PINS_ARGS = -exclude left:0-600 -exclude left:1000-1600: -exclude right:* -exclude top:* -exclude bottom:*

export TNS_END_PERCENT = 100
export REMOVE_ABC_BUFFERS = 1

# Magic Tool Configuration
export MAGIC_ZEROIZE_ORIGIN = 0
export MAGIC_EXT_USE_GDS = 1

# CTS tuning
export CTS_BUF_DISTANCE = 600
export SKIP_GATE_CLONING = 1

# Note: CORE_UTILIZATION commented out because we use explicit DIE_AREA/CORE_AREA
# export CORE_UTILIZATION = 0.1
```

---

## 4. Common Errors and Solutions

### Error 1: Duplicate Library Files

**Error Message:**
```
Makefile:197: target 'objects/sky130hd/vsdbabysoc/base/lib/sky130_fd_sc_hd__tt_025C_1v80.lib' given more than once
preprocessLib.py: error: unrecognized arguments: /home/iraj/OpenROAD-flow-scripts/flow/designs/sky130hd/vsdbabysoc/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
```

**Cause:** Standard cell library exists in both platform and design directories.

**Solution:**
```bash
rm designs/sky130hd/vsdbabysoc/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
```

### Error 2: Missing Include File

**Error Message:**
```
ERROR: Can't open include file `rvmyth_gen.v /*_\TLV */'!
```

**Cause:** `rvmyth.v` includes `rvmyth_gen.v` which wasn't copied.

**Solution:**
```bash
cp /home/iraj/OpenROAD-flow-scripts/VSDBabySoC/src/module/rvmyth_gen.v \
   designs/src/vsdbabysoc/
```

### Error 3: Liberty File Syntax Error

**Error Message:**
```
[ERROR STA-0164] /home/iraj/OpenROAD-flow-scripts/flow/designs/sky130hd/vsdbabysoc/lib/avsdpll.lib line 54, syntax error
```

**Cause:** Power/ground pins incorrectly defined as regular pins.

**Solution:** See Step 3.1 - Change `pin (VDD)` and `pin (GND)` to `pg_pin (VDD)` and `pg_pin (GND)`.

### Error 4: Floorplan Initialization Error

**Error Message:**
```
Error: Floorplan initialization methods are mutually exclusive, pick one.
```

**Cause:** Multiple floorplan sizing methods set simultaneously:
- `FP_SIZING = absolute`
- `DIE_AREA` and `CORE_AREA` defined
- `CORE_UTILIZATION` set

**Solution:** Use only ONE method. Comment out `FP_SIZING` and `CORE_UTILIZATION`:
```makefile
# export FP_SIZING = absolute
export DIE_AREA = 0 0 2500 2500
export CORE_AREA = 20 20 2480 2480
# export CORE_UTILIZATION = 0.1
```

### Error 5: Macro Placement Failed

**Error Message:**
```
[ERROR MPL-0045] Cannot find a balanced partitioning for the clusters.
```

**Cause:** Automatic macro placer failing with manual placement file present.

**Solution:** Change from `MACRO_PLACEMENT_CFG` to `MACRO_PLACEMENT`:
```makefile
# Use manual placement only
export MACRO_PLACEMENT = $(DESIGN_DIR)/macro.cfg
```

### Error 6: Macro Config Parse Error

**Error Message:**
```
Error: macro_place.tcl, 5 can't use non-numeric string as operand of "*"
```

**Cause:** Wrong format in macro.cfg file.

**Solution:** Fix format in `macro.cfg`:
```
# Correct format: instance_name orientation x y
pll N 200 950
dac N 150 250
```

### Error 7: Missing Macro Instances in Netlist

**Error Message:**
```
Cannot find instance pll
```

**Cause:** Analog macros need to be defined as blackbox modules.

**Solution:** Add to config.mk:
```makefile
export VERILOG_FILES_BLACKBOX = $(DESIGN_HOME)/src/$(DESIGN_NICKNAME)/avsdpll.v \
                                $(DESIGN_HOME)/src/$(DESIGN_NICKNAME)/avsddac.v
```

And clean previous synthesis:
```bash
rm -rf objects/sky130hd/vsdbabysoc/base/lib/*.lib
rm -rf results/sky130hd/vsdbabysoc/base/1_*.*
rm -rf logs/sky130hd/vsdbabysoc/base/1_*.*
```

---

## 5. Running the Flow

### Step 5.1: Synthesis

```bash
cd /home/iraj/OpenROAD-flow-scripts/flow
make DESIGN_CONFIG=./designs/sky130hd/vsdbabysoc/config.mk synth
```

**Expected Output:**
- Synthesized netlist: `results/sky130hd/vsdbabysoc/base/1_synth.v`
- Reports: `reports/sky130hd/vsdbabysoc/base/synth_*.rpt`

**What happens:**
1. Reads Verilog files
2. Treats avsdpll and avsddac as blackboxes
3. Synthesizes digital logic (rvmyth, clk_gate)
4. Maps to Sky130 standard cells
5. Generates gate-level netlist

### Step 5.2: Floorplan

```bash
make DESIGN_CONFIG=./designs/sky130hd/vsdbabysoc/config.mk floorplan
```

**Expected Output:**
- Database: `results/sky130hd/vsdbabysoc/base/2_*_floorplan*.odb`
- Reports: `reports/sky130hd/vsdbabysoc/base/2_*_floorplan*.rpt`

**What happens:**
1. Creates die area (2500×2500 µm)
2. Creates core area (20,20 to 2480,2480)
3. Places macros (pll at 200,950; dac at 150,250)
4. Creates power distribution network (PDN)
5. Places IO pins according to pin_order.cfg

### Step 5.3: Placement

```bash
make DESIGN_CONFIG=./designs/sky130hd/vsdbabysoc/config.mk place
```

**What happens:**
1. Global placement of standard cells
2. Detailed placement
3. Optimization for timing and congestion

### Step 5.4: Clock Tree Synthesis (CTS)

```bash
make DESIGN_CONFIG=./designs/sky130hd/vsdbabysoc/config.mk cts
```

**Expected Output:**
- Database: `results/sky130hd/vsdbabysoc/base/4_1_cts.odb`
- Reports: `reports/sky130hd/vsdbabysoc/base/4_cts_*.rpt`

**What happens:**
1. Analyzes clock distribution
2. Inserts clock buffers (clkbuf_0_CLK, clkbuf_5_*, clkbuf_leaf_*)
3. Balances clock skew
4. Reports timing

**Key CTS Results:**
```
worst slack (max): 6.55 ns (MET)
total negative slack: 0.00 ns
worst negative slack: 0.00 ns
clock skew: -0.24 ns
```

### Step 5.5: Routing

```bash
make DESIGN_CONFIG=./designs/sky130hd/vsdbabysoc/config.mk route
```

**What happens:**
1. Global routing (plan wire paths)
2. Detailed routing (actual metal connections)
3. Adds filler cells
4. Final DRC checks

### Step 5.6: Complete Flow

```bash
# Run everything in one command
make DESIGN_CONFIG=./designs/sky130hd/vsdbabysoc/config.mk
```

---

## 6. GUI Visualization

### Step 6.1: Basic GUI Commands

**Open GUI at different stages:**
```bash
# After synthesis
make DESIGN_CONFIG=./designs/sky130hd/vsdbabysoc/config.mk gui_synth

# After floorplan
make DESIGN_CONFIG=./designs/sky130hd/vsdbabysoc/config.mk gui_floorplan

# After placement
make DESIGN_CONFIG=./designs/sky130hd/vsdbabysoc/config.mk gui_place

# After CTS
make DESIGN_CONFIG=./designs/sky130hd/vsdbabysoc/config.mk gui_cts

# After routing
make DESIGN_CONFIG=./designs/sky130hd/vsdbabysoc/config.mk gui_route

# Final design
make DESIGN_CONFIG=./designs/sky130hd/vsdbabysoc/config.mk gui_final
```

### Step 6.2: Create Auto-Highlight Script for CTS Visualization

Create a script to automatically highlight timing paths when GUI opens.

**File:** `designs/sky130hd/vsdbabysoc/gui_cts_highlight.tcl`

```tcl
# Auto-highlight script for CTS visualization
# This script highlights clock tree and critical timing paths

proc highlight_vsdbabysoc_cts {} {
    puts "Highlighting VSDBabySoC Clock Tree and Timing Paths..."
    
    # Clear any previous highlights
    gui::clear_highlights
    
    # Highlight main clock network
    puts "  - Highlighting main clock (CLK)"
    gui::highlight_net "CLK"
    
    # Highlight clock tree buffers (Level 0)
    puts "  - Highlighting clock tree level 0"
    gui::highlight_net "clknet_0_CLK"
    
    # Highlight clock tree leaf buffers
    puts "  - Highlighting clock tree leaf nets"
    catch {gui::highlight_net "clknet_5_6__leaf_CLK"}
    catch {gui::highlight_net "clknet_5_11__leaf_CLK"}
    catch {gui::highlight_net "clknet_5_15__leaf_CLK"}
    catch {gui::highlight_net "clknet_leaf_33_CLK"}
    catch {gui::highlight_net "clknet_leaf_55_CLK"}
    catch {gui::highlight_net "clknet_leaf_88_CLK"}
    
    # Highlight macros
    puts "  - Highlighting PLL and DAC macros"
    gui::highlight_inst "pll"
    gui::highlight_inst "dac"
    
    # Highlight critical path nets (from worst slack path)
    puts "  - Highlighting critical timing path"
    catch {gui::highlight_net "core.CPU_is_slli_a3"}
    catch {gui::highlight_net "_02607_"}
    catch {gui::highlight_net "net458"}
    catch {gui::highlight_net "_02728_"}
    catch {gui::highlight_net "_02733_"}
    catch {gui::highlight_net "_02736_"}
    catch {gui::highlight_net "_03411_"}
    catch {gui::highlight_net "_03413_"}
    catch {gui::highlight_net "_03414_"}
    catch {gui::highlight_net "_03415_"}
    catch {gui::highlight_net "_01061_"}
    
    # Zoom to fit
    gui::fit
    
    puts "Highlighting complete!"
    puts ""
    puts "Legend:"
    puts "  - Blue highlights: Clock network"
    puts "  - Yellow highlights: PLL and DAC macros"
    puts "  - Red highlights: Critical timing path"
    puts ""
    puts "Use 'gui::clear_highlights' to clear all highlights"
}

# Auto-run on load
highlight_vsdbabysoc_cts
```

**To use this script automatically:**

Add to your config.mk:
```makefile
# GUI auto-load script for CTS visualization
export GUI_SCRIPT = $(DESIGN_DIR)/gui_cts_highlight.tcl
```

Or manually source it in GUI:
```tcl
source designs/sky130hd/vsdbabysoc/gui_cts_highlight.tcl
```

### Step 6.3: Manual GUI Commands Reference

**Basic Highlighting:**
```tcl
# Highlight a net
gui::highlight_net "net_name"

# Highlight an instance
gui::highlight_inst "instance_name"

# Clear all highlights
gui::clear_highlights

# Zoom to fit
gui::fit
```

**Timing Analysis:**
```tcl
# Show worst slack
report_wns
report_tns
report_worst_slack

# Show timing paths
report_checks -path_delay max -format full_clock_expanded

# Show clock skew
report_clock_skew

# Show specific number of paths
report_checks -path_delay max -group_count 10
```

**Clock Tree Information:**
```tcl
# Find all clock buffers
set block [ord::get_db_block]
foreach inst [$block getInsts] {
    set master_name [[$inst getMaster] getName]
    if {[string match "*clkbuf*" $master_name]} {
        puts "Clock buffer: [$inst getName]"
    }
}
```

---

## 7. Results and Reports

### Design Statistics

**After CTS:**
- **Die Area:** 2500 µm × 2500 µm = 6.25 mm²
- **Core Area:** 2460 µm × 2460 µm = 6.05 mm²
- **Standard Cells:** 5,841 instances
- **Macros:** 2 (avsdpll, avsddac)
- **Design Utilization:** ~12%
- **Clock Buffers Inserted:** ~32+ buffers

**Timing Results (Post-CTS):**
```
Worst Slack (Setup):     6.55 ns (MET)
Total Negative Slack:    0.00 ns
Worst Negative Slack:    0.00 ns
Clock Period:            11.00 ns
Clock Skew:              -0.24 ns
```

### Key Reports Location

```
flow/reports/sky130hd/vsdbabysoc/base/
├── synth_*.rpt              # Synthesis reports
├── 2_*_floorplan*.rpt       # Floorplan reports
├── 3_*_place*.rpt           # Placement reports
├── 4_cts_*.rpt              # CTS timing reports
├── 5_*_route*.rpt           # Routing reports
└── 6_*_final*.rpt           # Final reports
```

### Important Files

**Databases (ODB format):**
```
flow/results/sky130hd/vsdbabysoc/base/
├── 1_synth.v                # Synthesized netlist
├── 2_1_floorplan.odb        # After floorplan
├── 2_2_floorplan_macro.odb  # After macro placement
├── 3_*_place*.odb           # After placement
├── 4_1_cts.odb              # After CTS
├── 5_*_route*.odb           # After routing
└── 6_1_merged.gds           # Final GDSII
```

---

## Project Summary

### What We Built
- Complete RTL-to-GDSII flow for VSDBabySoC
- Mixed-signal design with digital core (RISC-V) and analog macros (PLL, DAC)
- Sky130 technology (130nm process)

### Key Achievements
1. ✅ Successfully synthesized 5,841 standard cell instances
2. ✅ Placed 2 analog macros with manual placement
3. ✅ Achieved timing closure (positive slack)
4. ✅ Balanced clock tree with minimal skew (-0.24ns)
5. ✅ Complete automated flow from RTL to GDSII

### Design Flow Steps
```
RTL (Verilog) 
  → Synthesis 
  → Floorplan 
  → Placement 
  → CTS 
  → Routing 
  → GDSII
```

### Total Project Time
- Initial setup: ~1 hour
- Debugging and fixes: ~2 hours  
- Full flow execution: ~30 minutes
- **Total: ~3.5 hours**

---

## Appendix: Quick Reference Commands

### Clean and Rebuild
```bash
# Clean specific stages
make DESIGN_CONFIG=./designs/sky130hd/vsdbabysoc/config.mk clean_synth
make DESIGN_CONFIG=./designs/sky130hd/vsdbabysoc/config.mk clean_place
make DESIGN_CONFIG=./designs/sky130hd/vsdbabysoc/config.mk clean_cts

# Clean everything
make DESIGN_CONFIG=./designs/sky130hd/vsdbabysoc/config.mk clean_all
```

### View Reports
```bash
# Synthesis report
cat reports/sky130hd/vsdbabysoc/base/synth_stat.txt

# CTS timing
cat reports/sky130hd/vsdbabysoc/base/4_cts_final.rpt

# Final timing
cat reports/sky130hd/vsdbabysoc/base/6_final.rpt
```

### File Paths Reference
```
Project Root: /home/iraj/OpenROAD-flow-scripts/flow/

Source Files:     designs/src/vsdbabysoc/
Config Files:     designs/sky130hd/vsdbabysoc/
Results:          results/sky130hd/vsdbabysoc/base/
Reports:          reports/sky130hd/vsdbabysoc/base/
Logs:             logs/sky130hd/vsdbabysoc/base/
```

---

**Document Version:** 1.0  
**Date:** November 16, 2025  
**Author:** Generated from VSDBabySoC RTL2GDS Flow Project  
**Design:** VSDBabySoC (RISC-V SoC with PLL and DAC)  
**Technology:** Sky130 (130nm)  
**Tools:** OpenROAD-flow-scripts v2.0
