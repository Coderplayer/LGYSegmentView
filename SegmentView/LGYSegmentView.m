//
//  LGYSegmentView.m
//  LGYSegmentView
//
//  Created by LGY on 2019/5/28.
//  Copyright © 2019 LGY. All rights reserved.
//

#import "LGYSegmentView.h"
#import "LGYSegmentItemView.h"

#define kScrollViewContentOffset @"contentOffset"

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
@property (nonatomic, strong)     UIScrollView *itemsScrollView;
@property (nonatomic, weak)     UIImageView *tracker;
@property (nonatomic, strong)   NSArray *items;
@property (nonatomic, strong)   NSMutableArray *itemViews;
//@property (nonatomic, copy)     NSArray *itemWidths;
@property (nonatomic, weak)     LGYSegmentItemView *selectedItemView;

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
        _itemMaxWidth = 0;
        _itemTitleFont = [UIFont systemFontOfSize:16];
        self.itemNormaldColor = [UIColor blackColor];
        self.itemSelectedColor = [UIColor redColor];
        _itemSpacing = 30;
        _trackerHeight = 3.0;
        _itemZoomScale = 1.0;
        _selectedItemIndex = NSNotFound;
        [self itemsScrollView];
        [self tracker];
        self.contentLRSpacing = _itemSpacing * 0.5;
        self.trackerColor = [UIColor redColor];
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
        [self refreshItemsViews];
    }
    return self;
}

- (void)updateItems:(NSArray<NSString *> *)items {
    self.items = items;
    [self.itemViews performSelector:@selector(removeFromSuperview)];
    [self.itemViews removeAllObjects];
    
    [self refreshItemsViews];
    _selectedItemIndex = NSNotFound;
    [self setNeedsLayout];
}

- (void)refreshItemsViews {
    for (NSString *title in self.items) {
        LGYSegmentItemView *itemView = [[LGYSegmentItemView alloc] initWithTitle:title];
        [itemView addTarget:self action:@selector(itemViewWasTapped:)];
        [self.itemsScrollView addSubview:itemView];
        [self.itemViews addObject:itemView];
    }
}

- (void)setItemCanAcceptTouch:(BOOL)itemCanAcceptTouch {
    _itemCanAcceptTouch = itemCanAcceptTouch;
    self.itemsScrollView.userInteractionEnabled = itemCanAcceptTouch;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize size = self.bounds.size;
    self.itemsScrollView.frame = self.bounds;
    NSMutableArray *itemWidths = [NSMutableArray array];
    
    if (self.selectedItemIndex == NSNotFound) {// 当segment没有被选中标签时，设置改index要在布局完成前否则修改transform之类的会有问题
        self.selectedItemIndex = 0; // 如果未设置初始选择标签则默认选中索引0
    }
    
    CGFloat tempContentWidth = (self.itemViews.count - 1) * self.itemSpacing;
    for (NSInteger i = 0; i < self.itemViews.count; i++) {
        LGYSegmentItemView *itemView = [self.itemViews objectAtIndex:i];
        itemView.font = self.itemTitleFont;
        itemView.textColor = self.itemNormaldColor;
        CGFloat titleWidth = [itemView itemTitleWidth];
        if (_itemMaxWidth > 0 && titleWidth > _itemMaxWidth) {
            titleWidth = _itemMaxWidth;
        }
        tempContentWidth += titleWidth;
        [itemWidths addObject:@(titleWidth)];
        
        if (self.itemSpacingCanAcceptHitTest) {
            CGFloat hitSpace = self.itemSpacing * 0.5;
            itemView.hitTestEdgeInsets = UIEdgeInsetsMake(0, -hitSpace, 0, -hitSpace);
        }else {
            itemView.hitTestEdgeInsets = UIEdgeInsetsZero;
        }
    }
//    self.itemWidths = [itemWidths copy];
    
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
        CGFloat titleWidth = [[itemWidths objectAtIndex:i] floatValue];
        itemView.frame = CGRectMake(x, 0, titleWidth, size.height - self.trackerHeight);
        x += titleWidth +  self.itemSpacing;
        lastItemView = itemView;
    }
    
    self.tracker.frame = CGRectMake(0, size.height - self.trackerHeight, 0.1, self.trackerHeight);
    self.tracker.layer.cornerRadius = self.trackerHeight * 0.5;
    self.tracker.layer.masksToBounds = YES;
    CGFloat contentWidth = CGRectGetMaxX(lastItemView.frame) + trulyLRSpacing;
    self.itemsScrollView.contentSize = CGSizeMake(contentWidth, 0);
    
    if (self.selectedItemIndex < self.itemViews.count) {
        LGYSegmentItemView *itemView = [self.itemViews objectAtIndex:self.selectedItemIndex];
        itemView.textColor = self.itemSelectedColor;
        itemView.transform = CGAffineTransformMakeScale(self.itemZoomScale, self.itemZoomScale);
        [self resetTrackerFrameWithSelectedItemView:itemView];
        [self adjustItemsScrollViewOffsetWithSelectedItemView:itemView animated:NO];
    }
}

