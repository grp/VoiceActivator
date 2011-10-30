
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

NSMutableDictionary *VAPreferencesCreate();
NSMutableDictionary *VAPreferencesLoad();
void VAPreferencesSave(NSDictionary *preferences);
NSObject *VAPreferencesGet(NSDictionary *preferences, NSString *key);
void VAPreferencesSet(NSMutableDictionary *preferences, NSString *key, NSObject *value);

NSMutableDictionary *VAPreferencesGetResponseWithIdentifier(NSDictionary *preferences, NSNumber *identifier);
void VAPreferencesSetResponseWithIdentifier(NSMutableDictionary *preferences, NSNumber *identifier, NSDictionary *response);
void VAPreferencesRemoveResponseWithIdentifier(NSMutableDictionary *preferences, NSNumber *identifier);

NSMutableDictionary *VAResponseCreateWithDictionary(NSDictionary *item);
NSMutableDictionary *VAResponseCreateWithParameters(NSString *text);
NSMutableDictionary *VAResponseCreate();
NSObject *VAResponseGet(NSDictionary *item, NSString *key);
void VAResponseSet(NSMutableDictionary *item, NSString *key, NSObject *value);
NSString *VAResponseActionName(NSDictionary *item);
NSNumber *VAResponseIdentifierForActionName(NSString *name);

NSMutableDictionary *VAPreferencesGetCommandWithIdentifier(NSDictionary *preferences, NSNumber *identifier);
void VAPreferencesSetCommandWithIdentifier(NSMutableDictionary *preferences, NSNumber *identifier, NSDictionary *command);
void VAPreferencesRemoveCommandWithIdentifier(NSMutableDictionary *preferences, NSNumber *identifier);

NSMutableDictionary *VACommandCreateWithDictionary(NSDictionary *item);
NSMutableDictionary *VACommandCreateWithParameters(NSString *cmd, NSNumber *type, NSString *action, NSNumber *complete);
NSMutableDictionary *VACommandCreate();
NSObject *VACommandGet(NSDictionary *item, NSString *key);
void VACommandSet(NSMutableDictionary *item, NSString *key, NSObject *value);
NSString *VACommandEventName(NSDictionary *item);
NSNumber *VACommandIdentifierForEventName(NSString *name);

NSString *VASpeechFormatText(NSString *speak);

