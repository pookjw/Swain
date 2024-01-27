//
//  DownloadingToolchainsViewItem.hpp
//  Swain
//
//  Created by Jinwoo Kim on 1/27/24.
//

#import <Cocoa/Cocoa.h>
#import "DownloadingToolchainsViewItemModel.hpp"

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_direct_members))
@interface DownloadingToolchainsViewItem : NSCollectionViewItem
@property (class, retain, nonatomic, readonly) NSUserInterfaceItemIdentifier identifier;
- (void)loadWithItemModel:(DownloadingToolchainsViewItemModel *)itemModel;
@end

NS_ASSUME_NONNULL_END
