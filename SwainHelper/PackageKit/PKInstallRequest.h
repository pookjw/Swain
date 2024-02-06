//
//  PKInstallRequest.h
//  SwainHelper
//
//  Created by Jinwoo Kim on 2/6/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PKPackageSpecifier;

@interface PKInstallRequest : NSObject
+ (instancetype)requestWithPackages:(NSArray<PKPackageSpecifier *> *)packages destination:(NSString *)destination;
@end

NS_ASSUME_NONNULL_END
