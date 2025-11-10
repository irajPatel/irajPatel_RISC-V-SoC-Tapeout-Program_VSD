# OpenSTA Configuration with Cell Upsizing - Compatible with OpenSTA 2.0.17
set_cmd_units -time ns -capacitance pF -current mA -voltage V -resistance kOhm -distance um

# Read liberty files
read_liberty -max /home/iraj/VLSI/openlane_working_dir/openlane/designs/picorv32a/src/sky130_fd_sc_hd__slow.lib
read_liberty -min /home/iraj/VLSI/openlane_working_dir/openlane/designs/picorv32a/src/sky130_fd_sc_hd__fast.lib

# Read netlist
read_verilog /home/iraj/VLSI/openlane_working_dir/openlane/designs/picorv32a/runs/31-10_05-39/results/synthesis/picorv32a.synthesis.v
link_design picorv32a

# Read constraints
read_sdc /home/iraj/VLSI/openlane_working_dir/openlane/designs/picorv32a/src/my_base.sdc

puts "\n=========================================="
puts "INITIAL TIMING REPORT"
puts "==========================================\n"
report_checks -path_delay min_max -fields {slew trans net cap input_pin} -format full_clock
report_tns
report_wns

# Get initial slack values
set initial_wns [sta::worst_slack -max]
set initial_tns [sta::total_negative_slack -max]

puts "\n=========================================="
puts "ANALYZING CRITICAL PATH CELLS"
puts "==========================================\n"

# List of known problematic cells from the timing report
# Format: {instance_name cell_type delay_ns}
set critical_path_cells {
    {_33682_ sky130_fd_sc_hd__mux4_1 1.10}
    {_35312_ sky130_fd_sc_hd__dfxtp_2 1.21}
    {_33213_ sky130_fd_sc_hd__mux2_1 0.93}
    {_32503_ sky130_fd_sc_hd__mux2_1 0.81}
    {_33212_ sky130_fd_sc_hd__mux2_1 0.65}
    {_17453_ sky130_fd_sc_hd__or2b_2 0.65}
    {_33229_ sky130_fd_sc_hd__mux2_1 0.63}
    {_33228_ sky130_fd_sc_hd__mux2_1 0.62}
    {_22230_ sky130_fd_sc_hd__a21o_2 0.42}
    {_22244_ sky130_fd_sc_hd__a21o_2 0.41}
    {_22259_ sky130_fd_sc_hd__a21o_2 0.41}
    {_22279_ sky130_fd_sc_hd__a21o_2 0.41}
    {_22311_ sky130_fd_sc_hd__a21o_2 0.41}
    {_22253_ sky130_fd_sc_hd__a21o_2 0.40}
    {_22297_ sky130_fd_sc_hd__a21o_2 0.40}
    {_22305_ sky130_fd_sc_hd__a21o_2 0.40}
    {_21788_ sky130_fd_sc_hd__and2_2 0.39}
    {_22195_ sky130_fd_sc_hd__xnor2_2 0.39}
    {_22208_ sky130_fd_sc_hd__a21o_2 0.39}
    {_22272_ sky130_fd_sc_hd__a21o_2 0.39}
    {_22291_ sky130_fd_sc_hd__a21o_2 0.38}
    {_22290_ sky130_fd_sc_hd__and2_2 0.36}
    {_22390_ sky130_fd_sc_hd__and3_2 0.35}
    {_22200_ sky130_fd_sc_hd__nand3b_2 0.32}
    {_22318_ sky130_fd_sc_hd__a21oi_2 0.31}
    {_22323_ sky130_fd_sc_hd__a21o_2 0.24}
    {_22380_ sky130_fd_sc_hd__o21bai_2 0.22}
    {_17454_ sky130_fd_sc_hd__o211a_2 0.21}
    {_22349_ sky130_fd_sc_hd__nand3b_2 0.21}
    {_22215_ sky130_fd_sc_hd__o21ai_2 0.19}
    {_22324_ sky130_fd_sc_hd__o21ai_2 0.19}
    {_22223_ sky130_fd_sc_hd__o21ai_2 0.18}
    {_22238_ sky130_fd_sc_hd__o21ai_2 0.18}
    {_22351_ sky130_fd_sc_hd__nand2_2 0.18}
    {_22365_ sky130_fd_sc_hd__nand3_2 0.17}
    {_22385_ sky130_fd_sc_hd__nand2_2 0.16}
    {_22285_ sky130_fd_sc_hd__o21ai_2 0.14}
    {_22348_ sky130_fd_sc_hd__nand3_2 0.12}
    {_22207_ sky130_fd_sc_hd__a2bb2oi_2 0.12}
    {_22266_ sky130_fd_sc_hd__a21boi_2 0.12}
    {_22222_ sky130_fd_sc_hd__o21ai_2 0.12}
    {_22263_ sky130_fd_sc_hd__nand2_2 0.11}
    {_22214_ sky130_fd_sc_hd__o21ai_2 0.10}
    {_22237_ sky130_fd_sc_hd__o21ai_2 0.10}
    {_22284_ sky130_fd_sc_hd__nand2_2 0.10}
    {_22391_ sky130_fd_sc_hd__nor2_2 0.06}
}

