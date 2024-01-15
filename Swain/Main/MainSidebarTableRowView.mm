//
//  MainSidebarTableRowView.mm
//  Swain
//
//  Created by Jinwoo Kim on 1/15/24.
//

#import "MainSidebarTableRowView.h"

@implementation MainSidebarTableRowView

- (void)dealloc {
    [_imageView release];
    [_textField release];
    [super dealloc];
}

@end
