//
//  ViewController.m
//  Demo
//
//  Created by LGY on 2020/2/18.
//  Copyright © 2020 LGY. All rights reserved.
//

#import "ViewController.h"
#import "SubViewController.h"
#import <NSString+LGYSized.h>
#import <LGYSegmentView.h>

static inline float kh_status_bar_height() {
    if (@available(iOS 13.0, *)) {
        return [UIApplication sharedApplication].delegate.window.windowScene.statusBarManager.statusBarFrame.size.height;
    }else {
        return [UIApplication sharedApplication].statusBarFrame.size.height;
    }
}

@interface ViewController ()<UIScrollViewDelegate,LGYSegmentViewDelegate>
@property (nonatomic, weak) LGYSegmentView *sv;
@property (nonatomic, weak) UIScrollView *contentScrollView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    CGSize size = self.view.bounds.size;
        //    @[@"BJ",@"NewYork",@"losAngeles",@"ShangHai",@"London",@"Berlin",@"paris"]
    LGYSegmentView *sv = [LGYSegmentView segmentViewWithItems:@[@"上海中心",@"帝国大厦",@"东京铁塔",@"埃菲尔铁塔",@"伦敦眼",@"迪拜塔"] delegate:self];//,
    sv.contentAligmentType = LGYSegmentViewContentAligmentCenter;
    sv.tracker.layer.cornerRadius = 0;
//    sv.itemMaxWidth = 90;
    CGFloat statusBarHeight = kh_status_bar_height();
    sv.frame = CGRectMake(0, statusBarHeight, self.view.bounds.size.width, 44);
//    sv.itemSelectFont = [UIFont fontWithName:@"PingFangSC-Medium" size:15];
    sv.itemNormalFont =  [UIFont fontWithName:@"PingFangSC-Medium" size:15];
    sv.trackerHeight = 4;
    sv.trackerTitleWidthScale = 0.5;
    sv.itemZoomScale = 1.2;
    sv.contentLRSpacing = 20;
    sv.trackerStyle = LGYSegmentTrackerTitleAttachmentWidth;
    sv.itemSpacingCanAcceptHitTest = YES;
//    sv.trackerCornerRadius = sv.trackerHeight * 0.5;
    [self.view addSubview:sv];
    self.sv = sv;
    
    
    self.contentScrollView.frame = CGRectMake(0, CGRectGetMaxY(sv.frame), size.width, size.height - CGRectGetMaxY(sv.frame));
    self.contentScrollView.contentSize = CGSizeMake(size.width * sv.items.count, 0);
    
    
    for (NSInteger i = 0; i < sv.items.count; i++) {
        SubViewController *subVC = [[SubViewController alloc] initWithBgColor:i % 2 ? [UIColor greenColor] : [UIColor purpleColor]];
        subVC.title = [sv.items objectAtIndex:i];
        [self addChildViewController:subVC];
    }

    self.sv.selectedItemIndex = 0;

    
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor redColor];
    label.textColor = [UIColor whiteColor];
    label.font = sv.itemNormalFont;//[UIFont fontWithName:@"PingFangSC-Medium" size:21];
    NSString *text = @"temp中国人民国家";
    label.text = text;
    [self.view addSubview:label];
//    CGFloat width = [text lgy_widthWithFont:label.font];
//    CGFloat w1 = [text lgy_widthWithFont:sv.itemSelectFont];
    label.frame = CGRectMake(0, 100, 80, 30);
    label.transform = CGAffineTransformMakeScale(1.25, 0);
//    NSLog(@"%@",NSStringFromCGRect(label.frame));//(origin = (x = -10, y = 115), size = (width = 100, height = 0))
    
    
    NSArray *arr;
    NSLog(@"---t---- %ld",arr.count);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.sv.userInteractionEnabled = NO;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    self.sv.userInteractionEnabled = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!scrollView.isDragging && !scrollView.isDecelerating) {
        // 该条件是判断是直接设置偏移量出发而非手拖动scorllView 勿删
//        NSLog(@"+++++++++++");
        return;
    }
//    NSLog(@"----------");
    //用户拖拽移动segment
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat process = 1.0 * offsetX / scrollView.bounds.size.width;
    self.sv.segmentRealTimeProcess = process;
}

// 手拖动
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    NSLog(@"scrollViewDidEndDecelerating ------- ");
    //用户拖拽移动segment
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat process = 1.0 * offsetX / scrollView.bounds.size.width;
    self.sv.segmentRealTimeProcess = process;
}


- (void)segmentView:(LGYSegmentView *)segmentView selectItemIndex:(NSInteger)index {
/*如果该代理方法是由拖拽self.scrollView而触发，说明self.scrollView已经在用户手指的拖拽下而发生偏移，此时不需要再用代码去设置偏移量，否则在跟踪模式为SPPageMenuTrackerFollowingModeHalf的情况下，滑到屏幕一半时会有闪跳现象。闪跳是因为外界设置的scrollView偏移和用户拖拽产生冲突*/
    if (!self.contentScrollView.isDragging) {
        CGPoint offset = CGPointMake(index * self.contentScrollView.bounds.size.width, 0);
        [self.contentScrollView setContentOffset:offset animated:YES];
    }

    if (self.childViewControllers.count <= index) {
        return;
    }
    UIViewController *targetViewController = self.childViewControllers[index];
    // 如果已经加载过，就不再加载
    if ([targetViewController isViewLoaded]) return;
    
    CGSize svSize = self.contentScrollView.bounds.size;
    
    targetViewController.view.frame = CGRectMake(svSize.width * index, 0, svSize.width, svSize.height);
    [self.contentScrollView addSubview:targetViewController.view];
}


- (UIScrollView *)contentScrollView {
    if (!_contentScrollView) {
        UIScrollView *contentScrollView = [[UIScrollView alloc] init];
        contentScrollView.delegate = self;
        contentScrollView.pagingEnabled = self;
        contentScrollView.backgroundColor = [UIColor orangeColor];
        [self.view addSubview:contentScrollView];
        _contentScrollView = contentScrollView;
    }
    return _contentScrollView;
}
@end