puts "Extracted [llength $critical_path_cells] cells from critical path"

# Count cell types
array set cell_type_count {}
foreach cell_entry $critical_path_cells {
    set cell_type [lindex $cell_entry 1]
    if {![info exists cell_type_count($cell_type)]} {
        set cell_type_count($cell_type) 0
    }
    incr cell_type_count($cell_type)
}

puts "\nTop Cell Types on Critical Path (sorted by frequency):"
puts "-------------------------------------------------------"

# Manual sorting by creating a list of {type count} pairs
set type_list [list]
foreach cell_type [array names cell_type_count] {
    lappend type_list [list $cell_type $cell_type_count($cell_type)]
}

# Sort by count (descending)
set sorted_list [lsort -integer -decreasing -index 1 $type_list]

set count 0
foreach entry [lrange $sorted_list 0 19] {
    incr count
    set cell_type [lindex $entry 0]
    set type_count [lindex $entry 1]
    puts [format "%2d. %-35s : %2d instances" $count $cell_type $type_count]
}

# Mapping of current size to next size
array set size_map {
    "_1" "_2"
    "_2" "_4"
    "_4" "_8"
}

# Function to get next larger size for a cell
proc get_upsized_cell {cell_ref} {
    global size_map
    
    foreach {old_suffix new_suffix} [array get size_map] {
        if {[string match "*$old_suffix" $cell_ref]} {
            set suffix_len [string length $old_suffix]
            set base_name [string range $cell_ref 0 end-$suffix_len]
            return "${base_name}${new_suffix}"
        }
    }
    return ""
}

puts "\n=========================================="
puts "STARTING CELL UPSIZING OPTIMIZATION"
puts "=========================================="
puts "Strategy: Upsize high-delay cells on critical path"
puts "Cell sizes: _1 -> _2 -> _4 -> _8\n"

set max_iterations 50
set cells_upsized 0
set iteration 0

# Sort cells by delay (highest first)
set sorted_cells [lsort -real -decreasing -index 2 $critical_path_cells]

