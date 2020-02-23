//
//  LGYSegmentItemView.h
//  LGYSegmentView
//
//  Created by LGY on 2019/5/28.
//  Copyright © 2019 LGY. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface LGYSegmentItemView : UIControl
/// titleLabel的文字颜色
@property (nonatomic, strong) UIColor *textColor;
/// titleLabel的文字大小
@property (nonatomic, assign) UIFont  *font;
/// 展示的文字
@property (nonatomic, copy, readonly) NSString *text;

@property (nonatomic, assign) UIEdgeInsets hitTestEdgeInsets;

- (instancetype)initWithTitle:(NSString *)title;
- (void)addTarget:(id)target action:(SEL)action;

@end

NS_ASSUME_NONNULL_END
