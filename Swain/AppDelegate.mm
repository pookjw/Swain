//
//  AppDelegate.mm
//  Swain
//
//  Created by Jinwoo Kim on 1/15/24.
//

#import "AppDelegate.hpp"
#import "MainWindow.hpp"
#import "HelperManager.hpp"

__attribute__((objc_direct_members))
@interface AppDelegate ()
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    MainWindow *window = [MainWindow new];
    window.releasedWhenClosed = NO;
    [window makeKeyAndOrderFront:self];
    [window release];
    
#if !SANDBOXED
    [HelperManager.sharedInstance uninstallHelperWithCompletionHandler:^(NSError * _Nullable error) {
        NSLog(@"%@", error);
        [HelperManager.sharedInstance installHelperWithCompletionHandler:^(NSError * _Nullable error) {
            NSLog(@"%@", error);
        }];
    }];
#endif
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


@end
