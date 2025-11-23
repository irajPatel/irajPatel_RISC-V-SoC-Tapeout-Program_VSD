# Post-Synthesis STA for VSDBabySoC - Week 8
# Adapted from working All_cornersTest.tcl
# Corrected paths for /home/iraj/OpenROAD-flow-scripts environment
# Run with: cat sta_vsdbabysoc_synth.tcl | docker run -v $HOME:/data opensta

# List of standard cell liberty files
set list_of_lib_files(1)  "sky130_fd_sc_hd__tt_025C_1v80.lib"
set list_of_lib_files(2)  "sky130_fd_sc_hd__tt_100C_1v80.lib"
set list_of_lib_files(3)  "sky130_fd_sc_hd__ff_100C_1v65.lib"
set list_of_lib_files(4)  "sky130_fd_sc_hd__ff_100C_1v95.lib"
set list_of_lib_files(5)  "sky130_fd_sc_hd__ff_n40C_1v56.lib"
set list_of_lib_files(6)  "sky130_fd_sc_hd__ff_n40C_1v65.lib"
set list_of_lib_files(7)  "sky130_fd_sc_hd__ff_n40C_1v76.lib"
set list_of_lib_files(8)  "sky130_fd_sc_hd__ff_n40C_1v95.lib"
set list_of_lib_files(9)  "sky130_fd_sc_hd__ss_100C_1v40.lib"
set list_of_lib_files(10) "sky130_fd_sc_hd__ss_100C_1v60.lib"
set list_of_lib_files(11) "sky130_fd_sc_hd__ss_n40C_1v28.lib"
set list_of_lib_files(12) "sky130_fd_sc_hd__ss_n40C_1v35.lib"
set list_of_lib_files(13) "sky130_fd_sc_hd__ss_n40C_1v40.lib"
set list_of_lib_files(14) "sky130_fd_sc_hd__ss_n40C_1v44.lib"
set list_of_lib_files(15) "sky130_fd_sc_hd__ss_n40C_1v60.lib"
set list_of_lib_files(16) "sky130_fd_sc_hd__ss_n40C_1v76.lib"

# CORRECTED PATHS for VSDBabySoC - Docker mount paths
set lib_path "/data/OpenROAD-flow-scripts/pdks/sky130A/libs.ref/sky130_fd_sc_hd/lib"
set custom_lib_path "/data/OpenROAD-flow-scripts/VSDBabySoC/OpenSTA/examples/timing_libs"
set design_path "/data/OpenROAD-flow-scripts/spef_verilog_output"
set sdc_path "/data/OpenROAD-flow-scripts/VSDBabySoC/OpenSTA/examples/BabySOC"
set output_path "/data/OpenROAD-flow-scripts/sta_output_week8/placement"

puts "###################################"
puts "### START of Post-Placement STA ###"
puts "### VSDBabySoC Week 8 Analysis  ###"
puts "###################################"
puts ""

# Read custom libs first (if they exist)
if {[file exists $custom_lib_path/avsdpll.lib]} {
    read_liberty $custom_lib_path/avsdpll.lib
    puts "Loaded avsdpll.lib"
}
if {[file exists $custom_lib_path/avsddac.lib]} {
    read_liberty $custom_lib_path/avsddac.lib
    puts "Loaded avsddac.lib"
}

# Loop over standard cell libraries
for {set i 1} {$i <= [array size list_of_lib_files]} {incr i} {
    puts "Running Corner $i/[array size list_of_lib_files]: $list_of_lib_files($i)"
    
    read_liberty $lib_path/$list_of_lib_files($i)
    read_verilog $design_path/vsdbabysoc_post_place.v
    link_design vsdbabysoc
    current_design
    
    read_sdc $sdc_path/vsdbabysoc_synthesis.sdc
    
    check_setup -verbose
    
    # Initialize output files on first iteration
    if { $i == 1 } {
        exec echo -n > $output_path/corners_list.txt
        exec echo -n > $output_path/sta_worst_max_slack.txt
        exec echo -n > $output_path/sta_worst_min_slack.txt
        exec echo -n > $output_path/sta_tns.txt
        exec echo -n > $output_path/sta_wns.txt
    }
    
    # Log corner name
    exec echo "$list_of_lib_files($i)" >> $output_path/corners_list.txt
    
    # Generate detailed timing report
    report_checks -path_delay min_max -fields {nets cap slew input_pins fanout} -digits {4} > $output_path/sta_min_max_$list_of_lib_files($i).txt
    
    # Report worst setup slack (max)
    exec echo -ne "$list_of_lib_files($i)    " >> $output_path/sta_worst_max_slack.txt
    report_worst_slack -max -digits {4} >> $output_path/sta_worst_max_slack.txt
    
    # Report worst hold slack (min)
    exec echo -ne "$list_of_lib_files($i)    " >> $output_path/sta_worst_min_slack.txt
    report_worst_slack -min -digits {4} >> $output_path/sta_worst_min_slack.txt
    
    # Report total negative slack
    exec echo -ne "$list_of_lib_files($i)    " >> $output_path/sta_tns.txt
    report_tns -digits {4} >> $output_path/sta_tns.txt
    
    # Report worst negative slack
    exec echo -ne "$list_of_lib_files($i)    " >> $output_path/sta_wns.txt
    report_wns -digits {4} >> $output_path/sta_wns.txt
}

puts ""
puts "###################################"
puts "### END of Post-Placement STA ###"
puts "###################################"
puts "Output files saved to: $output_path/"
puts ""

exit
