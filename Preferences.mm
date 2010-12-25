#import <Preferences/Preferences.h>

@interface VAPreferencesListController : PSListController {
    NSArray *_vacommands;
}

@property (nonatomic, retain) NSArray *VACommands;

@end

@implementation VAPreferencesListController
@synthesize VACommands=_vacommands;

- (id)specifiers {
	if (!_specifiers) _specifiers = [[self loadSpecifiersFromPlistName:@"VABase" target:self] retain];
    return _specifiers;
}

@end


@interface VACommandListController : PSListController {
    NSDictionary *_vacommand;
}

@property (nonatomic, retain) NSDictionary *VACommand;

@end

@implementation VACommandListController
@synthesize VACommand=_vacommand;

- (id)specifiers {
	if (!_specifiers) _specifiers = [[self loadSpecifiersFromPlistName:@"VACommand" target:self] retain];
    return _specifiers;
}

@end


@interface VANewCommandListController : VACommandListController {
}
@end

@implementation VANewCommandListController
@end

// vim:ft=objc
