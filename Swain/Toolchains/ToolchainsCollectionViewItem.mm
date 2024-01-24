//
//  ToolchainsCollectionViewItem.mm
//  Swain
//
//  Created by Jinwoo Kim on 1/19/24.
//

#import "ToolchainsCollectionViewItem.hpp"
#import "NSTextField+ApplyLabelStyle.hpp"
#import "NSView+Private.h"
#import <CoreFoundation/CoreFoundation.h>
#import <objc/message.h>
@import SwainCore;

namespace ns_ToolchainsCollectionViewItem {
    NSUserInterfaceItemIdentifier const identifier = NSStringFromClass(ToolchainsCollectionViewItem.class);
void callback(CFNotificationCenterRef center, void *observer, CFNotificationName name, const void *object, CFDictionaryRef userInfo) {
    NSLog(@"Hello!");
}
}

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
    return ns_ToolchainsCollectionViewItem::identifier;
}

- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self commonInit_ToolchainsCollectionViewItem];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self commonInit_ToolchainsCollectionViewItem];
    }
    
    return self;
}

- (void)dealloc {
    void *object = swift::_impl::_impl_RefCountedClass::getOpaquePointer(SwainCore::ToolchainPackageManager::getSharedInstance());
    swift::String name = SwainCore::ToolchainPackageManager::getDidChangeDownloadingProgressesNotificationName();
    const char *cString = [static_cast<NSString *>(name) cStringUsingEncoding:NSUTF8StringEncoding];
    CFStringRef cfString = CFStringCreateWithCString(kCFAllocatorDefault,
                                                     cString,
                                                     kCFStringEncodingUTF8);
    
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetLocalCenter(),
                                       self,
                                       cfString,
                                       object);
    
    [_stackView release];
    [_downloadButton release];
    [_managedObjectID release];
    [super dealloc];
}

- (void)commonInit_ToolchainsCollectionViewItem __attribute__((objc_direct)) {
    void *object = swift::_impl::_impl_RefCountedClass::getOpaquePointer(SwainCore::ToolchainPackageManager::getSharedInstance());
    
    
    swift::String name = SwainCore::ToolchainPackageManager::getDidChangeDownloadingProgressesNotificationName();
//    CFStringRef cfString = CFStringCreateWithCString(kCFAllocatorDefault,
//                                                     swift::_impl::_impl_String::getOpaquePointer(name),
//                                                     kCFStringEncodingUTF8);
    
    const char *cString = [static_cast<NSString *>(name) cStringUsingEncoding:NSUTF8StringEncoding];
    CFStringRef cfString = CFStringCreateWithCString(kCFAllocatorDefault,
                                                     cString,
                                                     kCFStringEncodingUTF8);
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(),
                                    self,
                                    ns_ToolchainsCollectionViewItem::callback,
                                    cfString,
                                    object,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"completedUnitCount"]) {
        NSLog(@"%f", reinterpret_cast<NSProgress *>(object).fractionCompleted);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
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
    using namespace SwainCore;
    
    auto managedObjectID = self.managedObjectID;
    
    ToolchainDataManager::getSharedInstance();
    ToolchainDataManager::getSharedInstance().managedObjectContext(^(NSManagedObjectContext * _Nullable context, NSError * _Nullable error) {
        assert(!error);
        
        [context performBlock:^{
            NSManagedObject *toolchain = [context objectWithID:managedObjectID];
            NSString *name = [toolchain valueForKey:@"name"];
            NSString *category = [toolchain valueForKey:@"category"];
            
            ToolchainPackageManager::getSharedInstance().download([name cStringUsingEncoding:NSUTF8StringEncoding],
                                                                  [category cStringUsingEncoding:NSUTF8StringEncoding],
                                                                  ^(NSProgress *progress) {
                [progress addObserver:self forKeyPath:@"completedUnitCount" options:NSKeyValueObservingOptionNew context:NULL];
            },
                                                                  ^(NSURL * _Nullable url, NSError * _Nullable error) {
                assert(!error);
                NSLog(@"%@", url);
            });
        }];
    });
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
