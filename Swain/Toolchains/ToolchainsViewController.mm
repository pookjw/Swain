//
//  ToolchainsViewController.mm
//  Swain
//
//  Created by Jinwoo Kim on 1/15/24.
//

#import "ToolchainsViewController.hpp"
#import "ToolchainsViewModel.hpp"
#import "ToolchainsCollectionViewItem.hpp"

__attribute__((objc_direct_members))
@interface ToolchainsViewController () <NSCollectionViewDelegate> {
    NSScrollView *_scrollView;
    NSCollectionView *_collectionView;
    ToolchainsViewModel *_viewModel;
}
@property (copy, nonatomic, readonly) NSString *toolchainCategory;
@property (retain, nonatomic, readonly) NSScrollView *scrollView;
@property (retain, nonatomic, readonly) NSCollectionView *collectionView;
@property (retain, nonatomic, readonly) ToolchainsViewModel *viewModel;
@end

@implementation ToolchainsViewController

- (instancetype)initWithToolchainCategory:(NSString *)toolchainCategory {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _toolchainCategory = [toolchainCategory copy];
    }
    
    return self;
}

- (void)dealloc {
    [_toolchainCategory release];
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
    
    [self.viewModel loadDataSourceWithToolchainCategory:_toolchainCategory completionHandler:^(NSError * _Nullable error) {
        assert(!error);
//        [self.viewModel reloadDataSourceWithCompletionHandler:^(NSError * _Nullable error) {
//            NSLog(@"Done!");
//            assert(!error);
//        }];
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
    
    NSCollectionViewCompositionalLayout *collectionViewLayout = [[NSCollectionViewCompositionalLayout alloc] initWithSectionProvider:^NSCollectionLayoutSection * _Nullable(NSInteger sectionIdx, id<NSCollectionLayoutEnvironment> _Nonnull) {
        auto itemSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.f]
                                                       heightDimension:[NSCollectionLayoutDimension estimatedDimension:44.f]];
        
        auto item = [NSCollectionLayoutItem itemWithLayoutSize:itemSize supplementaryItems:@[]];
        
        auto groupSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.f]
                                                        heightDimension:[NSCollectionLayoutDimension estimatedDimension:44.f]];
        
        auto group = [NSCollectionLayoutGroup verticalGroupWithLayoutSize:groupSize subitems:@[item]];
        
        auto section = [NSCollectionLayoutSection sectionWithGroup:group];
        
        return section;
    } 
                                                                                                                       configuration:configuration];
    
    [configuration release];
    
    NSCollectionView *collectionView = [NSCollectionView new];
    collectionView.collectionViewLayout = collectionViewLayout;
    collectionView.delegate = self;
    [collectionViewLayout release];
    
    [collectionView registerClass:ToolchainsCollectionViewItem.class forItemWithIdentifier:ToolchainsCollectionViewItem.identifier];
    
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
    __weak decltype(self) weakSelf = self;
    
    auto dataSource = [[NSCollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> alloc] initWithCollectionView:self.collectionView itemProvider:^NSCollectionViewItem * _Nullable(NSCollectionView * _Nonnull collectionView, NSIndexPath * _Nonnull indexPath, NSManagedObjectID * _Nonnull managedObjectID) {
        auto item = reinterpret_cast<ToolchainsCollectionViewItem *>([collectionView makeItemWithIdentifier:ToolchainsCollectionViewItem.identifier forIndexPath:indexPath]);
        
        if (auto managedObjectContext = weakSelf.viewModel.childManagedObjectContext) {
            [item loadWithManagedObjectContext:managedObjectContext managedObjectID:managedObjectID];
        }
        
        return item;
    }];
    
    return [dataSource autorelease];
}

@end
