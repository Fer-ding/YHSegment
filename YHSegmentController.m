//
//  YHSegmengController.m
//  CuratoSpace
//
//  Created by YueHui on 2018/7/11.
//  Copyright © 2018年 LHY. All rights reserved.
//

#import "YHSegmentController.h"

typedef void(^YHViewControllerIndexBlock)(NSUInteger, UIButton *, UIViewController *);

@interface YHSegmentController ()

@property (nonatomic, strong, readwrite) UIViewController *currentViewController;
@property (nonatomic, strong, readwrite) YHSegmentView *segmentView;
@property (nonatomic, strong, readwrite) UIScrollView *containerView;
@property (nonatomic, readwrite) NSUInteger index;
@property (nonatomic, copy) NSArray *titles;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint viewOrigin; // 记录原始位置
@property (nonatomic, assign) CGSize offsetSize;  /**< 这个属性是用在badge上的偏移，width是_buttonSpace,height是titleLabel的y*/
@property (nonatomic, copy) YHViewControllerIndexBlock indexBlock;

@end

@implementation YHSegmentController {
    __block BOOL _ifSegmentViewSelectedIndex;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.containerView.contentSize = CGSizeMake(self.titles.count * self.view.bounds.size.width, self.view.bounds.size.height);
    [self setSelectedAtIndex:self.index];
}

- (void)dealloc {
//    for (UIViewController *childController in self.childViewControllers) {
//        [childController removeObserver:self forKeyPath:@"title"];
//    }
}

+ (instancetype)segmentControllerWithViewControllers:(NSArray *)viewControllers {
    return [[self alloc] initWithViewControllers:viewControllers];
}

- (instancetype)initWithViewControllers:(NSArray *)viewControllers {
    self = [super init];
    if (!self || !viewControllers.count) {
        return nil;
    }
    
    NSMutableArray *titles = [NSMutableArray arrayWithCapacity:viewControllers.count];
    for (UIViewController *childController in viewControllers) {
//        [childController addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
        
        if (childController.title) {
            [titles addObject:childController.title];
        }
    }
    
    _viewControllers = [viewControllers copy];
    _titles = [titles copy];
    _pagingEnabled = YES;
    _bounces = NO;
    [self segmentPageSetting];
    [self containerViewSetting];
    
    return self;
}

- (void)segmentPageSetting {
    
    _segmentView = [[YHSegmentView alloc] initWithTitles:_titles];
    _segmentView.backgroundColor = [UIColor whiteColor];
    
    __weak typeof(self) weakSelf = self;
    [_segmentView selectedAtIndex:^(NSUInteger index, UIButton * _Nonnull button) {
        _ifSegmentViewSelectedIndex = YES;
        [weakSelf moveToViewControllerAtIndex:index];
    }];
}

- (void)containerViewSetting {
    
    UIScrollView *scrollView = [[UIScrollView alloc]init];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.delegate = self;
    scrollView.pagingEnabled = _pagingEnabled;
    scrollView.bounces = _bounces;
    
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scrollView];
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:scrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:scrollView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:scrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:scrollView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
    
    [self.view addConstraints:@[topConstraint, leftConstraint, bottomConstraint, rightConstraint]];
    
    self.containerView = scrollView;
}

#pragma mark ---- scrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _containerView) {
        NSInteger index = round(scrollView.contentOffset.x / self.size.width);
        
        // 移除不足一页的操作
        if (index != self.index) {
            [self setSelectedAtIndex:index];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView == _containerView) {
        
        CGFloat offsetX = scrollView.contentOffset.x;
        
        //滑动加载viewController
        NSInteger index = offsetX / CGRectGetWidth(scrollView.frame);
        if (offsetX - self.index * CGRectGetWidth(scrollView.frame) > 0) {
            index++;
        }
        if (index > self.viewControllers.count - 1) {
            return;
        }

        UIViewController *targetViewController = self.viewControllers[index];
        if (_ifSegmentViewSelectedIndex) {
            _ifSegmentViewSelectedIndex = NO;
        }
        else {
            if (![self.childViewControllers containsObject:targetViewController] && targetViewController) {
                [self updateFrameChildViewController:targetViewController atIndex:index];
            }
        }
    
        [_segmentView adjustOffsetXToFixIndicatePosition:offsetX containerWidth:CGRectGetWidth(scrollView.frame)];
    }
}

#pragma mark ---- index

- (void)setSelectedAtIndex:(NSUInteger)index {
    _index = index;
    [_segmentView setSelectedAtIndex:index];
}

- (void)moveToViewControllerAtIndex:(NSUInteger)index {
    [self scrollContainerViewToIndex:index];
    
    UIViewController *targetViewController = self.viewControllers[index];
    if ([self.childViewControllers containsObject:targetViewController] || !targetViewController) {
        return;
    }
    
    [self updateFrameChildViewController:targetViewController atIndex:index];
}

- (void)selectedAtIndex:(void (^)(NSUInteger, UIButton * _Nonnull, UIViewController * _Nonnull))indexBlock {
    if (indexBlock) {
        _indexBlock = indexBlock;
    }
}

- (void)updateFrameChildViewController:(UIViewController *)childViewController atIndex:(NSUInteger)index {
    childViewController.view.frame = CGRectOffset(CGRectMake(0, 0, _containerView.frame.size.width, _containerView.frame.size.height), index * self.size.width, 0);
    
    [_containerView addSubview:childViewController.view];
    [self addChildViewController:childViewController];
}

#pragma mark ---- scroll

- (void)scrollContainerViewToIndex:(NSUInteger)index {
    [UIView animateWithDuration:_segmentView.duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [_containerView setContentOffset:CGPointMake(index * self.size.width, 0)];
    } completion:^(BOOL finished) {
        if (_indexBlock) {
            _indexBlock(index, _segmentView.selectedButton, self.currentViewController);
        }
    }];
}

#pragma mark ---- set

- (void)setPagingEnabled:(BOOL)pagingEnabled {
    _pagingEnabled = pagingEnabled;
    
    self.containerView.pagingEnabled = pagingEnabled;
}

- (void)setBounces:(BOOL)bounces {
    _bounces = bounces;
    
    self.containerView.bounces = bounces;
}

#pragma mark ---- get

- (NSUInteger)index {
    return self.segmentView.index;
}

- (UIViewController *)currentViewController {
    return self.viewControllers[self.index];
}

- (CGSize)size {
    return self.view.bounds.size;
}

@end

#pragma mark ---- 分类(UIViewController)

#import <objc/runtime.h>

@implementation UIViewController(YHSegment)
@dynamic segmentController;

- (YHSegmentController *)segmentController {
    if ([self.parentViewController isKindOfClass:[YHSegmentController class]] && self.parentViewController) {
        return (YHSegmentController *)self.parentViewController;
    }
    return nil;
}

- (void)addSegmentController:(YHSegmentController *)segment {
    if (self == segment) {
        return;
    }
    
    [self addChildViewController:segment];
    
    // 默认加入第一个控制器
    UIViewController *firstViewController = segment.viewControllers.firstObject;
    [segment performSelector:@selector(updateFrameChildViewController:atIndex:) withObject:firstViewController withObject:0];
}
@end
