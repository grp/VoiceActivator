
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

