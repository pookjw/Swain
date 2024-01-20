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
@interface ToolchainsViewModel () <NSFetchedResultsControllerDelegate>
@property (retain, nonatomic) NSCollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> *dataSource;
@property (retain, nonatomic) NSManagedObjectContext * _Nullable childManagedObjectContext;
@property (retain, nonatomic) NSFetchedResultsController<NSManagedObject *> *queue_fetchedResultsController;
@property (retain, nonatomic) dispatch_queue_t queue;
@property (assign, atomic) BOOL requestedLoading;
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
    [_childManagedObjectContext release];
    [_queue_fetchedResultsController release];
    
    if (_queue) {
        dispatch_release(_queue);
    }
    
    [super dealloc];
}

- (void)loadDataSourceWithToolchainCategory:(NSString *)toolchainCategory completionHandler:(void (^)(NSError * _Nullable error))completionHandler {
    dispatch_async(_queue, ^{
        if (self.queue_fetchedResultsController) {
            completionHandler(nil);
            return;
        }
        
        if (self.requestedLoading) {
            completionHandler(nil);
            return;
        }
        
        self.requestedLoading = YES;
        
        //
        
        [SWCToolchainManager.sharedInstance managedObjectContextWithCompletionHandler:^(NSManagedObjectContext * _Nullable managedObjectContext, NSError * _Nullable error) {
            if (error) {
                completionHandler(error);
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
                self.childManagedObjectContext = childManagedObjectContext;
                
                auto fetchRequest = [[NSFetchRequest<NSManagedObject *> alloc] initWithEntityName:@"Toolchain"];
                auto sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
                fetchRequest.sortDescriptors = @[sortDescriptor];
                [sortDescriptor release];
                
                fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K == %@" argumentArray:@[@"category", toolchainCategory]];
                
                auto fetchedResultsController = [[NSFetchedResultsController<NSManagedObject *> alloc] initWithFetchRequest:fetchRequest 
                                                                                                       managedObjectContext:childManagedObjectContext
                                                                                                         sectionNameKeyPath:nil
                                                                                                                  cacheName:nil];
                
                [fetchRequest release];
                
                fetchedResultsController.delegate = self;
                
                self.queue_fetchedResultsController = fetchedResultsController;
                NSError * _Nullable error = nil;
                [fetchedResultsController performFetch:&error];
                completionHandler(error);
                [fetchedResultsController release];
            });
            
            [childManagedObjectContext release];
        }];
    });
}

- (NSProgress *)reloadDataSourceWithCompletionHandler:(void (^)(NSError * _Nullable))completionHandler {
    return [SWCToolchainManager.sharedInstance reloadToolchainsWithCompletion:completionHandler];
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
        NSError * _Nullable error = nil;
        [self.queue_fetchedResultsController performFetch:&error];
        assert(!error);
    });
}

- (void)controller:(NSFetchedResultsController *)controller didChangeContentWithSnapshot:(NSDiffableDataSourceSnapshot<NSString *,NSManagedObjectID *> *)snapshot {
    [_dataSource applySnapshot:snapshot animatingDifferences:YES];
}

@end
