//
//  ToolchainsViewController.mm
//  Swain
//
//  Created by Jinwoo Kim on 1/15/24.
//

#import "ToolchainsViewController.hpp"

__attribute__((objc_direct_members))
@interface ToolchainsViewController () {
    NSScrollView *_scrollView;
    NSCollectionView *_collectionView;
}
@property (retain, nonatomic, readonly) NSScrollView *scrollView;
@property (retain, nonatomic, readonly) NSCo
@end

@implementation ToolchainsViewController

- (void)dealloc {
    [_scrollView release];
    [_collectionView release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = NSColor.greenColor.CGColor;
}

@end
