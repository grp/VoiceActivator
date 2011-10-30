
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import <libactivator.h>
#import <substrate.h>
#import <launch.h>

#import <AudioToolbox/AudioToolbox.h>

#import "VAShared.h"

@interface VARelayEventDataSource : NSObject <LAEventDataSource>  { } @end
@implementation VARelayEventDataSource
- (NSString *)localizedTitleForEventName:(NSString *)eventName { return @"VoiceActivator Event"; }
- (NSString *)localizedGroupForEventName:(NSString *)eventName { return @"VoiceActivator"; }
- (NSString *)localizedDescriptionForEventName:(NSString *)eventName { return @"Voice command from VoiceActivator."; }
- (BOOL)eventWithNameIsHidden:(NSString *)eventName { return YES; }
- (BOOL)eventWithName:(NSString *)eventName isCompatibleWithMode:(NSString *)eventMode { return YES; }
@end

@protocol VSSpeechSynthesizerDelegate;
@interface VARelayActionController : NSObject <LAListener, VSSpeechSynthesizerDelegate> { } @end
@implementation VARelayActionController
- (void) speechSynthesizer:(NSObject *) synth didFinishSpeaking:(BOOL)didFinish withError:(NSError *) error { NSLog(@"done: %d %@ %@", didFinish, synth, error); }
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event forListenerName:(NSString *)listenerName {
    NSDictionary *preferences = VAPreferencesLoad();
    NSNumber *identifier = VAResponseIdentifierForActionName(listenerName);
    NSDictionary *response = VAPreferencesGetResponseWithIdentifier(preferences, identifier);
    NSString *text = VASpeechFormatText((NSString *) VAResponseGet(response, kVAResponseTextKey));

/*UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);    
UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);*/

    id vca = [[objc_getClass("SBVoiceControlAlert") alloc] initFromMenuButton];
    [vca setObject:@"Speaker" forKey:@"SBAudioRouteType"];
    [vca setObject:[NSNumber numberWithBool:YES] forKey:@"SBTriggeredByMenu"];
    [vca setObject:[NSNumber numberWithBool:NO] forKey:@"SBHeadsetConnected"];
    [vca _proximityChanged:nil];
    id vcd = [[objc_getClass("SBVoiceControlMenuedAlertDisplay") alloc] initWithFrame:CGRectZero session:[vca _session]];
    [vcd _invalidateRouting];
    [vcd _configureRoutingIfNecessary];
    NSLog(@"blah %@ %@", vca, vcd);

    /*id synth = [[objc_getClass("VSSpeechSynthesizer") alloc] initForInputFeedback];
    [synth setDelegate:self];
    [synth setVolume:0.01f];
    //[synth setPitch:0.5f];
    //[synth setRate:1.0f];
    [synth startSpeakingString:text];
    [synth setVolume:0.9f];
    [vcd _invalidateRouting];
    [vcd _configureRoutingIfNecessary];*/
//AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
    id synth = [vca _session];//[[objc_getClass("VSRecognitionSession") alloc] init];
    //[MSHookIvar<id>(synth, "_synthesizer") setVolume:1.0f];
    [synth performSelector:@selector(beginSpeakingString:) withObject:text afterDelay:0.2f];

    [event setHandled:YES];
}
@end

static NSMutableArray *responseNames = nil;
static VARelayActionController *actionController = nil;
static VARelayEventDataSource *dataSource = nil;
static NSMutableArray *eventNames = nil;

static void VARelayUnregisterAction(NSString *name) {
    [[LAActivator sharedInstance] unregisterListenerWithName:name];
}

static void VARelayRegisterAction(NSString *name) {
    [[LAActivator sharedInstance] registerListener:actionController forName:name];
}

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


    NSMutableArray *newResponses = [[NSMutableArray alloc] init];
    for (NSDictionary *response in (NSArray *) VAPreferencesGet(preferences, kVAPreferencesResponsesKey)) {
        [newResponses addObject:VAResponseActionName(response)];
    }

    for (NSString *response in responseNames) {
        if ([newResponses indexOfObjectIdenticalTo:response] == NSNotFound) {
            VARelayUnregisterAction(response);
        }
    }

    for (NSString *action in newResponses) {
        VARelayRegisterAction(action);
    }

    [responseNames autorelease];
    responseNames = newResponses;


    // XXX: This is stupid. I should not need to use the launchd API here.
    launch_data_t msg = launch_data_alloc(LAUNCH_DATA_DICTIONARY);
    launch_data_dict_insert(msg, launch_data_new_string("com.apple.voiced"), LAUNCH_KEY_STOPJOB);
    launch_data_t resp = launch_msg(msg); // ignore errors, nothing we can do about them
    launch_data_free(msg);
    launch_data_free(resp);

    [[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Library/Caches/VoiceServices/" error:NULL];
}

static void VARelayPreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info) {
    VARelayApplyPreferences();
}

static void VARelaySendActivatorEvent(NSString *name) {
    LAEvent *event = [LAEvent eventWithName:name];
    [[LAActivator sharedInstance] sendEventToListener:event];
}

static void VARelayActivatorEventCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info) {
    VARelaySendActivatorEvent(@"how_do_i_get_this");
}

__attribute__((constructor)) static void VARelayInit() {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    responseNames = [[NSMutableArray alloc] init];
    actionController = [[VARelayActionController alloc] init];
    eventNames = [[NSMutableArray alloc] init];
    dataSource = [[VARelayEventDataSource alloc] init];

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, VARelayPreferencesChangedCallback, CFSTR("com.chpwn.voiceactivator.preferences_changed"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    VARelayApplyPreferences();

    [pool release];
}
