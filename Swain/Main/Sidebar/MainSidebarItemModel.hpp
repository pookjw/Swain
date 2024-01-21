//
//  MainSidebarItemModel.hpp
//  Swain
//
//  Created by Jinwoo Kim on 1/17/24.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MainSidebarItemModelType) {
    MainSidebarItemModelTypeStable,
    MainSidebarItemModelTypeRelease,
    MainSidebarItemModelTypeMain
};

__attribute__((objc_direct_members))
@interface MainSidebarItemModel : NSObject
@property (assign, readonly, nonatomic) MainSidebarItemModelType type;
@property (readonly, nonatomic) NSImage *image;
@property (readonly, nonatomic) NSImage *selectedImage;
@property (readonly, nonatomic) NSString *title;
@property (readonly, nonatomic) NSString * _Nullable toolchainCategory;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithType:(MainSidebarItemModelType)type NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
