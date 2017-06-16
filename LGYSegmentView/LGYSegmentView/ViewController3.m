//
//  ViewController3.m
//  LGYSegmentView
//
//  Created by 李冠余 on 2017/6/13.
//  Copyright © 2017年 李冠余. All rights reserved.
//

#import "ViewController3.h"

@interface ViewController3 ()

@end

@implementation ViewController3

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    UIView *redV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    redV.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:redV];
    
    UILabel *titleL = [[UILabel alloc] init];
    titleL.text = self.title;
    titleL.font = [UIFont systemFontOfSize:30];
    titleL.frame = CGRectMake(0, 0, 150, 60);
    titleL.backgroundColor = [UIColor lightGrayColor];
    titleL.textColor = [UIColor whiteColor];
    titleL.center = self.view.center;
    [self.view addSubview:titleL];
}

@end