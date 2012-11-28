
#import <libactivator.h>
#import "VAShared.h"

typedef enum PSTableCellType {
        PSGroupCell,
        PSLinkCell,
        PSLinkListCell,
        PSListItemCell,
        PSTitleValueCell,
        PSSliderCell,
        PSSwitchCell,
        PSStaticTextCell,
        PSEditTextCell,
        PSSegmentCell,
        PSGiantIconCell,
        PSGiantCell,
        PSSecureEditTextCell,
        PSButtonCell,
        PSEditTextViewCell
} PSSpecifierType;

@interface PSSpecifier : NSObject
+ (id)preferenceSpecifierNamed:(NSString *)name target:(id)target set:(SEL)set get:(SEL)get detail:(Class)detailControllerClass cell:(PSSpecifierType)type edit:(Class)editControllerClass;
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSArray *values;
@property (nonatomic, retain) id userInfo;
@property (nonatomic, assign) id target;
@property (nonatomic, assign) PSSpecifierType cellType;
@property (nonatomic, assign) Class detailControllerClass;
- (void)setProperty:(id)property forKey:(id)key;
- (id)propertyForKey:(id)key;
- (void)removePropertyForKey:(id)key;
@end

@interface PSViewController : UIViewController {
    UIViewController *_parentController;
    PSViewController *_rootController;
    PSSpecifier *_specifier;
}

- (void)setSpecifier:(PSSpecifier *)specifier;
- (PSSpecifier *)specifier;
- (id)parentController;
- (id)rootController;
@end

@interface PSListController : PSViewController {
    NSMutableDictionary *_cells;
    BOOL _cachesCells;
    BOOL _forceSynchronousIconLoadForCreatedCells;

    UITableView *_table;
    id _specifiers;
    NSMutableDictionary *_specifiersByID;
    NSMutableArray *_groups;

    NSString *_specifierID;

    NSMutableArray *_bundleControllers;
    BOOL _bundlesLoaded;
    BOOL _showingSetupController;

    UIActionSheet *_actionSheet;
    UIAlertView *_alertView;
    BOOL _swapAlertButtons;

    BOOL _keyboardWasVisible;
    id _keyboard;

    UIPopoverController *_popupStylePopoverController;
    BOOL _popupStylePopoverShouldRePresent;
    BOOL _popupIsModal;
    BOOL _popupIsDismissing;

    BOOL _hasAppeared;

    CGFloat _verticalContentOffset;
    NSString *_offsetItemName;
    CGPoint _contentOffsetWithKeyboard;
}

- (NSArray *)loadSpecifiersFromPlistName:(NSString *)name target:(PSListController *)target;

- (PSSpecifier *)specifierAtIndex:(NSInteger)index;
- (PSSpecifier *)specifierForID:(NSString *)identifier;

- (BOOL)containsSpecifier:(PSSpecifier *)specifier;
- (NSInteger)indexOfSpecifier:(PSSpecifier *)specifier;
- (NSInteger)indexOfSpecifierID:(NSString *)identifier;

- (void)reloadSpecifiers;
- (void)reloadSpecifierAtIndex:(NSInteger)index;
- (BOOL)shouldReloadSpecifiersOnResume;

- (void)addSpecifier:(PSSpecifier *)specifier;
- (void)addSpecifiersFromArray:(NSArray *)specifires animated:(BOOL)animated;
- (void)insertSpecifier:(PSSpecifier *)specifier atIndex:(NSInteger)index;
- (void)insertSpecifier:(PSSpecifier *)specifier atIndex:(NSInteger)index animated:(BOOL)animated;
- (void)insertSpecifier:(PSSpecifier *)specifier afterSpecifier:(PSSpecifier *)specifier;
- (void)insertSpecifier:(PSSpecifier *)specifier afterSpecifier:(PSSpecifier *)specifier animated:(BOOL)animated;
- (void)insertSpecifier:(PSSpecifier *)specifier afterSpecifierID:(NSString *)identifier;
- (void)insertSpecifier:(PSSpecifier *)specifier afterSpecifierID:(NSString *)identifier animated:(BOOL)animated;

- (void)removeSpecifier:(PSSpecifier *)specifier;
- (void)removeSpecifier:(PSSpecifier *)specifier animated:(BOOL)animated;
- (void)removeSpecifierID:(NSString *)identifier;
- (void)removeSpecifierAtIndex:(NSInteger)index;
- (void)removeSpecifierAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)removeLastSpecifier;
@end

@interface PSSetupController : PSListController
- (void)pushControllerOnParentWithSpecifier:(PSSpecifier *)specifier ;
- (void)popControllerOnParent;

- (void)dismiss;
- (void)dismissAnimated:(BOOL)animated;
@end

static VAPreferences *preferences = nil;

__attribute__((constructor)) static void VAPreferencesInit() {
    preferences = [VAPreferencesLoad() retain];
}

