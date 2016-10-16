################################################################################
#
# AXI4S2DMOV-module
#
################################################################################

AXI4S2DMOV_MODULE_VERSION = 1.0
AXI4S2DMOV_MODULE_SITE    = $(TOPDIR)/../axi4s2dmov
AXI4S2DMOV_MODULE_SITE_METHOD  = local
AXI4S2DMOV_MODULES_LICENSE = LGPLv2.1/GPLv2 

AXI4S2DMOV_MODULE_DEPENDENCIES = linux

define AXI4S2DMOV_MODULE_BUILD_CMDS
	$(MAKE) -C $(@D) $(LINUX_MAKE_FLAGS) KERNELDIR=$(LINUX_DIR)
endef

define AXI4S2DMOV_MODULE_INSTALL_TARGET_CMDS
	$(MAKE) -C $(@D) $(LINUX_MAKE_FLAGS) KERNELDIR=$(LINUX_DIR) modules_install
endef

$(eval $(generic-package))
