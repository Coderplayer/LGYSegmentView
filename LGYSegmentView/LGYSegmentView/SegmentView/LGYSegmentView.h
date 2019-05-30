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
    LGYSegmentTrackerEqualTitleWith,
    LGYSegmentTrackerAttachmentTitle,
};

@class LGYSegmentView;
@protocol LGYSegmentViewDelegate <NSObject>
@optional
- (void)segmentView:(LGYSegmentView *)segmentView selectItemIndex:(NSInteger)index;
- (void)segmentView:(LGYSegmentView *)segmentView fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
@end

@interface LGYSegmentView : UIView
@property (nonatomic, strong, readonly) NSArray<NSString *> *items;
@property (nonatomic, weak, nullable)     id <LGYSegmentViewDelegate> delegate;
/** 指示器高度 */
@property (nonatomic, assign)   CGFloat trackerHeight;
/** 指示器颜色 */
@property (nonatomic, strong)   UIColor *trackerColor;
/** 最左边和最右边的segmentItem距离segmentView的边距 */
@property (nonatomic, assign)   CGFloat contentLRSpacing;
/** item之间的水平间距 */
@property (nonatomic, assign)   CGFloat itemSpacing;
/** item之间的部分也可以响应点击事件 */
@property (nonatomic, assign)   CGFloat itemSpacingCanAcceptHitTest;
/** title选中缩放值，以1为基准 */
@property (nonatomic, assign)   CGFloat itemZoomScale;
@property (nonatomic, strong)   UIFont *itemTitleFont;
@property (nonatomic, strong)   UIColor *itemNormaldColor;
@property (nonatomic, strong)   UIColor *itemSelectedColor;
/** 设置segment实时进度，此属性只在用户主动滑动情况下设置 */
@property (nonatomic, assign)   CGFloat segmentRealTimeProcess;
/** 设置选中的item,设置次属性会调用代理方法 */
@property (nonatomic) NSInteger selectedItemIndex;

@property (nonatomic, assign) LGYSegmentTrackerStyle trackerStyle;
+ (instancetype)segmentViewWithItems:(NSArray<NSString *> *)items
                            delegate:(nullable id<LGYSegmentViewDelegate>)delegate;
- (void)updateItems:(NSArray<NSString *> *)items;
@end

NS_ASSUME_NONNULL_END
