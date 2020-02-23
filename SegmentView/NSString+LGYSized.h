//
//  NSString+LGYSized.h
//  Demo
//
//  Created by LGY on 2020/2/22.
//  Copyright © 2020 LGY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/NSStringDrawing.h>
#import <UIKit/UIFont.h>
NS_ASSUME_NONNULL_BEGIN

@interface NSString (LGYSized)
- (CGFloat)lgy_widthWithFont:(UIFont *)font;
- (CGFloat)lgy_widthWithFont:(UIFont *)font maxWith:(CGFloat)maxWith;
- (CGFloat)lgy_maxWidthWithNormalFont:(UIFont *)normalFont selectFont:(UIFont *)selectFont;
@end

NS_ASSUME_NONNULL_END
