//
//  LGYSegmentView.m
//  LGYSegmentView
//
//  Created by LGY on 2019/5/28.
//  Copyright © 2019 LGY. All rights reserved.
//

#import "LGYSegmentView.h"
#import "LGYSegmentItemView.h"
#import "NSString+LGYSized.h"

/// 背景scrollView
@interface LGYSegmentScorllView : UIScrollView
@end

@implementation LGYSegmentScorllView
// 重写这个方法的目的是：当手指长按按钮时无法滑动scrollView的问题
- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    return YES;
}
@end

#pragma mark - LGYSegmentView 实现
@interface LGYSegmentView ()
/// 存放所有标签的父视图ScrollView
@property (nonatomic, strong) UIScrollView     *scrollView;
/// 底部指示器视图
@property (nonatomic, strong) UIImageView      *tracker;
@property (nonatomic, strong) NSArray          *items;
@property (nonatomic, strong) NSMutableArray   *itemViews;

@property (nonatomic, assign) CGFloat normalR;
@property (nonatomic, assign) CGFloat normalG;
@property (nonatomic, assign) CGFloat normalB;
@property (nonatomic, assign) CGFloat normalA;

@property (nonatomic, assign) CGFloat selectR;
@property (nonatomic, assign) CGFloat selectG;
@property (nonatomic, assign) CGFloat selectB;
@property (nonatomic, assign) CGFloat selectA;
@end

@implementation LGYSegmentView
#pragma mark - 创建segment
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _itemMaxWidth = CGFLOAT_MAX;
        _itemNormalFont = [UIFont systemFontOfSize:16];
        _itemSpacing = 30;
        _trackerHeight = 3.0;
        _itemZoomScale = 1.0;
        _selectedItemIndex = NSNotFound;
        _contentLRSpacing = _itemSpacing * 0.5;
        _itemSpacingCanAcceptHitTest = YES;
        _trackerTitleWidthScale = 1.0;
        self.itemNormalColor = [UIColor blackColor];
        self.itemSelectColor = [UIColor redColor];
        [self tracker];
        self.trackerColor = [UIColor redColor];
        [self scrollView];
    }
    return self;
}

+ (instancetype)segmentViewWithItems:(NSArray *)items delegate:(id<LGYSegmentViewDelegate>)delegate {
    return [[self alloc] initWithItems:items delegate:delegate];
}

- (instancetype)initWithItems:(NSArray *)items delegate:(id<LGYSegmentViewDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
        self.items = items;
        [self updateSegmentItemViews];
    }
    return self;
}

- (void)updateItems:(NSArray<NSString *> *)items {
    self.items = items;
    [self updateSegmentItemViews];
      [self setNeedsLayout];
}

