//
//  YHSegmentView.h
//  CuratoSpace
//
//  Created by YueHui on 2018/7/11.
//  Copyright © 2018年 LHY. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, YHSegmentStyle) {
    YHSegmentStyleDefault,    /**< 指示杆和按钮的标题齐平*/
    YHSegmentStyleFixedWidth,      /**< 指示杆宽度固定，自己设置*/
};

NS_ASSUME_NONNULL_BEGIN

@interface YHSegmentView : UIView

+ (__nullable instancetype)segmentViewTitles:(NSArray <NSString *>*)titles;
- (__nullable instancetype)initWithTitles:(NSArray <NSString *>*)titles;

@property (nonatomic, assign) YHSegmentStyle style;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) UIColor *segmentTintColor;   /**< 选中时的字体颜色，默认黑色*/
@property (nonatomic, strong) UIColor *segmentNormalColor;
@property (nonatomic, strong) UIColor *separateColor;   /**< 设置分割线的颜色，默认YHColorHexAndAlpha(0xA3A3AE, 0.9)*/
@property (nonatomic, assign, getter=isScrollEnabled) BOOL scrollEnabled; /**< 默认YES*/
@property (nonatomic, assign, getter=isShowSeparateLine) BOOL showSeparateLine; /**< 默认YES*/

@property (nonatomic, assign) CGFloat leftMargin;
@property (nonatomic, assign) CGFloat rightMargin;
@property (nonatomic, assign) CGFloat buttonSpace;
@property (nonatomic, assign) CGFloat indicateWidth;
@property (nonatomic, assign) BOOL autoAdjustSpace; //自动计算间距，需要设置bounds

@property (nonatomic, strong, readonly) NSArray <UIButton *>*buttons;
@property (nonatomic, strong, readonly) UIScrollView *contentView;
@property (nonatomic, strong, readonly) UIButton *selectedButton;
@property (nonatomic, assign, readonly) NSUInteger index;
@property (nonatomic, assign, readonly) NSTimeInterval duration;  /**< 滑动时间*/

- (void)setSelectedAtIndex:(NSUInteger)index;
- (void)selectedAtIndex:(void(^)(NSUInteger index, UIButton *button))indexBlock;

/// offset
- (void)adjustOffsetXToFixIndicatePosition:(CGFloat)offsetX containerWidth:(CGFloat)containerWidth;

@end
NS_ASSUME_NONNULL_END
