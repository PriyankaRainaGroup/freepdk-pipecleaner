##### text labels for Calibre LVS #####
source ./design_data/insert_pad_labels.tcl

change_names -rules verilog -hierarchy
##### write out verilog netlist with pg/VDD/VSS #####
write_verilog -no_corner_pad_cells -no_pad_filler_cells -no_core_filler_cells -force_no_output_references {TAPCELLBWP BOUNDARY_LEFTBWP BOUNDARY_RIGHTBWP PAD60GU PRCUTA_G} -force_output_references {ANTENNABWPHVT} -diode_ports -pg -supply_statement none ./chip_pwr.v
##### write out verilog netlist without pg (default) #####
write_verilog -no_pg_pin_only_cells -no_corner_pad_cells -no_pad_filler_cells -no_core_filler_cells -force_no_output_references {TAPCELLBWP BOUNDARY_LEFTBWP BOUNDARY_RIGHTBWP PAD60GU PRCUTA_G ANTENNABWPHVT} -supply_statement none ./chip.v

##### extraction #####
extract_rc -coupling_cap -routed_nets_only -incremental
write_parasitics -output ./chip.spef -format SPEF

##### output files #####
write_sdf -significant_digits 6 ./chip.sdf
write_sdc ./chip.sdc

##### set milkyway CEL #####
save_mw_cel
close_mw_cel
open_mw_cel -readonly chip.CEL

set_write_stream_options \
    -child_depth 99 \
        -output_pin {geometry} \
        -keep_data_type \
        -map_layer /tsmc28/pdk/2016.09.28/TN28CLPR002S1_1_5A/N28_PRTF_Syn_v1d5a/N28_PRTF_Syn_v1d5a/PR_tech/Synopsys/GdsOutMap/gdsout_4X2Y1Z.map

write_stream -cells chip -format gds ./chip.gds

##### generate reports #####
file mkdir ./reports
report_placement_utilization > ./reports/util.rpt
report_timing -delay_type max -significant_digits 4 > ./reports/timing_report_max
report_timing -delay_type min -significant_digits 4 > ./reports/timing_report_min
report_constraint -all -significant_digits 4 > ./reports/constraints_report
report_area > ./reports/area_report
report_power > ./reports/power_report
report_design > ./reports/design_report
check_design > ./reports/design_check

##### reset timing derate and report actual margins #####
reset_timing_derate
report_timing -delay_type max -significant_digits 4 > ./reports/timing_report_max_no_derate
report_timing -delay_type min -significant_digits 4 > ./reports/timing_report_min_no_derate
