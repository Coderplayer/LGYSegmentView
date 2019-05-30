//
//  LGYSegmentItemView.h
//  LGYSegmentView
//
//  Created by LGY on 2019/5/28.
//  Copyright © 2019 LGY. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LGYSegmentItemView : UILabel
@property (nonatomic, assign) UIEdgeInsets hitTestEdgeInsets;
@property (nonatomic, weak, readonly) UITapGestureRecognizer *tap;
- (instancetype)initWithTitle:(NSString *)title;
- (void)addTarget:(id)target action:(SEL)action;
- (CGFloat)itemTitleWidth;
@end

NS_ASSUME_NONNULL_END
