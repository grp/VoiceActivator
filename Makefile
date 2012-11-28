include theos/makefiles/common.mk

export GO_EASY_ON_ME = 1
export TARGET = iphone:latest:5.0
export TARGET_STRIP_FLAGS = -u
export ARCHS = armv7

BUNDLE_NAME = VAPreferences
TWEAK_NAME = VARelay VAPlugin VAInjector

VAInjector_FILES = VAInjector.mm VAShared.mm
VAInjector_FRAMEWORKS = CoreFoundation UIKit CoreTelephony AudioToolbox AVFoundation
VAInjector_PRIVATE_FRAMEWORKS = VoiceServices

VAPlugin_FILES = VAPlugin.xm VAShared.mm
VAPlugin_FRAMEWORKS = CoreFoundation UIKit CoreTelephony AudioToolbox AVFoundation

VAPreferences_FILES = VAPreferences.mm VAShared.mm
VAPreferences_INSTALL_PATH = /Library/PreferenceBundles/
VAPreferences_FRAMEWORKS = CoreFoundation UIKit CoreTelephony AudioToolbox AVFoundation
VAPreferences_PRIVATE_FRAMEWORKS = VoiceServices Preferences
VAPreferences_LDFLAGS = -lactivator

VARelay_FILES = VARelay.mm VAShared.mm
VARelay_FRAMEWORKS = CoreFoundation UIKit CoreTelephony AudioToolbox AVFoundation CoreGraphics
VARelay_PRIVATE_FRAMEWORKS = VoiceServices
VARelay_LDFLAGS = -lactivator

include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/tweak.mk