#pragma mark - delegate
- (void)delegatePerformMethodWithSelectedIndex:(NSInteger)selectedIndex {
    if (self.delegate && [self.delegate respondsToSelector:@selector(segmentView:selectItemIndex:)]) {
        [self.delegate segmentView:self selectItemIndex:selectedIndex];
    }
}
#pragma mark - segment内部跳转控制
/** 调整追踪器的位置 */
- (void)resetTrackerFrameWithSelectedItemView:(LGYSegmentItemView *)selectedItemView {
    CGFloat trackerW = selectedItemView.bounds.size.width;
    CGFloat trackerH = self.trackerHeight;
    self.tracker.bounds = CGRectMake(0, 0, trackerW, trackerH);
    CGFloat centerY = self.itemsScrollView.bounds.size.height - self.trackerHeight * 0.5;
    self.tracker.center = CGPointMake(selectedItemView.center.x, centerY);
    self.tracker.transform = CGAffineTransformMakeScale(self.itemZoomScale, 1);
}

/** 动态调整itemsScrollView的偏移量 */
- (void)adjustItemsScrollViewOffsetWithSelectedItemView:(LGYSegmentItemView *)itemView animated:(BOOL)animated {
    if (CGRectEqualToRect(self.itemsScrollView.bounds, CGRectZero)) {
        return;
    }
    
    CGPoint centerInSegmentView = itemView.center;
    CGFloat offSetX = centerInSegmentView.x - CGRectGetWidth(self.itemsScrollView.bounds) * 0.5;
    CGFloat maxOffsetX = self.itemsScrollView.contentSize.width - CGRectGetWidth(self.itemsScrollView.bounds);
    if (offSetX <= 0 || maxOffsetX <= 0) {
        offSetX = 0;
    } else if (offSetX > maxOffsetX){
        offSetX = maxOffsetX;
    }
    
    [self.itemsScrollView setContentOffset:CGPointMake(offSetX, 0) animated:animated];
}

