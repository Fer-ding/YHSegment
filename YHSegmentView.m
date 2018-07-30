//
//  YHSegmentView.m
//  CuratoSpace
//
//  Created by YueHui on 2018/7/11.
//  Copyright © 2018年 LHY. All rights reserved.
//

#import "YHSegmentView.h"

#define YHColorHexAndAlpha(rgbValue, alphaValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:alphaValue]

typedef void(^YHIndexBlock)(NSUInteger ,UIButton *);

@interface YHSegmentView ()

@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIScrollView *contentView;
@property (nonatomic, strong) UIStackView *contentContainerView;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, copy) NSArray *titles;
@property (nonatomic, strong) UIView *separateLine;
@property (nonatomic, strong) UIButton *selectedButton; /**< 当前被选中的按钮*/
@property (nonatomic, strong) UIView *indicateView;     /**< 指示杆*/
@property (nonatomic, copy)   YHIndexBlock indexBlock;
@property (nonatomic, assign) CGFloat indicateHeight;   /**< 指示杆高度*/
@property (nonatomic, assign) NSTimeInterval duration;  /**< 滑动时间*/
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat minItemSpace;     /**< 最小Item之间的间距*/
@property (nonatomic, strong) UIFont *font;

@property (strong, nonatomic) NSLayoutConstraint *indicateViewWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *indicateViewLeftConstraint;
@property (strong, nonatomic) NSLayoutConstraint *contentContainerViewLeftConstraint;
@property (strong, nonatomic) NSLayoutConstraint *contentContainerViewRightConstraint;

@end

@implementation YHSegmentView

+ (instancetype)segmentViewTitles:(NSArray<NSString *> *)titles {
    return [[self alloc] initWithTitles:titles];
}

- (instancetype)initWithTitles:(NSArray<NSString *> *)titles {
    self = [super initWithFrame:CGRectZero];
    if (!titles.count || !self) {
        return nil;
    }
    
    _titles = titles;
    [self segmentBasicSetting];
    [self segmentPageSetting];
    
    return self;
}

- (void)segmentBasicSetting {
    self.backgroundColor = [UIColor colorWithWhite:1. alpha:0.5];
    _buttons = [NSMutableArray array];
    _minItemSpace = 10.0;//original 40.0
    _segmentTintColor = [UIColor redColor];
    _segmentNormalColor = [UIColor grayColor];
    _font = [UIFont systemFontOfSize:14];
    _buttonSpace = _minItemSpace;
    _indicateHeight = 3.;
    _duration = .25;
    _scrollEnabled = YES;
    _showSeparateLine = YES;
    _separateColor = YHColorHexAndAlpha(0xA3A3AE, 0.9);
}

- (void)segmentPageSetting {
    
    _backgroundImageView = [[UIImageView alloc] init];
    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    _backgroundImageView.clipsToBounds = YES;
    _backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_backgroundImageView];
    
    // _backgroundImageView
    {
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_backgroundImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:_backgroundImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_backgroundImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:_backgroundImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
        [self addConstraints:@[topConstraint, leftConstraint, bottomConstraint, rightConstraint]];
    }
    
    _contentView = [[UIScrollView alloc] init];
    _contentView.backgroundColor = [UIColor clearColor];
    _contentView.showsHorizontalScrollIndicator = NO;
    _contentView.showsVerticalScrollIndicator = NO;
    _contentView.scrollEnabled = _scrollEnabled;
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_contentView];
    
    // _contentView
    {
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
        [self addConstraints:@[topConstraint, leftConstraint, bottomConstraint, rightConstraint]];
    }
    
    UIStackView *containerView = [[UIStackView alloc] init];
    containerView.axis = UILayoutConstraintAxisHorizontal;
    containerView.spacing = _buttonSpace;
    containerView.distribution = UIStackViewDistributionEqualSpacing;
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [_contentView addSubview:containerView];
    self.contentContainerView = containerView;
    
    // _contentContainerView
    {
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:containerView.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:containerView.superview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:containerView.superview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:containerView.superview attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:containerView.superview attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
        [containerView.superview addConstraints:@[topConstraint, leftConstraint, bottomConstraint, rightConstraint, heightConstraint]];
        
        self.contentContainerViewLeftConstraint = leftConstraint;
        self.contentContainerViewRightConstraint = rightConstraint;
    }
    
    for (int i = 0; i < _titles.count; i++) {
        NSString *title = _titles[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTag:i];
        [button.titleLabel setFont:_font];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:_segmentNormalColor forState:UIControlStateNormal];
        [button setTitleColor:_segmentTintColor forState:UIControlStateSelected];
        [button addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [containerView addArrangedSubview:button];
        [_buttons addObject:button];
        
        if (i == 0) {
            button.selected = YES;
            _selectedButton = button;
            
            // 添加指示杆
            _indicateView = [[UIView alloc] init];
            _indicateView.backgroundColor = _segmentTintColor;
            _indicateView.translatesAutoresizingMaskIntoConstraints = NO;
            _indicateView.layer.cornerRadius = 1.5;
            [_contentView addSubview:_indicateView];
            
            // _indicateView
            {
                NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:_indicateView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_indicateView.superview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:_buttonSpace];
                NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_indicateView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_indicateView.superview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-0.5];
                NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:_indicateView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:0 constant:0];
                NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:_indicateView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:0 constant:_indicateHeight];
                
                [_indicateView.superview addConstraints:@[leftConstraint, bottomConstraint, widthConstraint, heightConstraint]];
                self.indicateViewLeftConstraint = leftConstraint;
                self.indicateViewWidthConstraint = widthConstraint;
            }
        }
    }
    
    _separateLine = [[UIView alloc] init];
    _separateLine.hidden = !_showSeparateLine;
    _separateLine.backgroundColor = _separateColor;
    _separateLine.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_separateLine];
    
    // _separateLine
    {
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:_separateLine attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_separateLine.superview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:_separateLine attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_separateLine.superview attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_separateLine attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_separateLine.superview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:_separateLine attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:0 constant:0.5];
        
        [_separateLine.superview addConstraints:@[leftConstraint, rightConstraint, bottomConstraint, heightConstraint]];
    }
    
    [self layoutIfNeeded];
}

