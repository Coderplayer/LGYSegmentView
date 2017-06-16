//
//  ViewController.m
//  LGYSegmentView
//
//  Created by 李冠余 on 2017/6/13.
//  Copyright © 2017年 李冠余. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "ViewController1.h"
#import "ViewController2.h"
#import "ViewController3.h"
#import "LGYLabel.h"
#import "LGYSegmentView.h"
#define kSCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define kSCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
@interface ViewController ()<UIScrollViewDelegate,LGYSegmentViewDelegate>
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, weak) LGYSegmentView * segmentView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpSubVCs];
    
    [self setUpSubViews];
    [self scrollViewDidEndScrollingAnimation:self.contentScrollView];
}



- (void)setUpSubVCs
{
    ViewController1 *vc1 = [[ViewController1 alloc] init];
    vc1.title = @"第一个控";
    [self addChildViewController:vc1];
    
    ViewController2 *vc2 = [[ViewController2 alloc] init];
    vc2.title = @"第二";
    [self addChildViewController:vc2];
    
    ViewController3 *vc3 = [[ViewController3 alloc] init];
    vc3.title = @"第三个控";
    [self addChildViewController:vc3];
    

    ViewController1 *vc4 = [[ViewController1 alloc] init];
    vc4.title = @"第4个控";
    [self addChildViewController:vc4];
    
    ViewController2 *vc5 = [[ViewController2 alloc] init];
    vc5.title = @"第5";
    [self addChildViewController:vc5];
    
    ViewController3 *vc6 = [[ViewController3 alloc] init];
    vc6.title = @"第6个控";
    [self addChildViewController:vc6];
    
    ViewController1 *vc7 = [[ViewController1 alloc] init];
    vc7.title = @"第7个控";
    [self addChildViewController:vc7];
    
    ViewController2 *vc8 = [[ViewController2 alloc] init];
    vc8.title = @"第8";
    [self addChildViewController:vc8];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
    if (scrollView != self.contentScrollView) {
        return;
    }
    CGFloat width = scrollView.frame.size.width;
    CGFloat height = scrollView.frame.size.height;
    CGFloat offsetX = scrollView.contentOffset.x;
    
    NSInteger index = offsetX / width;
    
    [self.segmentView fatherVCContentscrollViewDidEndScrollingAnimationIndex:index];
    
    UIViewController *baseVC = self.childViewControllers[index];
    if ([baseVC isViewLoaded]) {
        return;
    }
    baseVC.view.frame = CGRectMake(offsetX, 0, width, height);
    [scrollView addSubview:baseVC.view];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView != self.contentScrollView) {
        return;
    }
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

/**
 * 只要scrollView在滚动，就会调用
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat scale = scrollView.contentOffset.x / scrollView.frame.size.width;
    [self.segmentView fatherVCContentscrollViewDidScrollScale:scale];
}



#pragma mark - setUpSubViews
- (void)setUpSubViews
{
    UIScrollView *contentScrollView = [[UIScrollView alloc] init];
    contentScrollView.backgroundColor = [UIColor colorWithRed:190/255.0 green:200/255.0 blue:230/255.0 alpha:1.0];
    contentScrollView.delegate = self;
    contentScrollView.showsVerticalScrollIndicator = NO;
    contentScrollView.showsHorizontalScrollIndicator = NO;
    contentScrollView.pagingEnabled = YES;
    contentScrollView.frame = CGRectMake(0, 64, kSCREEN_WIDTH, kSCREEN_HEIGHT- 64);
    [self.view addSubview:contentScrollView];
    _contentScrollView = contentScrollView;
    
    NSInteger subVCCount = self.childViewControllers.count;
    self.contentScrollView.contentSize = CGSizeMake(subVCCount * kSCREEN_WIDTH, 0);
    [self segmentView];
}
- (LGYSegmentView *)segmentView
{
    if (!_segmentView) {
        NSArray *titles = @[@"第一个控",@"第二",@"第三个控",@"第4个控",@"第5",@"第6个控",@"第7个控",@"第8"];
        LGYSegmentView *segmentView = [LGYSegmentView segmentViewWithTitles:titles withDelegate:self];
        segmentView.frame = CGRectMake(0, 0, kSCREEN_WIDTH, 44);
        segmentView.titleSelectedEnlageScale = 0.2;
        segmentView.segmentTitleFont = [UIFont systemFontOfSize:20];
        segmentView.indicatorVHeight = 4;
        segmentView.segmentSelectedColor = [UIColor colorWithRed:244/255.0 green:36/255.0 blue:64/255.0 alpha:1.0];
        segmentView.segmentNormalColor = [UIColor colorWithRed:7/255.0 green:7/255.0 blue:7/255.0 alpha:1.0];
//        segmentView.indicatorVColor = [UIColor greenColor];
        self.navigationItem.titleView = segmentView;
        _segmentView = segmentView;
    }
    return _segmentView;
}

- (void)segmentView:(LGYSegmentView *)segementView didSelectedTitleIndex:(NSInteger)index
{
    UIViewController *baseVC = self.childViewControllers[index];
    CGPoint offset = self.contentScrollView.contentOffset;
    offset.x = index * self.contentScrollView.frame.size.width;
    
    CGFloat width = self.contentScrollView.frame.size.width;
    CGFloat height = self.contentScrollView.frame.size.height;
    
    [self.contentScrollView setContentOffset:offset animated:NO];
    baseVC.view.frame = CGRectMake(offset.x, 0, width, height);
    [self.contentScrollView addSubview:baseVC.view];
}

@end