static void VAPreferencesPostPreferencesChangedNotification() {
    CFNotificationCenterPostNotificationWithOptions(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.chpwn.voiceactivator.preferences-changed"), NULL, NULL, 0);
}

@interface VAPreferencesListController : PSListController {
    PSSpecifier *lastc;
    PSSpecifier *lastr;
}
@end

@interface VAActivatorEventController : PSViewController {
    LAEventSettingsController *settings;
}
@end

@interface VAActivatorActionController : PSViewController {
    LAListenerSettingsViewController *settings;
}
@end

@interface VAResponseListController : PSListController {
    VAResponse *response;
    PSSpecifier *text;
}
@end

@interface VANewResponseSetupController : PSSetupController
@end

@interface VANewResponseListController : VAResponseListController
@end

@interface VACommandListController : PSListController {
    VACommand *command;
    PSSpecifier *action;
    PSSpecifier *activator;
    PSSpecifier *exit;
    PSSpecifier *varhelp;
    int helpidx;
    int exitidx;
}
@end

@interface VANewCommandSetupController : PSSetupController
@end

@interface VANewCommandListController : VACommandListController
@end

static VAPreferencesListController *sharedListController;
@implementation VAPreferencesListController

+ (id)sharedInstance {
    return sharedListController;
}

- (PSSpecifier *)specifierForCommand:(VACommand *)command {
    PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:VACommandGet(command, kVACommandCommandKey)
        target:nil set:nil get:nil detail:[VACommandListController class] cell:PSLinkCell edit:nil];
    [specifier setProperty:[VACommandGet(command, kVACommandIdentifierKey) stringValue] forKey:@"id"];
    return specifier;
}

- (PSSpecifier *)specifierForResponse:(VAResponse *)response {
    PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:VAResponseGet(response, kVAResponseTextKey)
        target:nil set:nil get:nil detail:[VAResponseListController class] cell:PSLinkCell edit:nil];
    [specifier setProperty:[VAResponseGet(response, kVAResponseIdentifierKey) stringValue] forKey:@"id"];
    return specifier;
}

- (NSArray *)specifiers {
    sharedListController = self;

    if (!_specifiers) {
        _specifiers =  [[self loadSpecifiersFromPlistName:@"VABase" target:self] mutableCopy];

        int start = 0;
        NSMutableArray *items = nil;

        items = [NSMutableArray array];
        start = [self indexOfSpecifierID:@"commands"] + 1;
        for (VACommand *command in VAPreferencesGet(preferences, kVAPreferencesCommandsKey)) [items insertObject:[self specifierForCommand:command] atIndex:0];
        for (PSSpecifier *specifier in items) [_specifiers insertObject:specifier atIndex:start];

        items = [NSMutableArray array];
        start = [self indexOfSpecifierID:@"responses"] + 1;
        for (VAResponse *response in VAPreferencesGet(preferences, kVAPreferencesResponsesKey)) [items insertObject:[self specifierForResponse:response] atIndex:0];
        for (PSSpecifier *specifier in items) [_specifiers insertObject:specifier atIndex:start];
    }

    return _specifiers;
}

- (void)removeSpecifierForCommand:(VACommand *)command animated:(BOOL)animated {
    PSSpecifier *specifier = [self specifierForID:VACommandGet(command, kVACommandIdentifierKey)];
    int index = [self indexOfSpecifier:specifier];
    if (specifier == lastc) lastc = [self specifierAtIndex:index - 1];
    [self removeSpecifier:specifier animated:animated];
}

- (void)removeSpecifierForResponse:(VAResponse *)response animated:(BOOL)animated {
    PSSpecifier *specifier = [self specifierForID:VAResponseGet(response, kVAResponseIdentifierKey)];
    int index = [self indexOfSpecifier:specifier];
    if (specifier == lastr) lastr = [self specifierAtIndex:index - 1];
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

@implementation VAActivatorEventController

- (UIView *)view {
    return [settings view];
}

- (id)navigationItem {
    return [settings navigationItem];
}

- (id)navigationTitle {
    return [settings navigationTitle];
}

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

@implementation VAActivatorActionController

- (UIView *)view {
    return [settings view];
}

- (id)navigationItem {
    return [settings navigationItem];
}

- (id)navigationTitle {
    return [settings navigationTitle];
}

- (void)dealloc {
    [settings release];
    [super dealloc];
}

- (id)initWithActionName:(NSString *)name {
    self = [super init];

    settings = [[LAListenerSettingsViewController alloc] init];
    [settings setListenerName:name];
    [settings setDelegate:self];

    return self;
}

@end

@implementation VAResponseListController

- (VAResponse *)produceResponse {
    NSString *identifier = [[self specifier] propertyForKey:@"id"];
    return [VAPreferencesGetResponseWithIdentifier(preferences, [NSNumber numberWithInt:[identifier intValue]]) retain];
}

- (id)specifiers {
	if (!_specifiers) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"VAResponse" target:self] mutableCopy];
        text = [[self specifierForID:@"text"] retain];

        if (response == nil) response = [self produceResponse];
    }

    return _specifiers;
}

