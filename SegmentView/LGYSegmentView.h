//
//  LGYSegmentView.h
//  LGYSegmentView
//
//  Created by LGY on 2019/5/28.
//  Copyright © 2019 LGY. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, LGYSegmentTrackerStyle) {
    LGYSegmentTrackerTitleScaleWidth, //底部指示器的宽度等比与title的宽度
    LGYSegmentTrackerTitleAttachmentWidth
};

typedef NS_ENUM(NSUInteger, LGYSegmentViewContentAligment) {
    LGYSegmentViewContentAligmentLeft, // 默认即是左对齐
    LGYSegmentViewContentAligmentCenter,
};

@class LGYSegmentView;
@protocol LGYSegmentViewDelegate <NSObject>
@optional
- (void)segmentView:(LGYSegmentView *)segmentView selectItemIndex:(NSInteger)index;
@end

@interface LGYSegmentView : UIView
@property (nonatomic, strong, readonly) NSArray<NSString *> *items;
/// 标题栏点击时间代理
@property (nonatomic, weak,   nullable) id <LGYSegmentViewDelegate> delegate;
/// 菜单栏子标签的对齐方式
@property (nonatomic, assign)   LGYSegmentViewContentAligment contentAligmentType;
/// 当外界的scrollView,正在滚动时，标签不应该接收点击事件
@property (nonatomic, assign, getter=canAcceptTapAction)   BOOL acceptTapAction;
/// 指示器高度
@property (nonatomic, assign)   CGFloat trackerHeight;
/// 指示器颜色
@property (nonatomic, strong)   UIColor *trackerColor;
/// 菜单指示器的宽度和被选中item宽度的比例系数，默认等于1，即相等
@property (nonatomic, assign)   CGFloat trackerTitleWidthScale;
/// 最左边和最右边的segmentItem距离segmentView的边距
@property (nonatomic, assign)   CGFloat contentLRSpacing;
/// item之间的水平间距
@property (nonatomic, assign)   CGFloat itemSpacing;
/// item间距部分是否可以以响应点击事件，默认响应
@property (nonatomic, assign)   CGFloat itemSpacingCanAcceptHitTest;
/// title选中缩放值，以1为基准
@property (nonatomic, assign)   CGFloat itemZoomScale;
/// 单个标题的最大宽度 默认为CGFLOAT_MAX:item的宽度不限制，否则则item的最大宽度不超过该值
@property (nonatomic, assign)   CGFloat itemMaxWidth;
/// title未选中时的font
@property (nonatomic, strong)   UIFont *itemNormalFont;
/// title选中时的font
@property (nonatomic, strong)   UIFont *itemSelectFont;
/// title未选中时的颜色
@property (nonatomic, strong)   UIColor *itemNormalColor;
/// title选中时的颜色
@property (nonatomic, strong)   UIColor *itemSelectColor;
/// 设置segment实时进度，此属性只在用户主动滑动情况下设置
@property (nonatomic, assign)   CGFloat segmentRealTimeProcess;
/// 设置选中的item,设置次属性会调用代理方法
@property (nonatomic) NSInteger selectedItemIndex;
/// 底部指示器tracker的样式
@property (nonatomic, assign)   LGYSegmentTrackerStyle trackerStyle;
/// 导航菜单上所有标签视图
@property (nonatomic, strong, readonly) NSMutableArray *itemViews;
/// 创建导航菜单的推荐方法
+ (instancetype)segmentViewWithItems:(NSArray<NSString *> *)items delegate:(nullable id<LGYSegmentViewDelegate>)delegate;
/// 更新导航菜单上的标签
- (void)updateItems:(NSArray<NSString *> *)items;
/// 点击标题视图后更新itemView
- (void)refreshItemViews;
@end

NS_ASSUME_NONNULL_END
