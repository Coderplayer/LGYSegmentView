//
//  ViewController1.m
//  LGYSegmentView
//
//  Created by 李冠余 on 2017/6/13.
//  Copyright © 2017年 李冠余. All rights reserved.
//

#import "ViewController1.h"
#import "Masonry.h"
@interface ViewController1 ()

@end

@implementation ViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:210/255.0 green:150/255.0 blue:230/255.0 alpha:1.0];
    UIView *redV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    redV.backgroundColor = [UIColor colorWithRed:230/255.0 green:150/255.0 blue:230/255.0 alpha:1.0];
    [self.view addSubview:redV];
    
    UIView *redV1 = [[UIView alloc] init];
    redV1.backgroundColor = [UIColor greenColor];
    [self.view addSubview:redV1];
    [redV1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(200, 50));
    }];

    
    UILabel *titleL = [[UILabel alloc] init];
    titleL.text = self.title;
    titleL.font = [UIFont systemFontOfSize:30];
    titleL.frame = CGRectMake(0, 0, 150, 60);
    titleL.backgroundColor = [UIColor lightGrayColor];
    titleL.textColor = [UIColor whiteColor];
    titleL.center = self.view.center;
    [self.view addSubview:titleL];
    
    
    
    UIView *fatherView = [[UIView alloc] init];
    UIView *childView = [[UIView alloc] init];
    
    UIView *backChildView = [[UIView alloc] init];
    [backChildView addSubview:childView];
    [fatherView addSubview:childView];
}





@end
