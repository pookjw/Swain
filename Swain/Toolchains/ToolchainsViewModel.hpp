//
//  ToolchainsViewModel.hpp
//  Swain
//
//  Created by Jinwoo Kim on 1/18/24.
//

#import <AppKit/AppKit.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_direct_members))
@interface ToolchainsViewModel : NSObject
@property (retain, nonatomic, readonly) NSManagedObjectContext * _Nullable childManagedObjectContext;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDataSource:(NSCollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> *)dataSource;
- (void)loadDataSourceWithToolchainCategory:(NSString *)toolchainCategory completionHandler:(void (^)(NSError * _Nullable error))completionHandler;
@end

NS_ASSUME_NONNULL_END
