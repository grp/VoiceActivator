
#import <Foundation/Foundation.h>

#define kVAPreferencesPath @"/var/mobile/Library/Preferences/com.chpwn.voiceactivator.plist"

#define kVAPreferencesCommandsKey @"items"
#define kVAPreferencesEnabledKey @"enabled"
#define kVAPreferencesPriorityKey @"priority"

#define kVACommandIdentifierKey @"identifier"
#define kVACommandCommandKey @"command"
#define kVACommandTypeKey @"type"
#define kVACommandActionKey @"action"
#define kVACommandCompleteKey @"complete"

#define kVACommandTypeSpeak [NSNumber numberWithInt:0]
#define kVACommandTypeURL [NSNumber numberWithInt:1]
#define kVACommandTypeActivator [NSNumber numberWithInt:2]

NSMutableDictionary *VAPreferencesCreate();
NSMutableDictionary *VAPreferencesLoad();
void VAPreferencesSave(NSDictionary *preferences);
NSObject *VAPreferencesGet(NSDictionary *preferences, NSString *key);
void VAPreferencesSet(NSMutableDictionary *preferences, NSString *key, NSObject *value);

NSMutableDictionary *VAPreferencesGetCommandWithIdentifier(NSDictionary *preferences, NSNumber *identifier);
void VAPreferencesSetCommandWithIdentifier(NSMutableDictionary *preferences, NSNumber *identifier, NSDictionary *command);
void VAPreferencesRemoveCommandWithIdentifier(NSMutableDictionary *preferences, NSNumber *identifier);

NSMutableDictionary *VACommandCreateWithDictionary(NSDictionary *item);
NSMutableDictionary *VACommandCreateWithParameters(NSString *cmd, NSNumber *type, NSString *action, NSNumber *complete);
NSMutableDictionary *VACommandCreate();
NSObject *VACommandGet(NSDictionary *item, NSString *key);
void VACommandSet(NSMutableDictionary *item, NSString *key, NSObject *value);
NSString *VACommandEventName(NSDictionary *command);


