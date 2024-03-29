//
//  DownloadingToolchainsViewItem.mm
//  Swain
//
//  Created by Jinwoo Kim on 1/27/24.
//

#import "DownloadingToolchainsViewItem.hpp"
#import "NSView+Private.h"
#import "NSTextField+ApplyLabelStyle.hpp"
#import "HelperManager.hpp"
@import SwainCore;

namespace ns_DownloadingToolchainsViewItem {
    NSUserInterfaceItemIdentifier const identifier = NSStringFromClass(DownloadingToolchainsViewItem.class);
    void *stateInfo = &stateInfo;
};

__attribute__((objc_direct_members))
@interface DownloadingToolchainsViewItem () {
    NSStackView *_verticalStackView;
    NSStackView *_horizontalStackView;
    NSTextField *_nameTextField;
    NSProgressIndicator *_progressIndicator;
    NSButton *_openButton;
}
@property (retain, nonatomic, readonly) NSStackView *verticalStackView;
@property (retain, nonatomic, readonly) NSStackView *horizontalStackView;
@property (retain, nonatomic, readonly) NSProgressIndicator *progressIndicator;
@property (retain, nonatomic, readonly) NSTextField *nameTextField;
@property (retain, nonatomic, readonly) NSButton *openButton;
@property (retain, nonatomic) DownloadingToolchainsViewItemModel * _Nullable itemModel;
@end

@implementation DownloadingToolchainsViewItem

+ (NSUserInterfaceItemIdentifier)identifier {
    return ns_DownloadingToolchainsViewItem::identifier;
}

