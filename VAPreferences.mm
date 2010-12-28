
#import <Preferences/Preferences.h>
#import <libactivator.h>
#import "VAShared.h"

static NSMutableDictionary *preferences = nil;

__attribute__((constructor)) static void VAPreferencesInit() {
    preferences = [VAPreferencesLoad() retain];
}

static void VAPreferencesPostPreferencesChangedNotification() {
    CFNotificationCenterPostNotificationWithOptions(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.chpwn.voiceactivator.preferences_changed"), NULL, NULL, 0);
}

@class VACommandListController, VANewCommandListController;

@interface VAPreferencesListController : PSListController {
    PSSpecifier *last;
} @end

static VAPreferencesListController *sharedListController;
@implementation VAPreferencesListController
+ (id)sharedInstance {
    return sharedListController;
}
- (PSSpecifier *)specifierForCommand:(NSDictionary *)command {
    PSSpecifier *specifier =  [PSSpecifier preferenceSpecifierNamed:VACommandGet(command, kVACommandCommandKey)
        target:nil set:nil get:nil detail:[VACommandListController class] cell:PSLinkCell edit:nil];
    [specifier setProperty:VACommandGet(command, kVACommandIdentifierKey) forKey:@"id"];
    return specifier;
}
- (NSArray *)specifiers {
    sharedListController = self;

    if (!_specifiers) {
        _specifiers =  [[self loadSpecifiersFromPlistName:@"VABase" target:self] mutableCopy];

        NSMutableArray *commands = [NSMutableArray array];
        int start = [self indexOfSpecifierID:@"commands"] + 1;
        for (NSDictionary *command in VAPreferencesGet(preferences, kVAPreferencesCommandsKey)) [commands insertObject:[self specifierForCommand:command] atIndex:0];
        for (PSSpecifier *specifier in commands) [_specifiers insertObject:specifier atIndex:start];
    }

    return _specifiers;
}
- (void)removeSpecifierForCommand:(NSDictionary *)command animated:(BOOL)animated {
    PSSpecifier *specifier = [self specifierForID:VACommandGet(command, kVACommandIdentifierKey)];
    int index = [self indexOfSpecifier:specifier];
    if (specifier == last) last = [self specifierAtIndex:index - 1];
    [self removeSpecifier:specifier animated:animated];
}
- (NSNumber *)getEnabledWithSpecifier:(PSSpecifier *)specifier {
    return VAPreferencesGet(preferences, kVAPreferencesEnabledKey);
}
- (void)setEnabled:(NSNumber *)enabled withSpecifier:(PSSpecifier *)specifier {
    VAPreferencesSet(preferences, kVAPreferencesEnabledKey, enabled);
    VAPreferencesSave(preferences);
    VAPreferencesPostPreferencesChangedNotification();
}
- (NSNumber *)getPriorityWithSpecifier:(PSSpecifier *)specifier {
    return VAPreferencesGet(preferences, kVAPreferencesPriorityKey);
}
- (void)setPriority:(NSNumber *)priority withSpecifier:(PSSpecifier *)specifier {
    VAPreferencesSet(preferences, kVAPreferencesPriorityKey, priority);
    VAPreferencesSave(preferences);
    VAPreferencesPostPreferencesChangedNotification();
}
@end


@interface VACommandListController : PSListController {
    NSMutableDictionary *command;
}
@end

@implementation VACommandListController
- (id)specifiers {
	if (!_specifiers) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"VACommand" target:self] retain];

        NSNumber *identifier = [[self specifier] propertyForKey:@"id"];
        command = [VAPreferencesGetCommandWithIdentifier(preferences, [NSNumber numberWithInt:[identifier intValue]]) retain];
    }

    return _specifiers;
}
- (void)write {
    VAPreferencesSave(preferences);
    VAPreferencesPostPreferencesChangedNotification();
    [[VAPreferencesListController sharedInstance] reloadSpecifiers];
}
- (void)save {
    if (command == nil) return;
    VAPreferencesSetCommandWithIdentifier(preferences, (NSNumber *) VACommandGet(command, kVACommandIdentifierKey), command);
    [self write];
}
- (NSString *)getCommandWithSpecifier:(PSSpecifier *)specifier {
    return VAPreferencesGet(command, kVACommandCommandKey);
}
- (void)setCommand:(NSString *)cmd withSpecifier:(PSSpecifier *)specifier {
    VACommandSet(command, kVACommandCommandKey, cmd);
    [self save];
}
- (NSNumber *)getTypeWithSpecifier:(PSSpecifier *)specifier {
    return VAPreferencesGet(command, kVACommandTypeKey);
}
- (void)setType:(NSNumber *)type withSpecifier:(PSSpecifier *)specifier {
    VACommandSet(command, kVACommandTypeKey, type);
    [self save];
}
- (NSNumber *)getExitWithSpecifier:(PSSpecifier *)specifier {
    return VAPreferencesGet(command, kVACommandCompleteKey);
}
- (void)setExit:(NSNumber *)exit withSpecifier:(PSSpecifier *)specifier {
    VACommandSet(command, kVACommandCompleteKey, exit);
    [self save];
}
- (void)delete {
    VAPreferencesRemoveCommandWithIdentifier(preferences, (NSNumber *) VACommandGet(command, kVACommandIdentifierKey));
    [self write];
}
- (void)deleteCommand {
    [self delete];
    [[self parentController] popViewControllerAnimated:YES];
}
- (void)configureWithSpecifier:(PSSpecifier *)specifier {
    if ([VACommandGet(command, kVACommandTypeKey) isEqual:kVACommandTypeActivator]) {
        LAEventSettingsController *settings = [[[LAEventSettingsController alloc]
            initWithModes:[[LAActivator sharedInstance] availableEventModes]
            eventName:VACommandEventName(command)
        ] autorelease];
        [[self parentController] pushViewController:settings animated:YES];
    }
}
- (void)dealloc {
    [command release];
    [super dealloc];
}
@end

@interface VANewCommandSetupController : PSSetupController { } @end
@implementation VANewCommandSetupController
+ (BOOL)isOverlay {
    return NO;
}
@end

@interface VANewCommandListController : VACommandListController {
}
@end

@implementation VANewCommandListController
- (NSArray *)specifiers {
	if (!_specifiers) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"VACommand" target:self] retain];
        [self removeSpecifier:[self specifierForID:@"delete"]];
        [self removeSpecifier:[self specifierForID:@"deletegroup"]];
        command = [VACommandCreate() retain];;
    }

    return _specifiers;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *cancelItem = [[[UIBarButtonItem alloc]
        initWithTitle:@"Cancel"
        style:UIBarButtonItemStyleBordered
        target:self
        action:@selector(cancelAndClose)
    ] autorelease];
    [[self navigationItem] setLeftBarButtonItem:cancelItem];

    UIBarButtonItem *saveItem = [[[UIBarButtonItem alloc]
        initWithTitle:@"Save"
        style:UIBarButtonItemStyleDone
        target:self
        action:@selector(saveAndClose)
    ] autorelease];
    [[self navigationItem] setRightBarButtonItem:saveItem];
}
- (void)saveAndClose {
    // NOTE: Don't save here since save already automatically happened.
    [[self parentController] dismiss];
}
- (void)cancelAndClose {
    [self delete];
    command = nil;
    [[self parentController] dismiss];
}
@end

// vim:ft=objc
