//
//  MainWindow.mm
//  Swain
//
//  Created by Jinwoo Kim on 1/15/24.
//

#import "MainWindow.hpp"
#import "MainSidebarViewController.hpp"
#import "ToolchainsViewController.hpp"
#import "ToolchainInspectorViewController.hpp"
#import "getStringFromSwiftString.hpp"
#import "DownloadingToolchainsViewController.hpp"
#import <objc/message.h>
@import SwainCore;

__attribute__((objc_direct_members))
@interface MainWindow () <NSToolbarDelegate, MainSidebarViewControllerDelegate> {
    NSSplitViewController *_splitViewController;
    NSSplitViewItem *_sidebarSplitViewItem;
    MainSidebarViewController *_mainSidebarViewController;
    ToolchainsViewController *_stableToolchainsViewController;
    ToolchainsViewController *_releaseToolchainsViewController;
    ToolchainsViewController *_mainToolchainsViewController;
    ToolchainInspectorViewController *_toolchainInspectorViewController;
}
@property (retain, nonatomic, readonly) NSSplitViewController *splitViewController;
@property (retain, nonatomic, readonly) NSSplitViewItem *sidebarSplitViewItem;
@property (retain, nonatomic) NSSplitViewItem *contentListSplitViewItem;
@property (retain, nonatomic) NSSplitViewItem * _Nullable inspectorSplitViewItem;
@property (retain, nonatomic, readonly) MainSidebarViewController *mainSidebarViewController;
@property (retain, nonatomic, readonly) ToolchainsViewController *mainToolchainsViewController;
@property (retain, nonatomic, readonly) ToolchainsViewController *stableToolchainsViewController;
@property (retain, nonatomic, readonly) ToolchainsViewController *releaseToolchainsViewController;
@property (retain, nonatomic, readonly) ToolchainsViewController * _Nullable currentToolchainsViewController;
@property (retain, nonatomic, readonly) ToolchainInspectorViewController *toolchainInspectorViewController;
@property (retain, nonatomic) NSProgress * _Nullable reloadProgress;
@property (retain, nonatomic, readonly) NSString * _Nullable searchText;
- (void)downloadingProgressesDidChange;
@end

namespace ns_MainWindow {
    const NSToolbarIdentifier toolbarIdentifier = @"MainWindowToolbarIdentifier";
    const NSToolbarItemIdentifier swiftToolbarItemIdentifier = @"MainWindowSwiftToolbarItemIdentifier";
    const NSToolbarItemIdentifier reloadToolbarItemIdentifier = @"MainWindowReloadToolbarItemIdentifier";
    const NSToolbarItemIdentifier searchToolbarItemIdentifier = @"MainWindowSearchToolbarItemIdentifier";
    const NSToolbarItemIdentifier downloadingToolchainsItemIdentifier = @"MainWindowDownloadingToolchainsItemIdentifier";

    void downloadingProgressesDidChangeCallback(CFNotificationCenterRef center,
                                                void *observer,
                                                CFNotificationName name,
                                                const void *object,
                                                CFDictionaryRef userInfo)
    {
        auto mainWindow = reinterpret_cast<MainWindow *>(object);
        [mainWindow downloadingProgressesDidChange];
    }
}

@implementation MainWindow

- (instancetype)init {
    self = [self initWithContentRect:NSMakeRect(0.f, 0.f, 800.f, 600.f)
                            styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable | NSWindowStyleMaskTitled | NSWindowStyleMaskFullSizeContentView
                              backing:NSBackingStoreBuffered
                                defer:YES];
    
    return self;
}

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag {
    if (self = [super initWithContentRect:contentRect styleMask:style backing:backingStoreType defer:flag]) {
        [self commonInit_MainWindow];
    }
    
    return self;
}

- (void)dealloc {
    void *object = swift::_impl::_impl_RefCountedClass::getOpaquePointer(SwainCore::ToolchainPackageManager::getSharedInstance());
    CFStringRef cfString = getCFStringFromSwiftString(SwainCore::ToolchainPackageManager::getDidChangeToolchainPackagesNotificationName());
    
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetLocalCenter(),
                                       self,
                                       cfString,
                                       object);
    
    [_splitViewController release];
    [_sidebarSplitViewItem release];
    [_contentListSplitViewItem release];
    [_inspectorSplitViewItem release];
    [_mainSidebarViewController release];
    [_stableToolchainsViewController release];
    [_releaseToolchainsViewController release];
    [_mainToolchainsViewController release];
    [_toolchainInspectorViewController release];
    [_reloadProgress cancel];
    [_reloadProgress release];
    [super dealloc];
}

