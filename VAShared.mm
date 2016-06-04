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

#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import <objc/runtime.h>

#import "VAShared.h"

VAPreferences *VAPreferencesCreate() {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
        [NSMutableArray array], kVAPreferencesCommandsKey,
        [NSMutableArray array], kVAPreferencesResponsesKey,
        [NSNumber numberWithBool:YES], kVAPreferencesEnabledKey,
        [NSNumber numberWithInt:0], kVAPreferencesPriorityKey,
    nil];
}

VAPreferences *VAPreferencesLoad() {
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:kVAPreferencesPath];
    VAPreferencesSet(prefs, kVAPreferencesCommandsKey, [[VAPreferencesGet(prefs, kVAPreferencesCommandsKey) mutableCopy] autorelease] ?: [NSMutableArray array]);
    VAPreferencesSet(prefs, kVAPreferencesResponsesKey, [[VAPreferencesGet(prefs, kVAPreferencesResponsesKey) mutableCopy] autorelease] ?: [NSMutableArray array]);
    return prefs;
}

void VAPreferencesSave(VAPreferences *preferences) {
    [preferences writeToFile:kVAPreferencesPath atomically:YES];
}

id VAPreferencesGet(VAPreferences *preferences, NSString *key) {
    return [preferences objectForKey:key];
}

void VAPreferencesSet(VAPreferences *preferences, NSString *key, id value) {
    [preferences setObject:value forKey:key];
}


VAResponse *VAPreferencesGetResponseWithIdentifier(VAPreferences *preferences, NSNumber *identifier) {
    NSArray *responses = VAPreferencesGet(preferences, kVAPreferencesResponsesKey);
    VAResponse *response = nil;

    for (VAResponse *resp in responses) {
        if ([VAResponseGet(resp, kVAResponseIdentifierKey) isEqual:identifier]) {
            response = resp;
        }
    }

    return VAResponseCreateWithDictionary(response);
}

void VAPreferencesSetResponseWithIdentifier(VAPreferences *preferences, NSNumber *identifier, VAResponse *response) {
    NSMutableArray *responses = VAPreferencesGet(preferences, kVAPreferencesResponsesKey);
    int index = -1;
    for (int i = 0; i < [responses count]; i++) if ([VAResponseGet([responses objectAtIndex:i], kVAResponseIdentifierKey) isEqual:identifier]) index = i;
    if (index != -1) [responses replaceObjectAtIndex:index withObject:response];
    else [responses addObject:response];
}

void VAPreferencesRemoveResponseWithIdentifier(VAPreferences *preferences, NSNumber *identifier) {
    NSMutableArray *responses = VAPreferencesGet(preferences, kVAPreferencesResponsesKey);
    int index = -1;
    for (int i = 0; i < [responses count]; i++) if ([VAResponseGet([responses objectAtIndex:i], kVAResponseIdentifierKey) isEqual:identifier]) index = i;
    if (index != -1) [responses removeObjectAtIndex:index];
}

VAResponse *VAResponseCreateWithDictionary(NSDictionary *item) {
    return [[item mutableCopy] autorelease];
}

VAResponse *VAResponseCreateWithParameters(NSString *text) {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInt:arc4random()], kVAResponseIdentifierKey,
        text, kVAResponseTextKey,
    nil];
}

VAResponse *VAResponseCreate() {
    return VAResponseCreateWithParameters(@"");
}

void VAResponseSet(VAResponse *item, NSString *key, id value) {
    [item setObject:value forKey:key];
}

id VAResponseGet(VAResponse *item, NSString *key) {
    return [item objectForKey:key];
}

NSString *VAResponseActionName(VAResponse *item) {
    return [@"com.chpwn.voiceactivator.response." stringByAppendingString:[VAResponseGet(item, kVAResponseIdentifierKey) stringValue]];
}

NSNumber *VAResponseIdentifierForActionName(NSString *name) {
    return [NSNumber numberWithInt:[[name substringFromIndex:[@"com.chpwn.voiceactivator.response." length]] intValue]];
}


VACommand *VAPreferencesGetCommandWithIdentifier(VAPreferences *preferences, NSNumber *identifier) {
    NSArray *commands = VAPreferencesGet(preferences, kVAPreferencesCommandsKey);
    VACommand *command = nil;

    for (VACommand *cmd in commands) {
        if ([VACommandGet(cmd, kVACommandIdentifierKey) isEqual:identifier]) {
            command = cmd;
        }
    }

    return VACommandCreateWithDictionary(command);
}

