//
//  DownloadingToolchainsViewItemModel.hpp
//  Swain
//
//  Created by Jinwoo Kim on 1/27/24.
//

#import <Foundation/Foundation.h>
@import SwainCore;

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_direct_members))
@interface DownloadingToolchainsViewItemModel : NSObject
@property (retain, nonatomic, readonly) SWCToolchainPackage *toolchainPackage;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWitToolchainPackage:(SWCToolchainPackage *)toolchainPackage NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
