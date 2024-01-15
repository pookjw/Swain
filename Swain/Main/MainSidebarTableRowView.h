//
//  MainSidebarTableRowView.hpp
//  Swain
//
//  Created by Jinwoo Kim on 1/15/24.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface MainSidebarTableRowView : NSTableRowView
@property (retain) IBOutlet NSImageView *imageView;
@property (retain) IBOutlet NSTextField *textField;
@end

NS_ASSUME_NONNULL_END
