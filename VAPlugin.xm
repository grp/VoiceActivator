/*
 * Copyright (c) 2010-2012, Xuzz Productions, LLC
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <mach-o/dyld.h>
#import <substrate.h>

#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <UIKit/UIKit.h>

#import "VAShared.h"

%group VAResultHandler
%hook VSBaseHelpResultHandler
- (id)actionForRecognitionResult:(id)result {
    int count = (int) [result elementCount];
    NSString *identifier = nil, *value = nil;
    BOOL success = count > 0 ? (BOOL) (int) [result getElementClassIdentifier:&identifier value:&value atIndex:0] : NO;

    if (success && identifier && [identifier hasPrefix:@"va-"]) {
        NSDictionary *prefs = VAPreferencesLoad();
        NSDictionary *item = VAPreferencesGetCommandWithIdentifier(prefs, [NSNumber numberWithInt:[[identifier substringFromIndex:3] intValue]]);
        NSString *action = VACommandGet(item, kVACommandActionKey);
        NSString *type = VACommandGet(item, kVACommandTypeKey);

        NSString *speak = @"";
        BOOL exit = YES;
        if ([type isEqual:kVACommandTypeSpeak]) {
            speak = VASpeechFormatText(action);
            exit = [(NSNumber *) VACommandGet(item, kVACommandCompleteKey) boolValue];
        } else if ([type isEqual:kVACommandTypeURL]) {
            [[objc_getClass("SpringBoard") sharedApplication] performSelector:@selector(applicationOpenURL:) withObject:[NSURL URLWithString:action] afterDelay:2.0f];
        } else if ([type isEqual:kVACommandTypeActivator]) {
            NSString *name = VACommandEventName(item);
            id event = [objc_getClass("LAEvent") eventWithName:name];
            [[objc_getClass("LAActivator") sharedInstance] performSelector:@selector(sendEventToListener:) withObject:event afterDelay:2.0f];
        }

        id done = [[objc_getClass("VSRecognitionSpeakAction") alloc] initWithSpokenFeedbackString:speak willTerminate:exit];
        return [done autorelease];
    } else {
        return %orig;
    }
}
%end
%end

__attribute__((constructor)) static void VAPluginInit() {
    // Preload, so we don't have to try and find out *exactly* when to hook it.
    dlopen("/System/Library/VoiceServices/PlugIns/Base.vsplugin/Base", RTLD_NOW);
    %init(VAResultHandler);
}

