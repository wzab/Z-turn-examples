set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[0]}]
set_property PACKAGE_PIN R14 [get_ports {LEDS[2]}]
set_property PACKAGE_PIN Y17 [get_ports {LEDS[1]}]
set_property PACKAGE_PIN Y16 [get_ports {LEDS[0]}]




connect_debug_port u_ila_0/probe1 [get_nets [list {design_1_i/s_axis_s2mm_tdata[0]} {design_1_i/s_axis_s2mm_tdata[1]} {design_1_i/s_axis_s2mm_tdata[2]} {design_1_i/s_axis_s2mm_tdata[3]} {design_1_i/s_axis_s2mm_tdata[4]} {design_1_i/s_axis_s2mm_tdata[5]} {design_1_i/s_axis_s2mm_tdata[6]} {design_1_i/s_axis_s2mm_tdata[7]} {design_1_i/s_axis_s2mm_tdata[8]} {design_1_i/s_axis_s2mm_tdata[9]} {design_1_i/s_axis_s2mm_tdata[10]} {design_1_i/s_axis_s2mm_tdata[11]} {design_1_i/s_axis_s2mm_tdata[12]} {design_1_i/s_axis_s2mm_tdata[13]} {design_1_i/s_axis_s2mm_tdata[14]} {design_1_i/s_axis_s2mm_tdata[15]} {design_1_i/s_axis_s2mm_tdata[16]} {design_1_i/s_axis_s2mm_tdata[17]} {design_1_i/s_axis_s2mm_tdata[18]} {design_1_i/s_axis_s2mm_tdata[19]} {design_1_i/s_axis_s2mm_tdata[20]} {design_1_i/s_axis_s2mm_tdata[21]} {design_1_i/s_axis_s2mm_tdata[22]} {design_1_i/s_axis_s2mm_tdata[23]} {design_1_i/s_axis_s2mm_tdata[24]} {design_1_i/s_axis_s2mm_tdata[25]} {design_1_i/s_axis_s2mm_tdata[26]} {design_1_i/s_axis_s2mm_tdata[27]} {design_1_i/s_axis_s2mm_tdata[28]} {design_1_i/s_axis_s2mm_tdata[29]} {design_1_i/s_axis_s2mm_tdata[30]} {design_1_i/s_axis_s2mm_tdata[31]}]]


create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 4096 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list design_1_i/processing_system7_0/inst/FCLK_CLK0]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 32 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {design_1_i/axi_mem_intercon_M00_AXI_WDATA[32]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[33]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[34]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[35]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[36]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[37]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[38]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[39]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[40]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[41]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[42]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[43]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[44]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[45]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[46]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[47]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[48]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[49]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[50]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[51]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[52]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[53]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[54]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[55]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[56]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[57]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[58]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[59]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[60]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[61]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[62]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[63]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 32 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {design_1_i/axi_mem_intercon_M00_AXI_RDATA[32]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[33]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[34]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[35]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[36]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[37]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[38]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[39]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[40]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[41]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[42]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[43]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[44]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[45]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[46]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[47]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[48]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[49]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[50]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[51]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[52]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[53]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[54]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[55]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[56]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[57]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[58]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[59]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[60]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[61]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[62]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[63]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 4 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {design_1_i/axi_mem_intercon_M00_AXI_WSTRB[4]} {design_1_i/axi_mem_intercon_M00_AXI_WSTRB[5]} {design_1_i/axi_mem_intercon_M00_AXI_WSTRB[6]} {design_1_i/axi_mem_intercon_M00_AXI_WSTRB[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 1 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list design_1_i/axi4s_src1_0_interface_axis_TLAST]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 1 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list design_1_i/axi4s_src1_0_interface_axis_TREADY]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 1 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list design_1_i/axi4s_src1_0_interface_axis_TVALID]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets ipb_clk]
