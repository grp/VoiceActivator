
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

static int last_image_index = 0;

static void VAImageUnloaded(const struct mach_header *mh, intptr_t slide) {
    last_image_index--;
}

static void VAImageLoaded(const struct mach_header *mh, intptr_t slide) {
    static int recursion_stopper = 0;
    const char *image = _dyld_get_image_name(last_image_index++);
    if (recursion_stopper > 0) return;

    if (image != NULL && strcmp(image, "/System/Library/VoiceServices/PlugIns/Base.vsplugin/Base") == 0) {
        recursion_stopper += 1;
        dlopen(image, RTLD_NOW);
        recursion_stopper -= 1;

        %init(VAResultHandler);
    }
}

__attribute__((constructor)) static void VAPluginInit() {
    _dyld_register_func_for_add_image(VAImageLoaded);
    _dyld_register_func_for_remove_image(VAImageUnloaded);
}

