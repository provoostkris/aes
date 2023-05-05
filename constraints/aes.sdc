#------------------------------------------------------------------------------
#--  Quartus timing constraint file for HDMI <> Terrasic DE10 nano Cyclone 5 design
#--  rev. 1.0 : 2021 Provoost Kris
#------------------------------------------------------------------------------

# clock definitions
create_clock -name fpga_clk_1  -period 20    [get_ports FPGA_CLK1_50]
create_clock -name fpga_clk_2  -period 20    [get_ports FPGA_CLK2_50]
create_clock -name fpga_clk_3  -period 20    [get_ports FPGA_CLK3_50]

# set false paths from user I/O
set_false_path -from [get_ports { KEY[0] KEY[1] } ]           -to [get_registers *]
set_false_path -from [get_ports { SW[0] SW[1] SW[2] SW[3] } ] -to [get_registers *]
set_false_path                                                -to [get_ports { Led[*] } ]