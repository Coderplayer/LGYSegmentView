//
//  ViewController.m
//  LGYSegmentView
//
//  Created by LGY on 2019/5/28.
//  Copyright © 2019 LGY. All rights reserved.
//

#import "ViewController.h"
#import "LGYSegmentView.h"
#import "SubViewController.h"
@interface ViewController ()<UIScrollViewDelegate,LGYSegmentViewDelegate>
@property (nonatomic, weak) LGYSegmentView *sv;
@property (nonatomic, weak) UIScrollView *contentScrollView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGSize size = self.view.bounds.size;
    LGYSegmentView *sv = [LGYSegmentView segmentViewWithItems:@[@"BJ",@"NewYork",@"losAngeles",@"ShangHai",@"London",@"Berlin",@"paris"] delegate:self];
    sv.frame = CGRectMake(0, 20, self.view.bounds.size.width, 44);
    sv.itemTitleFont = [UIFont fontWithName:@"PingFangSC-Medium" size:25];// [UIFont boldSystemFontOfSize:25];
    sv.trackerHeight = 4;
//    sv.backgroundColor = [UIColor redColor];
    sv.itemZoomScale = 1.2;
    sv.trackerStyle = LGYSegmentTrackerAttachmentTitle;
    sv.itemSpacingCanAcceptHitTest = YES;
    [self.view addSubview:sv];
    self.sv = sv;
    
    self.contentScrollView.frame = CGRectMake(0, 64, size.width, size.height - 64);
    self.contentScrollView.contentSize = CGSizeMake(size.width * sv.items.count, 0);
    
    
    for (NSInteger i = 0; i < sv.items.count; i++) {
        SubViewController *subVC = [[SubViewController alloc] initWithBgColor:i % 2 ? [UIColor greenColor] : [UIColor purpleColor]];
        subVC.title = [sv.items objectAtIndex:i];
        [self addChildViewController:subVC];
    }
    
//    self.sv.selectedItemIndex = 0;
    
    if (sv.selectedItemIndex < self.childViewControllers.count) {
        [self.contentScrollView setContentOffset:CGPointMake(size.width * 3, 0) animated:NO];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    self.sv.itemZoomScale = 1.4;
}

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//
//}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!scrollView.isDragging && !scrollView.isDecelerating) {
        return;
    }
    //用户拖拽移动segment
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat process = 1.0 * offsetX / scrollView.bounds.size.width;
    self.sv.segmentRealTimeProcess = process;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
//    CGFloat offsetX = scrollView.contentOffset.x;
//    NSInteger index = offsetX / scrollView.bounds.size.width;
//    self.sv.selectedItemIndex = index;
    
    if (scrollView.isDragging && !scrollView.isDecelerating) {
        NSLog(@"----");
    }
    //用户拖拽移动segment
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat process = 1.0 * offsetX / scrollView.bounds.size.width;
    self.sv.segmentRealTimeProcess = process;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    CGFloat offsetX = scrollView.contentOffset.x;
//    CGFloat index = offsetX / scrollView.bounds.size.width;
//    self.sv.selectedItemIndex = index;
    
    //用户拖拽移动segment
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat process = 1.0 * offsetX / scrollView.bounds.size.width;
    self.sv.segmentRealTimeProcess = process;
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
@end