foreach cell_entry $sorted_cells {
    incr iteration
    
    set inst_name [lindex $cell_entry 0]
    set cell_type [lindex $cell_entry 1]
    set cell_delay [lindex $cell_entry 2]
    
    # Get current WNS before upsizing
    set current_wns [sta::worst_slack -max]
    set current_tns [sta::total_negative_slack -max]
    
    # Check if timing is already met
    if {$current_wns >= 0} {
        puts "\n*** TIMING MET! WNS = [format %.3f $current_wns] ns ***"
        break
    }
    
    # Get next size
    set upsized_cell [get_upsized_cell $cell_type]
    
    if {$upsized_cell eq ""} {
        continue
    }
    
    # Check if the target cell exists in library
    set lib_cells [get_lib_cells "*/$upsized_cell"]
    if {[llength $lib_cells] == 0} {
        continue
    }
    
    # Check if instance exists
    set inst [get_cells $inst_name]
    if {$inst eq ""} {
        continue
    }
    
    puts [format "Iteration %2d: %s" $iteration $inst_name]
    puts [format "  Current: %-35s (delay: %.3f ns)" $cell_type $cell_delay]
    puts [format "  Target:  %-35s" $upsized_cell]
    
    # Try to replace the cell
    if {[catch {replace_cell $inst [lindex $lib_cells 0]} err]} {
        puts "  ERROR: Could not upsize - $err"
        continue
    }
    
    incr cells_upsized
    
    # Get new WNS after upsizing
    set new_wns [sta::worst_slack -max]
    set new_tns [sta::total_negative_slack -max]
    set improvement [expr {$new_wns - $current_wns}]
    
    puts [format "  Result:  WNS %.3f ns -> %.3f ns (Δ = %+.3f ns)" $current_wns $new_wns $improvement]
    puts [format "           TNS %.3f ns -> %.3f ns (Δ = %+.3f ns)" $current_tns $new_tns [expr {$new_tns - $current_tns}]]
    
    # Stop if we've achieved timing closure
    if {$new_wns >= 0} {
        puts "\n*** TIMING CLOSURE ACHIEVED! ***"
        break
    }
    
    # Stop if no improvement for high delay cells
    if {$improvement < 0.01 && $cell_delay > 0.5 && $iteration > 5} {
        puts "\n  Warning: Minimal improvement on high-delay cell. Continuing..."
    }
    
    if {$iteration >= $max_iterations} {
        puts "\n  Reached maximum iterations ($max_iterations)"
        break
    }
}

set final_wns [sta::worst_slack -max]
set final_tns [sta::total_negative_slack -max]

puts "\n=========================================="
puts "OPTIMIZATION SUMMARY"
puts "=========================================="
puts [format "Total cells upsized:     %d" $cells_upsized]
puts [format "Iterations performed:    %d" $iteration]
puts ""
puts [format "Initial WNS: %7.3f ns" $initial_wns]
puts [format "Final WNS:   %7.3f ns" $final_wns]
puts [format "Improvement: %7.3f ns (%.1f%%)" [expr {$final_wns - $initial_wns}] [expr {($final_wns - $initial_wns) / abs($initial_wns) * 100}]]
puts ""
puts [format "Initial TNS: %7.3f ns" $initial_tns]
puts [format "Final TNS:   %7.3f ns" $final_tns]
puts [format "Improvement: %7.3f ns (%.1f%%)" [expr {$final_tns - $initial_tns}] [expr {($final_tns - $initial_tns) / abs($initial_tns) * 100}]]
puts ""

if {$final_wns >= 0} {
    puts "STATUS: ✓ TIMING CONSTRAINTS MET!"
} else {
    puts "STATUS: ✗ Timing violation remains"
    puts [format "        Need additional %.3f ns improvement" [expr {abs($final_wns)}]]
    puts "\nSuggestions:"
    puts "  1. Increase clock period in SDC file"
    puts "  2. Further optimize high fanout nets (e.g., latched_stalu with 33 loads)"
    puts "  3. Consider buffer insertion on critical paths"
    puts "  4. Run synthesis with different strategies"
}

puts "\n=========================================="
puts "FINAL TIMING REPORT"
puts "=========================================="
report_checks -path_delay min_max -fields {slew trans net cap input_pin} -format full_clock
report_tns
report_wns

# Write out the modified netlist
write_verilog /home/iraj/VLSI/openlane_working_dir/openlane/designs/picorv32a/runs/31-10_05-39/results/synthesis/picorv32a.synthesis.v

puts "\n=========================================="
puts "Optimized netlist written to:"
puts "picorv32a.synthesis.v"
puts "=========================================="