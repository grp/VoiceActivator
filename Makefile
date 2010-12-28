include theos/makefiles/common.mk

export GO_EASY_ON_ME=1

BUNDLE_NAME = VAPlugin VAPreferences
TWEAK_NAME = VARelay

VAPlugin_FILES = VAPlugin.mm VAShared.mm
VAPlugin_INSTALL_PATH = /System/Library/VoiceServices/PlugIns/
VAPlugin_BUNDLE_EXTENSION = vsplugin

VAPreferences_FILES = VAPreferences.mm VAShared.mm
VAPreferences_INSTALL_PATH = /Library/PreferenceBundles/
VAPreferences_FRAMEWORKS = UIKit
VAPreferences_PRIVATE_FRAMEWORKS = Preferences
VAPreferences_LDFLAGS = -lactivator

VARelay_FILES = VARelay.mm VAShared.mm
VARelay_FRAMEWORKS = UIKit
VARelay_LDFLAGS = -lactivator

include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/tweak.mk

