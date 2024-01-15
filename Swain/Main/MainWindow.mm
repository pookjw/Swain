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

__attribute__((objc_direct_members))
@interface MainWindow () {
    NSSplitViewController *_splitViewController;
    NSSplitViewItem *_contentListSplitViewItem;
    NSSplitViewItem *_sidebarSplitViewItem;
    MainSidebarViewController *_mainSidebarViewController;
    ToolchainsViewController *_toolchainsViewController;
}
@property (retain, nonatomic, readonly) NSSplitViewController *splitViewController;
@property (retain, nonatomic, readonly) NSSplitViewItem *sidebarSplitViewItem;
@property (retain, nonatomic, readonly) NSSplitViewItem *contentListSplitViewItem;
@property (retain, nonatomic, readonly) ToolchainsViewController *toolchainsViewController;
@property (retain, nonatomic, readonly) MainSidebarViewController *mainSidebarViewController;
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
    [_toolchainsViewController release];
    [super dealloc];
}

- (void)commonInit_MainWindow __attribute__((objc_direct)) {
    self.movableByWindowBackground = YES;
    
    NSSplitViewController *splitViewController = self.splitViewController;
    self.contentViewController = splitViewController;
    
    [splitViewController addSplitViewItem:self.sidebarSplitViewItem];
    [splitViewController addSplitViewItem:self.contentListSplitViewItem];
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
    reinterpret_cast<void (*)(id, SEL, CGFloat)>(objc_msgSend)(sidebarSplitViewItem, sel_registerName("setMinimumSize:"), 400.f);
    reinterpret_cast<void (*)(id, SEL, CGFloat)>(objc_msgSend)(sidebarSplitViewItem, sel_registerName("setMaximumSize:"), 400.f);
    
    _sidebarSplitViewItem = [sidebarSplitViewItem retain];
    return sidebarSplitViewItem;
}

- (NSSplitViewItem *)contentListSplitViewItem {
    if (auto contentListSplitViewItem = _contentListSplitViewItem) return contentListSplitViewItem;
    
    NSSplitViewItem *contentListSplitViewItem = [NSSplitViewItem contentListWithViewController:self.toolchainsViewController];
    contentListSplitViewItem.canCollapse = NO;
    
    _contentListSplitViewItem = [contentListSplitViewItem retain];
    return contentListSplitViewItem;
}

- (MainSidebarViewController *)mainSidebarViewController {
    if (auto mainSidebarViewController = _mainSidebarViewController) return mainSidebarViewController;
    
    MainSidebarViewController *mainSidebarViewController = [MainSidebarViewController new];
    
    _mainSidebarViewController = [mainSidebarViewController retain];
    return [mainSidebarViewController autorelease];
}

- (ToolchainsViewController *)toolchainsViewController {
    if (auto toolchainsViewController = _toolchainsViewController) return toolchainsViewController;
    
    ToolchainsViewController *toolchainsViewController = [ToolchainsViewController new];
    
    _toolchainsViewController = [toolchainsViewController retain];
    return [toolchainsViewController autorelease];
}

@end
