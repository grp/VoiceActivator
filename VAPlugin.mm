
#import <objc/runtime.h>
@protocol VSRecognitionResultHandler;

@interface VAResultHandler : NSObject <VSRecognitionResultHandler>  { } @end
@implementation VAResultHandler
- (id)actionForRecognitionResult:(id)recognitionResult {
    id act = [[objc_getClass("VSRecognitionSpeakAction") alloc] initWithSpokenFeedbackString:@"its time to go to bed" willTerminate:NO];
    NSLog(@"hello to va");
    return [act autorelease];
}
@end

