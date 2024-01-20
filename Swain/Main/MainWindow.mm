//
//  MainWindow.mm
//  Swain
//
//  Created by Jinwoo Kim on 1/15/24.
//

#import "MainWindow.hpp"
#import "MainSidebarViewController.hpp"
#import "ToolchainsViewController.hpp"
#import <objc/message.h>
@import SwainCore;

namespace ns_MainWindow {
    const NSToolbarIdentifier toolbarIdentifier = @"MainWindowToolbarIdentifier";
}

__attribute__((objc_direct_members))
@interface MainWindow () <MainSidebarViewControllerDelegate> {
    NSSplitViewController *_splitViewController;
    NSSplitViewItem *_sidebarSplitViewItem;
    MainSidebarViewController *_mainSidebarViewController;
    ToolchainsViewController *_stableToolchainsViewController;
    ToolchainsViewController *_releaseToolchainsViewController;
    ToolchainsViewController *_mainToolchainsViewController;
}
@property (retain, nonatomic, readonly) NSSplitViewController *splitViewController;
@property (retain, nonatomic, readonly) NSSplitViewItem *sidebarSplitViewItem;
@property (retain, nonatomic) NSSplitViewItem * _Nullable contentListSplitViewItem;
@property (retain, nonatomic, readonly) MainSidebarViewController *mainSidebarViewController;
@property (retain, nonatomic, readonly) ToolchainsViewController *mainToolchainsViewController;
@property (retain, nonatomic, readonly) ToolchainsViewController *stableToolchainsViewController;
@property (retain, nonatomic, readonly) ToolchainsViewController *releaseToolchainsViewController;
@end

@implementation MainWindow

- (instancetype)init {
    self = [self initWithContentRect:NSMakeRect(0.f, 0.f, 600.f, 400.f)
                            styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable
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
    [_splitViewController release];
    [_sidebarSplitViewItem release];
    [_contentListSplitViewItem release];
    [_mainSidebarViewController release];
    [_stableToolchainsViewController release];
    [_releaseToolchainsViewController release];
    [_mainToolchainsViewController release];
    [super dealloc];
}

- (void)commonInit_MainWindow __attribute__((objc_direct)) {
    self.title = @"Swain";
    self.movableByWindowBackground = YES;
    self.contentMinSize = CGSizeMake(600.f, 400.f);
    
    NSSplitViewController *splitViewController = self.splitViewController;
    self.contentViewController = splitViewController;
    
    [splitViewController addSplitViewItem:self.sidebarSplitViewItem];
    
    NSViewController *emptyViewController = [NSViewController new];
    [self replaceContentViewController:emptyViewController];
    [emptyViewController release];
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
    
    ToolchainsViewController *mainToolchainsViewController = [[ToolchainsViewController alloc] initWithToolchainCategory:SWCToolchainCategoryMainName()];
    
    _mainToolchainsViewController = [mainToolchainsViewController retain];
    return [mainToolchainsViewController autorelease];
}

- (ToolchainsViewController *)stableToolchainsViewController {
    if (auto stableToolchainsViewController = _stableToolchainsViewController) return stableToolchainsViewController;
    
    ToolchainsViewController *stableToolchainsViewController = [[ToolchainsViewController alloc] initWithToolchainCategory:SWCToolchainCategoryStableName()];
    
    _stableToolchainsViewController = [stableToolchainsViewController retain];
    return [stableToolchainsViewController autorelease];
}

- (ToolchainsViewController *)releaseToolchainsViewController {
    if (auto releaseToolchainsViewController = _releaseToolchainsViewController) return releaseToolchainsViewController;
    
    ToolchainsViewController *releaseToolchainsViewController = [[ToolchainsViewController alloc] initWithToolchainCategory:SWCToolchainCategoryReleaseName()];
    
    _releaseToolchainsViewController = [releaseToolchainsViewController retain];
    return [releaseToolchainsViewController autorelease];
}

- (void)mainSidebarViewController:(MainSidebarViewController *)mainSidebarViewController didSelectToolchainCategory:(NSString *)toolchainCategory {
    if ([toolchainCategory isEqualToString:SWCToolchainCategoryMainName()]) {
        [self replaceContentViewController:self.mainToolchainsViewController];
    } else if ([toolchainCategory isEqualToString:SWCToolchainCategoryStableName()]) {
        [self replaceContentViewController:self.stableToolchainsViewController];
    } else if ([toolchainCategory isEqualToString:SWCToolchainCategoryReleaseName()]) {
        [self replaceContentViewController:self.releaseToolchainsViewController];
    }
}

- (void)replaceContentViewController:(NSViewController *)contentViewController __attribute__((objc_direct)) {
    if (auto contentListSplitViewItem = self.contentListSplitViewItem) {
        [self.splitViewController removeSplitViewItem:contentListSplitViewItem];
        self.contentListSplitViewItem = nil;
    }
    
    NSSplitViewItem *contentListSplitViewItem = [NSSplitViewItem contentListWithViewController:contentViewController];
    [self.splitViewController addSplitViewItem:contentListSplitViewItem];
    self.contentListSplitViewItem = contentListSplitViewItem;
}

@end
