# Quartus Prime: Generate Tcl File for Project
# File: aes.tcl
# Generated on: Thu Feb  1 23:05:09 2024

# Load Quartus Prime Tcl Project package
package require ::quartus::project
# Load Quartus Prime Tcl Flow package
package require ::quartus::flow

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "aes"]} {
		puts "Project aes is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists aes]} {
		project_open -revision aes aes
	} else {
		project_new -revision aes aes
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY "Cyclone V"
	set_global_assignment -name DEVICE 5CSEBA6U23I7
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 18.1.0
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "16:43:41  AUGUST 01, 2021"
	set_global_assignment -name LAST_QUARTUS_VERSION "22.1std.2 Lite Edition"
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP "-40"
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 100
	set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 256
	set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
	set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
	set_global_assignment -name VHDL_FILE ../../vhdl/aes_pkg.vhd
	set_global_assignment -name VHDL_FILE ../../vhdl/galois_mul.vhd
	set_global_assignment -name VHDL_FILE ../../vhdl/sbox.vhd
	set_global_assignment -name VHDL_FILE ../../vhdl/trf_subbytes.vhd
	set_global_assignment -name VHDL_FILE ../../vhdl/trf_shiftrows.vhd
	set_global_assignment -name VHDL_FILE ../../vhdl/trf_mixcolumns.vhd
	set_global_assignment -name VHDL_FILE ../../vhdl/trf_addroundkey.vhd
	set_global_assignment -name VHDL_FILE ../../vhdl/key_expand.vhd
	set_global_assignment -name VHDL_FILE ../../vhdl/aes.vhd
	set_global_assignment -name EDA_SIMULATION_TOOL "ModelSim (VHDL)"
	set_global_assignment -name EDA_TIME_SCALE "1 ps" -section_id eda_simulation
	set_global_assignment -name EDA_OUTPUT_DATA_FORMAT VHDL -section_id eda_simulation
	set_global_assignment -name EDA_GENERATE_FUNCTIONAL_NETLIST OFF -section_id eda_board_design_timing
	set_global_assignment -name EDA_GENERATE_FUNCTIONAL_NETLIST OFF -section_id eda_board_design_symbol
	set_global_assignment -name EDA_GENERATE_FUNCTIONAL_NETLIST OFF -section_id eda_board_design_signal_integrity
	set_global_assignment -name EDA_GENERATE_FUNCTIONAL_NETLIST OFF -section_id eda_board_design_boundary_scan
	set_global_assignment -name EDA_NATIVELINK_GENERATE_SCRIPT_ONLY ON -section_id eda_simulation
	set_global_assignment -name EDA_RUN_TOOL_AUTOMATICALLY ON -section_id eda_simulation
	set_global_assignment -name DEVICE_FILTER_PIN_COUNT 896
	set_global_assignment -name DEVICE_FILTER_SPEED_GRADE 7
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

	# Commit assignments
	export_assignments

  execute_flow -analysis_and_elaboration
  # quartus_map aes -c aes
  
	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
