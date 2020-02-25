//
//  NSString+LGYSized.m
//  Demo
//
//  Created by LGY on 2020/2/22.
//  Copyright © 2020 LGY. All rights reserved.
//

#import "NSString+LGYSized.h"

@implementation NSString (LGYSized)
- (CGFloat)lgy_widthWithFont:(UIFont *)font {
    return [self lgy_widthWithFont:font maxWith:CGFLOAT_MAX];
}

- (CGFloat)lgy_widthWithFont:(UIFont *)font maxWith:(CGFloat)maxWith {
    if (!font) {
        return 0;
    }
    // 以下代码当 font为nil时，会崩溃
    CGFloat width = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName : font}
                                       context:nil].size.width + 1;
    if (width > maxWith) {
        width = maxWith;
    }
    return width;
}

- (CGFloat)lgy_maxWidthWithNormalFont:(UIFont *)normalFont selectFont:(UIFont *)selectFont {
    if ([normalFont.fontName isEqualToString:selectFont.fontName]) {
        UIFont *maxFont = (normalFont.pointSize > selectFont.pointSize) ? normalFont : selectFont;
        return [self lgy_widthWithFont:maxFont];
    }else {
        CGFloat normalWidth = [self lgy_widthWithFont:normalFont];
        CGFloat selectWidth = [self lgy_widthWithFont:selectFont];
        return (normalWidth > selectWidth) ? normalWidth : selectWidth;
    }
}
@end
