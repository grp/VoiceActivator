include theos/makefiles/common.mk

export GO_EASY_ON_ME=1
export SDKVERSION = 4.2

BUNDLE_NAME = VAPreferences
TWEAK_NAME = VARelay VAPlugin VAInjector
TOOL_NAME = extrainst_ postrm

postrm_FILES = postrm.m
postrm_INSTALL_PATH = /DEBIAN/

extrainst__FILES = extrainst_.m
extrainst__INSTALL_PATH = /DEBIAN/

VAInjector_FILES = VAInjector.mm VAShared.mm
VAInjector_INSTALL_PATH = /Library/VoiceActivator/

VAPlugin_FILES = VAPlugin.xm VAShared.mm

VAPreferences_FILES = VAPreferences.mm VAShared.mm
VAPreferences_INSTALL_PATH = /Library/PreferenceBundles/
VAPreferences_FRAMEWORKS = UIKit
VAPreferences_PRIVATE_FRAMEWORKS = Preferences
VAPreferences_LDFLAGS = -lactivator

VARelay_FILES = VARelay.mm VAShared.mm
VARelay_FRAMEWORKS = UIKit
VARelay_LDFLAGS = -lactivator

include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/tool.mk
include $(THEOS_MAKE_PATH)/tweak.mk

