# Post-CTS STA for VSDBabySoC - Week 8
# Adapted from working All_cornersTest.tcl
# Run with: cat sta_vsdbabysoc_cts.tcl | docker run -i -v $HOME:/data opensta

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

set_cmd_units -time ns -capacitance pF -current mA -voltage V -resistance kOhm -distance um
set_units -time ns -capacitance pF -current mA -voltage V -resistance kOhm -distance um

# Read custom libs first
read_liberty /data/OpenROAD-flow-scripts/VSDBabySoC/OpenSTA/examples/timing_libs/avsdpll.lib
read_liberty /data/OpenROAD-flow-scripts/VSDBabySoC/OpenSTA/examples/timing_libs/avsddac.lib

# For OpenSTA: use Verilog instead of read_db (which is OpenRoad only)
read_verilog /data/OpenROAD-flow-scripts/flow/results/sky130hd/vsdbabysoc/base/1_synth.v
link_design vsdbabysoc
current_design

puts "############################"
puts "### START of Post-CTS STA ###"
puts "############################"

# Loop over standard cell libraries
for {set i 1} {$i <= [array size list_of_lib_files]} {incr i} {
    puts "Running Corner $i: $list_of_lib_files($i)"
    read_liberty /data/OpenROAD-flow-scripts/pdks/sky130A/libs.ref/sky130_fd_sc_hd/lib/$list_of_lib_files($i)
    
    read_sdc /data/OpenROAD-flow-scripts/VSDBabySoC/OpenSTA/examples/BabySOC/vsdbabysoc_synthesis.sdc
    
    check_setup -verbose
    
    # Initialize output files on first iteration
    if { $i == 1 } {
        exec echo -n > /data/OpenROAD-flow-scripts/sta_output_week8/cts/corners_list.txt
        exec echo -n > /data/OpenROAD-flow-scripts/sta_output_week8/cts/sta_worst_max_slack.txt
        exec echo -n > /data/OpenROAD-flow-scripts/sta_output_week8/cts/sta_worst_min_slack.txt
        exec echo -n > /data/OpenROAD-flow-scripts/sta_output_week8/cts/sta_tns.txt
        exec echo -n > /data/OpenROAD-flow-scripts/sta_output_week8/cts/sta_wns.txt
    }
    
    # Log corner name
    exec echo "$list_of_lib_files($i)" >> /data/OpenROAD-flow-scripts/sta_output_week8/cts/corners_list.txt
    
    # Generate detailed timing report
    report_checks -path_delay min_max -fields {nets cap slew input_pins fanout} -digits {4} > /data/OpenROAD-flow-scripts/sta_output_week8/cts/sta_min_max_$list_of_lib_files($i).txt
    
    # Report worst setup slack (max)
    exec echo -ne "$list_of_lib_files($i)    " >> /data/OpenROAD-flow-scripts/sta_output_week8/cts/sta_worst_max_slack.txt
    report_worst_slack -max -digits {4} >> /data/OpenROAD-flow-scripts/sta_output_week8/cts/sta_worst_max_slack.txt
    
    # Report worst hold slack (min)
    exec echo -ne "$list_of_lib_files($i)    " >> /data/OpenROAD-flow-scripts/sta_output_week8/cts/sta_worst_min_slack.txt
    report_worst_slack -min -digits {4} >> /data/OpenROAD-flow-scripts/sta_output_week8/cts/sta_worst_min_slack.txt
    
    # Report total negative slack
    exec echo -ne "$list_of_lib_files($i)    " >> /data/OpenROAD-flow-scripts/sta_output_week8/cts/sta_tns.txt
    report_tns -digits {4} >> /data/OpenROAD-flow-scripts/sta_output_week8/cts/sta_tns.txt
    
    # Report worst negative slack
    exec echo -ne "$list_of_lib_files($i)    " >> /data/OpenROAD-flow-scripts/sta_output_week8/cts/sta_wns.txt
    report_wns -digits {4} >> /data/OpenROAD-flow-scripts/sta_output_week8/cts/sta_wns.txt
}

puts "##########################"
puts "### END of Post-CTS STA ###"
puts "##########################"

exit
    check_setup -verbose
    
    if { $i == 1 } {
        exec echo -n > $output_path/corners_list.txt
        exec echo -n > $output_path/sta_worst_max_slack.txt
        exec echo -n > $output_path/sta_worst_min_slack.txt
        exec echo -n > $output_path/sta_tns.txt
        exec echo -n > $output_path/sta_wns.txt
    } else {
        # Do nothing
    }
    
    exec echo "$list_of_lib_files($i)" >> $output_path/corners_list.txt
    
    report_checks -path_delay min_max -fields {capacitance slew input_pins fanout} -digits {4} > $output_path/sta_min_max_$list_of_lib_files($i).txt
    
    exec echo -ne "$list_of_lib_files($i)    " >> $output_path/sta_worst_max_slack.txt
    report_worst_slack -max -digits {4} >> $output_path/sta_worst_max_slack.txt
    
    exec echo -ne "$list_of_lib_files($i)    " >> $output_path/sta_worst_min_slack.txt
    report_worst_slack -min -digits {4} >> $output_path/sta_worst_min_slack.txt
    
    exec echo -ne "$list_of_lib_files($i)    " >> $output_path/sta_tns.txt
    report_tns -digits {4} >> $output_path/sta_tns.txt
    
    exec echo -ne "$list_of_lib_files($i)    " >> $output_path/sta_wns.txt
    report_wns -digits {4} >> $output_path/sta_wns.txt
}

puts ""
puts "##########################"
puts "### END of Post-CTS STA ###"
puts "##########################"
puts "Output files saved to: $output_path/"

exit
