//
//  SettingsHelperViewController.mm
//  Swain
//
//  Created by Jinwoo Kim on 2/7/24.
//

#if !SANDBOXED

#import "SettingsHelperViewController.hpp"
#import "NSView+Private.h"
#import "NSTextField+ApplyLabelStyle.hpp"
#import "HelperManager.hpp"

__attribute__((objc_direct_members))
@interface SettingsHelperViewController () {
    NSStackView *_stackView;
    NSTextField *_helperStatusTextField;
    NSButton *_installHelperButton;
    NSButton *_uninstallHelperButton;
    NSButton *_pingPongButton;
}
@property (retain, nonatomic, readonly) NSStackView *stackView;
@property (retain, nonatomic, readonly) NSTextField *helperStatusTextField;
@property (retain, nonatomic, readonly) NSButton *installHelperButton;
@property (retain, nonatomic, readonly) NSButton *uninstallHelperButton;
@property (retain, nonatomic, readonly) NSButton *pingPongButton;
@end

@implementation SettingsHelperViewController

- (void)dealloc {
    [_stackView release];
    [_helperStatusTextField release];
    [_installHelperButton release];
    [_uninstallHelperButton release];
    [_pingPongButton release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSView *view = self.view;
    NSStackView *stackView = self.stackView;
    [stackView addArrangedSubview:self.helperStatusTextField];
    [stackView addArrangedSubview:self.installHelperButton];
    [stackView addArrangedSubview:self.uninstallHelperButton];
    [stackView addArrangedSubview:self.pingPongButton];
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [view addSubview:stackView];
    [NSLayoutConstraint activateConstraints:@[
        [stackView.centerXAnchor constraintEqualToAnchor:view.centerXAnchor],
        [stackView.centerYAnchor constraintEqualToAnchor:view.centerYAnchor],
        [stackView.topAnchor constraintGreaterThanOrEqualToAnchor:view.topAnchor],
        [stackView.leadingAnchor constraintGreaterThanOrEqualToAnchor:view.leadingAnchor],
        [stackView.trailingAnchor constraintLessThanOrEqualToAnchor:view.trailingAnchor],
        [stackView.bottomAnchor constraintLessThanOrEqualToAnchor:view.bottomAnchor]
    ]];
    
    [self updateHelperStatusTextFieldWithIsInstalled:HelperManager.sharedInstance.isInstalled];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(isIntalledDidChange:)
                                               name:ns_HelperManager::isInstalledDidChangeNotification
                                             object:HelperManager.sharedInstance];
}

- (NSStackView *)stackView {
    if (auto stackView = _stackView) return stackView;
    
    NSStackView *stackView = [[NSStackView alloc] initWithFrame:self.view.bounds];
    stackView.orientation = NSUserInterfaceLayoutOrientationVertical;
    stackView.alignment = NSLayoutAttributeCenterX;
    stackView.spacing = 8.f;
    stackView.distribution = NSStackViewDistributionFillProportionally;
    
    _stackView = [stackView retain];
    return [stackView autorelease];
}

- (NSTextField *)helperStatusTextField {
    if (auto helperStatusTextField = _helperStatusTextField) return helperStatusTextField;
    
    NSTextField *helperStatusTextField = [NSTextField labelWithString:@"Pending..."];
    [helperStatusTextField applyLabelStyle];
    
    _helperStatusTextField = [helperStatusTextField retain];
    return helperStatusTextField;
}

- (NSButton *)installHelperButton {
    if (auto installHelperButton = _installHelperButton) return installHelperButton;
    
    NSButton *installHelperButton = [NSButton buttonWithTitle:@"Install Helper"
                                                       target:self
                                                       action:@selector(installHelperButtonDidTrigger:)];
    installHelperButton.bezelStyle = NSBezelStylePush;
    
    _installHelperButton = [installHelperButton retain];
    return installHelperButton;
}

- (NSButton *)uninstallHelperButton {
    if (auto installHelperButton = _uninstallHelperButton) return installHelperButton;
    
    NSButton *installHelperButton = [NSButton buttonWithTitle:@"Uninstall Helper"
                                                       target:self
                                                       action:@selector(uninstallHelperButtonDidTrigger:)];
    installHelperButton.bezelStyle = NSBezelStylePush;
    
    _installHelperButton = [installHelperButton retain];
    return installHelperButton;
}

- (NSButton *)pingPongButton {
    if (auto pingPongButton = _pingPongButton) return pingPongButton;
    
    NSButton *pingPongButton = [NSButton buttonWithTitle:@"Ping"
                                                  target:self
                                                  action:@selector(pingPongButtonDidTrigger:)];
    pingPongButton.bezelStyle = NSBezelStylePush;
    
    _pingPongButton = [pingPongButton retain];
    return pingPongButton;
}

- (void)installHelperButtonDidTrigger:(NSButton *)sender {
    [HelperManager.sharedInstance installHelperWithCompletionHandler:^(NSError * _Nullable error) {
        
    }];
}

- (void)uninstallHelperButtonDidTrigger:(NSButton *)sender {
    [HelperManager.sharedInstance uninstallHelperWithCompletionHandler:^(NSError * _Nullable error) {
        
    }];
}

- (void)pingPongButtonDidTrigger:(NSButton *)sender {
    
}

- (void)isIntalledDidChange:(NSNotification *)notification {
    BOOL isInstalled = reinterpret_cast<NSNumber *>(notification.userInfo[ns_HelperManager::isInstalledKey]).boolValue;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateHelperStatusTextFieldWithIsInstalled:isInstalled];
    });
}

- (void)updateHelperStatusTextFieldWithIsInstalled:(BOOL)isInstalled __attribute__((objc_direct)) {
    self.helperStatusTextField.stringValue = isInstalled ? @"Installed" : @"Not Installed";
}

@end

#endif
