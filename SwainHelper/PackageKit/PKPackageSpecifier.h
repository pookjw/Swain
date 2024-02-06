//
//  PKPackageSpecifier.h
//  SwainHelper
//
//  Created by Jinwoo Kim on 2/6/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PKPackageSpecifier : NSObject
- (instancetype)initWithPackageReference:(id /* PKPackageReference * */)packageReference;
@end

NS_ASSUME_NONNULL_END
