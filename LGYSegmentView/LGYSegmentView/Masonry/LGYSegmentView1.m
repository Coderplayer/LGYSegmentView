//
//  LGYSegmentView.m
//  LGYSegmentView
//
//  Created by 李冠余 on 2017/6/14.
//  Copyright © 2017年 李冠余. All rights reserved.
//

#import "LGYSegmentView1.h"
#import "Masonry.h"
#import "MJExtension.h"
static NSString *const SegmentItemCellID = @"SegmentItemCellID";

@interface LGYSegmentView1 ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionViewFlowLayout * flowLayout;
@property (nonatomic, strong) NSMutableArray<SegmentItem *> *segmentItems;
@end

@implementation LGYSegmentView1
{
    UICollectionView *_collectionView;
    UIView *_indicatorV;
    UIColor *_segmentNormalColor;
    UIColor *_segmentSelectedColor;
    
    UIFont *_segmentNormalTitleFont;
    UIFont *_segmentSelectedTitleFont;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUpsubViews];
    }
    return self;
}

- (void)setUpsubViews
{
    self.segmentItems = [NSMutableArray array];
    [self collectionView];
    [self indicatorV];
    NSIndexPath *indexP = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.collectionView selectItemAtIndexPath:indexP animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    CGFloat itemWidth = width / self.segmentItems.count;
    CGFloat itemheight = height - self.segmentIndicatorHeight;
    self.flowLayout.itemSize = CGSizeMake(itemWidth, itemheight);
    self.collectionView.frame = self.bounds;
}

#pragma mark - SubV
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        [collectionView registerClass:[SegmentItemCell class] forCellWithReuseIdentifier:SegmentItemCellID];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [self addSubview:collectionView];
        _collectionView = collectionView;
    }
    return _collectionView;
}

- (UIView *)indicatorV
{
    if (!_indicatorV) {
        UIView *indicatorV = [[UIView alloc] init];
        [self addSubview:indicatorV];
        _indicatorV = indicatorV;
    }
    return _indicatorV;
}

- (NSMutableArray<SegmentItem *> *)segmentItems
{
    if (!_segmentItems) {
        _segmentItems = [NSMutableArray array];
    }
    return _segmentItems;
}

#pragma mark - propertySetting
- (void)setSegmentTitles:(NSArray<NSString *> *)segmentTitles
{
    _segmentTitles = segmentTitles;
    
    self.segmentItems = nil;
    NSMutableArray *itemDicArr = [NSMutableArray array];
    for (NSString *title in segmentTitles) {
//        @property (nonatomic, copy) NSString *segmentTitle;
//        @property (nonatomic, strong) UIColor *curColor;
//        @property (nonatomic, strong) UIFont *curFont;
        NSMutableDictionary *itemDic = [NSMutableDictionary dictionary];
        itemDic[@"segmentTitle"] = title;
        itemDic[@"curColor"] = self.segmentNormalColor;
        itemDic[@"curFont"] = self.segmentNormalTitleFont;
        [itemDicArr addObject:itemDic];
    }
    self.segmentItems = [SegmentItem mj_objectArrayWithKeyValuesArray:itemDicArr];
    [self.collectionView reloadData];
    
}

- (void)setSegmentNormalColor:(UIColor *)segmentNormalColor
{
    _segmentNormalColor = segmentNormalColor;
    for (SegmentItem *item in self.segmentItems) {
        item.curColor = segmentNormalColor;
    }
    [self.collectionView reloadData];
}

- (UIColor *)segmentNormalColor
{
    return _segmentNormalColor ? _segmentNormalColor : [UIColor blackColor];
}

- (void)setSegmentSelectedColor:(UIColor *)segmentSelectedColor
{
    _segmentSelectedColor = segmentSelectedColor;
    [self.collectionView reloadData];
}

- (UIColor *)segmentSelectedColor
{
    return _segmentSelectedColor ? _segmentSelectedColor : self.segmentNormalColor;
}

- (void)setSegmentNormalTitleFont:(UIFont *)segmentNormalTitleFont
{
    _segmentNormalTitleFont = segmentNormalTitleFont;
    for (SegmentItem *item in self.segmentItems) {
        item.curFont = segmentNormalTitleFont;
    }
    [self.collectionView reloadData];
}

- (UIFont *)segmentNormalTitleFont
{
    return _segmentNormalTitleFont ? _segmentNormalTitleFont : [UIFont systemFontOfSize:18];
}

- (void)setSegmentSelectedTitleFont:(UIFont *)segmentSelectedTitleFont
{
    _segmentSelectedTitleFont = segmentSelectedTitleFont;
    [self.collectionView reloadData];
}

- (UIFont *)segmentSelectedTitleFont
{
    return _segmentSelectedTitleFont ? _segmentSelectedTitleFont : self.segmentNormalTitleFont;
}
#pragma mark - <UICollectionViewDelegate,UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.segmentItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SegmentItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SegmentItemCellID forIndexPath:indexPath];
    SegmentItem *item = self.segmentItems[indexPath.row];
    cell.segmentItem = item;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SegmentItem *item = self.segmentItems[indexPath.row];
    item.curColor = self.segmentSelectedColor;
    [self.collectionView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SegmentItem *item = self.segmentItems[indexPath.row];
    item.curColor = self.segmentNormalColor;
    [self.collectionView reloadData];
}

@end

//*----------------------------------------------------------------------------------------------------------------------*/
#pragma mark - SegmentItemCell
@interface SegmentItemCell()
@property (nonatomic, weak) UILabel *titleL;
@end

@implementation SegmentItemCell
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UILabel *titleL = [[UILabel alloc] init];
        [self.contentView addSubview:titleL];
        _titleL = titleL;
        [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (void)setSegmentItem:(SegmentItem *)segmentItem
{
    _segmentItem = segmentItem;
    self.titleL.text = segmentItem.segmentTitle;
    self.titleL.textColor = segmentItem.curColor;
    self.titleL.font = segmentItem.curFont;
}
@end



//*----------------------------------------------------------------------------------------------------------------------*/
#pragma mark - SegmentItem
@implementation SegmentItem

@end


















