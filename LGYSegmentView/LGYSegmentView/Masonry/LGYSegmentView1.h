//
//  LGYSegmentView.h
//  LGYSegmentView
//
//  Created by 李冠余 on 2017/6/14.
//  Copyright © 2017年 李冠余. All rights reserved.
//

//用collection实现特效标题尚未开发完成，要不断刷新collectionView改变文字效果，还是直接修改？？？？
#import <UIKit/UIKit.h>
@class LGYSegmentView1;
@protocol LGYSegmentViewDelegate <NSObject>
@required
- (void)segmentView:(LGYSegmentView1 *)segmentView didSelectedIndex:(NSInteger)index;
@end

@interface LGYSegmentView1 : UIView
@property (nonatomic, strong) NSArray <NSString *>*segmentTitles;
@property (nonatomic, strong) UIColor *segmentNormalColor;
@property (nonatomic, strong) UIColor *segmentSelectedColor;
@property (nonatomic, strong) UIFont *segmentNormalTitleFont;
@property (nonatomic, strong) UIFont *segmentSelectedTitleFont;
@property (nonatomic, assign) CGFloat segmentIndicatorHeight;
@property (nonatomic, weak) id<LGYSegmentViewDelegate> delegate;
@property(nonatomic,weak,readonly) UICollectionView *collectionView;
@property (nonatomic, weak,readonly) UIView * indicatorV;
@end


//*----------------------------------------------------------------------------------------------------------------------*/
@interface SegmentItem : NSObject

@property (nonatomic, copy) NSString *segmentTitle;
@property (nonatomic, strong) UIColor *curColor;
@property (nonatomic, strong) UIFont *curFont;

@end

//*----------------------------------------------------------------------------------------------------------------------*/
@interface SegmentItemCell : UICollectionViewCell

@property (nonatomic, strong) SegmentItem *segmentItem;

@end