- (void)adjustSegmentContentRealTimeBySegmentProcess {
    CGFloat segmentRealTimeProcess = self.segmentRealTimeProcess;
    
    CGFloat progress = segmentRealTimeProcess - floor(segmentRealTimeProcess);
    // 停止滑动选中某一个标签
    if (self.selectedItemIndex == NSNotFound) {
        return;
    }
    
    NSInteger previousIndex = floor(segmentRealTimeProcess);
    LGYSegmentItemView *previousItemView = [self.itemViews objectAtIndex:previousIndex];
    
    
    CGRect newFrame = self.tracker.frame;
    CGPoint newCenter = self.tracker.center;
    
    if (progress) {// 前后不是同一个即滚动的位置在两个item中间
        
        NSInteger nextIndex     = ceil(segmentRealTimeProcess);
        LGYSegmentItemView *nextItemView     = [self.itemViews objectAtIndex:nextIndex];
        
        // 2个item之间的距离
        CGFloat xDistance = nextItemView.center.x - previousItemView.center.x;
        CGFloat detaItemViewWith = nextItemView.frame.size.width - previousItemView.frame.size.width;
        
        if (self.trackerStyle == LGYSegmentTrackerEqualTitleWith) {
            newCenter.x = previousItemView.center.x + xDistance * progress;
            newFrame.size.width = previousItemView.frame.size.width + detaItemViewWith * progress;
            self.tracker.frame = newFrame;
            self.tracker.center = newCenter;
        }else {
            CGFloat oriTrackerX = previousItemView.frame.origin.x;
            CGFloat trackerMaxWitdh = CGRectGetMaxX(nextItemView.frame) - CGRectGetMinX(previousItemView.frame);
            CGFloat rDistance = CGRectGetMaxX(nextItemView.frame) - CGRectGetMaxX(previousItemView.frame);
            if (progress < 0.5) { //使用右间距，trackert右边变长
                newFrame.origin.x = previousItemView.frame.origin.x;
                newFrame.size.width = previousItemView.frame.size.width + rDistance * progress * 2;
            }else {
                CGFloat lDistance = CGRectGetMinX(nextItemView.frame) - CGRectGetMinX(previousItemView.frame);
                newFrame.origin.x = oriTrackerX + lDistance * (progress - 0.5) * 2;
                newFrame.size.width = trackerMaxWitdh - lDistance * (progress - 0.5) * 2;
            }
            self.tracker.frame = newFrame;
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
        newCenter.x = previousItemView.center.x;
        newFrame.size.width = previousItemView.frame.size.width;
        self.tracker.frame = newFrame;
        self.tracker.center = newCenter;
        
        self.selectedItemIndex = previousIndex;
        if (!CGRectEqualToRect(previousItemView.frame, CGRectZero)) {
            previousItemView.transform = CGAffineTransformMakeScale(self.itemZoomScale, self.itemZoomScale);
        }
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
    NSArray *components = [self getRGBForColor:self.itemNormaldColor];
    self.normalR = [components[0] floatValue];
    self.normalG = [components[1] floatValue];
    self.normalB = [components[2] floatValue];
    self.normalA = [components[3] floatValue];
}

- (void)updateSelectlRGBA {
    NSArray *components = [self getRGBForColor:self.itemSelectedColor];
    self.selectR = [components[0] floatValue];
    self.selectG = [components[1] floatValue];
    self.selectB = [components[2] floatValue];
    self.selectA = [components[3] floatValue];
}
#pragma mark - 点击事件 segment was tapped
- (void)itemViewWasTapped:(UITapGestureRecognizer *)tap {
    LGYSegmentItemView *itemView = (LGYSegmentItemView *)tap.view;
    
    NSInteger index = [self.itemViews indexOfObject:itemView];
    if (_selectedItemIndex == index) {
        return;
    }
    
    _selectedItemIndex = index;
    _segmentRealTimeProcess = index;
    [UIView animateWithDuration:0.25 animations:^{
        for (LGYSegmentItemView *subItemView in self.itemViews) {
            if (![itemView isEqual:subItemView]) {
                subItemView.transform = CGAffineTransformIdentity;
                subItemView.textColor = self.itemNormaldColor;
            }
        }
        
        if (!CGRectEqualToRect(itemView.frame, CGRectZero)) { // 布局尚未完成
            [self resetTrackerFrameWithSelectedItemView:itemView];
            itemView.transform = CGAffineTransformMakeScale(self.itemZoomScale, self.itemZoomScale);
        }
    }];
    
    itemView.textColor = self.itemSelectedColor;
    [self adjustItemsScrollViewOffsetWithSelectedItemView:itemView animated:YES];
    [self delegatePerformMethodWithSelectedIndex:_selectedItemIndex];
}

#pragma mark - 属性设置
- (void)setItems:(NSArray *)items {
    _items = [items copy];
    self.tracker.hidden = (items.count < 2); //只有一个标题隐藏指示器
}

- (void)setTrackerHeight:(CGFloat)trackerHeight {
    _trackerHeight = trackerHeight;
    [self setNeedsLayout];
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
}

- (void)setItemTitleFont:(UIFont *)itemTitleFont {
    _itemTitleFont = itemTitleFont;
    [self setNeedsLayout];
}

- (void)setItemNormaldColor:(UIColor *)itemNormaldColor {
    _itemNormaldColor = itemNormaldColor;
    [self updateNormalRGBA];
    
    LGYSegmentItemView *selectItemView = [self currentSelectItemView];
    for (LGYSegmentItemView *itemView in self.itemViews) {
        if (![itemView isEqual:selectItemView]) {
            itemView.textColor = itemNormaldColor;
        }
    }
}

- (void)setItemSelectedColor:(UIColor *)itemSelectedColor {
    _itemSelectedColor = itemSelectedColor;
    [self updateSelectlRGBA];
    [self currentSelectItemView].textColor = itemSelectedColor;
}

- (void)setItemZoomScale:(CGFloat)itemZoomScale {
    _itemZoomScale = itemZoomScale;
    [self setNeedsLayout];
}

- (void)setSelectedItemIndex:(NSInteger)selectedItemIndex {
    if (_selectedItemIndex == selectedItemIndex) {
        return;
    }
    if (selectedItemIndex < self.itemViews.count) {
        LGYSegmentItemView *selectedTitleView = [self.itemViews objectAtIndex:selectedItemIndex];
        [self itemViewWasTapped:selectedTitleView.tap];
    }else {
        NSAssert(NO, @"selectedItemIndex超过了items的总个数“%ld”",self.items.count);
    }
}

- (LGYSegmentItemView *)currentSelectItemView {
    if (self.selectedItemIndex < self.items.count) {
        return [self.itemViews objectAtIndex:self.selectedItemIndex];
    }else {
        return nil;
    }
}

#pragma mark - subViews
- (UIScrollView *)itemsScrollView {
    if (!_itemsScrollView) {
        LGYSegmentScorllView *itemsScrollView = [[LGYSegmentScorllView alloc] init];
        itemsScrollView.showsVerticalScrollIndicator = NO;
        itemsScrollView.showsHorizontalScrollIndicator = NO;
        itemsScrollView.scrollsToTop = NO; // 目的是不要影响到外界的scrollView置顶功能
        itemsScrollView.bouncesZoom = NO;
        itemsScrollView.bounces = YES;
        [self addSubview:itemsScrollView];
        _itemsScrollView = itemsScrollView;
    }
    return _itemsScrollView;
}

- (UIImageView *)tracker {
    if (!_tracker) {
        UIImageView *tracker = [[UIImageView alloc] init];
        [self.itemsScrollView addSubview:tracker];
        _tracker = tracker;
    }
    return _tracker;
}

- (NSMutableArray *)itemViews {
    if (!_itemViews) {
        _itemViews = [NSMutableArray array];
    }
    return _itemViews;
}

@end






/* 外界添加控制器view的srollView，pageMenu会监听该scrollView的滚动状况，让跟踪器时刻跟随此scrollView滑动；所谓的滚动状况，是指手指拖拽滚动，非手指拖拽不算
//@property (nonatomic, strong)   UIScrollView *linkScrollView;
- (void)setLinkScrollView:(UIScrollView *)linkScrollView {
    if (linkScrollView) {
        if ([_linkScrollView isEqual:linkScrollView]) {
            return;
        }
        
        if (_linkScrollView) {
            [linkScrollView removeObserver:self forKeyPath:kScrollViewContentOffset];
        }
        
        _linkScrollView = linkScrollView;
        [linkScrollView addObserver:self forKeyPath:kScrollViewContentOffset options:NSKeyValueObservingOptionNew context:nil];
    }else {
        if (_linkScrollView) {
            [linkScrollView removeObserver:self forKeyPath:kScrollViewContentOffset];
            _linkScrollView = nil;
        }
    }
}
#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.linkScrollView) {
        if ([keyPath isEqualToString:kScrollViewContentOffset]) {
            // 当scrolllView滚动时,让跟踪器跟随scrollView滑动
            //            [self prepareMoveTrackerFollowScrollView:self.linkScrollView];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

*/
