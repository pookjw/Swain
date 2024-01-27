//
//  NSTextField+ApplyLabelStyle.mm
//  Swain
//
//  Created by Jinwoo Kim on 1/20/24.
//

#import "NSTextField+ApplyLabelStyle.hpp"

@implementation NSTextField (ApplyLabelStyle)

- (void)applyLabelStyle {
    self.editable = NO;
    self.selectable = NO;
    self.bezeled = NO;
    self.preferredMaxLayoutWidth = 0.f;
    self.lineBreakMode = NSLineBreakByWordWrapping;
    self.drawsBackground = NO;
    self.textColor = NSColor.controlTextColor;
}

@end
