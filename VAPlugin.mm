
#import <objc/runtime.h>
#import "VAShared.h"


@protocol VSRecognitionResultHandler;

__attribute__((constructor)) static void VAPluginInit() {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSLog(@"testing loaded vsbundle");

    [pool release];
}

@interface VAResultHandler : NSObject <VSRecognitionResultHandler>  { } @end
@implementation VAResultHandler
- (id)actionForRecognitionResult:(id)recognitionResult {
    id act = [[objc_getClass("VSRecognitionSpeakAction") alloc] initWithSpokenFeedbackString:@"its time to go to bed" willTerminate:NO];
    NSLog(@"recognized result");
    return [act autorelease];
}
@end

