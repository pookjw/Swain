//
//  MainSidebarItemModel.mm
//  Swain
//
//  Created by Jinwoo Kim on 1/17/24.
//

#import "MainSidebarItemModel.hpp"
@import SwainCore;

__attribute__((objc_direct_members))
@interface MainSidebarItemModel ()
@end

@implementation MainSidebarItemModel

- (instancetype)initWithType:(MainSidebarItemModelType)type {
    if (self = [super init]) {
        _type = type;
    }
    
    return self;
}

- (id)copyWithZone:(struct _NSZone *)zone {
    auto copy = reinterpret_cast<decltype(self)>([self.class new]);
    copy->_type = _type;
    return copy;
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else {
        return _type == reinterpret_cast<decltype(self)>(other)->_type;
    }
}

- (NSUInteger)hash {
    return _type;
}

- (NSImage *)image {
    switch (_type) {
        case MainSidebarItemModelTypeStable:
            return [NSImage imageWithSystemSymbolName:@"swift" accessibilityDescription:nil];
        case MainSidebarItemModelTypeRelease:
            return [NSImage imageWithSystemSymbolName:@"tortoise" accessibilityDescription:nil];
        case MainSidebarItemModelTypeMain:
            return [NSImage imageWithSystemSymbolName:@"hare" accessibilityDescription:nil];
        default:
            return [NSImage imageWithSystemSymbolName:@"questionmark" accessibilityDescription:nil];
    }
}

- (NSImage *)selectedImage {
    switch (_type) {
        case MainSidebarItemModelTypeStable:
            return [NSImage imageWithSystemSymbolName:@"swift" accessibilityDescription:nil];
        case MainSidebarItemModelTypeRelease:
            return [NSImage imageWithSystemSymbolName:@"tortoise.fill" accessibilityDescription:nil];
        case MainSidebarItemModelTypeMain:
            return [NSImage imageWithSystemSymbolName:@"hare.fill" accessibilityDescription:nil];
        default:
            return [NSImage imageWithSystemSymbolName:@"questionmark" accessibilityDescription:nil];
    }
}

- (NSString *)title {
    switch (_type) {
        case MainSidebarItemModelTypeStable:
            return @"Releases";
        case MainSidebarItemModelTypeRelease:
            return @"Development";
        case MainSidebarItemModelTypeMain:
            return @"Trunk Development";
        default:
            return @"(null)";
    }
}

- (NSString *)toolchainCategory {
    switch (_type) {
        case MainSidebarItemModelTypeStable:
            return SwainCore::Toolchain::getCategoryStableName();
        case MainSidebarItemModelTypeRelease:
            return SwainCore::Toolchain::getCategoryReleaseName();
        case MainSidebarItemModelTypeMain:
            return SwainCore::Toolchain::getCategoryMainName();
        default:
            return nil;
    }
}

@end
