//
//  LGYSegmentItemView.m
//  LGYSegmentView
//
//  Created by LGY on 2019/5/28.
//  Copyright © 2019 LGY. All rights reserved.
//

#import "LGYSegmentItemView.h"

@interface LGYSegmentItemView ()
/// titleLabel
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation LGYSegmentItemView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title {
    if (self = [super init]) {
        self.titleLabel.text = title;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.frame = self.bounds;
}
- (void)setTextColor:(UIColor *)textColor {
    self.titleLabel.textColor = textColor;
}

- (void)setFont:(UIFont *)font {
    self.titleLabel.font = font;
}

- (NSString *)text {
    return self.titleLabel.text;
}

- (void)addTarget:(id)target action:(SEL)action {
    [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (UIEdgeInsetsEqualToEdgeInsets(self.hitTestEdgeInsets, UIEdgeInsetsZero) ||
                   !self.enabled ||
                   !self.userInteractionEnabled ||
                   self.hidden)
    {
        return [super pointInside:point withEvent:event];
    }
    
    CGRect relativeFrame = self.bounds;
    CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, self.hitTestEdgeInsets);
    
    BOOL ins = CGRectContainsPoint(hitFrame, point);
    return ins;
}


@end