/// 更新菜单的标签子视图
- (void)updateSegmentItemViews {
    [self.itemViews performSelector:@selector(removeFromSuperview)];
    [self.itemViews removeAllObjects];
    NSMutableArray *itemViews = [NSMutableArray array];
    for (NSInteger index = 0; index < self.items.count; index ++){
        NSString *title = [self.items objectAtIndex:index];
        LGYSegmentItemView *itemView = [[LGYSegmentItemView alloc] initWithTitle:title];
        itemView.tag = index;
        [itemView addTarget:self action:@selector(itemViewWasTapped:)];
        [self.scrollView addSubview:itemView];
        [itemViews addObject:itemView];
    }
    
    self.itemViews = [itemViews copy];
    _selectedItemIndex = NSNotFound;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize size = self.bounds.size;
    self.scrollView.frame = self.bounds;
    const NSInteger itemCount = self.itemViews.count;
    CGFloat itemWidths[itemCount];

    UIEdgeInsets itemHitEdgeInserts = UIEdgeInsetsZero;
    if (self.itemSpacingCanAcceptHitTest) {
         CGFloat hitSpace = self.itemSpacing * 0.5;
         itemHitEdgeInserts = UIEdgeInsetsMake(0, -hitSpace, 0, -hitSpace);
    }
    
    CGFloat tempContentWidth = (self.itemViews.count - 1) * self.itemSpacing;
    for (NSInteger i = 0; i < self.itemViews.count; i++) {
        LGYSegmentItemView *itemView = [self.itemViews objectAtIndex:i];
        CGFloat titleWidth = [itemView.text lgy_maxWidthWithNormalFont:_itemNormalFont selectFont:_itemSelectFont];
        if (titleWidth > _itemMaxWidth) {
            titleWidth = _itemMaxWidth;
        }
        tempContentWidth += titleWidth;
        itemWidths[i] = titleWidth;
        itemView.hitTestEdgeInsets = itemHitEdgeInserts;
    }

    CGFloat trulyLRSpacing = self.contentLRSpacing;
    if(self.contentAligmentType == LGYSegmentViewContentAligmentCenter) {
        CGFloat delta = size.width - tempContentWidth;
        if (delta > 0) {
            trulyLRSpacing = delta * 0.5;
        }
    }
    
    LGYSegmentItemView *lastItemView = nil;
    CGFloat x = trulyLRSpacing;
    for (NSInteger i = 0; i < self.itemViews.count; i++) {
        LGYSegmentItemView *itemView = [self.itemViews objectAtIndex:i];
        CGFloat titleWidth = itemWidths[i];
        itemView.transform = CGAffineTransformIdentity;
        itemView.frame = CGRectMake(x, 0, titleWidth, size.height - self.trackerHeight);
        x += titleWidth +  self.itemSpacing;
        lastItemView = itemView;
    }
    [self refreshItemViews];
    self.tracker.frame = CGRectMake(0, size.height - self.trackerHeight, 0.1, self.trackerHeight);
    
    CGFloat contentWidth = CGRectGetMaxX(lastItemView.frame) + trulyLRSpacing;
    self.scrollView.contentSize = CGSizeMake(contentWidth, 0);
    
    //当前选中的标签
    LGYSegmentItemView *selectItemView = self.currentSelectItemView;
    selectItemView.transform = CGAffineTransformMakeScale(self.itemZoomScale, self.itemZoomScale);
    [self resetTrackerFrameWithSelectedItemView:selectItemView];
    [self adjustscrollViewOffsetWithSelectedItemView:selectItemView animated:NO];
}

#pragma mark - delegate
- (void)delegatePerformMethodWithSelectedIndex:(NSInteger)selectedIndex {
    if (self.delegate && [self.delegate respondsToSelector:@selector(segmentView:selectItemIndex:)]) {
        [self.delegate segmentView:self selectItemIndex:selectedIndex];
    }
}
#pragma mark - segment内部跳转控制
/// 调整追踪器的位置
- (void)resetTrackerFrameWithSelectedItemView:(LGYSegmentItemView *)selectedItemView {
    CGFloat trackerW = selectedItemView.frame.size.width * _trackerTitleWidthScale;
    CGFloat trackerH = self.trackerHeight;
    self.tracker.bounds = CGRectMake(0, 0, trackerW, trackerH);
    CGFloat centerY = self.scrollView.bounds.size.height - self.trackerHeight * 0.5;
    self.tracker.center = CGPointMake(selectedItemView.center.x, centerY);
}


- (CGFloat)itemViewLocatedToScrollViewCenterShouldOffsetWith:(LGYSegmentItemView *)itemView {
    if (CGRectEqualToRect(self.scrollView.bounds, CGRectZero)) {
        return 0;
    }
    
    CGPoint centerInSegmentView = itemView.center;
    CGFloat offSetX = centerInSegmentView.x - CGRectGetWidth(self.scrollView.bounds) * 0.5;
    CGFloat maxOffsetX = self.scrollView.contentSize.width - CGRectGetWidth(self.scrollView.bounds);
    if (offSetX <= 0 || maxOffsetX <= 0) {
        offSetX = 0;
    } else if (offSetX > maxOffsetX){
        offSetX = maxOffsetX;
    }
    return offSetX;
}

/// 动态调整scrollView的偏移量
- (void)adjustscrollViewOffsetWithSelectedItemView:(LGYSegmentItemView *)itemView animated:(BOOL)animated {
    CGFloat offsetX = [self itemViewLocatedToScrollViewCenterShouldOffsetWith:itemView];
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:animated];
}

