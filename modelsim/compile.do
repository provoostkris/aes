------------------------------------------------------------------------------
--  Compilation execution script
--  rev. 1.0 : 2023 Provoost Kris
------------------------------------------------------------------------------

  proc delete_lib { lib } { if ![file isdirectory $lib] { vdel -all -lib $lib } }
  proc ensure_lib { lib } { if ![file isdirectory $lib] { vlib $lib } }

  delete_lib work
  ensure_lib work

echo "Compiling design"

  vcom  -quiet -work work ../vhdl/aes_pkg.vhd
  vcom  -quiet -work work ../vhdl/galois_mul.vhd
  vcom  -quiet -work work ../vhdl/sbox.vhd
  vcom  -quiet -work work ../vhdl/trf_subbytes.vhd
  vcom  -quiet -work work ../vhdl/trf_shiftrows.vhd
  vcom  -quiet -work work ../vhdl/trf_mixcolumns.vhd
  vcom  -quiet -work work ../vhdl/trf_addroundkey.vhd
  vcom  -quiet -work work ../vhdl/key_expand.vhd
  vcom  -quiet -work work ../vhdl/aes.vhd

  #vcom  -quiet -work work ../quartus/simulation/modelsim/aes.vho

echo "Compiling test bench"

  vcom  -quiet -work work ../bench/tb_trf_subbytes.vhd
  vcom  -quiet -work work ../bench/tb_trf_shiftrows.vhd
  vcom  -quiet -work work ../bench/tb_trf_mixcolumns.vhd
  vcom  -quiet -work work ../bench/tb_trf_addroundkey.vhd
  vcom  -quiet -work work ../bench/tb_key_expand.vhd
  vcom  -quiet -work work ../bench/tb_aes.vhd


echo "Compilation script completed "