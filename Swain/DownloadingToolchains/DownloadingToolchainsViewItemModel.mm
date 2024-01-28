//
//  DownloadingToolchainsViewItemModel.mm
//  Swain
//
//  Created by Jinwoo Kim on 1/27/24.
//

#import "DownloadingToolchainsViewItemModel.hpp"

__attribute__((objc_direct_members))
@interface DownloadingToolchainsViewItemModel ()
@property (retain, nonatomic) SWCToolchainPackage *toolchainPackage;
@end

@implementation DownloadingToolchainsViewItemModel

- (instancetype)initWitToolchainPackage:(SWCToolchainPackage *)toolchainPackage {
    if (self = [super init]) {
        self.toolchainPackage = toolchainPackage;
    }
    
    return self;
}

- (void)dealloc {
    [_toolchainPackage release];
    [super dealloc];
}

@end
