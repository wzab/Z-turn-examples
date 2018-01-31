
 PARAMETER VERSION = 2.2.0


BEGIN OS
 PARAMETER OS_NAME = device_tree
 PARAMETER PROC_INSTANCE = ps7_cortexa9_0
 PARAMETER console_device = ps7_uart_1
 PARAMETER main_memory = ps7_ddr_0
END


BEGIN PROCESSOR
 PARAMETER DRIVER_NAME = cpu_cortexa9
 PARAMETER HW_INSTANCE = ps7_cortexa9_0
END


BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = axi_fifo_mm_s_0
 PARAMETER compatible = xlnx,axi-fifo-mm-s-4.1
 PARAMETER interrupt-parent = intc
 PARAMETER interrupts = 0 29 4
 PARAMETER reg = 0x43c10000 0x10000
 PARAMETER xlnx,axi-str-rxd-protocol = XIL_AXI_STREAM_ETH_DATA
 PARAMETER xlnx,axi-str-rxd-tdata-width = 32
 PARAMETER xlnx,axi-str-txc-protocol = XIL_AXI_STREAM_ETH_CTRL
 PARAMETER xlnx,axi-str-txc-tdata-width = 32
 PARAMETER xlnx,axi-str-txd-protocol = XIL_AXI_STREAM_ETH_DATA
 PARAMETER xlnx,axi-str-txd-tdata-width = 32
 PARAMETER xlnx,axis-tdest-width = 4
 PARAMETER xlnx,axis-tid-width = 4
 PARAMETER xlnx,axis-tuser-width = 4
 PARAMETER xlnx,data-interface-type = 0
 PARAMETER xlnx,has-axis-tdest = 0
 PARAMETER xlnx,has-axis-tid = 0
 PARAMETER xlnx,has-axis-tkeep = 1
 PARAMETER xlnx,has-axis-tstrb = 1
 PARAMETER xlnx,has-axis-tuser = 0
 PARAMETER xlnx,rx-fifo-depth = 512
 PARAMETER xlnx,rx-fifo-pe-threshold = 2
 PARAMETER xlnx,rx-fifo-pf-threshold = 507
 PARAMETER xlnx,s-axi-id-width = 4
 PARAMETER xlnx,s-axi4-data-width = 32
 PARAMETER xlnx,select-xpm = 0
 PARAMETER xlnx,tx-fifo-depth = 512
 PARAMETER xlnx,tx-fifo-pe-threshold = 2
 PARAMETER xlnx,tx-fifo-pf-threshold = 507
 PARAMETER xlnx,use-rx-cut-through = 0
 PARAMETER xlnx,use-rx-data = 1
 PARAMETER xlnx,use-tx-ctrl = 0
 PARAMETER xlnx,use-tx-cut-through = 0
 PARAMETER xlnx,use-tx-data = 1
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = gpio
 PARAMETER HW_INSTANCE = axi_gpio_ctl
 PARAMETER reg = 0x41200000 0x10000
 PARAMETER xlnx,all-inputs = 0
 PARAMETER xlnx,all-inputs-2 = 0
 PARAMETER xlnx,all-outputs = 1
 PARAMETER xlnx,all-outputs-2 = 0
 PARAMETER xlnx,dout-default = 0x00000000
 PARAMETER xlnx,dout-default-2 = 0x00000000
 PARAMETER xlnx,gpio-width = 2
 PARAMETER xlnx,gpio2-width = 32
 PARAMETER xlnx,interrupt-present = 0
 PARAMETER xlnx,is-dual = 0
 PARAMETER xlnx,tri-default = 0xFFFFFFFF
 PARAMETER xlnx,tri-default-2 = 0xFFFFFFFF
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = axil2ipb_0
 PARAMETER compatible = xlnx,axil2ipb-1.0
 PARAMETER reg = 0x43c00000 0x10000
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = ps7_afi_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = ps7_afi_1
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = ps7_afi_2
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = ps7_afi_3
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = ps7_coresight_comp_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = ddrps
 PARAMETER HW_INSTANCE = ps7_ddr_0
 PARAMETER reg = 0x0 0x40000000
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = ddrcps
 PARAMETER HW_INSTANCE = ps7_ddrc_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = devcfg
 PARAMETER HW_INSTANCE = ps7_dev_cfg_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = none
 PARAMETER HW_INSTANCE = ps7_dma_ns
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = dmaps
 PARAMETER HW_INSTANCE = ps7_dma_s
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = emacps
 PARAMETER HW_INSTANCE = ps7_ethernet_0
 PARAMETER phy-mode = rgmii-id
 PARAMETER xlnx,ptp-enet-clock = 111111115
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = globaltimerps
 PARAMETER HW_INSTANCE = ps7_globaltimer_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = gpiops
 PARAMETER HW_INSTANCE = ps7_gpio_0
 PARAMETER emio-gpio-width = 64
 PARAMETER gpio-mask-high = 0
 PARAMETER gpio-mask-low = 22016
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = ps7_gpv_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = ps7_intc_dist_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = ps7_iop_bus_config_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = ps7_l2cachec_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = ocmcps
 PARAMETER HW_INSTANCE = ps7_ocmc_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = pl310ps
 PARAMETER HW_INSTANCE = ps7_pl310_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = pmups
 PARAMETER HW_INSTANCE = ps7_pmu_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = ramps
 PARAMETER HW_INSTANCE = ps7_ram_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = none
 PARAMETER HW_INSTANCE = ps7_ram_1
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = ps7_scuc_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = scugic
 PARAMETER HW_INSTANCE = ps7_scugic_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = scutimer
 PARAMETER HW_INSTANCE = ps7_scutimer_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = scuwdt
 PARAMETER HW_INSTANCE = ps7_scuwdt_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER HW_INSTANCE = ps7_sd_0
 PARAMETER xlnx,has-cd = 1
 PARAMETER xlnx,has-power = 0
 PARAMETER xlnx,has-wp = 1
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = slcrps
 PARAMETER HW_INSTANCE = ps7_slcr_0
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = uartps
 PARAMETER HW_INSTANCE = ps7_uart_1
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = xadcps
 PARAMETER HW_INSTANCE = ps7_xadc_0
END


