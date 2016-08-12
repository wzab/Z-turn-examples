################################################################################
#
# AXI-IRQ1-module
#
################################################################################

AXI_IRQ1_MODULE_VERSION = 1.0
AXI_IRQ1_MODULE_SITE    = $(TOPDIR)/../axi_irq1
AXI_IRQ1_MODULE_SITE_METHOD  = local
AXI_IRQ1_MODULE_LICENSE = LGPLv2.1/GPLv2 

AXI_IRQ1_MODULE_DEPENDENCIES = linux

define AXI_IRQ1_MODULE_BUILD_CMDS
	$(MAKE) -C $(@D) $(LINUX_MAKE_FLAGS) KERNELDIR=$(LINUX_DIR)
endef

define AXI_IRQ1_MODULE_INSTALL_TARGET_CMDS
	$(MAKE) -C $(@D) $(LINUX_MAKE_FLAGS) KERNELDIR=$(LINUX_DIR) modules_install
endef

$(eval $(generic-package))
