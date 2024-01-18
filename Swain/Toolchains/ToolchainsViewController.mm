//
//  ToolchainsViewController.mm
//  Swain
//
//  Created by Jinwoo Kim on 1/15/24.
//

#import "ToolchainsViewController.hpp"
#import "ToolchainsViewModel.hpp"

__attribute__((objc_direct_members))
@interface ToolchainsViewController () {
    NSScrollView *_scrollView;
    NSCollectionView *_collectionView;
    ToolchainsViewModel *_viewModel;
}
@property (retain, nonatomic, readonly) NSScrollView *scrollView;
@property (retain, nonatomic, readonly) NSCollectionView *collectionView;
@property (retain, nonatomic, readonly) ToolchainsViewModel *viewModel;
@end

@implementation ToolchainsViewController

- (void)dealloc {
    [_scrollView release];
    [_collectionView release];
    [_viewModel release];
    [super dealloc];
}

- (void)loadView {
    self.view = self.scrollView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.viewModel loadDataSourceWithCompletionHandler:^(NSError * _Nullable error) {
        assert(!error);
    }];
}

- (NSScrollView *)scrollView {
    if (auto scrollView = _scrollView) return scrollView;
    
    NSScrollView *scrollView = [NSScrollView new];
    scrollView.documentView = self.collectionView;
    
    _scrollView = [scrollView retain];
    return [scrollView autorelease];
}

- (NSCollectionView *)collectionView {
    if (auto collectionView = _collectionView) return collectionView;
    
    NSCollectionViewCompositionalLayoutConfiguration *configuration = [NSCollectionViewCompositionalLayoutConfiguration new];
    configuration.scrollDirection = NSCollectionViewScrollDirectionVertical;
    
    NSCollectionViewCompositionalLayout *collectionViewLayout = [[NSCollectionViewCompositionalLayout alloc] initWithSectionProvider:^NSCollectionLayoutSection * _Nullable(NSInteger section, id<NSCollectionLayoutEnvironment> _Nonnull) {
        return nil;
    } 
                                                                                                                       configuration:configuration];
    
    [configuration release];
    
    NSCollectionView *collectionView = [NSCollectionView new];
    collectionView.collectionViewLayout = collectionViewLayout;
    [collectionViewLayout release];
    
    _collectionView = [collectionView retain];
    return [collectionView autorelease];
}

- (ToolchainsViewModel *)viewModel {
    if (auto viewModel = _viewModel) return viewModel;
    
    ToolchainsViewModel *viewModel = [[ToolchainsViewModel alloc] initWithDataSource:[self makeDataSource]];
    
    _viewModel = [viewModel retain];
    return [viewModel autorelease];
}

- (NSCollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> *)makeDataSource __attribute__((objc_direct)) {
    auto dataSource = [[NSCollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> alloc] initWithCollectionView:self.collectionView itemProvider:^NSCollectionViewItem * _Nullable(NSCollectionView * _Nonnull, NSIndexPath * _Nonnull, NSManagedObjectID * _Nonnull) {
        return nil;
    }];
    
    return [dataSource autorelease];
}

@end
