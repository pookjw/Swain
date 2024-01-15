//
//  MainSidebarViewController.mm
//  Swain
//
//  Created by Jinwoo Kim on 1/15/24.
//

#import "MainSidebarViewController.hpp"
#import "MainSidebarTableRowView.h"

__attribute__((objc_direct_members))
@interface MainSidebarViewController () <NSTableViewDataSource, NSTableViewDelegate> {
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
    
    NSTableColumn *tableColumn = [[NSTableColumn alloc] initWithIdentifier:@"Test"];
    tableColumn.title = @"Test";
    [tableView addTableColumn:tableColumn];
    [tableColumn release];
    
    NSNib *nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass(MainSidebarTableRowView.class) bundle:[NSBundle bundleForClass:MainSidebarTableRowView.class]];
    [tableView registerNib:nib forIdentifier:NSTableViewRowViewKey];
    [nib release];
    
    _tableView = [tableView retain];
    return [tableView autorelease];
}


#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return 3;
}


#pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return nil;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    NSTableRowView *rowView = [tableView makeViewWithIdentifier:NSTableViewRowViewKey owner:self];
    return [rowView autorelease];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 36.f;
}

@end
