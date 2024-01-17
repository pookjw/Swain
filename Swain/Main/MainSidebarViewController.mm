//
//  MainSidebarViewController.mm
//  Swain
//
//  Created by Jinwoo Kim on 1/15/24.
//

#import "MainSidebarViewController.hpp"
#import "MainSidebarTableCellView.h"

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

//- (NSOutlineView *)outlineView {
//    if (auto outlineView = _outlineView) return outlineView;
//    
//    NSOutlineView *outlineView = [NSOutlineView new];
//    outlineView.dataSource = self;
//    outlineView.delegate = self;
//    
//    NSNib *nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass(MainSidebarTableRowView.class) bundle:[NSBundle bundleForClass:MainSidebarTableRowView.class]];
//    [outlineView registerNib:nib forIdentifier:NSTableViewRowViewKey];
//    [nib release];
//    
//    _outlineView = [outlineView retain];
//    return [outlineView autorelease];
//}

- (NSTableView *)tableView {
    if (auto tableView = _tableView) return tableView;
    
    NSTableView *tableView = [NSTableView new];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.style = NSTableViewStyleSourceList;
    tableView.usesAutomaticRowHeights = NO;
    
//    tableView.headerView = nil;
//    
//    NSTableColumn *tableColumn = [[NSTableColumn alloc] initWithIdentifier:@"Test"];
//    tableColumn.title = @"Test";
//    [tableView addTableColumn:tableColumn];
//    [tableColumn release];
    
    NSNib *nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass(MainSidebarTableCellView.class) bundle:[NSBundle bundleForClass:MainSidebarTableCellView.class]];
    [tableView registerNib:nib forIdentifier:@"Test"];
    [nib release];
    
    _tableView = [tableView retain];
    return [tableView autorelease];
}


#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return 3;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return nil;
}


#pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    MainSidebarTableCellView *view = [tableView makeViewWithIdentifier:@"Test" owner:nil];
    
    return view;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 36.f;
}

@end
