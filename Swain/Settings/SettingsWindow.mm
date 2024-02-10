//
//  SettingsWindow.mm
//  Swain
//
//  Created by Jinwoo Kim on 2/7/24.
//

#import "SettingsWindow.hpp"
#import "SettingsGeneralViewController.hpp"
#import "SettingsHelperViewController.hpp"

__attribute__((objc_direct_members))
@interface SettingsWindow () {
    NSTabViewController *_tabViewController;
    SettingsGeneralViewController *_generalViewController;
    SettingsHelperViewController *_helperViewController;
    NSTabViewItem *_generalTabViewItem;
    NSTabViewItem *_helperTabViewItem;
}
@property (retain, nonatomic, readonly) NSTabViewController *tabViewController;
@property (retain, nonatomic, readonly) SettingsGeneralViewController *generalViewController;
@property (retain, nonatomic, readonly) SettingsHelperViewController *helperViewController;
@property (retain, nonatomic, readonly) NSTabViewItem *generalTabViewItem;
@property (retain, nonatomic, readonly) NSTabViewItem *helperTabViewItem;
@end

@implementation SettingsWindow

- (instancetype)init {
    self = [self initWithContentRect:NSMakeRect(0.f, 0.f, 400.f, 300.f)
                            styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable | NSWindowStyleMaskTitled | NSWindowStyleMaskFullSizeContentView
                              backing:NSBackingStoreBuffered
                                defer:YES];
    
    return self;
}

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag {
    if (self = [super initWithContentRect:contentRect styleMask:style backing:backingStoreType defer:flag]) {
        [self commonInit_SettingsWindow];
    }
    
    return self;
}

- (void)dealloc {
    [_tabViewController release];
    [_generalViewController release];
    [_helperViewController release];
    [_generalTabViewItem release];
    [_helperTabViewItem release];
    [super dealloc];
}

- (void)commonInit_SettingsWindow __attribute__((objc_direct)) {
    self.title = @"Settings";
    self.movableByWindowBackground = YES;
    self.contentMinSize = CGSizeMake(400.f, 300.f);
    
    NSTabViewController *tabViewController = self.tabViewController;
    [tabViewController addTabViewItem:self.generalTabViewItem];
    [tabViewController addTabViewItem:self.helperTabViewItem];
    
    self.contentViewController = tabViewController;
}

- (NSTabViewController *)tabViewController {
    if (auto tabViewController = _tabViewController) return tabViewController;
    
    NSTabViewController *tabViewController = [NSTabViewController new];
    tabViewController.tabStyle = NSTabViewControllerTabStyleToolbar;
    
    _tabViewController = [tabViewController retain];
    return [tabViewController autorelease];
}

- (SettingsGeneralViewController *)generalViewController {
    if (auto generalViewController = _generalViewController) return generalViewController;
    
    SettingsGeneralViewController *generalViewController = [SettingsGeneralViewController new];
    
    _generalViewController = [generalViewController retain];
    return [generalViewController autorelease];
}

- (SettingsHelperViewController *)helperViewController {
    if (auto helperViewController = _helperViewController) return helperViewController;
    
    SettingsHelperViewController *helperViewController = [SettingsHelperViewController new];
    
    _helperViewController = [helperViewController retain];
    return [helperViewController autorelease];
}

- (NSTabViewItem *)generalTabViewItem {
    if (auto generalTabViewItem = _generalTabViewItem) return generalTabViewItem;
    
    NSTabViewItem *generalTabViewItem = [NSTabViewItem tabViewItemWithViewController:self.generalViewController];
    generalTabViewItem.label = @"General";
    generalTabViewItem.image = [NSImage imageWithSystemSymbolName:@"gearshape" accessibilityDescription:nil];
    
    _generalTabViewItem = [generalTabViewItem retain];
    return generalTabViewItem;
}

- (NSTabViewItem *)helperTabViewItem {
    if (auto helperTabViewItem = _helperTabViewItem) return helperTabViewItem;
    
    NSTabViewItem *helperTabViewItem = [NSTabViewItem tabViewItemWithViewController:self.helperViewController];
    helperTabViewItem.label = @"Helper";
    helperTabViewItem.image = [NSImage imageWithSystemSymbolName:@"fireworks" accessibilityDescription:nil];
    
    _helperTabViewItem = [helperTabViewItem retain];
    return helperTabViewItem;
}

@end