- (void)adjustScrollViewContentOffsetRealTimeBySegmentProcess {
    CGFloat segmentRealTimeProcess = self.segmentRealTimeProcess;
    CGFloat progress = segmentRealTimeProcess - floor(segmentRealTimeProcess);
    
    NSInteger previousIndex = floor(segmentRealTimeProcess);
    LGYSegmentItemView *previousItemView = [self.itemViews objectAtIndex:previousIndex];
    
    if (progress > 0) { //位于两个itemView中间位置
        CGFloat preItemShouldOffsetX = [self itemViewLocatedToScrollViewCenterShouldOffsetWith:previousItemView];
        
        NSInteger nextIndex = ceil(segmentRealTimeProcess);
        LGYSegmentItemView *nextItemView = [self.itemViews objectAtIndex:nextIndex];
        CGFloat nextItemShouldOffsetX = [self itemViewLocatedToScrollViewCenterShouldOffsetWith:nextItemView];
        
        CGFloat realTimeOffset = preItemShouldOffsetX + (nextItemShouldOffsetX - preItemShouldOffsetX) * progress;
        [self.scrollView setContentOffset:CGPointMake(realTimeOffset, 0) animated:NO];
        
    }else { // 正好滚动到某一个item位置
        [self adjustscrollViewOffsetWithSelectedItemView:previousItemView animated:NO];
    }
}

- (void)adjustSegmentContentRealTimeBySegmentProcess {
    // 停止滑动选中某一个标签
    if (self.selectedItemIndex == NSNotFound) {
        return;
    }
    CGFloat segmentRealTimeProcess = self.segmentRealTimeProcess;
    CGFloat progress = segmentRealTimeProcess - floor(segmentRealTimeProcess);
    
    NSInteger previousIndex = floor(segmentRealTimeProcess);
    LGYSegmentItemView *previousItemView = [self.itemViews objectAtIndex:previousIndex];
    
    CGRect newframe = self.tracker.frame;
    CGPoint newCenter = self.tracker.center;
    
    if (progress) {// 前后不是同一个即滚动的位置在两个item中间
        NSInteger nextIndex = ceil(segmentRealTimeProcess);
        LGYSegmentItemView *nextItemView = [self.itemViews objectAtIndex:nextIndex];
        if (self.trackerStyle == LGYSegmentTrackerTitleScaleWidth) {
            // 2个item之间的距离
            CGFloat xDistance = nextItemView.center.x - previousItemView.center.x;
            CGFloat detaItemViewWith = nextItemView.frame.size.width - previousItemView.frame.size.width;
            
            newCenter.x = previousItemView.center.x + xDistance * progress;
            newframe.size.width = (previousItemView.frame.size.width + detaItemViewWith * progress) * _trackerTitleWidthScale;
            self.tracker.frame = newframe;
            self.tracker.center = newCenter;
        }else {
            CGFloat preItemWidth  = CGRectGetWidth(previousItemView.frame);
            CGFloat preTrackerWidth = preItemWidth * _trackerTitleWidthScale;
            CGFloat preTrackerLRMargin = preItemWidth * (1 - _trackerTitleWidthScale) * 0.5;
            CGFloat preTrackerMinX = CGRectGetMinX(previousItemView.frame) + preTrackerLRMargin;
            CGFloat preTrackerMaxX = CGRectGetMaxX(previousItemView.frame) - preTrackerLRMargin;

            CGFloat nextItemWidth = CGRectGetWidth(nextItemView.frame);
//            CGFloat nextTrackerWidth = nextItemWidth * _trackerTitleWidthScale;
            CGFloat nextTrackerLRMargin = nextItemWidth * (1 - _trackerTitleWidthScale) * 0.5;
            CGFloat nextTrackerMinX = CGRectGetMinX(nextItemView.frame) + preTrackerLRMargin;
            CGFloat nextTrackerMaxX = CGRectGetMaxX(nextItemView.frame) - nextTrackerLRMargin;
            CGFloat trackerMaxWitdh = nextTrackerMaxX - preTrackerMinX;
            CGFloat rDistance = nextTrackerMaxX - preTrackerMaxX;
            if (progress < 0.5) { //使用右间距，trackert右边变长
                newframe.origin.x = preTrackerMinX;
                newframe.size.width = preTrackerWidth + rDistance * progress * 2;
            }else {
                CGFloat lDistance = nextTrackerMinX - preTrackerMinX;
                CGFloat deltaDistance = lDistance * (progress - 0.5) * 2;
                newframe.origin.x   = preTrackerMinX + deltaDistance;
                newframe.size.width = trackerMaxWitdh - deltaDistance;
            }
            self.tracker.frame = newframe;
        }
        
        if (self.itemZoomScale != 1) {
            CGFloat diff = self.itemZoomScale - 1;
            CGFloat previousZoomScale = (1 - progress) * diff + 1;
            previousItemView.transform = CGAffineTransformMakeScale(previousZoomScale, previousZoomScale);
            CGFloat nextZoomScale   = progress * diff + 1;
            nextItemView.transform  = CGAffineTransformMakeScale(nextZoomScale, nextZoomScale);
        }
        
        CGFloat r = self.selectR - self.normalR;
        CGFloat g = self.selectG - self.normalG;
        CGFloat b = self.selectB - self.normalB;
        CGFloat a = self.selectA - self.normalA;
        CGFloat toProgress = 1 - progress;
        UIColor *fromColor = [UIColor colorWithRed:self.normalR +  r * progress  green:self.normalG +  g * progress  blue:self.normalB +  b * progress alpha:self.normalA + a * progress];
        UIColor *toColor = [UIColor colorWithRed:self.normalR + r * toProgress green:self.normalG + g * toProgress blue:self.normalB + b * toProgress alpha:self.normalA + a * toProgress];
        
        previousItemView.textColor = toColor;
        nextItemView.textColor = fromColor;
        
    }else { // 正好滚动到某一个item位置
        //此时previousItemView即为选中的itemView
        if (CGRectEqualToRect(previousItemView.bounds, CGRectZero)) {
            previousItemView.transform = CGAffineTransformMakeScale(_itemZoomScale, _itemZoomScale);
        }
        [self resetTrackerFrameWithSelectedItemView:previousItemView];
        self.selectedItemIndex = previousIndex;
    }
}

