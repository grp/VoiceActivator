
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

@interface VAActivatorEventController : PSViewController {
    LAEventSettingsController *settings;
}
@end

@implementation VAActivatorEventController
- (UIView *)view { return [settings view]; }
- (id)navigationItem { return [settings navigationItem]; }
- (id)navigationTitle { return [settings navigationTitle]; }
- (void)dealloc {
    [settings release];
    [super dealloc];
}
- (id)initWithEventName:(NSString *)event {
    self = [super init];

    settings = [[LAEventSettingsController alloc]
        initWithModes:[[LAActivator sharedInstance] availableEventModes]
        eventName:event
    ];

    [settings setDelegate:self];
    return self;
}
@end

@interface VACommandListController : PSListController {
    NSMutableDictionary *command;
    PSSpecifier *action;
    PSSpecifier *activator;
    PSSpecifier *exit;
    int exitidx;
}
@end

@implementation VACommandListController
- (NSDictionary *)produceCommand {
    NSNumber *identifier = [[self specifier] propertyForKey:@"id"];
    return [VAPreferencesGetCommandWithIdentifier(preferences, [NSNumber numberWithInt:[identifier intValue]]) retain];
}
- (id)specifiers {
	if (!_specifiers) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"VACommand" target:self] mutableCopy];
        action = [[self specifierForID:@"action"] retain];
        activator = [[self specifierForID:@"activator"] retain];
        exit = [[self specifierForID:@"exit"] retain];
        exitidx = [self indexOfSpecifier:exit] - 1;

        if (command == nil) command = [self produceCommand];
        [self updateAction];
        [self updateExit];
    }

    return _specifiers;
}
- (void)updateAction {
    int idx = 0;
    if ([self containsSpecifier:action]) idx = [self indexOfSpecifier:action];
    else idx = [self indexOfSpecifier:activator];

    [self removeSpecifier:activator animated:NO];
    [self removeSpecifier:action animated:NO];

    if ([VACommandGet(command, kVACommandTypeKey) isEqual:kVACommandTypeActivator]) [self insertSpecifier:activator atIndex:idx animated:NO];
    else [self insertSpecifier:action atIndex:idx animated:NO];
}
- (void)updateExit {
    [self removeSpecifier:exit animated:NO];
    if ([VACommandGet(command, kVACommandTypeKey) isEqual:kVACommandTypeSpeak])
        [self insertSpecifier:exit atIndex:exitidx animated:NO];
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
- (NSString *)getActionWithSpecifier:(PSSpecifier *)specifier {
    return VAPreferencesGet(command, kVACommandActionKey);
}
- (void)setAction:(NSString *)cmd withSpecifier:(PSSpecifier *)specifier {
    VACommandSet(command, kVACommandActionKey, cmd);
    [self save];
}
- (NSNumber *)getTypeWithSpecifier:(PSSpecifier *)specifier {
    return VAPreferencesGet(command, kVACommandTypeKey);
}
- (void)setType:(NSNumber *)type withSpecifier:(PSSpecifier *)specifier {
    VACommandSet(command, kVACommandTypeKey, type);
    [self updateAction];
    [self updateExit];
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
        VAActivatorEventController *settings = [[[VAActivatorEventController alloc]
            initWithEventName:VACommandEventName(command)
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
- (NSDictionary *)produceCommand {
    [self removeSpecifier:[self specifierForID:@"delete"]];
    [self removeSpecifier:[self specifierForID:@"deletegroup"]];
    return [VACommandCreate() retain];
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
    // NOTE: Don't bother to save here since save already automatically happened.
    [[self parentController] dismiss];
}
- (void)cancelAndClose {
    [self delete];
    command = nil;
    [[self parentController] dismiss];
}
@end

// vim:ft=objc
