#!/usr/bin/tclsh
# OpenLane Synthesis Timing Optimization Script (updated)
# Focus: HIGH IMPACT parameters for WNS/TNS reduction only
# Improvements:
#  - Ignore numeric prefix in report filenames (uses wildcard suffix matching)
#  - extract_metrics(run_tag) accepts run tag and searches that run's reports/logs
#  - More robust glob patterns and regex extraction for WNS/TNS/Area

package require openlane 0.9

# Configuration
set DESIGN_NAME "picorv32a"
set BASE_TAG "timing_opt"
set RESULTS_FILE "synthesis_timing_results.csv"

# Initialize results file with header
set results_fh [open $RESULTS_FILE w]
puts $results_fh "Run,Strategy,Sizing,Buffering,MaxFanout,MaxTran,DrivingCell,CapLoad,WNS,TNS,Area,Chip_Area"
close $results_fh

# HIGH IMPACT timing parameters only
set strategies {"DELAY 0" "DELAY 1" "DELAY 2" "DELAY 3"}
set sizing_options {0 1}
set buffering_options {0 1}
set fanout_options {3 4 5}
set max_tran_options {0.5 0.75  1.5}
set driving_cells { "sky130_fd_sc_hd__inv_8" "sky130_fd_sc_hd__inv_16"}
set cap_load_options { 17.65 25.0}

# Tracking variables
set run_count 0
set best_wns -999999
set best_tns -999999
set best_config ""
set best_run 0

puts "\n=========================================="
puts "Synthesis Timing Optimization Sweep"
puts "Design: $DESIGN_NAME"
puts "Focus: HIGH IMPACT timing parameters only"
puts "==========================================\n"