- (void)commonInit_MainWindow __attribute__((objc_direct)) {
    self.title = @"Swain";
    self.movableByWindowBackground = YES;
    self.contentMinSize = CGSizeMake(800.f, 600.f);
    
    //
    
    NSSplitViewController *splitViewController = self.splitViewController;
    self.contentViewController = splitViewController;
    
    [splitViewController addSplitViewItem:self.sidebarSplitViewItem];
    
    NSViewController *emptyViewController = [NSViewController new];
    [self replaceContentViewController:emptyViewController];
    [emptyViewController release];
    
    //
    
    void *object = swift::_impl::_impl_RefCountedClass::getOpaquePointer(SwainCore::ToolchainPackageManager::getSharedInstance());
    CFStringRef cfString = getCFStringFromSwiftString(SwainCore::ToolchainPackageManager::getDidChangeToolchainPackagesNotificationName());
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(),
                                    self,
                                    ns_MainWindow::downloadingProgressesDidChangeCallback,
                                    cfString,
                                    object,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    
    //
    
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:ns_MainWindow::toolbarIdentifier];
    toolbar.delegate = self;
    toolbar.allowsUserCustomization = NO;
    toolbar.displayMode = NSToolbarDisplayModeIconOnly;
    
    self.toolbar = toolbar;
    [toolbar release];
}

- (NSSplitViewController *)splitViewController {
    if (auto splitViewController = _splitViewController) return splitViewController;
    
    NSSplitViewController *splitViewController = [NSSplitViewController new];
    
    _splitViewController = [splitViewController retain];
    return [splitViewController autorelease];
}

- (NSSplitViewItem *)sidebarSplitViewItem {
    if (auto sidebarSplitViewItem = _sidebarSplitViewItem) return sidebarSplitViewItem;
    
    NSSplitViewItem *sidebarSplitViewItem = [NSSplitViewItem sidebarWithViewController:self.mainSidebarViewController];
    sidebarSplitViewItem.canCollapse = NO;
    reinterpret_cast<void (*)(id, SEL, CGFloat)>(objc_msgSend)(sidebarSplitViewItem, sel_registerName("setMinimumSize:"), 250.f);
    reinterpret_cast<void (*)(id, SEL, CGFloat)>(objc_msgSend)(sidebarSplitViewItem, sel_registerName("setMaximumSize:"), 250.f);
    
    _sidebarSplitViewItem = [sidebarSplitViewItem retain];
    return sidebarSplitViewItem;
}

- (MainSidebarViewController *)mainSidebarViewController {
    if (auto mainSidebarViewController = _mainSidebarViewController) return mainSidebarViewController;
    
    MainSidebarViewController *mainSidebarViewController = [MainSidebarViewController new];
    mainSidebarViewController.delegate = self;
    
    _mainSidebarViewController = [mainSidebarViewController retain];
    return [mainSidebarViewController autorelease];
}

- (ToolchainsViewController *)mainToolchainsViewController {
    if (auto mainToolchainsViewController = _mainToolchainsViewController) return mainToolchainsViewController;
    
    ToolchainsViewController *mainToolchainsViewController = [[ToolchainsViewController alloc] initWithToolchainCategory:SwainCore::Toolchain::getCategoryMainName() searchText:self.searchText];
    
    _mainToolchainsViewController = [mainToolchainsViewController retain];
    return [mainToolchainsViewController autorelease];
}

- (ToolchainsViewController *)stableToolchainsViewController {
    if (auto stableToolchainsViewController = _stableToolchainsViewController) return stableToolchainsViewController;
    
    ToolchainsViewController *stableToolchainsViewController = [[ToolchainsViewController alloc] initWithToolchainCategory:SwainCore::Toolchain::getCategoryStableName() searchText:self.searchText];
    
    _stableToolchainsViewController = [stableToolchainsViewController retain];
    return [stableToolchainsViewController autorelease];
}

- (ToolchainsViewController *)releaseToolchainsViewController {
    if (auto releaseToolchainsViewController = _releaseToolchainsViewController) return releaseToolchainsViewController;
    
    ToolchainsViewController *releaseToolchainsViewController = [[ToolchainsViewController alloc] initWithToolchainCategory:SwainCore::Toolchain::getCategoryReleaseName() searchText:self.searchText];
    
    _releaseToolchainsViewController = [releaseToolchainsViewController retain];
    return [releaseToolchainsViewController autorelease];
}

