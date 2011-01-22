
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <libactivator.h>

#import "VAShared.h"

@interface VARelayEventDataSource : NSObject <LAEventDataSource>  { } @end
@implementation VARelayEventDataSource
- (NSString *)localizedTitleForEventName:(NSString *)eventName { return @"VoiceActivator Event"; }
- (NSString *)localizedGroupForEventName:(NSString *)eventName { return @"VoiceActivator"; }
- (NSString *)localizedDescriptionForEventName:(NSString *)eventName { return @"Voice command from VoiceActivator."; }
- (BOOL)eventWithNameIsHidden:(NSString *)eventName { return YES; }
- (BOOL)eventWithName:(NSString *)eventName isCompatibleWithMode:(NSString *)eventMode { return YES; }
@end

static VARelayEventDataSource *dataSource = nil;
static NSMutableArray *eventNames = nil;

static void VARelayUnregisterEvent(NSString *name) {
    [[LAActivator sharedInstance] unregisterEventDataSourceWithEventName:name];
}

static void VARelayRegisterEvent(NSString *name) {
    [[LAActivator sharedInstance] registerEventDataSource:dataSource forEventName:name];
}

static NSMutableDictionary *VARelayCreateDefaultPreferences() {
    NSMutableDictionary *preferences = VAPreferencesCreate();
    NSDictionary *va = VACommandCreateWithParameters(@"voiceactivator", kVACommandTypeURL, @"cydia://package/com.chpwn.voiceactivator", [NSNumber numberWithBool:YES]);
    NSDictionary *ch = VACommandCreateWithParameters(@"chpwn", kVACommandTypeURL, @"http://chpwn.com/", [NSNumber numberWithBool:YES]);
    [(NSMutableArray *) VAPreferencesGet(preferences, kVAPreferencesCommandsKey) addObject:va];
    [(NSMutableArray *) VAPreferencesGet(preferences, kVAPreferencesCommandsKey) addObject:ch];
    return preferences;
}

static void VARelayApplyPreferences() {
    NSDictionary *preferences = VAPreferencesLoad();
    if (preferences == nil) {
        preferences = VARelayCreateDefaultPreferences();
        VAPreferencesSave(preferences);
    }

    NSMutableArray *newEventNames = [[NSMutableArray alloc] init];
    for (NSDictionary *command in (NSArray *) VAPreferencesGet(preferences, kVAPreferencesCommandsKey)) {
        [newEventNames addObject:VACommandEventName(command)];
    }

    for (NSString *event in eventNames) {
        if ([newEventNames indexOfObjectIdenticalTo:event] == NSNotFound) {
            VARelayUnregisterEvent(event);
        }
    }

    for (NSString *event in newEventNames) {
        VARelayRegisterEvent(event);
    }

    [eventNames autorelease];
    eventNames = newEventNames;
}

static void VARelayPreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    VARelayApplyPreferences();
}

__attribute__((constructor)) static void VARelayInit() {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    eventNames = [[NSMutableArray alloc] init];
    dataSource = [[VARelayEventDataSource alloc] init];

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, VARelayPreferencesChangedCallback, CFSTR("com.chpwn.voiceactivator.preferences_changed"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    VARelayApplyPreferences();

    [pool release];
}
