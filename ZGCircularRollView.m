//
//  ZGCirularRollView.m
//  TestDemo
//
//  Created by 赵刚 on 2017/3/23.
//  Copyright © 2017年 赵刚. All rights reserved.
//

#import "ZGCircularRollView.h"

#define kViewHeight                             self.bounds.size.height
#define kViewWidth                              self.bounds.size.width
#define kViewCenterX                            self.center.x


@interface ZGCircularRollView ()

@property (nonatomic, strong) NSMutableArray *circularRollViewArray;
@property (nonatomic, strong) NSTimer        *timer;

@property (nonatomic, assign) NSInteger      nextItem;

@end

@implementation ZGCircularRollView

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self UISetInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if([self respondsToSelector:@selector(viewSetInit)])
    {
        [self UISetInit];
    }
}

- (void)UISetInit
{
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:self.circularRollView];
    
    [self addSubview:self.pageControl];
    self.pageControl.frame = CGRectMake(kViewCenterX, kViewHeight - 5, 0, 0);
}

- (void)updateCircularRollView
{
    if (self.cirularRollViewPagePosition == ZGCirularRollViewPagePosition_left) {
        self.pageControl.frame = CGRectMake(kViewWidth - (10 * self.imageArray.count), kViewHeight - 5, 0, 0);
    }else{
        self.pageControl.frame = CGRectMake(kViewCenterX - (5 * self.imageArray.count), kViewHeight - 5, 0, 0);
    }
    self.pageControl.numberOfPages = self.imageArray.count;
    
    
    [self.circularRollViewArray addObject:[self.imageArray lastObject]];
    [self.circularRollViewArray addObjectsFromArray:self.imageArray];
    [self.circularRollViewArray addObject:[self.imageArray firstObject]];
    
    [self.circularRollView reloadData];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
    [self.circularRollView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    
    //开始定时器其实就是把上一次的定时器销毁，然后再重新创建一个新的定时器
    [self startTimer];
}

#pragma mark - 代理方法

//每个section有多少个item
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.circularRollViewArray.count;
}

//返回每个cell.
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    
    //从缓存池中取cell。
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
    
    UIImageView *backImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.circularRollViewArray[indexPath.item]]];
    backImageView.frame = self.bounds;
    [cell.contentView addSubview:backImageView];
    
    //这一步是实现代理的方法，不写对整个轮播的实现没影响。
    if ([cell respondsToSelector:@selector(setDelegate:)]) {
        [cell performSelector:@selector(setDelegate:) withObject:self];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    //记录将要出现的cell，来作为下面的是否换cell做判断。
    self.nextItem = indexPath.item;
}

//这个方法是上一个视图完全消失，就调用一次
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    //按照5123451来做判断，如果当前的内容是第一个5，则直接无动画的转到倒数第二个的5。如果当前内容是最后一个1，则无动画的跳转到正数第二个1。
    if (indexPath.item == 1 && self.nextItem == 0) {
        NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForItem:(self.circularRollViewArray.count - 2) inSection:0];
        [self.circularRollView scrollToItemAtIndexPath:tmpIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }else if ((indexPath.item == (self.circularRollViewArray.count - 2)) && (self.nextItem == (self.circularRollViewArray.count - 1))){
        NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
        [self.circularRollView scrollToItemAtIndexPath:tmpIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }else{
        
    }
    
}

// 通过这个方法，来控制currentPage
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger pageNum = ((scrollView.contentOffset.x + (kViewWidth / 2.0)) / kViewWidth);
    
    if (pageNum == 0) {
        self.pageControl.currentPage = self.circularRollViewArray.count - 2;
    }else if (pageNum > 0 && pageNum < (self.circularRollViewArray.count - 1)){
        self.pageControl.currentPage = pageNum - 1;
    }else{
        self.pageControl.currentPage = 0;
    }
}

//这里是定时器所调用的方法，每调用一次，都向前一张跳转。这里为什么使用self.endDisplayItem而不是使用self.nextItem呢？原因是当你手动拖动的时候，只要稍微拖动一下，就会改变self.nextItem的值，等到定时器下次跳转的时候就会跳转两张，用户体验不是很好。
- (void)circularRollViewToNextItem
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(self.nextItem + 1) inSection:0];
    [self.circularRollView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self endTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self startTimer];
}

#pragma mark - 懒加载

- (UICollectionView *)circularRollView
{
    if (!_circularRollView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.itemSize = self.bounds.size;
        
        _circularRollView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        _circularRollView.showsHorizontalScrollIndicator = NO;
        _circularRollView.bounces = NO;
        _circularRollView.delegate = self;
        _circularRollView.dataSource = self;
        _circularRollView.pagingEnabled = YES;
        _circularRollView.backgroundColor = [UIColor clearColor];
        
        [_circularRollView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
    }

    return _circularRollView;
}

- (UIPageControl *)pageControl
{
    if(!_pageControl){
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.hidesForSinglePage = YES;
        _pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:1 alpha:0.4];
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    }
    return _pageControl;
    
}

- (NSArray *)imageArray
{
    if (!_imageArray) {
        _imageArray = [[NSArray alloc] init];
    }
    return _imageArray;
}

- (NSMutableArray *)circularRollViewArray
{
    if (!_circularRollViewArray) {
        _circularRollViewArray = [[NSMutableArray alloc] init];
    }
    return _circularRollViewArray;
}

- (NSTimer *)timer
{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:3.f target:self selector:@selector(circularRollViewToNextItem) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

- (void)endTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)startTimer
{
    [self endTimer];
    [self timer];
}

@end
