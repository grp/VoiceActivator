# Copyright (c) 2010-2012, Xuzz Productions, LLC
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

include theos/makefiles/common.mk

export GO_EASY_ON_ME = 1
export TARGET = iphone:latest:4.0
export TARGET_STRIP_FLAGS = -u
export ARCHS = armv7

BUNDLE_NAME = VAPreferences
TWEAK_NAME = VARelay VAPlugin VAInjector
TOOL_NAME = extrainst_

extrainst__FILES = extrainst_.m
extrainst__INSTALL_PATH = /DEBIAN/

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
include $(THEOS_MAKE_PATH)/tool.mk
include $(THEOS_MAKE_PATH)/tweak.mk

