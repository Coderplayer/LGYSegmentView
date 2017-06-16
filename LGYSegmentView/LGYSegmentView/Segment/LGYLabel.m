//
//  LGYLabel.m
//  LGYSegmentView
//
//  Created by 李冠余 on 2017/6/14.
//  Copyright © 2017年 李冠余. All rights reserved.
//

#import "LGYLabel.h"
const CGFloat LGYRed = 0;
const CGFloat LGYGreen = 0;
const CGFloat LGYBlue = 0;
const CGFloat LGYAlpha = 1.0;
@interface LGYLabel ()
@property (nonatomic, assign) CGFloat normalRed;
@property (nonatomic, assign) CGFloat normalGreen;
@property (nonatomic, assign) CGFloat normalBlue;

@property (nonatomic, assign) CGFloat selectRed;
@property (nonatomic, assign) CGFloat selectGreen;
@property (nonatomic, assign) CGFloat selectBlue;
@end

@implementation LGYLabel
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
//        self.font = [UIFont systemFontOfSize:18];
        self.textColor = [UIColor blackColor];
        self.textAlignment = NSTextAlignmentCenter;
//        self.backgroundColor = [UIColor greenColor];
//        self.layer.cornerRadius = 10;
//        self.layer.masksToBounds = YES;
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)setNormalColor:(UIColor *)normalColor
{
    _normalColor = normalColor;
    const CGFloat *components = CGColorGetComponents(normalColor.CGColor);
    self.textColor = normalColor;
    _normalRed = components[0];
    _normalGreen = components[1];
    _normalBlue = components[2];
}

- (void)setSelectedColor:(UIColor *)selectedColor
{
    _selectedColor = selectedColor;
    const CGFloat *components = CGColorGetComponents(selectedColor.CGColor);
    _selectRed = components[0];
    _selectGreen = components[1];
    _selectBlue = components[2];
}
- (void)setScale:(CGFloat)scale
{
    _scale = scale;    
    //      R G B
    // 默认：0.4 0.6 0.7
    // 红色：1   0   0
    if (self.selectedColor) {
        CGFloat red = self.normalRed + (self.selectRed - self.normalRed) * scale;
        CGFloat green = self.normalGreen + (self.selectGreen - self.normalGreen) * scale;
        CGFloat blue = self.normalBlue + (self.selectBlue - self.normalBlue) * scale;
        self.textColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    }   
    // 大小缩放比例
    CGFloat transformScale = 1 + scale * self.enlageScale; // [1, 1.2]
    self.transform = CGAffineTransformMakeScale(transformScale, transformScale);
}
@end
