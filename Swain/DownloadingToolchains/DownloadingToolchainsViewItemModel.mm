//
//  DownloadingToolchainsViewItemModel.mm
//  Swain
//
//  Created by Jinwoo Kim on 1/27/24.
//

#import "DownloadingToolchainsViewItemModel.hpp"

__attribute__((objc_direct_members))
@interface DownloadingToolchainsViewItemModel ()
@property (copy, nonatomic) NSString *name;
@property (retain, nonatomic) NSProgress *progress;
@end

@implementation DownloadingToolchainsViewItemModel

- (instancetype)initWithName:(NSString *)name progress:(NSProgress *)progress {
    if (self = [super init]) {
        self.name = name;
        self.progress = progress;
    }
    
    return self;
}

- (void)dealloc {
    [_name release];
    [_progress release];
    [super dealloc];
}

@end
