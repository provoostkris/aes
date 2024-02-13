------------------------------------------------------------------------------
--  Compilation execution script
--  rev. 1.0 : 2023 Provoost Kris
------------------------------------------------------------------------------

# Clearing the transcript window:
.main clear

echo "Remove old files"

  proc detect_lib { lib } { if { [file exists $lib]} { echo " library detected $lib" } }
  proc delete_lib { lib } { if { [file exists $lib]} { file delete -force $lib } }
  proc ensure_lib { lib } { if {![file exists $lib]} { vlib $lib } }

  detect_lib work
  delete_lib work
  ensure_lib work
  
echo "Compiling design"

  set path_rtl "../../aes"
  do $path_rtl/modelsim/vcom_rtl.do

  #vcom  -quiet -work work ../quartus/simulation/modelsim/aes.vho

echo "Compiling test bench"

  vcom  -2008 -quiet -work work ../bench/tb_trf_subbytes.vhd
  vcom  -2008 -quiet -work work ../bench/tb_trf_shiftrows.vhd
  vcom  -2008 -quiet -work work ../bench/tb_trf_mixcolumns.vhd
  vcom  -2008 -quiet -work work ../bench/tb_trf_addroundkey.vhd
  vcom  -2008 -quiet -work work ../bench/tb_key_expand.vhd
  vcom  -2008 -quiet -work work ../bench/tb_aes.vhd
  vcom  -2008 -quiet -work work ../bench/tb_aes_wrap.vhd


echo "Compilation script completed "