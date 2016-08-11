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
connect_debug_port u_ila_0/probe0 [get_nets [list {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[0]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[1]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[2]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[3]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[4]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[5]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[6]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[7]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[8]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[9]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[10]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[11]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[12]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[13]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[14]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[15]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[16]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[17]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[18]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[19]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[20]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[21]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[22]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[23]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[24]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[25]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[26]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[27]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[28]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[29]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[30]} {design_1_i/axi_mem_intercon_M00_AXI_ARADDR[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 2 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {design_1_i/axi_mem_intercon_M00_AXI_ARBURST[0]} {design_1_i/axi_mem_intercon_M00_AXI_ARBURST[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 4 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {design_1_i/axi_mem_intercon_M00_AXI_ARCACHE[0]} {design_1_i/axi_mem_intercon_M00_AXI_ARCACHE[1]} {design_1_i/axi_mem_intercon_M00_AXI_ARCACHE[2]} {design_1_i/axi_mem_intercon_M00_AXI_ARCACHE[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 4 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {design_1_i/axi_mem_intercon_M00_AXI_ARLEN[0]} {design_1_i/axi_mem_intercon_M00_AXI_ARLEN[1]} {design_1_i/axi_mem_intercon_M00_AXI_ARLEN[2]} {design_1_i/axi_mem_intercon_M00_AXI_ARLEN[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 2 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {design_1_i/axi_mem_intercon_M00_AXI_ARLOCK[0]} {design_1_i/axi_mem_intercon_M00_AXI_ARLOCK[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 3 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {design_1_i/axi_mem_intercon_M00_AXI_ARPROT[0]} {design_1_i/axi_mem_intercon_M00_AXI_ARPROT[1]} {design_1_i/axi_mem_intercon_M00_AXI_ARPROT[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 4 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {design_1_i/axi_mem_intercon_M00_AXI_ARQOS[0]} {design_1_i/axi_mem_intercon_M00_AXI_ARQOS[1]} {design_1_i/axi_mem_intercon_M00_AXI_ARQOS[2]} {design_1_i/axi_mem_intercon_M00_AXI_ARQOS[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 3 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {design_1_i/axi_mem_intercon_M00_AXI_ARSIZE[0]} {design_1_i/axi_mem_intercon_M00_AXI_ARSIZE[1]} {design_1_i/axi_mem_intercon_M00_AXI_ARSIZE[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 32 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[0]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[1]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[2]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[3]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[4]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[5]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[6]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[7]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[8]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[9]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[10]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[11]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[12]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[13]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[14]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[15]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[16]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[17]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[18]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[19]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[20]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[21]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[22]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[23]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[24]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[25]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[26]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[27]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[28]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[29]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[30]} {design_1_i/axi_mem_intercon_M00_AXI_AWADDR[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 2 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {design_1_i/axi_mem_intercon_M00_AXI_AWBURST[0]} {design_1_i/axi_mem_intercon_M00_AXI_AWBURST[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 4 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {design_1_i/axi_mem_intercon_M00_AXI_AWCACHE[0]} {design_1_i/axi_mem_intercon_M00_AXI_AWCACHE[1]} {design_1_i/axi_mem_intercon_M00_AXI_AWCACHE[2]} {design_1_i/axi_mem_intercon_M00_AXI_AWCACHE[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 4 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {design_1_i/axi_mem_intercon_M00_AXI_AWLEN[0]} {design_1_i/axi_mem_intercon_M00_AXI_AWLEN[1]} {design_1_i/axi_mem_intercon_M00_AXI_AWLEN[2]} {design_1_i/axi_mem_intercon_M00_AXI_AWLEN[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 2 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {design_1_i/axi_mem_intercon_M00_AXI_AWLOCK[0]} {design_1_i/axi_mem_intercon_M00_AXI_AWLOCK[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 3 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {design_1_i/axi_mem_intercon_M00_AXI_AWPROT[0]} {design_1_i/axi_mem_intercon_M00_AXI_AWPROT[1]} {design_1_i/axi_mem_intercon_M00_AXI_AWPROT[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 4 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {design_1_i/axi_mem_intercon_M00_AXI_AWQOS[0]} {design_1_i/axi_mem_intercon_M00_AXI_AWQOS[1]} {design_1_i/axi_mem_intercon_M00_AXI_AWQOS[2]} {design_1_i/axi_mem_intercon_M00_AXI_AWQOS[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 3 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {design_1_i/axi_mem_intercon_M00_AXI_AWSIZE[0]} {design_1_i/axi_mem_intercon_M00_AXI_AWSIZE[1]} {design_1_i/axi_mem_intercon_M00_AXI_AWSIZE[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 6 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list {design_1_i/axi_mem_intercon_M00_AXI_BID[0]} {design_1_i/axi_mem_intercon_M00_AXI_BID[1]} {design_1_i/axi_mem_intercon_M00_AXI_BID[2]} {design_1_i/axi_mem_intercon_M00_AXI_BID[3]} {design_1_i/axi_mem_intercon_M00_AXI_BID[4]} {design_1_i/axi_mem_intercon_M00_AXI_BID[5]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 2 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list {design_1_i/axi_mem_intercon_M00_AXI_BRESP[0]} {design_1_i/axi_mem_intercon_M00_AXI_BRESP[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 32 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list {design_1_i/axi_mem_intercon_M00_AXI_RDATA[0]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[1]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[2]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[3]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[4]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[5]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[6]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[7]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[8]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[9]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[10]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[11]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[12]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[13]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[14]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[15]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[16]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[17]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[18]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[19]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[20]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[21]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[22]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[23]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[24]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[25]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[26]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[27]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[28]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[29]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[30]} {design_1_i/axi_mem_intercon_M00_AXI_RDATA[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 6 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list {design_1_i/axi_mem_intercon_M00_AXI_RID[0]} {design_1_i/axi_mem_intercon_M00_AXI_RID[1]} {design_1_i/axi_mem_intercon_M00_AXI_RID[2]} {design_1_i/axi_mem_intercon_M00_AXI_RID[3]} {design_1_i/axi_mem_intercon_M00_AXI_RID[4]} {design_1_i/axi_mem_intercon_M00_AXI_RID[5]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 2 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list {design_1_i/axi_mem_intercon_M00_AXI_RRESP[0]} {design_1_i/axi_mem_intercon_M00_AXI_RRESP[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 32 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list {design_1_i/axi_mem_intercon_M00_AXI_WDATA[0]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[1]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[2]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[3]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[4]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[5]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[6]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[7]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[8]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[9]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[10]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[11]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[12]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[13]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[14]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[15]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[16]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[17]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[18]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[19]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[20]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[21]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[22]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[23]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[24]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[25]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[26]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[27]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[28]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[29]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[30]} {design_1_i/axi_mem_intercon_M00_AXI_WDATA[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 4 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list {design_1_i/axi_mem_intercon_M00_AXI_WSTRB[0]} {design_1_i/axi_mem_intercon_M00_AXI_WSTRB[1]} {design_1_i/axi_mem_intercon_M00_AXI_WSTRB[2]} {design_1_i/axi_mem_intercon_M00_AXI_WSTRB[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 32 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list {design_1_i/axi4s_src1_0_interface_axis_TDATA[0]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[1]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[2]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[3]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[4]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[5]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[6]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[7]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[8]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[9]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[10]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[11]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[12]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[13]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[14]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[15]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[16]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[17]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[18]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[19]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[20]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[21]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[22]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[23]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[24]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[25]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[26]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[27]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[28]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[29]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[30]} {design_1_i/axi4s_src1_0_interface_axis_TDATA[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 4 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list {design_1_i/axi4s_src1_0_interface_axis_TKEEP[0]} {design_1_i/axi4s_src1_0_interface_axis_TKEEP[1]} {design_1_i/axi4s_src1_0_interface_axis_TKEEP[2]} {design_1_i/axi4s_src1_0_interface_axis_TKEEP[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
set_property port_width 1 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list design_1_i/axi_mem_intercon_M00_AXI_ARID]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
set_property port_width 1 [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list design_1_i/axi_mem_intercon_M00_AXI_ARREADY]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe27]
set_property port_width 1 [get_debug_ports u_ila_0/probe27]
connect_debug_port u_ila_0/probe27 [get_nets [list design_1_i/axi_mem_intercon_M00_AXI_ARVALID]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe28]
set_property port_width 1 [get_debug_ports u_ila_0/probe28]
connect_debug_port u_ila_0/probe28 [get_nets [list design_1_i/axi_mem_intercon_M00_AXI_AWID]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe29]
set_property port_width 1 [get_debug_ports u_ila_0/probe29]
connect_debug_port u_ila_0/probe29 [get_nets [list design_1_i/axi_mem_intercon_M00_AXI_AWREADY]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe30]
set_property port_width 1 [get_debug_ports u_ila_0/probe30]
connect_debug_port u_ila_0/probe30 [get_nets [list design_1_i/axi_mem_intercon_M00_AXI_AWVALID]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe31]
set_property port_width 1 [get_debug_ports u_ila_0/probe31]
connect_debug_port u_ila_0/probe31 [get_nets [list design_1_i/axi_mem_intercon_M00_AXI_BREADY]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe32]
set_property port_width 1 [get_debug_ports u_ila_0/probe32]
connect_debug_port u_ila_0/probe32 [get_nets [list design_1_i/axi_mem_intercon_M00_AXI_BVALID]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe33]
set_property port_width 1 [get_debug_ports u_ila_0/probe33]
connect_debug_port u_ila_0/probe33 [get_nets [list design_1_i/axi_mem_intercon_M00_AXI_RLAST]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe34]
set_property port_width 1 [get_debug_ports u_ila_0/probe34]
connect_debug_port u_ila_0/probe34 [get_nets [list design_1_i/axi_mem_intercon_M00_AXI_RREADY]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe35]
set_property port_width 1 [get_debug_ports u_ila_0/probe35]
connect_debug_port u_ila_0/probe35 [get_nets [list design_1_i/axi_mem_intercon_M00_AXI_RVALID]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe36]
set_property port_width 1 [get_debug_ports u_ila_0/probe36]
connect_debug_port u_ila_0/probe36 [get_nets [list design_1_i/axi_mem_intercon_M00_AXI_WID]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe37]
set_property port_width 1 [get_debug_ports u_ila_0/probe37]
connect_debug_port u_ila_0/probe37 [get_nets [list design_1_i/axi_mem_intercon_M00_AXI_WLAST]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe38]
set_property port_width 1 [get_debug_ports u_ila_0/probe38]
connect_debug_port u_ila_0/probe38 [get_nets [list design_1_i/axi_mem_intercon_M00_AXI_WREADY]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe39]
set_property port_width 1 [get_debug_ports u_ila_0/probe39]
connect_debug_port u_ila_0/probe39 [get_nets [list design_1_i/axi_mem_intercon_M00_AXI_WVALID]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets ipb_clk]
