//
//  ToolchainsCollectionViewItem.hpp
//  Swain
//
//  Created by Jinwoo Kim on 1/19/24.
//

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_direct_members))
@interface ToolchainsCollectionViewItem : NSCollectionViewItem
@property (class, retain, nonatomic, readonly) NSUserInterfaceItemIdentifier identifier;
- (void)loadWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext managedObjectID:(NSManagedObjectID *)managedObjectID;
@end

NS_ASSUME_NONNULL_END
