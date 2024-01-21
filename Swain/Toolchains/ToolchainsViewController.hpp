//
//  ToolchainsViewController.hpp
//  Swain
//
//  Created by Jinwoo Kim on 1/15/24.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_direct_members))
@interface ToolchainsViewController : NSViewController
@property (copy, nonatomic) NSString * _Nullable searchText;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSNibName)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithToolchainCategory:(NSString *)toolchainCategory searchText:(NSString * _Nullable)searchText;
@end

NS_ASSUME_NONNULL_END
