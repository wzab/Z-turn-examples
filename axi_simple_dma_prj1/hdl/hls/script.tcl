open_project proj
set_top dma1
add_files src/dma_xor_engine.cpp
add_files -tb src/dma_xor_engine_tb.cpp -cflags "-Wno-unknown-pragmas" -csimflags "-Wno-unknown-pragmas"
open_solution "solution1"
set_part {xc7z020clg400-1}
create_clock -period 4 -name default
config_export -description {WZab simple DMA core written in HLS} -display_name WZ_DMA_HLS -format ip_catalog -rtl vhdl -vendor WZab -version 1.35 -vivado_optimization_level 2 -vivado_phys_opt place -vivado_report_level 0
config_sdx -target none
config_interface -clock_enable=0 -m_axi_addr64=0 -m_axi_offset direct -register_io off
#source "./dma1/solution1/directives.tcl"
#csim_design -clean
csynth_design
set Revision [expr [clock seconds] / 10]
#cosim_design -O -wave_debug -trace_level port -argv {-debug} -tool xsim
export_design -rtl vhdl -format ip_catalog \
   -ipname "dma1" \
   -description "WZab simple DMA core written in HLS" -vendor "WZab"\
   -version 1.35.$Revision -display_name "WZ_SIMPLE_DMA_HLS"
