
#import <mach-o/dyld.h>
#import <substrate.h>

#import "VAShared.h"

%group VAResultHandler
%hook VSBaseHelpResultHandler
- (id)actionForRecognitionResult:(id)result {
    int count = (int) [result elementCount];
    NSString *identifier = nil, *value = nil;
    BOOL success = count > 0 ? (BOOL) (int) [result getElementClassIdentifier:&identifier value:&value atIndex:0] : NO;

    NSLog(@"count: %d sucess: %d identifier: %@ value: %@", count, success, identifier, value);

    if (success && identifier && [identifier hasPrefix:@"va-"]) {
        NSLog(@"we are going custom here");

        NSDictionary *prefs = VAPreferencesLoad();
        NSDictionary *item = VAPreferencesGetCommandWithIdentifier(prefs, [NSNumber numberWithInt:[[identifier substringFromIndex:3] intValue]]);
        NSLog(@"item is %@", item);
        NSString *action = VACommandGet(item, kVACommandActionKey);
        NSString *type = VACommandGet(item, kVACommandTypeKey);

        NSString *speak = @"";
        if ([type isEqual:kVACommandTypeSpeak]) speak = action;
        if ([type isEqual:kVACommandTypeURL]) [[objc_getClass("SpringBoard") sharedApplication] applicationOpenURL:[NSURL URLWithString:action]];

        id done = [[objc_getClass("VSRecognitionSpeakAction") alloc] initWithSpokenFeedbackString:speak willTerminate:[VACommandGet(item, kVACommandCompleteKey) boolValue]];
        return [done autorelease];
    } else {
        return %orig;
    }
}
%end
%end

static void VAImageLoaded(const struct mach_header *mh, intptr_t slide) {
    static int recursion_stopper = 0;
    if (recursion_stopper > 0) return;

    static int i = 0;
    const char *image = _dyld_get_image_name(i++);

    if (strcmp(image, "/System/Library/VoiceServices/PlugIns/Base.vsplugin/Base") == 0) {
        NSLog(@"VAInjector: Found Base.vsplugin");;
        recursion_stopper += 1;
        dlopen(image, RTLD_NOW);
        recursion_stopper -= 1;

        %init(VAResultHandler);
    }
}

__attribute__((constructor)) static void VAPluginInit() {
    _dyld_register_func_for_add_image(VAImageLoaded);
}

