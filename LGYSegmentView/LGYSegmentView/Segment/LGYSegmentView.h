//
//  LGYSegmentView.h
//  LGYSegmentView
//
//  Created by 李冠余 on 2017/6/15.
//  Copyright © 2017年 李冠余. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LGYSegmentView;
@protocol LGYSegmentViewDelegate <NSObject>
@required
- (void)segmentView:(LGYSegmentView *)segementView didSelectedTitleIndex:(NSInteger)index;
@end

@interface LGYSegmentView : UIView
@property (nonatomic, assign,readonly) NSInteger  currentSelIndex;
/** pop回来如果titleView消失，先设置此属性在设置titleView */
@property(nonatomic, assign) CGSize intrinsicContentSize;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) UIColor *segmentNormalColor;
@property (nonatomic, strong) UIColor *segmentSelectedColor;
@property (nonatomic, strong) UIColor *indicatorVColor;
@property (nonatomic, assign) CGFloat titleWidth;
@property (nonatomic, assign) CGFloat indicatorVHeight;
@property (nonatomic, strong) UIFont *segmentTitleFont;

@property (nonatomic, assign) CGFloat titleSelectedEnlageScale;
@property (nonatomic, weak) id <LGYSegmentViewDelegate> delegate;

//** 推荐创建方式, */
+ (LGYSegmentView *)segmentViewWithTitles:(NSArray *)titles withDelegate:(id<LGYSegmentViewDelegate>)delegate;

- (void)fatherVCContentscrollViewDidScrollScale:(CGFloat)scale;
- (void)fatherVCContentscrollViewDidEndScrollingAnimationIndex:(NSInteger)index;
- (void)selectTitleAtIndex:(NSInteger)selIndex;
@end
