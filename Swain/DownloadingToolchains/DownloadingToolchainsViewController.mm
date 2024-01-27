//
//  DownloadingToolchainsViewController.mm
//  Swain
//
//  Created by Jinwoo Kim on 1/27/24.
//

#import "DownloadingToolchainsViewController.hpp"
#import "DownloadingToolchainsViewItem.hpp"
#import "DownloadingToolchainsViewModel.hpp"
#import "DownloadingToolchainsViewItemModel.hpp"

__attribute__((objc_direct_members))
@interface DownloadingToolchainsViewController () <NSCollectionViewDelegate> {
    NSScrollView *_scrollView;
    NSCollectionView *_collectionView;
    DownloadingToolchainsViewModel *_viewModel;
}
@property (retain, nonatomic, readonly) NSScrollView *scrollView;
@property (retain, nonatomic, readonly) NSCollectionView *collectionView;
@property (retain, nonatomic, readonly) DownloadingToolchainsViewModel *viewModel;
@end

@implementation DownloadingToolchainsViewController

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
    [self.viewModel loadDataSourceCompletionHandler:^{
        
    }];
}

- (NSScrollView *)scrollView {
    if (auto scrollView = _scrollView) return scrollView;
    
    NSScrollView *scrollView = [NSScrollView new];
    scrollView.documentView = self.collectionView;
    scrollView.drawsBackground = NO;
    scrollView.contentView.drawsBackground = NO;
    scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
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
    collectionView.allowsEmptySelection = YES;
    collectionView.selectable = YES;
    collectionView.collectionViewLayout = collectionViewLayout;
    collectionView.delegate = self;
    collectionView.backgroundColors = @[NSColor.clearColor];
    [collectionViewLayout release];
    
    [collectionView registerClass:DownloadingToolchainsViewItem.class forItemWithIdentifier:DownloadingToolchainsViewItem.identifier];
    
    _collectionView = [collectionView retain];
    return [collectionView autorelease];
}

- (DownloadingToolchainsViewModel *)viewModel {
    if (auto viewModel = _viewModel) return viewModel;
    
    DownloadingToolchainsViewModel *viewModel = [[DownloadingToolchainsViewModel alloc] initWithDataSource:[self makeDataSource]];
    
    _viewModel = [viewModel retain];
    
    return [viewModel autorelease];
}

- (NSCollectionViewDiffableDataSource<NSNumber *, DownloadingToolchainsViewItemModel *> *)makeDataSource __attribute__((objc_direct)) {
    auto dataSource = [[NSCollectionViewDiffableDataSource<NSNumber *, DownloadingToolchainsViewItemModel *> alloc] initWithCollectionView:self.collectionView itemProvider:^NSCollectionViewItem * _Nullable(NSCollectionView * _Nonnull collectionView, NSIndexPath * _Nonnull indexPath, DownloadingToolchainsViewItemModel * _Nonnull itemModel) {
        auto item = reinterpret_cast<DownloadingToolchainsViewItem *>([collectionView makeItemWithIdentifier:DownloadingToolchainsViewItem.identifier forIndexPath:indexPath]);
        
        [item loadWithItemModel:itemModel];
        
        return item;
    }];
    
    return [dataSource autorelease];
}

@end
