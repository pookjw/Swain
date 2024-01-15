//
//  ToolchainsViewController.mm
//  Swain
//
//  Created by Jinwoo Kim on 1/15/24.
//

#import "ToolchainsViewController.hpp"

__attribute__((objc_direct_members))
@interface ToolchainsViewController ()

@end

@implementation ToolchainsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = NSColor.greenColor.CGColor;
}

@end
