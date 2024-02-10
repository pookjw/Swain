//
//  HelperManager.hpp
//  Swain
//
//  Created by Jinwoo Kim on 2/4/24.
//

#if !SANDBOXED
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

namespace ns_HelperManager {
    extern NSNotificationName const isInstalledDidChangeNotification;
    extern NSString * const isInstalledKey;
}

__attribute__((objc_direct_members))
@interface HelperManager : NSObject
@property (assign, readonly, nonatomic) BOOL isInstalled;
+ (instancetype)sharedInstance;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (void)installHelperWithCompletionHandler:(void (^)(NSError * _Nullable error))completionHandler;
- (void)uninstallHelperWithCompletionHandler:(void (^)(NSError * _Nullable error))completionHandler;
- (void)installPackageWithURL:(NSURL *)packageURL completionHandler:(void (^)(NSError * _Nullable error))completionHandler;
@end

NS_ASSUME_NONNULL_END
#endif
