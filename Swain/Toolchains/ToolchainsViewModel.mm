//
//  ToolchainsViewModel.mm
//  Swain
//
//  Created by Jinwoo Kim on 1/18/24.
//

#import "ToolchainsViewModel.hpp"
@import SwainCore;

__attribute__((objc_direct_members))
@interface ToolchainsViewModel () <NSFetchedResultsControllerDelegate> {
    dispatch_queue_t _queue;
}
@property (retain, nonatomic) NSCollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> *dataSource;
@property (retain, nonatomic) NSManagedObjectContext * _Nullable childManagedObjectContext;
@property (retain, nonatomic) NSFetchedResultsController<NSManagedObject *> *fetchedResultsController;
@property (retain, nonatomic, readonly) dispatch_queue_t queue;
@property (assign, atomic) BOOL isLoading;
@end

@implementation ToolchainsViewModel

- (instancetype)initWithDataSource:(NSCollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> *)dataSource {
    if (self = [super init]) {
        _dataSource = [dataSource retain];
        
        
    }
    
    return self;
}

- (void)dealloc {
    [_dataSource release];
    [_childManagedObjectContext release];
    [_fetchedResultsController release];
    
    if (_queue) {
        dispatch_release(_queue);
    }
    
    [super dealloc];
}

- (void)loadDataSourceWithToolchainCategory:(NSString *)toolchainCategory searchText:(NSString * _Nullable)searchText completionHandler:(void (^)(NSError * _Nullable error))completionHandler {
    dispatch_async(self.queue, ^{
        if (self.isLoading) {
            completionHandler(nil);
            return;
        }
        
        self.isLoading = YES;
        
        //
        
        if (auto childManagedObjectContext = self.childManagedObjectContext) {
            auto fetchedResultsController = [self makeFetchedResultsControllerWithManagedObjectContext:childManagedObjectContext toolchainCategory:toolchainCategory searchText:searchText];
            self.fetchedResultsController = fetchedResultsController;
            
            NSError * _Nullable error = nil;
            [fetchedResultsController performFetch:&error];
            completionHandler(error);
            
            self.isLoading = NO;
        } else {
            SwainCore::ToolchainDataManager::getSharedInstance().managedObjectContext(^(NSManagedObjectContext * _Nullable managedObjectContext, NSError * _Nullable error) {
                if (error) {
                    completionHandler(error);
                    self.isLoading = NO;
                    return;
                }
                
                auto childManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
                childManagedObjectContext.automaticallyMergesChangesFromParent = YES;
                childManagedObjectContext.mergePolicy = [NSMergePolicy mergeByPropertyStoreTrumpMergePolicy];
                childManagedObjectContext.parentContext = managedObjectContext;
                
                [NSNotificationCenter.defaultCenter addObserver:self
                                                       selector:@selector(contextDidMerge:)
                                                           name:NSManagedObjectContextDidMergeChangesObjectIDsNotification
                                                         object:childManagedObjectContext];
                
                dispatch_async(self->_queue, ^{
                    self.childManagedObjectContext = [childManagedObjectContext retain];
                    
                    auto fetchedResultsController = [self makeFetchedResultsControllerWithManagedObjectContext:childManagedObjectContext toolchainCategory:toolchainCategory searchText:searchText];
                    self.fetchedResultsController = fetchedResultsController;
                    
                    [childManagedObjectContext performBlock:^{
                        NSError * _Nullable error = nil;
                        [fetchedResultsController performFetch:&error];
                        completionHandler(error);
                        
                        self.isLoading = NO;
                    }];
                });
            });
        }
    });
}

- (dispatch_queue_t)queue {
    if (auto queue = _queue) return queue;
        
    dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, QOS_MIN_RELATIVE_PRIORITY);
    dispatch_queue_t queue = dispatch_queue_create("ToolchainsViewModel", attr);
    _queue = queue;
    
    return queue;
}

- (NSFetchedResultsController<NSManagedObject *> *)makeFetchedResultsControllerWithManagedObjectContext:(NSManagedObjectContext * _Nonnull)managedObjectContext
                                                                                      toolchainCategory:(NSString * _Nonnull)toolchainCategory
                                                                                             searchText:(NSString * _Nullable)searchText __attribute__((objc_direct))
{
    auto fetchRequest = [[NSFetchRequest<NSManagedObject *> alloc] initWithEntityName:@"Toolchain"];
    auto sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    [sortDescriptor release];
    
    auto subpredicates = [NSMutableArray<NSPredicate *> new];
    
    NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:@"%K == %@" argumentArray:@[@"category", toolchainCategory]];
    [subpredicates addObject:categoryPredicate];
    
    if (searchText.length > 0) {
        NSPredicate *namePrericate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@" argumentArray:@[@"name", searchText]];
        [subpredicates addObject:namePrericate];
    }
    
    fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
    [subpredicates release];
    
    auto fetchedResultsController = [[NSFetchedResultsController<NSManagedObject *> alloc] initWithFetchRequest:fetchRequest 
                                                                                           managedObjectContext:managedObjectContext
                                                                                             sectionNameKeyPath:nil
                                                                                                      cacheName:nil];
    
    [fetchRequest release];
    
    fetchedResultsController.delegate = self;
    
    return [fetchedResultsController autorelease];
}

- (void)contextDidMerge:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    auto insertedObjectIDs = reinterpret_cast<NSSet *>(userInfo[NSInsertedObjectIDsKey]);
    auto updatedObjectIDs = reinterpret_cast<NSSet *>(userInfo[NSUpdatedObjectIDsKey]);
    auto deletedObjectIDs = reinterpret_cast<NSSet *>(userInfo[NSDeletedObjectIDsKey]);
    
    if ((insertedObjectIDs.count == 0) && (updatedObjectIDs.count == 0) && (deletedObjectIDs.count == 0)) {
        return;
    }
    
    dispatch_async(_queue, ^{
        [self.childManagedObjectContext performBlock:^{
            NSError * _Nullable error = nil;
            [self.fetchedResultsController performFetch:&error];
            assert(!error);
        }];
    });
}

- (void)controller:(NSFetchedResultsController *)controller didChangeContentWithSnapshot:(NSDiffableDataSourceSnapshot<NSString *,NSManagedObjectID *> *)snapshot {
    [_dataSource applySnapshot:snapshot animatingDifferences:YES];
}

@end
