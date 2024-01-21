//
//  ToolchainsCollectionViewItem.mm
//  Swain
//
//  Created by Jinwoo Kim on 1/19/24.
//

#import "ToolchainsCollectionViewItem.hpp"
#import "NSTextField+ApplyLabelStyle.hpp"
#import "NSView+Private.h"
#import <objc/message.h>

NSUserInterfaceItemIdentifier const identifier = NSStringFromClass(ToolchainsCollectionViewItem.class);

__attribute__((objc_direct_members))
@interface ToolchainsCollectionViewItem () {
    NSStackView *_stackView;
    NSButton *_downloadButton;
}
@property (retain, nonatomic, readonly) NSStackView *stackView;
@property (retain, nonatomic, readonly) NSButton *downloadButton;
@property (copy, nonatomic) NSManagedObjectID * _Nullable managedObjectID;
@end

@implementation ToolchainsCollectionViewItem

+ (NSUserInterfaceItemIdentifier)identifier {
    return identifier;
}

- (void)dealloc {
    [_stackView release];
    [_downloadButton release];
    [_managedObjectID release];
    [super dealloc];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self updateBackgroundColor];
}

- (void)setHighlightState:(NSCollectionViewItemHighlightState)highlightState {
    [super setHighlightState:highlightState];
    [self updateBackgroundColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSTextField *textField = [[NSTextField alloc] initWithFrame:self.view.bounds];
    textField.textColor = NSColor.controlTextColor;
    [textField applyLabelStyle];
    
    NSStackView *stackView = self.stackView;
    [stackView addArrangedSubview:textField];
    [stackView addArrangedSubview:self.downloadButton];
    
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:stackView];
    [NSLayoutConstraint activateConstraints:@[
        [stackView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [stackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [stackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [stackView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    self.textField = textField;
    [textField release];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.textField.stringValue = [NSString string];
}

- (void)loadWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext managedObjectID:(NSManagedObjectID *)managedObjectID {
    self.managedObjectID = managedObjectID;
    
    [managedObjectContext performBlock:^{
        NSManagedObject *managedObject = [managedObjectContext objectWithID:managedObjectID];
        NSString *name = [managedObject valueForKey:@"name"];
        if (name == nil) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![self.managedObjectID isEqual:managedObjectID]) return;
            self.textField.stringValue = name;
        });
    }];
}

- (NSStackView *)stackView {
    if (auto stackView = _stackView) return stackView;
    
    NSStackView *stackView = [[NSStackView alloc] initWithFrame:self.view.bounds];
    stackView.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    stackView.alignment = NSLayoutAttributeCenterY;
    stackView.distribution = NSStackViewDistributionFillProportionally;
    stackView.spacing = 8.f;
    stackView.edgeInsets = NSEdgeInsetsMake(8.f, 8.f, 8.f, 8.f);
    
    _stackView = [stackView retain];
    return [stackView autorelease];
}

- (NSButton *)downloadButton {
    if (auto downloadButton = _downloadButton) return downloadButton;
    
    NSButton *downloadButton = [NSButton buttonWithImage:[NSImage imageWithSystemSymbolName:@"arrow.down" accessibilityDescription:nil]
                                                  target:self
                                                  action:@selector(downloadButtonDidTrigger:)];
    
    downloadButton.bezelStyle = NSBezelStyleCircular;
    
    _downloadButton = [downloadButton retain];
    return downloadButton;
}

- (void)downloadButtonDidTrigger:(NSButton *)sender {
    
}

- (void)updateBackgroundColor __attribute__((objc_direct)) {
    if (self.selected) {
        self.view.backgroundColor = NSColor.systemTealColor;
    } else if (self.highlightState == NSCollectionViewItemHighlightForSelection) {
        self.view.backgroundColor = [NSColor.systemTealColor colorWithAlphaComponent:0.3];
    } else {
        self.view.backgroundColor = nil;
    }
}

@end
