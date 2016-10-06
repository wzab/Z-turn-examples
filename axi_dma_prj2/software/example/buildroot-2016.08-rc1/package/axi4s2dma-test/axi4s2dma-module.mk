################################################################################
#
# AXI4S2DMA-test
#
################################################################################

AXI4S2DMA_TEST_VERSION = 1.0
AXI4S2DMA_TEST_SITE    = $(TOPDIR)/../axi4s2dma
AXI4S2DMA_TEST_SITE_METHOD  = local
AXI4S2DMA_TEST_LICENSE = LGPLv2.1/GPLv2 

AXI4S2DMA_TEST_DEPENDENCIES = linux axi4s2dma-module

define AXI4S2DMA_TEST_BUILD_CMDS
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/app a4s2d_app
endef

define AXI4S2DMA_TEST_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/app/a4s2d_app $(TARGET_DIR)/usr/bin
endef

$(eval $(generic-package))


