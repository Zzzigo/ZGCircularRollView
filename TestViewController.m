//
//  TestViewController.m
//  TestDemo
//
//  Created by 赵刚 on 2017/3/23.
//  Copyright © 2017年 赵刚. All rights reserved.
//

#import "TestViewController.h"
#import "ZGCircularRollView.h"

@interface TestViewController ()

@property (nonatomic, strong) ZGCircularRollView *circularRollView;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.circularRollView];
    
    [self.circularRollView updateCircularRollView];
    
}

- (ZGCircularRollView *)circularRollView
{
    if (!_circularRollView) {
        _circularRollView = [[ZGCircularRollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
        
        _circularRollView.imageArray = @[@"test_image_1",
                                         @"test_image_2",
                                         @"test_image_3",
                                         @"test_image_4",
                                         @"test_image_5"
                                         ];
        
        _circularRollView.cirularRollViewPagePosition = ZGCirularRollViewPagePosition_left;
    }
    return _circularRollView;
}

@end
