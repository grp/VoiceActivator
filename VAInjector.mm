/*
 * Copyright (c) 2010-2012, Xuzz Productions, LLC
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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

