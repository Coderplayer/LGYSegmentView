//
//  LGYSegmentView.m
//  LGYSegmentView
//
//  Created by 李冠余 on 2017/6/15.
//  Copyright © 2017年 李冠余. All rights reserved.
//

#import "LGYSegmentView.h"
#import "LGYLabel.h"

#define  TitleDefaultMinWidth 100

@interface LGYSegmentView()
@property (nonatomic, weak) UIView * indicatorV;
@property (nonatomic, weak) UIView *titlesView;
// 底部指示器父视图,指示器frame修改时会反过来调用父控件的layoutSubviews
@property (nonatomic, weak) UIScrollView *backScrollView;

@end
@implementation LGYSegmentView
{
    UIFont *_segmentTitleFont;
    CGFloat _titleSelectedEnlageScale;
    NSInteger _currentSelIndex;
}

+ (LGYSegmentView *)segmentViewWithTitles:(NSArray *)titles withDelegate:(id<LGYSegmentViewDelegate>)delegate
{
    LGYSegmentView *segmentV = [[self alloc] init];
    segmentV.titles = titles;
    segmentV.delegate = delegate;
    return segmentV;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUpSubviews];
    }
    return self;
}

- (void)setUpSubviews {
    [self backScrollView];
    [self titlesView];
}

- (CGFloat)indicatorVHeight {
    return (_indicatorVHeight > 0) ? _indicatorVHeight : 4.0;
}

- (void)setIndicatorVColor:(UIColor *)indicatorVColor {
    _indicatorVColor = indicatorVColor;
    self.indicatorV.backgroundColor = indicatorVColor;
}

- (void)setSegmentSelectedColor:(UIColor *)segmentSelectedColor {
    _segmentSelectedColor = segmentSelectedColor;
    self.indicatorV.backgroundColor = segmentSelectedColor;
    for (LGYLabel * label in self.titlesView.subviews) {
        label.selectedColor = segmentSelectedColor;
    }
}

- (void)setSegmentNormalColor:(UIColor *)segmentNormalColor {
    _segmentNormalColor = segmentNormalColor;
    for (LGYLabel * label in self.titlesView.subviews) {
        label.normalColor = segmentNormalColor;
    }
}

- (void)setSegmentTitleFont:(UIFont *)segmentTitleFont {
    _segmentTitleFont = segmentTitleFont;
    for (LGYLabel * label in self.titlesView.subviews) {
        label.font = segmentTitleFont;
    }
}

- (void)setTitleSelectedEnlageScale:(CGFloat)titleSelectedEnlageScale {
    _titleSelectedEnlageScale = titleSelectedEnlageScale;
    for (LGYLabel * label in self.titlesView.subviews) {
        label.enlageScale = titleSelectedEnlageScale;
    }
}

- (void)setTitles:(NSMutableArray *)titles {
    if (titles.count <= 0) {
        return;
    }
    self.indicatorV.hidden = (titles.count <= 1);
    _titles = [titles copy];
    for (NSString *title in titles) {
        LGYLabel *label = [[LGYLabel alloc] init];
        label.text = title;
        if (titles.count > 1) {
           [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelClick:)]];
        }        
        [self.titlesView addSubview:label];
    }
    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize selfSize = self.bounds.size;
    self.backScrollView.frame = self.bounds;
    NSInteger count = _titlesView.subviews.count;

    CGFloat atitleLW = 0;
    if (_titleWidth > 0) {
        atitleLW = self.titleWidth;
    }else{
        CGFloat averageWidth = (1.0 * selfSize.width / self.titles.count);
        atitleLW = (averageWidth < TitleDefaultMinWidth) ? TitleDefaultMinWidth : averageWidth;
    } 
    CGFloat atitleLH = selfSize.height - self.indicatorVHeight;
    CGFloat contentW = atitleLW * count;
    
    _titlesView.frame = CGRectMake(0, 0, contentW, atitleLH);
    _backScrollView.contentSize = CGSizeMake(contentW, 0);
    _backScrollView.scrollEnabled = (contentW > selfSize.width);
    
    for (NSInteger i = 0; i < count; i ++) {
        
        LGYLabel *label = (LGYLabel *)self.titlesView.subviews[i];
        CGFloat labelX = i * atitleLW;
        label.frame = CGRectMake(labelX, 0, atitleLW, atitleLH);

        if (i == 0) { // 最前面的label
            label.scale = 1.0;
            _indicatorV.layer.cornerRadius = self.indicatorVHeight * 0.5;
            _indicatorV.layer.masksToBounds = YES;
            _indicatorV.frame = CGRectMake(label.titleOriX ,selfSize.height - self.indicatorVHeight, label.enlageTitleWidth, self.indicatorVHeight);
        }
    }

    [self updateTitleAtIndex:_currentSelIndex];
}