void VAPreferencesSetCommandWithIdentifier(VAPreferences *preferences, NSNumber *identifier, VACommand *command) {
    NSMutableArray *commands = VAPreferencesGet(preferences, kVAPreferencesCommandsKey);
    int index = -1;
    for (int i = 0; i < [commands count]; i++) if ([VACommandGet([commands objectAtIndex:i], kVACommandIdentifierKey) isEqual:identifier]) index = i;
    if (index != -1) [commands replaceObjectAtIndex:index withObject:command];
    else [commands addObject:command];
}

void VAPreferencesRemoveCommandWithIdentifier(VAPreferences *preferences, NSNumber *identifier) {
    NSMutableArray *commands = VAPreferencesGet(preferences, kVAPreferencesCommandsKey);
    int index = -1;
    for (int i = 0; i < [commands count]; i++) if ([VACommandGet([commands objectAtIndex:i], kVACommandIdentifierKey) isEqual:identifier]) index = i;
    if (index != -1) [commands removeObjectAtIndex:index];
}

VACommand *VACommandCreateWithDictionary(NSDictionary *item) {
    return [[item mutableCopy] autorelease];
}

VACommand *VACommandCreateWithParameters(NSString *cmd, NSNumber *type, NSString *action, NSNumber *complete) {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInt:arc4random()], kVACommandIdentifierKey,
        cmd, kVACommandCommandKey,
        type, kVACommandTypeKey,
        action, kVACommandActionKey,
        complete, kVACommandCompleteKey,
    nil];
}

VACommand *VACommandCreate() {
    return VACommandCreateWithParameters(@"", kVACommandTypeSpeak, @"", [NSNumber numberWithBool:NO]);
}

void VACommandSet(VACommand *item, NSString *key, id value) {
    [item setObject:value forKey:key];
}

id VACommandGet(VACommand *item, NSString *key) {
    return [item objectForKey:key];
}

NSString *VACommandEventName(VACommand *command) {
    return [@"com.chpwn.voiceactivator.event." stringByAppendingString:[VACommandGet(command, kVACommandIdentifierKey) stringValue]];
}

NSNumber *VACommandIdentifierForEventName(NSString *name) {
    return [NSNumber numberWithInt:[[name substringFromIndex:[@"com.chpwn.voiceactivator.event." length]] intValue]];
}


NSString *VASpeechFormatText(NSString *text) {
    NSString *speak = text;

    if ([speak rangeOfString:@"$DATE"].location != NSNotFound) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEEE MMMM d yyyy"];
        NSString *date = [formatter stringFromDate:[NSDate date]];
        speak = [speak stringByReplacingOccurrencesOfString:@"$DATE" withString:date];
    }

    if ([speak rangeOfString:@"$TIME"].location != NSNotFound) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterNoStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        NSString *time = [formatter stringFromDate:[NSDate date]];
        speak = [speak stringByReplacingOccurrencesOfString:@"$TIME" withString:time];
    }

    if ([speak rangeOfString:@"$BATTERY"].location != NSNotFound) {
        NSString *battery = [NSString stringWithFormat:@"%d", (int) ([[UIDevice currentDevice] batteryLevel] * 100.0f)];
        speak = [speak stringByReplacingOccurrencesOfString:@"$BATTERY" withString:battery];
    }

    if ([speak rangeOfString:@"$VERSION"].location != NSNotFound) {
        NSString *version = [[UIDevice currentDevice] systemVersion];
        speak = [speak stringByReplacingOccurrencesOfString:@"$VERSION" withString:version];
    }

    if ([speak rangeOfString:@"$MODEL"].location != NSNotFound) {
        NSString *model = [[UIDevice currentDevice] localizedModel];
        speak = [speak stringByReplacingOccurrencesOfString:@"$MODEL" withString:model];
    }

    if ([speak rangeOfString:@"$CARRIER"].location != NSNotFound) {
        CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *carrier = [netinfo subscriberCellularProvider];
        NSString *name = [carrier carrierName];
        if (name == nil || [name isEqualToString:@""]) name = @"(No Carrier)";
        speak = [speak stringByReplacingOccurrencesOfString:@"$CARRIER" withString:name];
        [netinfo release];
    }

    return speak;
}

@interface VSSpeechSynthesizer : NSObject
- (id)startSpeakingString:(NSString *)string;
@end

void VASpeechSpeakText(NSString *text) {
    VSSpeechSynthesizer *synth = [[objc_getClass("VSSpeechSynthesizer") alloc] init];
    [synth startSpeakingString:text];
}