- (CGFloat)calculateSpace {
    CGFloat space = 0;
    CGFloat totalWidth = 0;
    
    for (NSString *title in _titles) {
        CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName : _font}];
        totalWidth += titleSize.width;
    }
    
    space = (self.size.width - totalWidth - self.leftMargin - self.rightMargin) / (_titles.count - 1);
    if (space > _minItemSpace) {
        return space;
    } else {
        return _minItemSpace;
    }
}

#pragma mark - 按钮点击

- (void)didClickButton:(UIButton *)button {
    if (button != _selectedButton) {
        button.selected = YES;
        _selectedButton.selected = NO;
        _selectedButton = button;
        
        [self scrollIndicateView];
        [self scrollSegementView];
    }
    
    if (_indexBlock) {
        _indexBlock(_selectedButton.tag, button);
    }
}

#pragma mark - 滑动
/**
 根据选中的按钮滑动指示杆
 */
- (void)scrollIndicateView {
    
    if (_style == YHSegmentStyleDefault) {
        self.indicateViewLeftConstraint.constant = CGRectGetMinX(_selectedButton.frame) + self.contentContainerViewLeftConstraint.constant - CGRectGetWidth(_selectedButton.frame) * 0.5;
        self.indicateViewWidthConstraint.constant = CGRectGetWidth(_selectedButton.frame);
    } else {
        self.indicateViewLeftConstraint.constant = CGRectGetMidX(_selectedButton.frame) + self.contentContainerViewLeftConstraint.constant - _indicateWidth * 0.5;
        self.indicateViewWidthConstraint.constant = _indicateWidth;
    }
    
    [UIView animateWithDuration:_duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self layoutIfNeeded];
    } completion:nil];
}

/**
 根据选中调整segementView的offset
 */