- (UIView *)indicatorV {
    if (!_indicatorV) {
        UIView *indicatorV = [[UIView alloc] init];
        indicatorV.backgroundColor = [UIColor redColor];
        [self.backScrollView addSubview:indicatorV];
        _indicatorV = indicatorV;
    }
    return _indicatorV;
}

- (UIView *)titlesView {
    if (!_titlesView) {
        UIView *titlesView = [[UIView alloc] init];
        [self.backScrollView addSubview:titlesView];
        _titlesView = titlesView;
    }
    return _titlesView;
}

- (UIScrollView *)backScrollView {
    if (!_backScrollView) {
        UIScrollView *backScrollView = [[UIScrollView alloc] init];
        backScrollView.showsVerticalScrollIndicator = NO;
        backScrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:backScrollView];
        _backScrollView = backScrollView;
    }
    return _backScrollView;
}

#pragma mark - 计算子空间位置及形变
- (void)fatherVCContentscrollViewDidScrollScale:(CGFloat)scale {
    if (scale <= 0 || scale >= self.titles.count - 1) return;
    // 获得需要操作的左边label
    NSInteger leftIndex = scale;
    LGYLabel *leftLabel = self.titlesView.subviews[leftIndex];
    
    // 获得需要操作的右边label
    NSInteger rightIndex = leftIndex + 1;
    LGYLabel *rightLabel = (rightIndex == self.titlesView.subviews.count) ? nil : self.titlesView.subviews[rightIndex];
    
    // 右边比例
    CGFloat rightScale = scale - leftIndex;
    // 左边比例
    CGFloat leftScale = 1 - rightScale;
    
    // 设置label的比例
    leftLabel.scale = leftScale;
    rightLabel.scale = rightScale;
    
    // 设置indicatorV的frame
    CGRect oriF = _indicatorV.frame;
    CGFloat width = [self caculateIndicatorVWidth:scale];
    oriF.size.width = width;
    CGFloat newX = [self caculateIndicatorVOriX:scale];
    oriF.origin.x = newX;
    _indicatorV.frame = oriF;
}

- (void)updateSelectedSegmentTitleScrollToCenter:(LGYLabel *)selLabel selIndex:(NSInteger)selIndex
{
    if (self.backScrollView.scrollEnabled) {
        CGFloat width = self.backScrollView.frame.size.width;
        CGPoint titleOffset = self.backScrollView.contentOffset;
        titleOffset.x = selLabel.center.x - width * 0.5;
        // 左边超出处理
        if (titleOffset.x < 0) titleOffset.x = 0;
        // 右边超出处理
        CGFloat maxTitleOffsetX = self.backScrollView.contentSize.width - width;
        if (titleOffset.x > maxTitleOffsetX) titleOffset.x = maxTitleOffsetX;
        
        [self.backScrollView setContentOffset:titleOffset animated:YES];
    }
}

- (void)fatherVCContentscrollViewDidEndScrollingAnimationIndex:(NSInteger)index {
    _currentSelIndex = index;
    // 让对应的顶部标题居中显示
    LGYLabel *label = self.titlesView.subviews[index];
    
    [self updateSelectedSegmentTitleScrollToCenter:label selIndex:index];
    // 让其他label回到最初的状态
    for (LGYLabel *otherLabel in self.titlesView.subviews) {
        if (otherLabel != label) otherLabel.scale = 0.0;
    }
}