- (ToolchainInspectorViewController *)toolchainInspectorViewController {
    if (auto toolchainInspectorViewController = _toolchainInspectorViewController) return toolchainInspectorViewController;
    
    ToolchainInspectorViewController *toolchainInspectorViewController = [ToolchainInspectorViewController new];
    
    _toolchainInspectorViewController = [toolchainInspectorViewController retain];
    return [toolchainInspectorViewController autorelease];
}

- (ToolchainsViewController *)currentToolchainsViewController {
    __kindof NSViewController *contentViewController = self.contentListSplitViewItem.viewController;
    
    if ([contentViewController isKindOfClass:ToolchainsViewController.class]) {
        return contentViewController;
    } else {
        return nil;
    }
}

- (void)mainSidebarViewController:(MainSidebarViewController *)mainSidebarViewController didSelectToolchainCategory:(NSString *)toolchainCategory {
    ToolchainsViewController *targetToolchainsViewController;
    
    if ([toolchainCategory isEqualToString:SwainCore::Toolchain::getCategoryMainName()]) {
        targetToolchainsViewController = self.mainToolchainsViewController;
    } else if ([toolchainCategory isEqualToString:SwainCore::Toolchain::getCategoryStableName()]) {
        targetToolchainsViewController = self.stableToolchainsViewController;
    } else if ([toolchainCategory isEqualToString:SwainCore::Toolchain::getCategoryReleaseName()]) {
        targetToolchainsViewController = self.releaseToolchainsViewController;
    } else {
        return;
    }
    
    [self replaceContentViewController:targetToolchainsViewController];
    targetToolchainsViewController.searchText = self.searchText;
}

- (void)replaceContentViewController:(NSViewController *)contentViewController __attribute__((objc_direct)) {
    if (auto contentListSplitViewItem = self.contentListSplitViewItem) {
        [self.splitViewController removeSplitViewItem:contentListSplitViewItem];
        self.contentListSplitViewItem = nil;
    }
    
    if (auto inspectorSplitViewItem = self.inspectorSplitViewItem) {
        [self.splitViewController removeSplitViewItem:inspectorSplitViewItem];
        self.inspectorSplitViewItem = nil;
    }
    
    NSSplitViewItem *contentListSplitViewItem = [NSSplitViewItem contentListWithViewController:contentViewController];
    [self.splitViewController addSplitViewItem:contentListSplitViewItem];
    self.contentListSplitViewItem = contentListSplitViewItem;
    
    if ([contentViewController isKindOfClass:ToolchainsViewController.class]) {
        NSSplitViewItem *inspectorSplitViewItem = [NSSplitViewItem inspectorWithViewController:self.toolchainInspectorViewController];
        self.inspectorSplitViewItem = inspectorSplitViewItem;
        [self.splitViewController addSplitViewItem:inspectorSplitViewItem];
    }
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    return @[
        ns_MainWindow::swiftToolbarItemIdentifier,
        ns_MainWindow::reloadToolbarItemIdentifier,
        ns_MainWindow::downloadingToolchainsItemIdentifier,
        ns_MainWindow::searchToolbarItemIdentifier,
        NSToolbarInspectorTrackingSeparatorItemIdentifier,
        NSToolbarFlexibleSpaceItemIdentifier,
        NSToolbarToggleInspectorItemIdentifier
    ];
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return [self toolbarAllowedItemIdentifiers:toolbar];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSToolbarItemIdentifier)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    if ([itemIdentifier isEqualToString:ns_MainWindow::swiftToolbarItemIdentifier]) {
        NSToolbarItem *swiftToolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        swiftToolbarItem.image = [NSImage imageWithSystemSymbolName:@"swift" accessibilityDescription:nil];
        swiftToolbarItem.navigational = YES;
        swiftToolbarItem.target = self;
        swiftToolbarItem.action = @selector(swiftToolbarItemDidTrigger:);
        
        // NSToolbarButton (NSButton)
        auto _view = reinterpret_cast<NSButton * (*)(id, SEL)>(objc_msgSend)(swiftToolbarItem, sel_registerName("_view"));
        
        // _NSToolbarButtonCell
        NSButtonCell *cell = static_cast<NSButtonCell *>(_view.cell);
        
        // Avoid NSIsEmptyRect
        reinterpret_cast<void (*)(id, SEL, struct CGRect, id)>(objc_msgSend)(cell, sel_registerName("_updateImageViewWithFrame:inView:"), CGRectMake(0.f, 0.f, 1.f, 1.f), _view);

        id buttonImageView = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(cell, sel_registerName("_buttonImageView"));
        
        reinterpret_cast<void (*)(id, SEL, id, id, BOOL)>(objc_msgSend)(buttonImageView, @selector(addSymbolEffect:options:animated:), [[NSSymbolBounceEffect bounceUpEffect] effectWithByLayer], [NSSymbolEffectOptions optionsWithRepeating], YES);
        
        return [swiftToolbarItem autorelease];
    } else if ([itemIdentifier isEqualToString:ns_MainWindow::reloadToolbarItemIdentifier]) {
        NSToolbarItem *reloadToolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        [self updateReloadToolbarItem:reloadToolbarItem isLoading:NO];
        
        return [reloadToolbarItem autorelease];
    } else if ([itemIdentifier isEqualToString:ns_MainWindow::downloadingToolchainsItemIdentifier]) {
        NSToolbarItem *downloadingToolchainsToolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        downloadingToolchainsToolbarItem.image = [NSImage imageWithSystemSymbolName:@"arrow.down.circle" accessibilityDescription:nil];
        downloadingToolchainsToolbarItem.target = self;
        downloadingToolchainsToolbarItem.action = @selector(downloadingToolchainsToolbarItemDidTrigger:);
        
        return [downloadingToolchainsToolbarItem autorelease];
    } else if ([itemIdentifier isEqualToString:ns_MainWindow::searchToolbarItemIdentifier]) {
        NSSearchToolbarItem *searchToolbarItem = [[NSSearchToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        searchToolbarItem.target = self;
        searchToolbarItem.action = @selector(searchFieldDidTrigger:);
        
        return [searchToolbarItem autorelease];
    } else {
        return nil;
    }
}

- (void)swiftToolbarItemDidTrigger:(NSToolbarItem *)sender {
    NSURLComponents *components = [NSURLComponents new];
    components.scheme = @"https";
    components.host = @"www.swift.org";
    components.path = @"/download/";
    
    if (auto url = components.URL) {
        [NSWorkspace.sharedWorkspace openURL:url];
    }
    
    [components release];
}

- (void)reloadToolbarItemDidTrigger:(NSToolbarItem *)sender {
    if (self.reloadProgress != nil) return;
    
    [self updateReloadToolbarItem:sender isLoading:YES];
    
    __weak decltype(self) weakSelf = self;
    
    const void *reloadProgressPtr = SwainCore::ToolchainDataManager::getSharedInstance().reloadToolchains(^(NSError * _Nullable error) {
        assert(!error);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            auto self = weakSelf;
            self.reloadProgress = nil;
            [self updateReloadToolbarItem:sender isLoading:NO];
        });
    });
    
    self.reloadProgress = reinterpret_cast<NSProgress *>(reloadProgressPtr);
}

