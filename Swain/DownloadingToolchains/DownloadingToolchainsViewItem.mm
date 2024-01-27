//
//  DownloadingToolchainsViewItem.mm
//  Swain
//
//  Created by Jinwoo Kim on 1/27/24.
//

#import "DownloadingToolchainsViewItem.hpp"
#import "NSView+Private.h"
#import "NSTextField+ApplyLabelStyle.hpp"

namespace ns_DownloadingToolchainsViewItem {
    NSUserInterfaceItemIdentifier const identifier = NSStringFromClass(DownloadingToolchainsViewItem.class);
};

__attribute__((objc_direct_members))
@interface DownloadingToolchainsViewItem () {
    NSStackView *_stackView;
    NSTextField *_dt_textField;
    NSProgressIndicator *_progressIndicator;
}
@property (retain, nonatomic, readonly) NSStackView *stackView;
@property (retain, nonatomic, readonly) NSProgressIndicator *progressIndicator;
@property (retain, nonatomic, readonly) NSTextField *dt_textField;
@end

@implementation DownloadingToolchainsViewItem

+ (NSUserInterfaceItemIdentifier)identifier {
    return ns_DownloadingToolchainsViewItem::identifier;
}

- (void)dealloc {
    [_stackView release];
    [_dt_textField release];
    [_progressIndicator release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSStackView *stackView = self.stackView;
    NSTextField *dt_textField = self.dt_textField;
    NSProgressIndicator *progressIndicator = self.progressIndicator;
    
    [self.view addSubview:stackView];
    [stackView addArrangedSubview:dt_textField];
    [stackView addArrangedSubview:progressIndicator];
    
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:stackView];
    [NSLayoutConstraint activateConstraints:@[
        [stackView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [stackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [stackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [stackView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

- (void)loadWithItemModel:(DownloadingToolchainsViewItemModel *)itemModel {
    self.dt_textField.stringValue = itemModel.name;
    self.progressIndicator.observedProgress = itemModel.progress;
}

- (NSStackView *)stackView {
    if (auto stackView = _stackView) return stackView;
    
    NSStackView *stackView = [[NSStackView alloc] initWithFrame:self.view.bounds];
    stackView.orientation = NSUserInterfaceLayoutOrientationVertical;
    stackView.alignment = NSLayoutAttributeLeading;
    stackView.distribution = NSStackViewDistributionFillProportionally;
    stackView.spacing = 8.f;
    stackView.edgeInsets = NSEdgeInsetsMake(8.f, 8.f, 8.f, 8.f);
    
    _stackView = [stackView retain];
    return [stackView autorelease];
}

- (NSTextField *)dt_textField {
    if (auto dt_textField = _dt_textField) return dt_textField;
    
    NSTextField *dt_textField = [NSTextField labelWithString:[NSString string]];
    [dt_textField applyLabelStyle];
    
    self.textField = dt_textField;
    _dt_textField = [dt_textField retain];
    
    return [dt_textField autorelease];
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

@end
