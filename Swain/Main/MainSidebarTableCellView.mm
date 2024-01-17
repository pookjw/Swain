//
//  MainSidebarTableCellView.mm
//  Swain
//
//  Created by Jinwoo Kim on 1/15/24.
//

#import "MainSidebarTableCellView.hpp"
#import "MainSidebarItemModel.hpp"

@implementation MainSidebarTableCellView

- (void)setObjectValue:(id)objectValue {
    [super setObjectValue:objectValue];
    
    if ([objectValue isKindOfClass:MainSidebarItemModel.class]) {
        auto itemModel = reinterpret_cast<MainSidebarItemModel *>(objectValue);
        
        self.imageView.image = itemModel.image;
        self.textField.stringValue = itemModel.title;
    }
    
    self.backgroundStyle = NSBackgroundStyleLowered;
}

@end
