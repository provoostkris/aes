------------------------------------------------------------------------------
--  Simulation execution script
--  rev. 1.0 : 2023 Provoost Kris
------------------------------------------------------------------------------

  do compile.do

echo "start simulation"

  vsim -gui -t ps -novopt work.tb_aes

echo "adding waves"

  view wave
  delete wave /*
  
  add wave  -expand             -group "dut i/o"     -ports            /tb_aes/dut/*
  add wave  -expand -radix hex  -group "dut sig"     -internal         /tb_aes/dut/*
  
  add wave  -expand -radix hex  -group "i_key_expand"            -internal         /tb_aes/dut/i_key_expand/*
  add wave  -expand -radix hex  -group "i_trf_addroundkey"       -internal         /tb_aes/dut/i_trf_addroundkey/*
  
  add wave  -expand -radix hex  -group "1.i_trf_subbytes"        -internal         /tb_aes/dut/gen_rounds(1)/i_trf_subbytes/*
  add wave  -expand -radix hex  -group "1.i_trf_shiftrows"       -internal         /tb_aes/dut/gen_rounds(1)/i_trf_shiftrows/*
  add wave  -expand -radix hex  -group "1.i_trf_mixcolumns"      -internal         /tb_aes/dut/gen_rounds(1)/i_trf_mixcolumns/*
  add wave  -expand -radix hex  -group "1.i_trf_addroundkey"     -internal         /tb_aes/dut/gen_rounds(1)/i_trf_addroundkey/*

echo "view wave forms"

  set NumericStdNoWarnings 1
  set StdArithNoWarnings 1
  run 1 ns
  set NumericStdNoWarnings 0
  set StdArithNoWarnings 0

  run 10 us

  configure wave -namecolwidth  370
  configure wave -valuecolwidth 180
  configure wave -justifyvalue right
  configure wave -signalnamewidth 1
  configure wave -snapdistance 10
  configure wave -datasetprefix 0
  configure wave -rowmargin 4
  configure wave -childrowmargin 2
  configure wave -gridoffset 0
  configure wave -gridperiod 1
  configure wave -griddelta 40
  configure wave -timeline 1
  configure wave -timelineunits us
  update

  wave zoom full