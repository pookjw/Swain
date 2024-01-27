//
//  DownloadingToolchainsViewModel.hpp
//  Swain
//
//  Created by Jinwoo Kim on 1/27/24.
//

#import <Cocoa/Cocoa.h>
#import "DownloadingToolchainsViewItemModel.hpp"

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_direct_members))
@interface DownloadingToolchainsViewModel : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDataSource:(NSCollectionViewDiffableDataSource<NSNumber *, DownloadingToolchainsViewItemModel *> *)dataSource NS_DESIGNATED_INITIALIZER;
- (void)loadDataSourceCompletionHandler:(void (^)(void))completionHandler;
@end

NS_ASSUME_NONNULL_END
