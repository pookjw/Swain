//
//  PKInstallClient.h
//  SwainHelper
//
//  Created by Jinwoo Kim on 2/6/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PKInstallRequest;

@interface PKInstallClient : NSObject
- (instancetype _Nullable)initWithRequest:(PKInstallRequest *)request inUserContext:(BOOL)inUserContext holdingBoostDuringInstall:(BOOL)holdingBoostDuringInstall delegate:(id _Nullable)delegate error:(NSError * __autoreleasing * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
