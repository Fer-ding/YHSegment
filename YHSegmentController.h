//
//  YHSegmengController.h
//  CuratoSpace
//
//  Created by YueHui on 2018/7/11.
//  Copyright © 2018年 LHY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHSegmentView.h"

NS_ASSUME_NONNULL_BEGIN
@interface YHSegmentController : UIViewController <UIScrollViewDelegate>

/// initial
+ (instancetype)segmentControllerWithViewControllers:(NSArray <UIViewController *>*)viewControllers;
- (instancetype)initWithViewControllers:(NSArray <UIViewController *>*)viewControllers;

@property (nonatomic, readonly) NSUInteger index;
@property (nonatomic, getter=isPagingEnabled) BOOL pagingEnabled;
@property (nonatomic, getter=isBounces) BOOL bounces;

@property (nonatomic, strong, readonly) YHSegmentView *segmentView;
@property (nonatomic, strong, readonly) UIViewController *currentViewController;
@property (nonatomic, strong, readonly) NSArray <UIViewController *>*viewControllers;
@property (nonatomic, strong, readonly) UIScrollView *containerView;

/// index
- (void)selectedAtIndex:(void(^)(NSUInteger index, UIButton *button, UIViewController *viewController))indexBlock;
- (void)setSelectedAtIndex:(NSUInteger)index;

@end

@interface UIViewController (YHSegment)
@property (nonatomic, strong, readonly) YHSegmentController *segmentController;
- (void)addSegmentController:(YHSegmentController *)segment;
@end

NS_ASSUME_NONNULL_END
