//
//  LGYSegmentItemView.m
//  LGYSegmentView
//
//  Created by LGY on 2019/5/28.
//  Copyright © 2019 LGY. All rights reserved.
//

#import "LGYSegmentItemView.h"

@interface LGYSegmentItemView ()
@property (nonatomic, weak) UITapGestureRecognizer *tap;
@end

@implementation LGYSegmentItemView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.textAlignment = NSTextAlignmentCenter;
        [self tap];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title {
    if (self = [super init]) {
        self.text = title;
    }
    return self;
}

- (UITapGestureRecognizer *)tap {
    if (!_tap) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [self addGestureRecognizer:tap];
        _tap = tap;
    }
    return _tap;
}

- (void)addTarget:(id)target action:(SEL)action {
    if (target && action) {
        [self.tap addTarget:target action:action];
    }
}

- (CGFloat)itemTitleWidth {
    return [self.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                   options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:@{NSFontAttributeName : self.font}
                                   context:nil].size.width + 1;
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