#pragma mark - 颜色相关
// 获取颜色的RGB值
- (NSArray *)getRGBForColor:(UIColor *)color {
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat alpha = 0.0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    return @[@(red), @(green), @(blue), @(alpha)];
}

- (void)updateNormalRGBA {
    NSArray *components = [self getRGBForColor:self.itemNormalColor];
    self.normalR = [components[0] floatValue];
    self.normalG = [components[1] floatValue];
    self.normalB = [components[2] floatValue];
    self.normalA = [components[3] floatValue];
}

- (void)updateSelectlRGBA {
    NSArray *components = [self getRGBForColor:self.itemSelectColor];
    self.selectR = [components[0] floatValue];
    self.selectG = [components[1] floatValue];
    self.selectB = [components[2] floatValue];
    self.selectA = [components[3] floatValue];
}
#pragma mark - 点击事件 segment was tapped
- (void)itemViewWasTapped:(LGYSegmentItemView *)itemView {
    NSInteger index = itemView.tag;

    if (_selectedItemIndex == index) {
        return;
    }
    
    _selectedItemIndex = index;
    _segmentRealTimeProcess = index;
    
    [self refreshItemViews];
    if (!CGRectEqualToRect(itemView.frame,CGRectZero)) { // 布局完成
            [UIView animateWithDuration:0.25 animations:^{
                for (LGYSegmentItemView *subItemView in self.itemViews) {
                    if (index != subItemView.tag) {
                        subItemView.transform = CGAffineTransformIdentity;
                    }
                }
                
                itemView.transform = CGAffineTransformMakeScale(self.itemZoomScale, self.itemZoomScale);
                [self resetTrackerFrameWithSelectedItemView:itemView];
            }];
    }
   
    [self adjustscrollViewOffsetWithSelectedItemView:itemView animated:YES];
    [self delegatePerformMethodWithSelectedIndex:_selectedItemIndex];
}

- (void)refreshItemViews {
    for (NSInteger index = 0; index < self.itemViews.count; index ++) {
        LGYSegmentItemView *itemView = [self.itemViews objectAtIndex:index];
        if (index == _selectedItemIndex) {
            itemView.textColor = _itemSelectColor;
            itemView.font = _itemSelectFont ? _itemSelectFont : _itemNormalFont;
        }else {
            itemView.textColor = _itemNormalColor;
            itemView.font = _itemNormalFont;
        }
        [itemView layoutIfNeeded];
    }
}

#pragma mark - 属性设置
- (void)setItems:(NSArray *)items {
    _items = [items copy];
    self.tracker.hidden = (items.count < 2); //只有一个标题隐藏指示器
}

- (void)setAcceptTapAction:(BOOL)acceptTapAction {
    _acceptTapAction = acceptTapAction;
    self.scrollView.userInteractionEnabled = acceptTapAction;
}

