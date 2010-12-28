
#import "VAShared.h"

NSMutableDictionary *VAPreferencesCreate() {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
        [NSMutableArray array], kVAPreferencesCommandsKey,
        [NSNumber numberWithBool:YES], kVAPreferencesEnabledKey,
        [NSNumber numberWithInt:0], kVAPreferencesPriorityKey,
    nil];
}

NSMutableDictionary *VAPreferencesLoad() {
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:kVAPreferencesPath];
    VAPreferencesSet(prefs, kVAPreferencesCommandsKey, [[VAPreferencesGet(prefs, kVAPreferencesCommandsKey) mutableCopy] autorelease]);
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