- (CGFloat)caculateIndicatorVWidth:(CGFloat)scale {
    NSInteger leftIndex = scale;
    NSInteger rightIndex = leftIndex + 1;

    LGYLabel *leftLabel = self.titlesView.subviews[leftIndex];
    CGFloat leftTW = leftLabel.enlageTitleWidth;
    if (rightIndex >= self.titlesView.subviews.count) {
        return leftTW;
    }
    
    LGYLabel *rightLabel = self.titlesView.subviews[rightIndex];
    CGFloat rightTW = rightLabel.enlageTitleWidth;
    CGFloat deltaW = (rightTW - leftTW) * (scale - leftIndex);
    CGFloat indicatorVWidth = leftTW + deltaW;
    
    return indicatorVWidth;
}

- (CGFloat)caculateIndicatorVOriX:(CGFloat)scale {
    NSInteger leftIndex = scale;
    NSInteger rightIndex = leftIndex + 1;
    
    LGYLabel *leftLabel = self.titlesView.subviews[leftIndex];
    CGFloat leftTX = leftLabel.titleOriX;
    if (rightIndex >= self.titlesView.subviews.count) {
        return leftTX;
    }
    LGYLabel *rightLabel = self.titlesView.subviews[rightIndex];
    CGFloat rightTX = rightLabel.titleOriX;
    CGFloat deltaX = (rightTX - leftTX) * (scale - leftIndex);
    CGFloat indicatorVNewX = leftTX + deltaX;
    return indicatorVNewX;
}

#pragma mark - 点击事件处理
/**
 * 监听顶部label点击
 */
- (void)labelClick:(UITapGestureRecognizer *)tap
{
    NSInteger index = [self.titlesView.subviews indexOfObject:tap.view];
    _currentSelIndex = index;
    LGYLabel *label = (LGYLabel *)tap.view;
    CGFloat titleW = label.enlageTitleWidth;
    CGRect oriFrame = self.indicatorV.frame;
    oriFrame.size.width = titleW;
    oriFrame.origin.x = label.titleOriX;
    
    [self updateSelectedSegmentTitleScrollToCenter:label selIndex:index];
    
    [UIView animateWithDuration:0.25 animations:^{
        _indicatorV.frame = oriFrame;
        // 让其他label回到最初的状态
        for (LGYLabel *otherLabel in self.titlesView.subviews) {
            if (otherLabel != tap.view) otherLabel.scale = 0.0;
        }
        
        label.scale = 1.0;
    }];
    
    if ([self.delegate respondsToSelector:@selector(segmentView:didSelectedTitleIndex:)]) {
        [self.delegate segmentView:self didSelectedTitleIndex:index];
    }
}

- (void)selectTitleAtIndex:(NSInteger)selIndex
{
    _currentSelIndex = selIndex;
    [self layoutIfNeeded];
}

- (void)updateTitleAtIndex:(NSInteger)selIndex {

    if (selIndex >= self.titlesView.subviews.count) {
        NSLog(@"超出点击标题");
        return;
    }
    _currentSelIndex = selIndex;
    LGYLabel *label = (LGYLabel *)[self.titlesView.subviews objectAtIndex:selIndex];
    NSInteger index = selIndex;
    CGFloat titleW = label.enlageTitleWidth;
    CGRect oriFrame = self.indicatorV.frame;
    oriFrame.size.width = titleW;
    oriFrame.origin.x = label.titleOriX;
    
    [self updateSelectedSegmentTitleScrollToCenter:label selIndex:index];
    
    //    [UIView animateWithDuration:0.25 animations:^{
    _indicatorV.frame = oriFrame;
    // 让其他label回到最初的状态
    for (LGYLabel *otherLabel in self.titlesView.subviews) {
        if (otherLabel != label) otherLabel.scale = 0.0;
    }
    label.scale = 1.0;
    //    }];
    
    if ([self.delegate respondsToSelector:@selector(segmentView:didSelectedTitleIndex:)]) {
        [self.delegate segmentView:self didSelectedTitleIndex:index];
    }
}
@end