- (void)setTrackerHeight:(CGFloat)trackerHeight {
    _trackerHeight = trackerHeight;
    [self setNeedsLayout];
}

- (void)setTrackerCornerRadius:(CGFloat)trackerCornerRadius {
    _trackerCornerRadius = trackerCornerRadius;
    self.tracker.layer.cornerRadius = trackerCornerRadius;
}

- (void)setTrackerColor:(UIColor *)trackerColor {
    _trackerColor = trackerColor;
    self.tracker.backgroundColor = trackerColor;
}

- (void)setContentLRSpacing:(CGFloat)contentLRSpacing {
    _contentLRSpacing = contentLRSpacing;
    [self setNeedsLayout];
}

- (void)setSegmentRealTimeProcess:(CGFloat)segmentRealTimeProcess {
    if (segmentRealTimeProcess < 0 || segmentRealTimeProcess > self.items.count - 1) {
        return;
    }
    _segmentRealTimeProcess = segmentRealTimeProcess;
    [self adjustSegmentContentRealTimeBySegmentProcess];
    [self adjustScrollViewContentOffsetRealTimeBySegmentProcess];
}

- (void)setItemNormalFont:(UIFont *)itemNormalFont {
    _itemNormalFont = itemNormalFont;
    [self setNeedsLayout];
}

- (void)setItemSelectFont:(UIFont *)itemSelectFont {
    _itemSelectFont = itemSelectFont;
    [self setNeedsLayout];
}

- (void)setItemNormalColor:(UIColor *)itemNormalColor {
    _itemNormalColor = itemNormalColor;
    [self updateNormalRGBA];
    [self setNeedsLayout];
}

- (void)setItemSelectColor:(UIColor *)itemSelectColor {
    _itemSelectColor = itemSelectColor;
    [self updateSelectlRGBA];
    [self setNeedsLayout];
}

- (void)setItemZoomScale:(CGFloat)itemZoomScale {
    _itemZoomScale = itemZoomScale;
    [self setNeedsLayout];
}

- (void)setSelectedItemIndex:(NSInteger)selectedItemIndex {
    if (_selectedItemIndex == selectedItemIndex) {
        LGYSegmentItemView *itemView = [self currentSelectItemView];
        // 该步骤防止拖动scorllViews使当前选中的itemView不是位于屏幕的中央
        // 所以每次滚动外部的scrollView停止时都会修正选中的itemView使其始终位于屏幕中心位置
        [self adjustscrollViewOffsetWithSelectedItemView:itemView animated:YES];
        return;
    }
    if (selectedItemIndex < self.itemViews.count) {
        LGYSegmentItemView *selectedTitleView = [self.itemViews objectAtIndex:selectedItemIndex];
        [self itemViewWasTapped:selectedTitleView];
    }else {
        NSAssert(NO, @"selectedItemIndex超过了items的总个数“%lu”",self.itemViews.count);
    }
}

- (LGYSegmentItemView *)currentSelectItemView {
    if (self.selectedItemIndex < self.itemViews.count) {
        return [self.itemViews objectAtIndex:self.selectedItemIndex];
    }else {
        return nil;
    }
}

#pragma mark - subViews
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        LGYSegmentScorllView *scrollView = [[LGYSegmentScorllView alloc] init];
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.scrollsToTop = NO; // 目的是不要影响到外界的scrollView置顶功能
        scrollView.bouncesZoom = NO;
        scrollView.bounces = YES;
        [self addSubview:scrollView];
        _scrollView = scrollView;
    }
    return _scrollView;
}

- (UIImageView *)tracker {
    if (!_tracker) {
        UIImageView *tracker = [[UIImageView alloc] init];
        tracker.layer.masksToBounds = YES;
        [self.scrollView addSubview:tracker];
        _tracker = tracker;
    }
    return _tracker;
}
@end



/**
关于tranform的一点说明
 UILabel *label = [[UILabel alloc] init];
 label.frame = CGRectMake(0, 100, 80, 30);
 
 label.transform = CGAffineTransformMakeScale(1.25, 0);
 NSLog(@"%@",NSStringFromCGRect(label.frame));// 打印你结果为(origin = (x = -10, y = 115), size = (width = 100, height = 0))
 即labelframe的width也被放大了
 此时要设置label的位置不能再通过frame要通过 （bouns + center组合实现）
 
*/