- (void)searchFieldDidTrigger:(NSSearchField *)sender {
    if (auto currentToolchainsViewController = self.currentToolchainsViewController) {
        currentToolchainsViewController.searchText = sender.stringValue;
    }
}

- (void)downloadingToolchainsToolbarItemDidTrigger:(NSToolbarItem *)sender {
    DownloadingToolchainsViewController *contentViewController = [DownloadingToolchainsViewController new];
    NSPopover *popover = [NSPopover new];
    
    popover.contentViewController = contentViewController;
    [contentViewController release];
    
    popover.behavior = NSPopoverBehaviorTransient;
    popover.contentSize = NSMakeSize(600.f, 400.f);
    
    [popover showRelativeToToolbarItem:sender];
    [popover release];
}

- (void)downloadingProgressesDidChange __attribute__((objc_direct)) {
    
}

- (NSString *)searchText {
    for (NSToolbarItem *toolbarItem in self.toolbar.visibleItems) {
        if ([toolbarItem isKindOfClass:NSSearchToolbarItem.class]) {
            auto searchToolbarItem = reinterpret_cast<NSSearchToolbarItem *>(toolbarItem);
            return searchToolbarItem.searchField.stringValue;
        }
    }
    
    return nil;
}

- (void)updateReloadToolbarItem:(NSToolbarItem *)reloadToolbarItem isLoading:(BOOL)isLoading __attribute__((objc_direct)) {
    if (isLoading) {
        NSProgressIndicator *indicator = [NSProgressIndicator new];
        indicator.usesThreadedAnimation = YES;
        indicator.style = NSProgressIndicatorStyleSpinning;
        indicator.indeterminate = YES;
        [indicator startAnimation:nil];
        reloadToolbarItem.view = indicator;
        [indicator release];
    } else {
        reloadToolbarItem.view = nil;
        reloadToolbarItem.target = self;
        reloadToolbarItem.action = @selector(reloadToolbarItemDidTrigger:);
        reloadToolbarItem.label = @"Reload";
        reloadToolbarItem.image = [NSImage imageWithSystemSymbolName:@"arrow.clockwise" accessibilityDescription:nil];
    }
}

@end
