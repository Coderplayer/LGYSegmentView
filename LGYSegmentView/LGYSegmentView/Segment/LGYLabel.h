//
//  LGYLabel.h
//  LGYSegmentView
//
//  Created by 李冠余 on 2017/6/14.
//  Copyright © 2017年 李冠余. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LGYLabel : UILabel
/** label的比例值 */
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGFloat enlageScale;
@property (nonatomic, strong) UIColor* normalColor;
@property (nonatomic, strong) UIColor* selectedColor;

@property (nonatomic, assign, readonly) CGFloat titleWidth;
@property (nonatomic, assign, readonly) CGFloat enlageTitleWidth;
@property (nonatomic, assign,readonly) CGFloat titleOriX;
@end
