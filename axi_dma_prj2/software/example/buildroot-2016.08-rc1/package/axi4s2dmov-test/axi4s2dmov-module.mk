################################################################################
#
# AXI4S2DMOV-test
#
################################################################################

AXI4S2DMOV_TEST_VERSION = 1.0
AXI4S2DMOV_TEST_SITE    = $(TOPDIR)/../axi4s2dmov
AXI4S2DMOV_TEST_SITE_METHOD  = local
AXI4S2DMOV_TEST_LICENSE = LGPLv2.1/GPLv2 

AXI4S2DMOV_TEST_DEPENDENCIES = linux axi4s2dmov-module

define AXI4S2DMOV_TEST_BUILD_CMDS
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/app a4s2d_app
endef

define AXI4S2DMOV_TEST_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/app/a4s2d_app $(TARGET_DIR)/usr/bin
endef

$(eval $(generic-package))


