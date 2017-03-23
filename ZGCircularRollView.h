//
//  ZGCirularRollView.h
//  TestDemo
//
//  Created by 赵刚 on 2017/3/23.
//  Copyright © 2017年 赵刚. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZGCirularRollViewPagePosition)
{
    ZGCirularRollViewPagePosition_center = 0,
    ZGCirularRollViewPagePosition_left   = 0,
};

@interface ZGCircularRollView : UIView <UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *circularRollView;

@property (nonatomic, strong) NSArray          *imageArray;

@property (nonatomic, strong) UIPageControl    *pageControl;

@property (nonatomic, assign) NSInteger        cirularRollViewPagePosition;

- (void)updateCircularRollView;

@end
