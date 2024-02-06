//
//  AppMenuItem.mm
//  Swain
//
//  Created by Jinwoo Kim on 2/6/24.
//

#import "AppMenuItem.hpp"
#import "SettingsWindow.hpp"

__attribute__((objc_direct_members))
@interface AppMenuItem () {
    NSMenuItem *_settingsMenuItem;
}
@property (retain, readonly, nonatomic) NSMenuItem *settingsMenuItem;
@end

@implementation AppMenuItem

- (instancetype)initWithTitle:(NSString *)string action:(SEL)selector keyEquivalent:(NSString *)charCode {
    if (self = [super initWithTitle:string action:selector keyEquivalent:charCode]) {
        [self commonInit_AppMenuItem];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self commonInit_AppMenuItem];
    }
    
    return self;
}

- (void)dealloc {
    [_settingsMenuItem release];
    [super dealloc];
}

- (void)commonInit_AppMenuItem __attribute__((objc_direct)) {
    NSMenu *submenu = [NSMenu new];
    
    [submenu addItem:self.settingsMenuItem];
    
    self.submenu = submenu;
    [submenu release];
}

- (NSMenuItem *)settingsMenuItem {
    if (auto settingsMenuItem = _settingsMenuItem) return settingsMenuItem;
    
    NSMenuItem *settingsMenuItem = [[NSMenuItem alloc] initWithTitle:@"Settings..." action:@selector(settingsMenuItemDidTrigger:) keyEquivalent:@","];
    settingsMenuItem.target = self;
    
    _settingsMenuItem = [settingsMenuItem retain];
    return [settingsMenuItem autorelease];
}

- (void)settingsMenuItemDidTrigger:(NSMenuItem *)sender {
    SettingsWindow *settingsWindow = [SettingsWindow new];
    settingsWindow.releasedWhenClosed = NO;
    [settingsWindow makeKeyAndOrderFront:self];
    [settingsWindow release];
}

@end
