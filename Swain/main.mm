//
//  main.m
//  Swain
//
//  Created by Jinwoo Kim on 1/15/24.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.hpp"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        AppDelegate *delegate = [AppDelegate new];
        NSApplication *application = NSApplication.sharedApplication;
        
        application.delegate = delegate;
        [application run];
        
        [delegate release];
    }
    
    return EXIT_SUCCESS;
}
