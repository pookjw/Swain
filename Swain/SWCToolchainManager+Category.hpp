//
//  SWCToolchainManager+Category.hpp
//  Swain
//
//  Created by Jinwoo Kim on 1/18/24.
//

@import SwainCore;

NS_ASSUME_NONNULL_BEGIN

@interface SWCToolchainManager (Category)
- (NSProgress *)reloadToolchainsWithCompletion:(void (^)(NSError * _Nullable error))completion;
@end

NS_ASSUME_NONNULL_END
