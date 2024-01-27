//
//  DownloadingToolchainsViewModel.mm
//  Swain
//
//  Created by Jinwoo Kim on 1/27/24.
//

#import "DownloadingToolchainsViewModel.hpp"
#import "getStringFromSwiftString.hpp"
@import SwainCore;

__attribute__((objc_direct_members))
@interface DownloadingToolchainsViewModel () {
    NSCollectionViewDiffableDataSource<NSNumber *, DownloadingToolchainsViewItemModel *> *_dataSource;
    dispatch_queue_t _queue;
}
@property (retain, nonatomic, readonly) NSCollectionViewDiffableDataSource<NSNumber *, DownloadingToolchainsViewItemModel *> *dataSource;
@property (retain, nonatomic, readonly) dispatch_queue_t queue;
@property (assign, atomic) BOOL isLoading;
- (void)downloadingProgressesDidChange;
@end

namespace ns_DownloadingToolchainsViewModel {
    void downloadingProgressesDidChangeCallback(CFNotificationCenterRef center,
                                                void *observer,
                                                CFNotificationName name,
                                                const void *object,
                                                CFDictionaryRef userInfo)
    {
        auto viewModel = reinterpret_cast<DownloadingToolchainsViewModel *>(observer);
        [viewModel downloadingProgressesDidChange];
    }
}

@implementation DownloadingToolchainsViewModel

- (instancetype)initWithDataSource:(NSCollectionViewDiffableDataSource<NSNumber *,DownloadingToolchainsViewItemModel *> *)dataSource {
    if (self = [super init]) {
        _dataSource = [dataSource retain];
        [self observeDownloadingProgressesDidChange];
    }
    
    return self;
}

- (void)dealloc {
    [self removeDownloadingProgressesDidChangeObserver];
    
    [_dataSource release];
    
    if (_queue) {
        dispatch_release(_queue);
    }
    
    [super dealloc];
}

- (void)loadDataSourceCompletionHandler:(void (^)(void))completionHandler {
    auto dataSource = _dataSource;
    
    dispatch_async(self.queue, ^{
        if (self.isLoading) {
            completionHandler();
            return;
        }
        
        self.isLoading = YES;
        
        SwainCore::ToolchainPackageManager::getSharedInstance().getDownloadingProgresses(^(NSArray<NSProgress *> *progresses) {
            dispatch_async(self.queue, ^{
                auto snapshot = [NSDiffableDataSourceSnapshot<NSNumber *, DownloadingToolchainsViewItemModel *> new];
                
                NSNumber *firstSection = @0;
                [snapshot appendSectionsWithIdentifiers:@[firstSection]];
                
                NSString *toolchainNameProgressUserInfoKey = SwainCore::ToolchainPackageManager::getToolchainNameProgressUserInfoKey();
                
                auto itemModels = [NSMutableArray<DownloadingToolchainsViewItemModel *> new];
                
                [progresses enumerateObjectsUsingBlock:^(NSProgress * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *toolchainName = obj.userInfo[toolchainNameProgressUserInfoKey];
                    if (toolchainName == nil) return;
                    
                    DownloadingToolchainsViewItemModel *itemModel = [[DownloadingToolchainsViewItemModel alloc] initWithName:toolchainName progress:obj];
                    
                    [itemModels addObject:itemModel];
                    [itemModel release];
                }];
                
                [snapshot appendItemsWithIdentifiers:itemModels intoSectionWithIdentifier:firstSection];
                [itemModels release];
                
                [dataSource applySnapshot:snapshot animatingDifferences:YES];
                completionHandler();
                self.isLoading = NO;
            });
        });
    });
}

- (dispatch_queue_t)queue {
    if (auto queue = _queue) return queue;
        
    dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, QOS_MIN_RELATIVE_PRIORITY);
    dispatch_queue_t queue = dispatch_queue_create("DownloadingToolchainsViewModel", attr);
    _queue = queue;
    
    return queue;
}

- (void)observeDownloadingProgressesDidChange __attribute__((objc_direct)) {
    void *object = swift::_impl::_impl_RefCountedClass::getOpaquePointer(SwainCore::ToolchainPackageManager::getSharedInstance());
    CFStringRef cfString = getCFStringFromSwiftString(SwainCore::ToolchainPackageManager::getDidChangeDownloadingProgressesNotificationName());
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(),
                                    self,
                                    ns_DownloadingToolchainsViewModel::downloadingProgressesDidChangeCallback,
                                    cfString,
                                    object,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
}

- (void)removeDownloadingProgressesDidChangeObserver __attribute__((objc_direct)) {
    void *object = swift::_impl::_impl_RefCountedClass::getOpaquePointer(SwainCore::ToolchainPackageManager::getSharedInstance());
    CFStringRef cfString = getCFStringFromSwiftString(SwainCore::ToolchainPackageManager::getDidChangeDownloadingProgressesNotificationName());
    
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetLocalCenter(),
                                       self,
                                       cfString,
                                       object);
}

- (void)downloadingProgressesDidChange __attribute__((objc_direct)) {
    [self loadDataSourceCompletionHandler:^{
        
    }];
}

@end
