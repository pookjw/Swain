//
//  MainSidebarViewController.mm
//  Swain
//
//  Created by Jinwoo Kim on 1/15/24.
//

#import "MainSidebarViewController.hpp"
#import "MainSidebarTableView.hpp"
#import "MainSidebarTableCellView.hpp"
#import "MainSidebarItemModel.hpp"

namespace ns_MainSidebarViewController {
    NSUserInterfaceItemIdentifier const cellViewIdentifier = @"MainSidebarTableCellViewIdentifier";
}

__attribute__((objc_direct_members))
@interface MainSidebarViewController () <NSTableViewDelegate, NSTableViewDataSource> {
    NSScrollView *_scrollView;
    MainSidebarTableView *_tableView;
}
@property (retain, nonatomic, readonly) NSScrollView *scrollView;
@property (retain, nonatomic, readonly) MainSidebarTableView *tableView;
@end

@implementation MainSidebarViewController

- (void)dealloc {
    [_tableView release];
    [super dealloc];
}

- (void)loadView {
    self.view = self.scrollView;
}

- (NSScrollView *)scrollView {
    if (auto scrollView = _scrollView) return scrollView;
    
    NSScrollView *scrollView = [NSScrollView new];
    scrollView.documentView = self.tableView;
    scrollView.drawsBackground = NO;
    
    _scrollView = [scrollView retain];
    return [scrollView autorelease];
}

- (MainSidebarTableView *)tableView {
    if (auto tableView = _tableView) return tableView;
    
    MainSidebarTableView *tableView = [MainSidebarTableView new];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.style = NSTableViewStyleSourceList;
    tableView.usesAutomaticRowHeights = NO;
    tableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleRegular;

    NSTableColumn *tableColumn = [[NSTableColumn alloc] initWithIdentifier:[NSString string]];
    [tableView addTableColumn:tableColumn];
    [tableColumn release];
    
    NSNib *nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass(MainSidebarTableCellView.class) bundle:[NSBundle bundleForClass:MainSidebarTableCellView.class]];
    [tableView registerNib:nib forIdentifier:ns_MainSidebarViewController::cellViewIdentifier];
    [nib release];
    
    _tableView = [tableView retain];
    return [tableView autorelease];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return 3;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    switch (row) {
        case 0:
            return [[[MainSidebarItemModel alloc] initWithType:MainSidebarItemModelTypeStable] autorelease];
        case 1:
            return [[[MainSidebarItemModel alloc] initWithType:MainSidebarItemModelTypeRelease] autorelease];
        case 2:
            return [[[MainSidebarItemModel alloc] initWithType:MainSidebarItemModelTypeMain] autorelease];
        default:
            return [NSNull null];
    }
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    MainSidebarTableCellView *view = [tableView makeViewWithIdentifier:ns_MainSidebarViewController::cellViewIdentifier owner:nil];
    return view;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 36.f;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    auto delegate = self.delegate;
    
    if (delegate == nil) return;
    
    auto tableView = reinterpret_cast<MainSidebarTableView *>(notification.object);
    
    NSInteger selectedRow = tableView.selectedRow;
    __kindof NSTableCellView * _Nullable selectedView = [tableView viewAtColumn:0 row:selectedRow makeIfNecessary:NO];
    
    if (selectedView == nil) return;
    
    MainSidebarItemModel * _Nullable objectValue = selectedView.objectValue;
    
    if (![objectValue isKindOfClass:MainSidebarItemModel.class]) return;
    
    NSString * _Nullable toolchainCategory = objectValue.toolchainCategory;
    
    if (toolchainCategory == nil) return;
    [delegate mainSidebarViewController:self didSelectToolchainCategory:toolchainCategory];
}

@end
