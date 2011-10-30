
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "VAShared.h"

NSMutableDictionary *VAPreferencesCreate() {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
        [NSMutableArray array], kVAPreferencesCommandsKey,
        [NSMutableArray array], kVAPreferencesResponsesKey,
        [NSNumber numberWithBool:YES], kVAPreferencesEnabledKey,
        [NSNumber numberWithInt:0], kVAPreferencesPriorityKey,
    nil];
}

NSMutableDictionary *VAPreferencesLoad() {
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:kVAPreferencesPath];
    VAPreferencesSet(prefs, kVAPreferencesCommandsKey, [[VAPreferencesGet(prefs, kVAPreferencesCommandsKey) mutableCopy] autorelease] ?: [NSMutableDictionary dictionary]);
    VAPreferencesSet(prefs, kVAPreferencesResponsesKey, [[VAPreferencesGet(prefs, kVAPreferencesResponsesKey) mutableCopy] autorelease] ?: [NSMutableDictionary dictionary]);
    return prefs;
}

void VAPreferencesSave(NSDictionary *preferences) {
    [preferences writeToFile:kVAPreferencesPath atomically:YES];
}

NSObject *VAPreferencesGet(NSDictionary *preferences, NSString *key) {
    return [preferences objectForKey:key];
}

void VAPreferencesSet(NSMutableDictionary *preferences, NSString *key, NSObject *value) {
    [preferences setObject:value forKey:key];
}


NSMutableDictionary *VAPreferencesGetResponseWithIdentifier(NSDictionary *preferences, NSNumber *identifier) {
    NSArray *responses = VAPreferencesGet(preferences, kVAPreferencesResponsesKey);
    NSDictionary *response = nil;
    for (NSDictionary *resp in responses) if ([VAResponseGet(resp, kVAResponseIdentifierKey) isEqual:identifier]) response = resp;
    return response;
}

void VAPreferencesSetResponseWithIdentifier(NSMutableDictionary *preferences, NSNumber *identifier, NSDictionary *response) {
    NSMutableArray *responses = VAPreferencesGet(preferences, kVAPreferencesResponsesKey);
    int index = -1;
    for (int i = 0; i < [responses count]; i++) if ([VAResponseGet([responses objectAtIndex:i], kVAResponseIdentifierKey) isEqual:identifier]) index = i;
    if (index != -1) [responses replaceObjectAtIndex:index withObject:response];
    else [responses addObject:response];
}

void VAPreferencesRemoveResponseWithIdentifier(NSMutableDictionary *preferences, NSNumber *identifier) {
    NSMutableArray *responses = VAPreferencesGet(preferences, kVAPreferencesResponsesKey);
    int index = -1;
    for (int i = 0; i < [responses count]; i++) if ([VAResponseGet([responses objectAtIndex:i], kVAResponseIdentifierKey) isEqual:identifier]) index = i;
    if (index != -1) [responses removeObjectAtIndex:index];
}

NSMutableDictionary *VAResponseCreateWithDictionary(NSDictionary *item) {
    return [[item mutableCopy] autorelease];
}

NSMutableDictionary *VAResponseCreateWithParameters(NSString *text) {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInt:arc4random()], kVAResponseIdentifierKey,
        text, kVAResponseTextKey,
    nil];
}

NSMutableDictionary *VAResponseCreate() {
    return VAResponseCreateWithParameters(@"");
}

void VAResponseSet(NSMutableDictionary *item, NSString *key, NSObject *value) {
    [item setObject:value forKey:key];
}

NSObject *VAResponseGet(NSDictionary *item, NSString *key) {
    return [item objectForKey:key];
}

NSString *VAResponseActionName(NSDictionary *item) {
    return [@"com.chpwn.voiceactivator.response." stringByAppendingString:[VAResponseGet(item, kVAResponseIdentifierKey) stringValue]];
}

NSNumber *VAResponseIdentifierForActionName(NSString *name) {
    return [NSNumber numberWithInt:[[name substringFromIndex:[@"com.chpwn.voiceactivator.response." length]] intValue]];
}


NSMutableDictionary *VAPreferencesGetCommandWithIdentifier(NSDictionary *preferences, NSNumber *identifier) {
    NSArray *commands = VAPreferencesGet(preferences, kVAPreferencesCommandsKey);
    NSDictionary *command = nil;
    for (NSDictionary *cmd in commands) if ([VACommandGet(cmd, kVACommandIdentifierKey) isEqual:identifier]) command = cmd;
    return VACommandCreateWithDictionary(command);
}

void VAPreferencesSetCommandWithIdentifier(NSMutableDictionary *preferences, NSNumber *identifier, NSDictionary *command) {
    NSMutableArray *commands = VAPreferencesGet(preferences, kVAPreferencesCommandsKey);
    int index = -1;
    for (int i = 0; i < [commands count]; i++) if ([VACommandGet([commands objectAtIndex:i], kVACommandIdentifierKey) isEqual:identifier]) index = i;
    if (index != -1) [commands replaceObjectAtIndex:index withObject:command];
    else [commands addObject:command];
}

void VAPreferencesRemoveCommandWithIdentifier(NSMutableDictionary *preferences, NSNumber *identifier) {
    NSMutableArray *commands = VAPreferencesGet(preferences, kVAPreferencesCommandsKey);
    int index = -1;
    for (int i = 0; i < [commands count]; i++) if ([VACommandGet([commands objectAtIndex:i], kVACommandIdentifierKey) isEqual:identifier]) index = i;
    if (index != -1) [commands removeObjectAtIndex:index];
}

NSMutableDictionary *VACommandCreateWithDictionary(NSDictionary *item) {
    return [[item mutableCopy] autorelease];
}

NSMutableDictionary *VACommandCreateWithParameters(NSString *cmd, NSNumber *type, NSString *action, NSNumber *complete) {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInt:arc4random()], kVACommandIdentifierKey,
        cmd, kVACommandCommandKey,
        type, kVACommandTypeKey,
        action, kVACommandActionKey,
        complete, kVACommandCompleteKey,
    nil];
}

NSMutableDictionary *VACommandCreate() {
    return VACommandCreateWithParameters(@"", kVACommandTypeSpeak, @"", [NSNumber numberWithBool:NO]);
}

void VACommandSet(NSMutableDictionary *item, NSString *key, NSObject *value) {
    [item setObject:value forKey:key];
}

NSObject *VACommandGet(NSDictionary *item, NSString *key) {
    return [item objectForKey:key];
}

NSString *VACommandEventName(NSDictionary *command) {
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