- (void)write {
    VAPreferencesSave(preferences);
    VAPreferencesPostPreferencesChangedNotification();
    [[VAPreferencesListController sharedInstance] reloadSpecifiers];
}

- (void)save {
    if (response == nil) return;
    VAPreferencesSetResponseWithIdentifier(preferences, (NSNumber *) VAResponseGet(response, kVAResponseIdentifierKey), response);
    [self write];
}

- (NSString *)getTextWithSpecifier:(PSSpecifier *)specifier {
    return VAResponseGet(response, kVAResponseTextKey);
}

- (void)setText:(NSString *)t withSpecifier:(PSSpecifier *)specifier {
    VAResponseSet(response, kVAResponseTextKey, t);
    [self save];
}

- (void)configureWithSpecifier:(PSSpecifier *)specifier {
    VAActivatorActionController *settings = [[[VAActivatorActionController alloc] initWithActionName:VAResponseActionName(response)] autorelease];;
    [[self rootController] pushViewController:settings animated:YES];
}

- (void)delete {
    VAPreferencesRemoveResponseWithIdentifier(preferences, (NSNumber *) VAResponseGet(response, kVAResponseIdentifierKey));
    [self write];
}

- (void)deleteResponse {
    [self delete];
    [[self parentController] popViewControllerAnimated:YES];
}

- (void)dealloc {
    [response release];
    [super dealloc];
}

@end

@implementation VANewResponseSetupController

+ (BOOL)isOverlay {
    return NO;
}

@end

@implementation VANewResponseListController

- (VAResponse *)produceResponse {
    [self removeSpecifier:[self specifierForID:@"delete"]];
    [self removeSpecifier:[self specifierForID:@"deletegroup"]];
    return [VAResponseCreate() retain];
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
    response = nil;
    [[self parentController] dismiss];
}

@end


@implementation VACommandListController

- (VACommand *)produceCommand {
    NSString *identifier = [[self specifier] propertyForKey:@"id"];
    return [VAPreferencesGetCommandWithIdentifier(preferences, [NSNumber numberWithInt:[identifier intValue]]) retain];
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

- (void)updateHelp {
    [self removeSpecifier:varhelp animated:NO];

    if ([VACommandGet(command, kVACommandTypeKey) isEqual:kVACommandTypeSpeak])
        [self insertSpecifier:varhelp atIndex:MIN((NSInteger) helpidx, (NSInteger) [_specifiers count] - 1)  animated:NO];
}

- (id)specifiers {
	if (!_specifiers) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"VACommand" target:self] mutableCopy];
        action = [[self specifierForID:@"action"] retain];
        activator = [[self specifierForID:@"activator"] retain];
        exit = [[self specifierForID:@"exit"] retain];
        varhelp = [[self specifierForID:@"varhelp"] retain];
        exitidx = [self indexOfSpecifier:exit] - 1;
        helpidx = [self indexOfSpecifier:varhelp] - 1;

        if (command == nil) command = [self produceCommand];
        [self updateAction];
        [self updateExit];
        [self updateHelp];
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
    return VACommandGet(command, kVACommandCommandKey);
}

- (void)setCommand:(NSString *)cmd withSpecifier:(PSSpecifier *)specifier {
    VACommandSet(command, kVACommandCommandKey, cmd);
    [self save];
}

- (NSString *)getActionWithSpecifier:(PSSpecifier *)specifier {
    return VACommandGet(command, kVACommandActionKey);
}

- (void)setAction:(NSString *)cmd withSpecifier:(PSSpecifier *)specifier {
    VACommandSet(command, kVACommandActionKey, cmd);
    [self save];
}

- (NSNumber *)getTypeWithSpecifier:(PSSpecifier *)specifier {
    return VACommandGet(command, kVACommandTypeKey);
}

- (void)setType:(NSNumber *)type withSpecifier:(PSSpecifier *)specifier {
    VACommandSet(command, kVACommandTypeKey, type);
    [self updateAction];
    [self updateExit];
    [self updateHelp];
    [self save];
}

- (NSNumber *)getExitWithSpecifier:(PSSpecifier *)specifier {
    return VACommandGet(command, kVACommandCompleteKey);
}

- (void)setExit:(NSNumber *)e withSpecifier:(PSSpecifier *)specifier {
    VACommandSet(command, kVACommandCompleteKey, e);
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
        [[self rootController] pushViewController:settings animated:YES];
    }
}

- (void)dealloc {
    [command release];
    [super dealloc];
}

@end

@implementation VANewCommandSetupController

+ (BOOL)isOverlay {
    return NO;
}

@end

@implementation VANewCommandListController

- (VACommand *)produceCommand {
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
