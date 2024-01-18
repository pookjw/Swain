//
//  ToolchainsViewModel.mm
//  Swain
//
//  Created by Jinwoo Kim on 1/18/24.
//

#import "ToolchainsViewModel.hpp"
#import "SWCToolchainManager+Category.hpp"
@import SwainCore;

__attribute__((objc_direct_members))
@interface ToolchainsViewModel () {
    NSFetchedResultsController<NSManagedObject *> *_queue_fetchedResultsController;
}
@property (retain, nonatomic) NSCollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> *dataSource;
@property (retain, nonatomic) NSManagedObjectContext *queue_childManagedObjectContext;
@property (retain, nonatomic, readonly) NSFetchedResultsController<NSManagedObject *> *queue_fetchedResultsController;
@property (retain, nonatomic) dispatch_queue_t queue;
@end

@implementation ToolchainsViewModel

- (instancetype)initWithDataSource:(NSCollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> *)dataSource {
    if (self = [super init]) {
        _dataSource = [dataSource retain];
        
        dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, QOS_MIN_RELATIVE_PRIORITY);
        dispatch_queue_t queue = dispatch_queue_create("ToolchainsViewModel", attr);
        _queue = queue;
    }
    
    return self;
}

- (void)dealloc {
    [_dataSource release];
    [_queue_childManagedObjectContext release];
    [_queue_fetchedResultsController release];
    
    if (_queue) {
        dispatch_release(_queue);
    }
    
    [super dealloc];
}

- (void)loadDataSourceWithCompletionHandler:(void (^)(NSError * _Nullable))completionHandler {
    [SWCToolchainManager.sharedInstance managedObjectContextWithCompletionHandler:^(NSManagedObjectContext * _Nullable managedObjectContext, NSError * _Nullable error) {
        if (error) {
            completionHandler(error);
            return;
        }
        
        
    }];
}

//- (NSFetchedResultsController<NSManagedObject *> *)queue_fetchedResultsController {
//    if (auto fetchedResultsController = _queue_fetchedResultsController) return fetchedResultsController;
//    
////    NSFetchRequest
////    
////    auto fetchedResultsController = [[NSFetchedResultsController<NSManagedObject *> alloc] initWithFetchRequest:<#(nonnull NSFetchRequest<NSManagedObject *> *)#> managedObjectContext:<#(nonnull NSManagedObjectContext *)#> sectionNameKeyPath:<#(nullable NSString *)#> cacheName:<#(nullable NSString *)#>]
//}

@end