- (void)dealloc {
    [_verticalStackView release];
    [_horizontalStackView release];
    [_nameTextField release];
    [_progressIndicator release];
    [_openButton release];
    
    [self removeIsDownloadingObserver];
    [_itemModel release];
    
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == ns_DownloadingToolchainsViewItem::stateInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateAttributes];
        });
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setItemModel:(DownloadingToolchainsViewItemModel *)itemModel {
    [self removeIsDownloadingObserver];
    [_itemModel release];
    _itemModel = [itemModel retain];
    
    [itemModel.toolchainPackage addObserver:self forKeyPath:@"stateInfo" options:NSKeyValueObservingOptionNew context:ns_DownloadingToolchainsViewItem::stateInfo];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSStackView *verticalStackView = self.verticalStackView;
    NSStackView *horizontalStackView = self.horizontalStackView;
    NSTextField *nameTextField = self.nameTextField;
    NSButton *openButton = self.openButton;
    NSProgressIndicator *progressIndicator = self.progressIndicator;
    
    [self.view addSubview:verticalStackView];
    [verticalStackView addArrangedSubview:horizontalStackView];
    [horizontalStackView addArrangedSubview:nameTextField];
    [horizontalStackView addArrangedSubview:openButton];
    [verticalStackView addArrangedSubview:progressIndicator];
    
    verticalStackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:verticalStackView];
    [NSLayoutConstraint activateConstraints:@[
        [verticalStackView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [verticalStackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [verticalStackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [verticalStackView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (void)loadWithItemModel:(DownloadingToolchainsViewItemModel *)itemModel {
    self.itemModel = itemModel;
    [self updateAttributes];
}

- (NSStackView *)horizontalStackView {
    if (auto horizontalStackView = _horizontalStackView) return horizontalStackView;
    
    NSStackView *horizontalStackView = [[NSStackView alloc] initWithFrame:self.view.bounds];
    horizontalStackView.orientation = NSUserInterfaceLayoutOrientationHorizontal;
//    horizontalStackView.alignment = ㅜ;
    horizontalStackView.distribution = NSStackViewDistributionFillProportionally;
    horizontalStackView.spacing = 8.f;
    horizontalStackView.edgeInsets = NSEdgeInsetsMake(8.f, 8.f, 8.f, 8.f);
    
    _horizontalStackView = [horizontalStackView retain];
    return [horizontalStackView autorelease];
}

- (NSStackView *)verticalStackView {
    if (auto verticalStackView = _verticalStackView) return verticalStackView;
    
    NSStackView *verticalStackView = [[NSStackView alloc] initWithFrame:self.view.bounds];
    verticalStackView.orientation = NSUserInterfaceLayoutOrientationVertical;
    verticalStackView.alignment = NSLayoutAttributeLeading;
    verticalStackView.distribution = NSStackViewDistributionFillProportionally;
    verticalStackView.spacing = 8.f;
    verticalStackView.edgeInsets = NSEdgeInsetsMake(8.f, 8.f, 8.f, 8.f);
    
    _verticalStackView = [verticalStackView retain];
    return [verticalStackView autorelease];
}

- (NSTextField *)nameTextField {
    if (auto nameTextField = _nameTextField) return nameTextField;
    
    NSTextField *nameTextField = [NSTextField labelWithString:[NSString string]];
    [nameTextField applyLabelStyle];
    
    self.textField = nameTextField;
    _nameTextField = [nameTextField retain];
    
    return nameTextField;
}

- (NSProgressIndicator *)progressIndicator {
    if (auto progressIndicator = _progressIndicator) return progressIndicator;
    
    NSProgressIndicator *progressIndicator = [[NSProgressIndicator alloc] initWithFrame:self.view.bounds];
    
    progressIndicator.style = NSProgressIndicatorStyleBar;
    progressIndicator.indeterminate = NO;
    progressIndicator.controlSize = NSControlSizeLarge;
    progressIndicator.usesThreadedAnimation = YES;
    
    _progressIndicator = [progressIndicator retain];
    return [progressIndicator autorelease];
}

- (NSButton *)openButton {
    if (auto openButton = _openButton) return openButton;
    
    NSButton *openButton = [NSButton buttonWithImage:[NSImage imageWithSystemSymbolName:@"folder.fill" accessibilityDescription:nil]
                                              target:self
                                              action:@selector(openButtonDidTrigger:)];
    
    openButton.bezelStyle = NSBezelStyleCircular;
    
    _openButton = [openButton retain];
    return openButton;
}

- (void)removeIsDownloadingObserver __attribute__((objc_direct)) {
    if (auto toolchainPackage = _itemModel.toolchainPackage) {
        [toolchainPackage removeObserver:self forKeyPath:@"stateInfo" context:ns_DownloadingToolchainsViewItem::stateInfo];
    }
}

- (void)updateAttributes __attribute__((objc_direct)) {
    self.nameTextField.stringValue = self.itemModel.toolchainPackage.name;
    self.progressIndicator.observedProgress = self.itemModel.toolchainPackage.stateInfo[SWCToolchainPackage.downloadingProgressKey];
    
    if ([self.itemModel.toolchainPackage.stateInfo[SWCToolchainPackage.stateKey] isEqualToString:SWCToolchainPackage.downloadingState]) {
        self.progressIndicator.hidden = NO;
        self.openButton.hidden = YES;
    } else {
        self.progressIndicator.hidden = YES;
        self.openButton.hidden = NO;
    }
}

- (void)openButtonDidTrigger:(NSButton *)sender {
    if (NSURL *downloadedURL = self.itemModel.toolchainPackage.stateInfo[SWCToolchainPackage.downloadedURLKey]) {
//        [NSWorkspace.sharedWorkspace openURL:downloadedURL];
        
#if SANDBOXED
        [NSWorkspace.sharedWorkspace activateFileViewerSelectingURLs:@[downloadedURL]];
#else
        [HelperManager.sharedInstance installPackageWithURL:downloadedURL completionHandler:^(NSError * _Nullable error) {
            assert(!error);
            
            SwainCore::XcodeManager::getSharedInstance().changeSelectedToolchain([self.itemModel.toolchainPackage.name cStringUsingEncoding:NSUTF8StringEncoding], ^(NSError * _Nullable error) {
                assert(!error);
            });
        }];
#endif
    }
}

@end
