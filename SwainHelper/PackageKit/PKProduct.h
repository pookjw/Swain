//
//  PKProduct.h
//  SwainHelper
//
//  Created by Jinwoo Kim on 2/6/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PKProduct : NSObject
@property (readonly) NSArray/* <PKPackageReference *> */ *allPackageReferences;
+ (instancetype _Nullable)productByLoadingProductAtURL:(NSURL *)url error:(NSError * __autoreleasing * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