- (void)scrollSegementView {
    
    if (_contentView.contentSize.width <= self.size.width || self.autoAdjustSpace) {
        return;
    }
    
    CGFloat selectedWidth = _selectedButton.frame.size.width;
    CGFloat offsetX = (self.size.width - selectedWidth) / 2;
    
    if (_selectedButton.frame.origin.x <= self.size.width / 2) {
        [_contentView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else if (CGRectGetMaxX(_selectedButton.frame) >= (_contentView.contentSize.width - self.size.width / 2)) {
        [_contentView setContentOffset:CGPointMake(_contentView.contentSize.width - self.size.width, 0) animated:YES];
    } else {
        [_contentView setContentOffset:CGPointMake(CGRectGetMinX(_selectedButton.frame) - offsetX, 0) animated:YES];
    }
}

- (void)adjustOffsetXToFixIndicatePosition:(CGFloat)offsetX containerWidth:(CGFloat)containerWidth {
    
    
    NSInteger fIndex = offsetX / containerWidth;
    
    CGFloat fCenterX = [self midXAtIndex:fIndex];
    CGFloat bCenterX = [self midXAtIndex:fIndex + 1];
    
    CGFloat fWidth = [self widthAtIndex:fIndex];
    CGFloat bWidth = [self widthAtIndex:fIndex + 1];
    
    CGFloat tx = (bCenterX - fCenterX) / containerWidth * (offsetX - containerWidth * fIndex);
    CGFloat tw = (bWidth - fWidth) / containerWidth * (offsetX - containerWidth * fIndex);
    CGFloat indicateWidth = _style == YHSegmentStyleDefault ? fWidth + tw : self.indicateWidth;
    self.indicateViewLeftConstraint.constant = self.leftMargin + fCenterX + tx - indicateWidth * 0.5;
    self.indicateViewWidthConstraint.constant = indicateWidth;
}

#pragma mark - index

- (NSUInteger)index {
    return _selectedButton.tag;
}

- (void)setSelectedAtIndex:(NSUInteger)index {
    
    for (UIView *view in _contentContainerView.subviews) {
        if ([view isKindOfClass:[UIButton class]] && view.tag == index) {
            UIButton *button = (UIButton *)view;
            [self didClickButton:button];
            break;
        }
    }
}

- (CGFloat)midXAtIndex:(NSUInteger)index {
    if (index > _titles.count - 1) {
        index = _titles.count - 1;
    }
    
    UIButton *button = [_buttons objectAtIndex:index];
    return CGRectGetMidX(button.frame);
}

- (CGFloat)widthAtIndex:(NSUInteger)index {
    if (index > _titles.count - 1) {
        index = _titles.count - 1;
    }
    
    UIButton *button = [_buttons objectAtIndex:index];
    return CGRectGetWidth(button.frame);
}

- (void)selectedAtIndex:(void (^)(NSUInteger, UIButton *))indexBlock {
    if (indexBlock) {
        _indexBlock = indexBlock;
    }
}

#pragma mark - update indicate Constraints

- (void)updateIndicateConstraints {
    
    switch (_style) {
        case YHSegmentStyleDefault: {
            self.indicateViewLeftConstraint.constant = CGRectGetMinX(_selectedButton.frame) + self.contentContainerViewLeftConstraint.constant - CGRectGetWidth(_selectedButton.frame) * 0.5;
            self.indicateViewWidthConstraint.constant = CGRectGetWidth(_selectedButton.frame);
        }
        break;
        case YHSegmentStyleFixedWidth: {
            self.indicateViewLeftConstraint.constant = CGRectGetMidX(_selectedButton.frame) + self.contentContainerViewLeftConstraint.constant - _indicateWidth * 0.5;
            self.indicateViewWidthConstraint.constant = _indicateWidth;
        }
        break;
        default:
        break;
    }
}

#pragma mark - set

- (void)setButtonSpace:(CGFloat)buttonSpace {
    _buttonSpace = buttonSpace;
    
    self.contentContainerView.spacing = buttonSpace;
    [self updateIndicateConstraints];
}

- (void)setLeftMargin:(CGFloat)leftMargin {
    _leftMargin = leftMargin;
    
    self.contentContainerViewLeftConstraint.constant = leftMargin;
    [self updateIndicateConstraints];
}

- (void)setRightMargin:(CGFloat)rightMargin {
    _rightMargin = rightMargin;
    
    self.contentContainerViewRightConstraint.constant = -rightMargin;
    [self updateIndicateConstraints];
}

- (void)setStyle:(YHSegmentStyle)style {
    _style = style;
    
    if (style == YHSegmentStyleFixedWidth && _indicateWidth >= 0) {
        [self updateIndicateConstraints];
    }
}

- (void)setIndicateWidth:(CGFloat)indicateWidth {
    _indicateWidth = indicateWidth;
    
    if (self.style != YHSegmentStyleFixedWidth) {
        return;
    }
    
    [self updateIndicateConstraints];
}

- (void)setAutoAdjustSpace:(BOOL)autoAdjustSpace {
    _autoAdjustSpace = autoAdjustSpace;
    
    self.buttonSpace = [self calculateSpace];
    self.scrollEnabled = NO;
}

- (void)setSeparateColor:(UIColor *)separateColor {
    _separateColor = separateColor;
    
    self.separateLine.backgroundColor = separateColor;
}

- (void)setSegmentTintColor:(UIColor *)segmentTintColor {
    _segmentTintColor = segmentTintColor;
    _indicateView.backgroundColor = segmentTintColor;
    for (UIView *view in _contentContainerView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            [button setTitleColor:segmentTintColor
                         forState:UIControlStateSelected];
        }
    }
}

- (void)setSegmentNormalColor:(UIColor *)segmentNormalColor {
    _segmentNormalColor = segmentNormalColor;
    for (UIView *view in _contentContainerView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            [button setTitleColor:segmentNormalColor
                         forState:UIControlStateNormal];
        }
    }
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    _scrollEnabled = scrollEnabled;
    
    _contentView.scrollEnabled = scrollEnabled;
}

- (void)setShowSeparateLine:(BOOL)showSeparateLine {
    _showSeparateLine = showSeparateLine;
    
    _separateLine.hidden = !showSeparateLine;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    
    if (backgroundImage) {
        self.backgroundImageView.image = backgroundImage;
        self.contentView.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark - get

- (CGSize)size {
    return self.bounds.size;
}

@end
