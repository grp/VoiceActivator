
#import <mach-o/dyld.h>
#import <substrate.h>

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
            speak = action;
            exit = [(NSNumber *) VACommandGet(item, kVACommandCompleteKey) boolValue];
        } else if ([type isEqual:kVACommandTypeURL]) {
            [[objc_getClass("SpringBoard") sharedApplication] applicationOpenURL:[NSURL URLWithString:action]];
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

