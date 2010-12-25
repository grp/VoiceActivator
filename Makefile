include theos/makefiles/common.mk

export GO_EASY_ON_ME=1

BUNDLE_NAME = VAPlugin VAPreferences
TWEAK_NAME = VARelay

VAPlugin_FILES = Plugin.mm
VAPlugin_INSTALL_PATH = /System/Library/VoiceServices/PlugIns/
VAPlugin_BUNDLE_EXTENSION = vsplugin

VAPreferences_FILES = Preferences.mm
VAPreferences_INSTALL_PATH = /Library/PreferenceBundles/
VAPreferences_FRAMEWORKS = UIKit
VAPreferences_PRIVATE_FRAMEWORKS = Preferences

VARelay_FILES = Relay.mm
VARelay_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/tweak.mk

