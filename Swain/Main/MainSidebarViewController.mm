//
//  MainSidebarViewController.mm
//  Swain
//
//  Created by Jinwoo Kim on 1/15/24.
//

#import "MainSidebarViewController.hpp"
#import "MainSidebarTableCellView.hpp"
#import "MainSidebarItemModel.hpp"

@interface Row : NSTableRowView
@end
@implementation Row
- (BOOL)isEmphasized { return NO; }

- (void)setEmphasized:(BOOL)emphasized {
    [super setEmphasized:emphasized];
}
@end

namespace MainSidebar {
    NSUserInterfaceItemIdentifier const cellViewIdentifier = @"MainSidebarTableCellViewIdentifier";
}

__attribute__((objc_direct_members))
@interface MainSidebarViewController () <NSTableViewDelegate, NSTableViewDataSource> {
    NSTableView *_tableView;
}
@property (retain, nonatomic, readonly) NSTableView *tableView;
@end

@implementation MainSidebarViewController

- (void)dealloc {
    [_tableView release];
    [super dealloc];
}

- (void)loadView {
    self.view = self.tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSTableView *)tableView {
    if (auto tableView = _tableView) return tableView;
    NSTableView *tableView = [NSTableView new];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.style = NSTableViewStyleSourceList;
    tableView.usesAutomaticRowHeights = NO;
    tableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleRegular;
    
//    NSTableColumn *tableColumn = [[NSTableColumn alloc] initWithIdentifier:[NSString string]];
//    [tableView addTableColumn:tableColumn];
//    [tableColumn release];
//    
    NSNib *nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass(MainSidebarTableCellView.class) bundle:[NSBundle bundleForClass:MainSidebarTableCellView.class]];
    [tableView registerNib:nib forIdentifier:MainSidebar::cellViewIdentifier];
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
//    MainSidebarTableCellView *view = [tableView makeViewWithIdentifier:MainSidebar::cellViewIdentifier owner:nil];
//    return view;
    return nil;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    return [[Row new] autorelease];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 36.f;
}

@end