# -----------------------------------------------------------------------------
# Function: extract_metrics
# Args: run_tag (string) - name of the run folder under designs/<design>/runs/<run_tag>
# Returns: list {wns tns area chip_area}
# -----------------------------------------------------------------------------
proc extract_metrics {run_tag} {
    set wns "N/A"
    set tns "N/A"
    set area "N/A"
    set chip_area "N/A"

    # Construct run path from DESIGN_DIR to be consistent with OpenLane layout
    if {[info exists ::env(DESIGN_DIR)] && [file exists $::env(DESIGN_DIR)]} {
        set run_path "$::env(DESIGN_DIR)/runs/$run_tag"
    } else {
        # fallback to current working dir if DESIGN_DIR not set
        set run_path "[file normalize [pwd]]/designs/$::env(DESIGN_NAME)/runs/$run_tag"
    }

    set reports_dir "$run_path/reports/synthesis"
    set logs_dir "$run_path/logs/synthesis"

    puts "DEBUG: Looking for reports in: $reports_dir"
    puts "DEBUG: Looking for logs in:    $logs_dir"

    # Print file lists (debug)
    if {[file exists $reports_dir]} {
        if {![catch {set files [glob -nocomplain $reports_dir/*]} err]} {
            puts "DEBUG: Files found in reports/synthesis:"
            foreach f $files { puts "  - [file tail $f]" }
        }
    } else {
        puts "DEBUG: Reports directory does NOT exist: $reports_dir"
    }

    if {[file exists $logs_dir]} {
        if {![catch {set files [glob -nocomplain $logs_dir/*]} err]} {
            puts "DEBUG: Files found in logs/synthesis:"
            foreach f $files { puts "  - [file tail $f]" }
        }
    } else {
        puts "DEBUG: Logs directory does NOT exist: $logs_dir"
    }

    # --- Find WNS file(s) by suffix / wildcard (ignore numeric prefix) ---
    set wns_candidates [concat \
        [glob -nocomplain "$reports_dir/*opensta_wns.rpt"] \
        [glob -nocomplain "$reports_dir/*wns*.rpt"] \
        [glob -nocomplain "$reports_dir/*opensta*.rpt"] \
        [glob -nocomplain "$logs_dir/*opensta*wns*"] \
    ]

    foreach f $wns_candidates {
        if {$f eq ""} continue
        if {[file exists $f]} {
            puts "DEBUG: Considering WNS candidate: [file tail $f]"
            if {![catch {set fh [open $f r]}]} {
                set content [read $fh]
                close $fh
                # try to extract explicit WNS numeric value
                if {[regexp -nocase {wns[^0-9\-\.]*([-]?[0-9]+\.[0-9]+|[-]?[0-9]+)} $content match val]} {
                    set wns $val
                    puts "DEBUG: Extracted WNS = $wns from [file tail $f]"
                    break
                } elseif {[regexp -nocase {worst\s+slack[^0-9\-\.]*([-]?[0-9]+\.[0-9]+|[-]?[0-9]+)} $content match val2]} {
                    set wns $val2
                    puts "DEBUG: Extracted WNS (worst slack) = $wns from [file tail $f]"
                    break
                }
            }
        }
    }

    # --- Find TNS file(s) by suffix / wildcard ---
    set tns_candidates [concat \
        [glob -nocomplain "$reports_dir/*opensta_tns.rpt"] \
        [glob -nocomplain "$reports_dir/*tns*.rpt"] \
        [glob -nocomplain "$reports_dir/*opensta*.rpt"] \
        [glob -nocomplain "$logs_dir/*opensta*tns*"] \
    ]

    foreach f $tns_candidates {
        if {$f eq ""} continue
        if {[file exists $f]} {
            puts "DEBUG: Considering TNS candidate: [file tail $f]"
            if {![catch {set fh [open $f r]}]} {
                set content [read $fh]
                close $fh
                if {[regexp -nocase {tns[^0-9\-\.]*([-]?[0-9]+\.[0-9]+|[-]?[0-9]+)} $content match val]} {
                    set tns $val
                    puts "DEBUG: Extracted TNS = $tns from [file tail $f]"
                    break
                } elseif {[regexp -nocase {total\s+negative\s+slack[^0-9\-\.]*([-]?[0-9]+\.[0-9]+|[-]?[0-9]+)} $content match val2]} {
                    set tns $val2
                    puts "DEBUG: Extracted TNS (total neg slack) = $tns from [file tail $f]"
                    break
                }
            }
        }
    }

    # --- Fallback: parse any main opensta timing report if one file contains both values ---
    if {($wns == "N/A") || ($tns == "N/A")} {
        set timing_candidates [concat \
            [glob -nocomplain "$reports_dir/*opensta*.rpt"] \
            [glob -nocomplain "$reports_dir/*opensta*.timing*"] \
            [glob -nocomplain "$reports_dir/*timing*.rpt"] \
            [glob -nocomplain "$logs_dir/*opensta*"] \
        ]

        foreach f $timing_candidates {
            if {$f eq ""} continue
            if {[file exists $f]} {
                puts "DEBUG: Considering general timing candidate: [file tail $f]"
                if {![catch {set fh [open $f r]}]} {
                    set content [read $fh]
                    close $fh
                    if {$wns == "N/A"} {
                        if {[regexp -nocase {wns[^0-9\-\.]*([-]?[0-9]+\.[0-9]+|[-]?[0-9]+)} $content match val]} {
                            set wns $val
                            puts "DEBUG: Extracted WNS = $wns from [file tail $f]"
                        } elseif {[regexp -nocase {worst\s+slack[^0-9\-\.]*([-]?[0-9]+\.[0-9]+|[-]?[0-9]+)} $content match val2]} {
                            set wns $val2
                            puts "DEBUG: Extracted WNS (worst slack) = $wns from [file tail $f]"
                        }
                    }
                    if {$tns == "N/A"} {
                        if {[regexp -nocase {tns[^0-9\-\.]*([-]?[0-9]+\.[0-9]+|[-]?[0-9]+)} $content match val3]} {
                            set tns $val3
                            puts "DEBUG: Extracted TNS = $tns from [file tail $f]"
                        } elseif {[regexp -nocase {total\s+negative\s+slack[^0-9\-\.]*([-]?[0-9]+\.[0-9]+|[-]?[0-9]+)} $content match val4]} {
                            set tns $val4
                            puts "DEBUG: Extracted TNS (total neg slack) = $tns from [file tail $f]"
                        }
                    }
                    if {$wns != "N/A" && $tns != "N/A"} {
                        break
                    }
                }
            }
        }
    }

    # --- Area extraction from synthesis stats (yosys/OpenSTA/OpenROAD) ---
    set stat_candidates [concat \
        [glob -nocomplain "$reports_dir/*yosys*.stat*"] \
        [glob -nocomplain "$reports_dir/*synthesis*.stat*"] \
        [glob -nocomplain "$reports_dir/*synthesis_stats*"] \
        [glob -nocomplain "$logs_dir/*yosys*"] \
        [glob -nocomplain "$reports_dir/*stat*.rpt"] \
    ]

    foreach f $stat_candidates {
        if {$f eq ""} continue
        if {[file exists $f]} {
            puts "DEBUG: Considering stat candidate: [file tail $f]"
            if {![catch {set fh [open $f r]}]} {
                set content [read $fh]
                close $fh
                if {[regexp {Chip area for module.*:\s*([0-9]+(?:\.[0-9]+)?) } $content match a]} {
                    set chip_area $a
                    puts "DEBUG: Extracted chip_area = $chip_area from [file tail $f]"
                    break
                } elseif {[regexp {Number of cells:\s*([0-9]+)} $content match cells]} {
                    set area $cells
                    puts "DEBUG: Extracted cell count = $area from [file tail $f]"
                    break
                } elseif {[regexp {Total\s+cells:\s*([0-9]+)} $content match tc]} {
                    set area $tc
                    puts "DEBUG: Extracted total cell count = $area from [file tail $f]"
                    break
                }
            }
        }
    }

    # Final fallback - try to read OpenROAD log for area
    set openroad_log "$logs_dir/*openroad*.log"
    set openroad_files [glob -nocomplain $openroad_log]
    foreach f $openroad_files {
        if {[file exists $f]} {
            if {![catch {set fh [open $f r]}]} {
                set content [read $fh]
                close $fh
                if {[regexp {Design area\s+([0-9]+)} $content match a2]} {
                    set area $a2
                    puts "DEBUG: Extracted area from OpenROAD log = $area"
                    break
                }
            }
        }
    }

    puts "DEBUG: Final results - WNS: $wns, TNS: $tns, Area: $area, Chip_Area: $chip_area"
    return [list $wns $tns $area $chip_area]
}

# ------------------------------
# PHASE 1: Core timing parameters
# ------------------------------
puts "\n====== PHASE 1: Testing DELAY Strategies with Sizing/Buffering ======\n"

foreach strategy $strategies {
    foreach sizing $sizing_options {
        foreach buffering $buffering_options {
            # Skip invalid combination (both sizing and buffering = 1)
            if {$sizing == 1 && $buffering == 1} {
                continue
            }

            incr run_count
            set current_tag "${BASE_TAG}_${run_count}"

            puts "\n--- Run $run_count ---"
            puts "Strategy: $strategy | Sizing: $sizing | Buffering: $buffering"

            # Prepare design & tag (this creates the run folder)
            prep -design $DESIGN_NAME -tag $current_tag -overwrite

            # Add LEFs (if present)
            set lefs [glob -nocomplain $::env(DESIGN_DIR)/src/*.lef]
            if {[llength $lefs] > 0} {
                add_lefs -src $lefs
            }

            # Set timing-critical parameters
            set ::env(SYNTH_STRATEGY) $strategy
            set ::env(SYNTH_SIZING) $sizing
            set ::env(SYNTH_BUFFERING) $buffering
            set ::env(SYNTH_MAX_FANOUT) 4

            # Run synthesis
            if {[catch {run_synthesis} err]} {
                puts "ERROR: run_synthesis failed: $err"
                set results_fh [open $RESULTS_FILE a]
                puts $results_fh "$run_count,$strategy,$sizing,$buffering,4,default,inv_8,17.65,ERROR,ERROR,ERROR,ERROR"
                close $results_fh
                continue
            }

            # Extract and save metrics (pass current run tag so we search correct run folder)
            set metrics [extract_metrics $current_tag]
            set wns [lindex $metrics 0]
            set tns [lindex $metrics 1]
            set area [lindex $metrics 2]
            set chip_area [lindex $metrics 3]

            puts "→ WNS: $wns | TNS: $tns | Area: $area"

            # CRITICAL CHECK: Stop if first run fails to extract metrics
            if {$run_count == 1 && $wns == "N/A" && $tns == "N/A"} {
                puts "\n=========================================="
                puts "ERROR: Unable to extract WNS/TNS metrics!"
                puts "=========================================="
                puts "The script cannot find the timing report files for the first run."
                puts "Please check the DEBUG output above to see which files exist."
                puts "Stopping script to prevent many failed runs."
                # Save what we have and exit
                set results_fh [open $RESULTS_FILE a]
                puts $results_fh "$run_count,$strategy,$sizing,$buffering,4,default,inv_8,17.65,$wns,$tns,$area,$chip_area"
                close $results_fh
                return
            }

            set results_fh [open $RESULTS_FILE a]
            puts $results_fh "$run_count,$strategy,$sizing,$buffering,4,default,inv_8,17.65,$wns,$tns,$area,$chip_area"
            close $results_fh

            # Track best (closer to zero from negative side)
            if {$wns != "N/A" && $tns != "N/A"} {
                if {[string is double -strict $wns] && [string is double -strict $tns]} {
                    if {$tns > $best_tns || ($tns == $best_tns && $wns > $best_wns)} {
                        set best_wns $wns
                        set best_tns $tns
                        set best_config "Strategy=$strategy, Sizing=$sizing, Buffering=$buffering, Fanout=4"
                        set best_run $run_count
                        puts "★ NEW BEST! WNS=$wns TNS=$tns"
                    }
                }
            }
        }
    }
}

# ------------------------------
# PHASE 2: Fanout optimization
# ------------------------------
puts "\n\n====== PHASE 2: Optimizing MAX_FANOUT ======\n"

foreach fanout $fanout_options {
    incr run_count
    set current_tag "${BASE_TAG}_${run_count}"

    puts "\n--- Run $run_count ---"
    puts "Strategy: DELAY 3 | Sizing: 1 | Fanout: $fanout"

    prep -design $DESIGN_NAME -tag $current_tag -overwrite
    set lefs [glob -nocomplain $::env(DESIGN_DIR)/src/*.lef]
    if {[llength $lefs] > 0} { add_lefs -src $lefs }

    set ::env(SYNTH_STRATEGY) "DELAY 3"
    set ::env(SYNTH_SIZING) 1
    set ::env(SYNTH_BUFFERING) 0
    set ::env(SYNTH_MAX_FANOUT) $fanout

    if {[catch {run_synthesis} err]} {
        puts "ERROR: $err"
        set results_fh [open $RESULTS_FILE a]
        puts $results_fh "$run_count,DELAY 3,1,0,$fanout,default,inv_8,17.65,ERROR,ERROR,ERROR,ERROR"
        close $results_fh
        continue
    }

    set metrics [extract_metrics $current_tag]
    set wns [lindex $metrics 0]
    set tns [lindex $metrics 1]
    set area [lindex $metrics 2]
    set chip_area [lindex $metrics 3]

    puts "→ WNS: $wns | TNS: $tns | Area: $area"

    set results_fh [open $RESULTS_FILE a]
    puts $results_fh "$run_count,DELAY 3,1,0,$fanout,default,inv_8,17.65,$wns,$tns,$area,$chip_area"
    close $results_fh

    if {$wns != "N/A" && $tns != "N/A"} {
        if {[string is double -strict $wns] && [string is double -strict $tns]} {
            if {$tns > $best_tns || ($tns == $best_tns && $wns > $best_wns)} {
                set best_wns $wns
                set best_tns $tns
                set best_config "Strategy=DELAY 3, Sizing=1, Buffering=0, Fanout=$fanout"
                set best_run $run_count
                puts "★ NEW BEST! WNS=$wns TNS=$tns"
            }
        }
    }
}

# ------------------------------
# PHASE 3: MAX_TRAN optimization
# ------------------------------
puts "\n\n====== PHASE 3: Optimizing MAX_TRAN (Critical!) ======\n"

foreach max_tran $max_tran_options {
    incr run_count
    set current_tag "${BASE_TAG}_${run_count}"

    puts "\n--- Run $run_count ---"
    puts "Strategy: DELAY 3 | Sizing: 1 | MaxTran: $max_tran ns"

    prep -design $DESIGN_NAME -tag $current_tag -overwrite
    set lefs [glob -nocomplain $::env(DESIGN_DIR)/src/*.lef]
    if {[llength $lefs] > 0} { add_lefs -src $lefs }

    set ::env(SYNTH_STRATEGY) "DELAY 3"
    set ::env(SYNTH_SIZING) 1
    set ::env(SYNTH_BUFFERING) 0
    set ::env(SYNTH_MAX_FANOUT) 4
    set ::env(SYNTH_MAX_TRAN) $max_tran

    if {[catch {run_synthesis} err]} {
        puts "ERROR: $err"
        set results_fh [open $RESULTS_FILE a]
        puts $results_fh "$run_count,DELAY 3,1,0,4,$max_tran,inv_8,17.65,ERROR,ERROR,ERROR,ERROR"
        close $results_fh
        continue
    }

    set metrics [extract_metrics $current_tag]
    set wns [lindex $metrics 0]
    set tns [lindex $metrics 1]
    set area [lindex $metrics 2]
    set chip_area [lindex $metrics 3]

    puts "→ WNS: $wns | TNS: $tns | Area: $area"

    set results_fh [open $RESULTS_FILE a]
    puts $results_fh "$run_count,DELAY 3,1,0,4,$max_tran,inv_8,17.65,$wns,$tns,$area,$chip_area"
    close $results_fh

    if {$wns != "N/A" && $tns != "N/A"} {
        if {[string is double -strict $wns] && [string is double -strict $tns]} {
            if {$tns > $best_tns || ($tns == $best_tns && $wns > $best_wns)} {
                set best_wns $wns
                set best_tns $tns
                set best_config "Strategy=DELAY 3, Sizing=1, Buffering=0, Fanout=4, MaxTran=$max_tran"
                set best_run $run_count
                puts "★ NEW BEST! WNS=$wns TNS=$tns"
            }
        }
    }
}

# ------------------------------
# PHASE 4: Driving cell optimization
# ------------------------------
puts "\n\n====== PHASE 4: Optimizing DRIVING_CELL strength ======\n"

foreach driving_cell $driving_cells {
    incr run_count
    set current_tag "${BASE_TAG}_${run_count}"

    # Extract cell name for display
    set cell_name [lindex [split $driving_cell "__"] end]

    puts "\n--- Run $run_count ---"
    puts "Strategy: DELAY 3 | Sizing: 1 | Driving Cell: $cell_name"

    prep -design $DESIGN_NAME -tag $current_tag -overwrite
    set lefs [glob -nocomplain $::env(DESIGN_DIR)/src/*.lef]
    if {[llength $lefs] > 0} { add_lefs -src $lefs }

    set ::env(SYNTH_STRATEGY) "DELAY 3"
    set ::env(SYNTH_SIZING) 1
    set ::env(SYNTH_BUFFERING) 0
    set ::env(SYNTH_MAX_FANOUT) 4
    set ::env(SYNTH_DRIVING_CELL) $driving_cell

    if {[catch {run_synthesis} err]} {
        puts "ERROR: $err"
        set results_fh [open $RESULTS_FILE a]
        puts $results_fh "$run_count,DELAY 3,1,0,4,default,$cell_name,17.65,ERROR,ERROR,ERROR,ERROR"
        close $results_fh
        continue
    }

    set metrics [extract_metrics $current_tag]
    set wns [lindex $metrics 0]
    set tns [lindex $metrics 1]
    set area [lindex $metrics 2]
    set chip_area [lindex $metrics 3]

    puts "→ WNS: $wns | TNS: $tns | Area: $area"

    set results_fh [open $RESULTS_FILE a]
    puts $results_fh "$run_count,DELAY 3,1,0,4,default,$cell_name,17.65,$wns,$tns,$area,$chip_area"
    close $results_fh

    if {$wns != "N/A" && $tns != "N/A"} {
        if {[string is double -strict $wns] && [string is double -strict $tns]} {
            if {$tns > $best_tns || ($tns == $best_tns && $wns > $best_wns)} {
                set best_wns $wns
                set best_tns $tns
                set best_config "Strategy=DELAY 3, Sizing=1, Buffering=0, Fanout=4, DrivingCell=$cell_name"
                set best_run $run_count
                puts "★ NEW BEST! WNS=$wns TNS=$tns"
            }
        }
    }
}

# ------------------------------
# PHASE 5: Capacitive load optimization
# ------------------------------
puts "\n\n====== PHASE 5: Optimizing CAP_LOAD ======\n"

foreach cap_load $cap_load_options {
    incr run_count
    set current_tag "${BASE_TAG}_${run_count}"

    puts "\n--- Run $run_count ---"
    puts "Strategy: DELAY 3 | Sizing: 1 | CapLoad: $cap_load fF"

    prep -design $DESIGN_NAME -tag $current_tag -overwrite
    set lefs [glob -nocomplain $::env(DESIGN_DIR)/src/*.lef]
    if {[llength $lefs] > 0} { add_lefs -src $lefs }

    set ::env(SYNTH_STRATEGY) "DELAY 3"
    set ::env(SYNTH_SIZING) 1
    set ::env(SYNTH_BUFFERING) 0
    set ::env(SYNTH_MAX_FANOUT) 4
    set ::env(SYNTH_CAP_LOAD) $cap_load

    if {[catch {run_synthesis} err]} {
        puts "ERROR: $err"
        set results_fh [open $RESULTS_FILE a]
        puts $results_fh "$run_count,DELAY 3,1,0,4,default,inv_8,$cap_load,ERROR,ERROR,ERROR,ERROR"
        close $results_fh
        continue
    }

    set metrics [extract_metrics $current_tag]
    set wns [lindex $metrics 0]
    set tns [lindex $metrics 1]
    set area [lindex $metrics 2]
    set chip_area [lindex $metrics 3]

    puts "→ WNS: $wns | TNS: $tns | Area: $area"

    set results_fh [open $RESULTS_FILE a]
    puts $results_fh "$run_count,DELAY 3,1,0,4,default,inv_8,$cap_load,$wns,$tns,$area,$chip_area"
    close $results_fh

    if {$wns != "N/A" && $tns != "N/A"} {
        if {[string is double -strict $wns] && [string is double -strict $tns]} {
            if {$tns > $best_tns || ($tns == $best_tns && $wns > $best_wns)} {
                set best_wns $wns
                set best_tns $tns
                set best_config "Strategy=DELAY 3, Sizing=1, Buffering=0, Fanout=4, CapLoad=$cap_load"
                set best_run $run_count
                puts "★ NEW BEST! WNS=$wns TNS=$tns"
            }
        }
    }
}

# Final Summary
puts "\n\n=========================================="
puts "     TIMING OPTIMIZATION COMPLETED"
puts "=========================================="
puts "Total synthesis runs: $run_count"
puts "Results file: $RESULTS_FILE"
puts "\n------------------------------------------"
puts "       BEST CONFIGURATION FOUND"
puts "------------------------------------------"
puts "Run #: $best_run"
puts "$best_config"
puts ""
puts "WNS: $best_wns ns"
puts "TNS: $best_tns ns"
puts "==========================================\n"

# Save best configuration to file
set config_file "best_timing_config.tcl"
set cfg_fh [open $config_file w]
puts $cfg_fh "# Best Timing Configuration"
puts $cfg_fh "# Automated sweep result - Run #$best_run"
puts $cfg_fh "#"
puts $cfg_fh "# Results:"
puts $cfg_fh "#   WNS: $best_wns ns"
puts $cfg_fh "#   TNS: $best_tns ns"
puts $cfg_fh "#"
puts $cfg_fh "# Configuration:"
puts $cfg_fh "#   $best_config"
puts $cfg_fh ""
puts $cfg_fh "# To apply: source this after prep and add_lefs"
close $cfg_fh

puts "✓ Best configuration saved to: $config_file"
puts "✓ All results in CSV: $RESULTS_FILE"
puts "\nAnalyze results to find optimal WNS/TNS tradeoff!"
puts "==========================================\n"
