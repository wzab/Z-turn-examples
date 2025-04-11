################################################################################
#
# WZDEMO-modules
#
################################################################################

WZDEMO_MODULES_VERSION = 1.0
WZDEMO_MODULES_SITE    = $(BR2_EXTERNAL_SWIS2_PATH)/src/wzdemo
WZDEMO_MODULES_SITE_METHOD = local
WZDEMO_MODULES_LICENSE = LGPLv2.1/GPLv2 

$(eval $(kernel-module))
$(eval $(generic-package))
