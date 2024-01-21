//
//  MainSidebarViewController.hpp
//  Swain
//
//  Created by Jinwoo Kim on 1/15/24.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class MainSidebarViewController;
@protocol MainSidebarViewControllerDelegate <NSObject>
- (void)mainSidebarViewController:(MainSidebarViewController *)mainSidebarViewController didSelectToolchainCategory:(NSString *)toolchainCategory;;
@end

__attribute__((objc_direct_members))
@interface MainSidebarViewController : NSViewController
@property (weak) id<MainSidebarViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
