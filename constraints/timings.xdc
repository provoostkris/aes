# CLOCKS external

  create_clock -period 10.000 [get_ports clk]

# False paths

  set_false_path -from                [get_ports rst_n]