include theos/makefiles/common.mk

export GO_EASY_ON_ME=1
export SDKVERSION = 4.2

BUNDLE_NAME = VAPreferences
TWEAK_NAME = VARelay VAPlugin VAInjector

VAInjector_FILES = VAInjector.mm VAShared.mm
VAInjector_INSTALL_PATH = /Library/VoiceActivator/
VAInjector_FRAMEWORKS = UIKit CoreTelephony

VAPlugin_FILES = VAPlugin.xm VAShared.mm
VAPlugin_FRAMEWORKS = UIKit CoreTelephony

VAPreferences_FILES = VAPreferences.mm VAShared.mm
VAPreferences_INSTALL_PATH = /Library/PreferenceBundles/
VAPreferences_FRAMEWORKS = UIKit CoreTelephony
VAPreferences_PRIVATE_FRAMEWORKS = Preferences
VAPreferences_LDFLAGS = -lactivator

VARelay_FILES = VARelay.mm VAShared.mm
VARelay_FRAMEWORKS = UIKit CoreTelephony AudioToolbox CoreGraphics
VARelay_LDFLAGS = -lactivator

include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/tweak.mk

