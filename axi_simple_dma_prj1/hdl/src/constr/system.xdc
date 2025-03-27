
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

set_property IOSTANDARD LVCMOS33 [get_ports {LEDWZ[0]}]


set_property IOSTANDARD LVCMOS33 [get_ports FCLK_CLK1_50M]
set_property PACKAGE_PIN R14 [get_ports {LEDWZ[0]}]
