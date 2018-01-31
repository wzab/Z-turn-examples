################################################################################
#
# AXIL2IPB-module
#
################################################################################

AXIL2IPB_MODULE_VERSION = 1.0
AXIL2IPB_MODULE_SITE    = $(TOPDIR)/../axil2ipb
AXIL2IPB_MODULE_SITE_METHOD  = local
AXIL2IPB_MODULES_LICENSE = LGPLv2.1/GPLv2 

AXIL2IPB_MODULE_DEPENDENCIES = linux

define AXIL2IPB_MODULE_BUILD_CMDS
	$(MAKE) -C $(@D) $(LINUX_MAKE_FLAGS) KERNELDIR=$(LINUX_DIR)
endef

define AXIL2IPB_MODULE_INSTALL_TARGET_CMDS
	$(MAKE) -C $(@D) $(LINUX_MAKE_FLAGS) KERNELDIR=$(LINUX_DIR) modules_install
endef

$(eval $(generic-package))
