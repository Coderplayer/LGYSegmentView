
//
//  SubViewController.m
//  LGYSegmentView
//
//  Created by LGY on 2019/5/30.
//  Copyright © 2019 LGY. All rights reserved.
//

#import "SubViewController.h"

@interface SubViewController ()
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UILabel *titleL;
@end

@implementation SubViewController

- (instancetype)initWithBgColor:(UIColor *)bgColor {
    if (self = [super init]) {
        self.bgColor = bgColor;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = self.bgColor;
    
    self.titleL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
    self.titleL.textAlignment = NSTextAlignmentCenter;
    self.titleL.textColor = [UIColor whiteColor];
    self.titleL.font = [UIFont boldSystemFontOfSize:20];
    self.titleL.text = self.title;
    self.titleL.center = self.view.center;
    [self.view addSubview:self.titleL];
}


@end
