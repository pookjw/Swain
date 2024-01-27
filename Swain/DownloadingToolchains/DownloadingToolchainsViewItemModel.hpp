//
//  DownloadingToolchainsViewItemModel.hpp
//  Swain
//
//  Created by Jinwoo Kim on 1/27/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_direct_members))
@interface DownloadingToolchainsViewItemModel : NSObject
@property (copy, nonatomic, readonly) NSString *name;
@property (retain, nonatomic, readonly) NSProgress *progress;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithName:(NSString *)name progress:(NSProgress *)progress NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
