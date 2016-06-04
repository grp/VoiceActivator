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

#import <Foundation/Foundation.h>

#define kVAPreferencesPath @"/var/mobile/Library/Preferences/com.chpwn.voiceactivator.plist"

#define kVAPreferencesCommandsKey @"items"
#define kVAPreferencesResponsesKey @"repsonses"
#define kVAPreferencesEnabledKey @"enabled"
#define kVAPreferencesPriorityKey @"priority"

#define kVAResponseIdentifierKey @"identifier"
#define kVAResponseTextKey @"text"

#define kVACommandIdentifierKey @"identifier"
#define kVACommandCommandKey @"command"
#define kVACommandTypeKey @"type"
#define kVACommandActionKey @"action"
#define kVACommandCompleteKey @"complete"

#define kVACommandTypeSpeak [NSNumber numberWithInt:0]
#define kVACommandTypeURL [NSNumber numberWithInt:1]
#define kVACommandTypeActivator [NSNumber numberWithInt:2]

typedef NSMutableDictionary VAPreferences;
typedef NSMutableDictionary VAResponse;
typedef NSMutableDictionary VACommand;

extern "C" {

VAPreferences *VAPreferencesCreate();
VAPreferences *VAPreferencesLoad();
void VAPreferencesSave(VAPreferences *preferences);
id VAPreferencesGet(VAPreferences *preferences, NSString *key);
void VAPreferencesSet(VAPreferences *preferences, NSString *key, id value);

VAResponse *VAPreferencesGetResponseWithIdentifier(VAPreferences *preferences, NSNumber *identifier);
void VAPreferencesSetResponseWithIdentifier(VAPreferences *preferences, NSNumber *identifier, VAResponse *response);
void VAPreferencesRemoveResponseWithIdentifier(VAPreferences *preferences, NSNumber *identifier);

VAResponse *VAResponseCreateWithDictionary(NSDictionary *item);
VAResponse *VAResponseCreateWithParameters(NSString *text);
VAResponse *VAResponseCreate();
id VAResponseGet(VAResponse *item, NSString *key);
void VAResponseSet(VAResponse *item, NSString *key, id value);
NSString *VAResponseActionName(VAResponse *item);
NSNumber *VAResponseIdentifierForActionName(NSString *name);

VACommand *VAPreferencesGetCommandWithIdentifier(VAPreferences *preferences, NSNumber *identifier);
void VAPreferencesSetCommandWithIdentifier(VAPreferences *preferences, NSNumber *identifier, VACommand *command);
void VAPreferencesRemoveCommandWithIdentifier(VAPreferences *preferences, NSNumber *identifier);

VACommand *VACommandCreateWithDictionary(NSDictionary *item);
VACommand *VACommandCreateWithParameters(NSString *cmd, NSNumber *type, NSString *action, NSNumber *complete);
VACommand *VACommandCreate();
id VACommandGet(VACommand *item, NSString *key);
void VACommandSet(VACommand *item, NSString *key, id value);
NSString *VACommandEventName(VACommand *item);
NSNumber *VACommandIdentifierForEventName(NSString *name);

NSString *VASpeechFormatText(NSString *speak);
void VASpeechSpeakText(NSString *text);

}

