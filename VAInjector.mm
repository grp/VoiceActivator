
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreFoundation/CFPropertyList.h>

#import <mach-o/nlist.h>
#import <objc/runtime.h>
#import <substrate.h>

#import "VAShared.h"

static CFReadStreamRef inject_stream;

static CFPropertyListRef (*CFCFPropertyListCreateWithStream)(
    CFAllocatorRef allocator,
    CFReadStreamRef strea,
    CFIndex streamLength,
    CFOptionFlags options,
    CFPropertyListFormat *format,
    CFErrorRef *error
);

CFPropertyListRef VACFPropertyListCreateWithStream (
    CFAllocatorRef allocator,
    CFReadStreamRef stream,
    CFIndex streamLength,
    CFOptionFlags options,
    CFPropertyListFormat *format,
    CFErrorRef *error
) {
    CFPropertyListRef prop = CFCFPropertyListCreateWithStream(
        allocator,
        stream,
        streamLength,
        options,
        format,
        error
    );

    if (stream == inject_stream) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

        NSDictionary *prefs = VAPreferencesLoad();
        NSArray *items = VAPreferencesGet(prefs, kVAPreferencesCommandsKey);
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        NSMutableArray *classes = [NSMutableArray array];
        [classes addObjectsFromArray:[(NSDictionary *) prop objectForKey:@"VSRecognitionClasses"]];
        NSMutableArray *sequences = [NSMutableArray array];
        [sequences addObjectsFromArray:[(NSDictionary *) prop objectForKey:@"VSRecognitionSequences"]];

        for (NSDictionary *item in items) {
            NSString *cmd = (NSString *) VACommandGet(item, kVACommandCommandKey);
            NSString *uni = (NSString *) [@"va-" stringByAppendingString:[VACommandGet(item, kVACommandIdentifierKey) stringValue]];

            NSDictionary *cls = [NSDictionary dictionaryWithObjectsAndKeys:
                [NSArray arrayWithObject:cmd], @"VSRecognitionClassElements",
                uni, @"VSRecognitionClassIdentifier",
                @"VSRecognitionClassTypeCommand", @"VSRecognitionClassType",
            nil];

            NSDictionary *seq = [NSDictionary dictionaryWithObjectsAndKeys:
                [NSArray arrayWithObject:uni], @"VSRecognitionSequenceElements",
            nil];

            [classes addObject:cls];
            [sequences addObject:seq];
        }

        [dict setObject:classes forKey:@"VSRecognitionClasses"];
        [dict setObject:sequences forKey:@"VSRecognitionSequences"];

        prop = (CFPropertyListRef) [dict retain];
        [pool release];
    }

    return prop;
}

static CFReadStreamRef (*CFCFReadStreamCreateWithFile)(
    CFAllocatorRef alloc,
    CFURLRef fileURL
);

CFReadStreamRef VACFReadStreamCreateWithFile(
    CFAllocatorRef alloc,
    CFURLRef fileURL
) {
    CFReadStreamRef stream = CFCFReadStreamCreateWithFile(
        alloc,
        fileURL
    );

    if (CFStringHasPrefix(CFURLGetString(fileURL), CFSTR("file://localhost/System/Library/VoiceServices/PlugIns/Base.vsplugin/com.apple.help"))) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

        if ([VAPreferencesGet(VAPreferencesLoad(), kVAPreferencesEnabledKey) boolValue]) {
            // This *entirely* defines enabled/disabled state.
            inject_stream = stream;
        }

        [pool release];
    }

    return stream;
}

__attribute__((constructor)) static void VAInjectorInit() {
    MSHookFunction(CFPropertyListCreateWithStream, VACFPropertyListCreateWithStream, &CFCFPropertyListCreateWithStream);
    MSHookFunction(CFReadStreamCreateWithFile, VACFReadStreamCreateWithFile, &CFCFReadStreamCreateWithFile);
}

