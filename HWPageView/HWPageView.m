//
//  HWPageView.m
//  Demo
//
//  Created by 陈智颖 on 15/11/30.
//  Copyright © 2015年 YY. All rights reserved.
//

#import "HWPageView.h"
#import "HWHelper.h"

#define tabItemTagKey @"tabItemTagKey"

#define defaultItemDotDiameter 3

#define defaultTabScrollHeight 36
#define defaultTabIemWidth 80

#define defaultSelectLineMask 10

#define TabItemMaxScale 1.1

#define defaultSeparateLineColor [UIColor colorWithRed:217.f/255.f green:217.f/255.f blue:217.f/255.f alpha:1]
#define defaultTabScrollBgColor [UIColor whiteColor]

@interface UIView (ChangePosition)

- (void)setX:(CGFloat)newX;
- (void)setY:(CGFloat)newY;

@end

@implementation UIView (ChangePosition)

- (void)setX:(CGFloat)newX {
    CGRect newFrame = self.frame;
    newFrame.origin.x = newX;
    self.frame = newFrame;
}

- (void)setY:(CGFloat)newY {
    CGRect newFrame = self.frame;
    newFrame.origin.y = newY;
    self.frame = newFrame;
}

@end

@interface TabItem : UIView {
    UILabel *_label;
    UILabel *_highlightLabel;
    
    HWPageSelectedType _style;
    CAShapeLayer *_dot;
}

@property (nonatomic) BOOL isSelected;

@end

@implementation TabItem

- (instancetype)initWithFrame:(CGRect)frame
                    withTitle:(NSString *)title
              withNormalColor:(UIColor *)normalColor
           withHighlightColor:(UIColor *)highlightColor
               separatorStyle:(HWPageSelectedType)style
{
    self = [super initWithFrame:frame];
    if (self) {
        _style = style;
        
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _label.font = [UIFont systemFontOfSize:15];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = normalColor;
        
        _highlightLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _highlightLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _highlightLabel.font = [UIFont systemFontOfSize:15];
        _highlightLabel.textAlignment = NSTextAlignmentCenter;
        _highlightLabel.textColor = highlightColor;
        
        if ([title isKindOfClass:[NSAttributedString class]]) {
            _label.attributedText = (NSAttributedString *)title;
            _highlightLabel.attributedText = (NSAttributedString *)title;
        } else {
            _label.text = title;
            _highlightLabel.text = title;
        }
        
        _dot = [CAShapeLayer layer];
        _dot.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, defaultItemDotDiameter, defaultItemDotDiameter)].CGPath;
        _dot.fillColor = highlightColor.CGColor;
        _dot.strokeColor = highlightColor.CGColor;
        
        if (_style == HWPageSelectedType_Dot) {
            [self.layer addSublayer:_dot];
        }
        [self addSubview:_label];
        [self addSubview:_highlightLabel];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _dot.position = CGPointMake((self.width - defaultItemDotDiameter) / 2,
                                self.height - defaultItemDotDiameter - 3);
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    _dot.hidden = !isSelected;
    
    _label.alpha = isSelected ? 0 : 1;
    _highlightLabel.alpha = isSelected ? 1 : 0;
    
    if (_style == HWPageSelectedType_Line) {
        return;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        _label.transform = isSelected ? CGAffineTransformMakeScale(TabItemMaxScale, TabItemMaxScale) : CGAffineTransformMakeScale(1, 1);
        _highlightLabel.transform = _label.transform;
    }];
}

- (void)gradualChangeTo:(CGFloat)value {
    _label.alpha = 1 - value;
    _highlightLabel.alpha = value;
    _dot.hidden = YES;
    
    if (_style == HWPageSelectedType_Line) {
        return;
    }
    
    _label.transform = CGAffineTransformMakeScale(1 + (TabItemMaxScale - 1) * value,
                                                  1 + (TabItemMaxScale - 1) * value);
    _highlightLabel.transform = _label.transform;
}

@end

@interface HWPageView () <UIScrollViewDelegate> {
    
    HWPageSelectedType _selectedType;
    
    UIView *_separateline;
    UIScrollView *_tabScroll;
    UIScrollView *_pageScroll;
    
    NSMutableArray *_tabAry;
    NSMutableArray *_pageAry;
    
    UIColor *_tabTitleNormalColor;
    UIColor *_tabTitleHighlightColor;
    
    CGFloat _tabScrollHeight;
    CGFloat _tabItemWidth;
    
    CGFloat _selectLinePadding;
    CGFloat _selectedLineDiffX;
    CGFloat _selectedTempX;
    
    UIView *_selectedLine;
    BOOL _isTabScrollCanRoll;

}

@property (nonatomic) NSInteger selectedIndex;

@end

@implementation HWPageView

- (instancetype)initWithFrame:(CGRect)frame
      withTabTitleNormalColor:(UIColor *)normalColor
   withTabTitleHighlightColor:(UIColor *)highlightColor
               isTabCanScroll:(BOOL)isTabCanScroll
                 selectedType:(HWPageSelectedType)type
                     delegate:(id<HWPageViewDataSource, HWPageViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _dataSource = delegate;
        _delegate = delegate;
        
        _tabScrollHeight = defaultTabScrollHeight;
        if (_delegate && [_delegate respondsToSelector:@selector(heightForTabInPageView:)]) {
            _tabScrollHeight = [_delegate heightForTabInPageView:self];
        }

        _tabAry = [NSMutableArray new];
        _pageAry = [NSMutableArray new];
        
        _tabTitleNormalColor = normalColor;
        _tabTitleHighlightColor = highlightColor;
        _isTabScrollCanRoll = isTabCanScroll;
        
        _selectedType = type;
        _pageOffset = 0.0f;
        
        [self reloadData];

    }
    return self;
}

- (void)reloadData {
    
    for (UIView *subView in _tabScroll.subviews) {
        [subView removeFromSuperview];
    }
    
    for (UIView *subView in _pageScroll.subviews) {
        [subView removeFromSuperview];
    }
    
    [_separateline removeFromSuperview];
    [_selectedLine removeFromSuperview];
    [_tabScroll removeFromSuperview];
    [_pageScroll removeFromSuperview];
    
    [_tabAry removeAllObjects];
    [_pageAry removeAllObjects];
    
    [self initTabScroll];
    [self initPageScroll];
    [self initSeparateline];
    [self initSelectedLine];
    
    self.clipsToBounds = YES;
    self.selectedIndex = _selectedIndex;
}

- (void)changePageToIndex:(NSInteger)index {
    self.selectedIndex = index;
}

#pragma mark - Custom Method
- (void)initSeparateline {
    _separateline = [[UIView alloc] initWithFrame:CGRectMake(0, _tabScroll.height, _tabScroll.width, 0.5)];
    _separateline.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _separateline.backgroundColor = defaultSeparateLineColor;
    [self addSubview:_separateline];
}

- (void)initSelectedLine {
    
    _selectedLine = [[UIView alloc] initWithFrame:CGRectZero];
    _selectedLine.backgroundColor = _tabTitleHighlightColor;
    _selectedLine.hidden = _selectedType != HWPageSelectedType_Line;
    
    _selectLinePadding = defaultSelectLineMask;
    if (_delegate && [_delegate respondsToSelector:@selector(paddingForSelectedLineInPageView:)]) {
        _selectLinePadding = [_delegate paddingForSelectedLineInPageView:self];
    }
    
    _selectedLineDiffX = _selectLinePadding;
    _selectedTempX = _selectLinePadding;
    
    [self addSubview:_selectedLine];
    [self resetSeletedLineFrame];
}

- (void)initTabScroll {
    
    if (!_dataSource) {
        return;
    }
    
    _tabScroll = [[UIScrollView alloc] initWithFrame:CGRectZero];
    
    UIColor *tabBgColor = defaultTabScrollBgColor;
    if (_delegate && [_delegate respondsToSelector:@selector(colorForTabBgInPageView:)]) {
        tabBgColor = [_delegate colorForTabBgInPageView:self];
    }
    
    for (NSInteger index = 0, count = [_dataSource numberOfPages]; index < count; index++) {
        TabItem *tabItem = [[TabItem alloc] initWithFrame:CGRectZero
                                                withTitle:[_dataSource pageView:self titleAtIndex:index]
                                          withNormalColor:_tabTitleNormalColor
                                       withHighlightColor:_tabTitleHighlightColor
                                           separatorStyle:_selectedType];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickTabItem:)];
        [tabItem addGestureRecognizer:tap];
        [tabItem.layer setValue:@(index) forKey:tabItemTagKey];
        tabItem.backgroundColor = tabBgColor;
        
        [_tabScroll addSubview:tabItem];
        [_tabAry addObject:tabItem];
    }
    
    _tabScroll.delegate = self;
    _tabScroll.scrollEnabled = _isTabScrollCanRoll;
    _tabScroll.scrollsToTop = NO;
    _tabScroll.showsHorizontalScrollIndicator = NO;
    
    [self addSubview:_tabScroll];
    
    [self resetTabScrollFrame:self.frame];
}

- (void)initPageScroll {
    
    if (!_dataSource) {
        return;
    }
    
    _pageScroll = [[UIScrollView alloc] initWithFrame:CGRectZero];
    
    for (NSInteger index = 0, count = [_dataSource numberOfPages]; index < count; index++) {
        UIView *contentView = [_dataSource pageView:self viewAtIndex:index];
        [_pageScroll addSubview:contentView];
        [_pageAry addObject:contentView];
    }
 
    _pageScroll.delegate = self;
    _pageScroll.pagingEnabled = YES;
    _pageScroll.scrollsToTop = NO;
    _pageScroll.showsHorizontalScrollIndicator = NO;
    
    [self addSubview:_pageScroll];
    
    [self resetPageScrollFrame:self.frame];
}

- (void)resetTabScroll {
    for (TabItem *item in _tabAry) {
        item.isSelected = NO;
    }
}

#pragma mark - Gesture
- (void)onClickTabItem:(UITapGestureRecognizer *)gesture {
    self.selectedIndex = [[gesture.view.layer valueForKey:tabItemTagKey] intValue];
}

- (void)handleGradualChangeWithContentOffset:(CGPoint)offset {
    CGFloat selectedOffsetX = _selectedIndex * _pageScroll.width;
    
    if (offset.x <= 0 || offset.x >= (_pageScroll.width * (_tabAry.count - 1))
        || fabs(selectedOffsetX - offset.x) >=  (2 * _pageScroll.width)) {
        return;
    }
    
    TabItem *hideItem = [_tabAry objectAtIndex:_selectedIndex];
    TabItem *showItem = [_tabAry objectAtIndex:offset.x > selectedOffsetX ? _selectedIndex + 1 : _selectedIndex - 1];
    
    CGFloat change = fabs(selectedOffsetX - offset.x) / _pageScroll.width;
    [hideItem gradualChangeTo:1 - change];
    [showItem gradualChangeTo:change];
}

#pragma mark - Setter 
- (void)setSelectedIndex:(NSInteger)selectedIndex {
    
    [self resetTabScroll];
    TabItem *selectedItem = [_tabAry objectAtIndex:selectedIndex];
    selectedItem.isSelected = YES;
    
    NSInteger visibleItemIndex = selectedIndex;
    NSInteger tabItemCount = _tabAry.count;
    
    if (visibleItemIndex >= tabItemCount / 2 && visibleItemIndex < tabItemCount - 1) {
        visibleItemIndex++;
    } else if (visibleItemIndex < tabItemCount / 2 && visibleItemIndex > 0) {
        visibleItemIndex--;
    }
    
    [_pageScroll setContentOffset:CGPointMake(_pageScroll.width * selectedIndex, 0) animated:NO];
    
    if (_isTabScrollCanRoll) {
        [_tabScroll scrollRectToVisible:CGRectMake(_tabItemWidth * visibleItemIndex, 0, _tabItemWidth, _tabScrollHeight) animated:YES];
        [_selectedLine setX:selectedIndex * _tabItemWidth + _selectLinePadding - _tabScroll.contentOffset.x];
    }
    else {
        [_selectedLine setX:selectedIndex * _tabItemWidth + _selectLinePadding];
    }
    
    _selectedPage = [_pageAry objectAtIndex:selectedIndex];
    
    if (_selectedIndex != selectedIndex
        && _delegate && [_delegate respondsToSelector:@selector(pageview:didChangeTabFromIndex:toIndex:)])
    {
        [_delegate pageview:self didChangeTabFromIndex:_selectedIndex toIndex:selectedIndex];
    }
    
    _selectedIndex = selectedIndex;
}

- (void)setSeparateLineColor:(UIColor *)separateLineColor {
    _separateLineColor = separateLineColor;
    _separateline.backgroundColor = separateLineColor;
}

- (void)setPageOffset:(CGFloat)pageOffset {
    _pageOffset = pageOffset;
    [self resetPageScrollFrame:self.frame];
}

-(void)setPageScrollEnable:(BOOL)pageScrollEnable {
    _pageScroll.scrollEnabled = pageScrollEnable;
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _pageScroll) {
        [_selectedLine setX:_selectedLineDiffX + scrollView.contentOffset.x * _tabItemWidth /_pageScroll.width];
        _selectedTempX = scrollView.contentOffset.x * _tabItemWidth / _pageScroll.width + _selectLinePadding;

        [self handleGradualChangeWithContentOffset:scrollView.contentOffset];
    }
    
    if (scrollView == _tabScroll) {
        [_selectedLine setX:_selectedTempX - scrollView.contentOffset.x];
        _selectedLineDiffX = _selectLinePadding - scrollView.contentOffset.x;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _pageScroll) {
        self.selectedIndex = scrollView.contentOffset.x / _pageScroll.width;
    }
}

#pragma mark - Reset Frame
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if (_dataSource == nil) {
        return;
    }

    [self resetTabScrollFrame:frame];
    [self resetPageScrollFrame:frame];
    [self resetSeletedLineFrame];
    
    self.selectedIndex = self.selectedIndex;
}

- (void)resetTabScrollFrame:(CGRect)frame
{
    NSInteger pageCount = _tabAry.count;
    
    _tabScroll.frame = CGRectMake(0, 0, frame.size.width, _tabScrollHeight);
    if (_isTabScrollCanRoll && _delegate && [_delegate respondsToSelector:@selector(widthForTabInPageView:)]) {
        _tabItemWidth = [_delegate widthForTabInPageView:self];
    } else {
        _tabItemWidth = _isTabScrollCanRoll ? defaultTabIemWidth : _tabScroll.width / pageCount;
    }
    _tabScroll.contentSize = CGSizeMake(_isTabScrollCanRoll ? _tabItemWidth * pageCount : _tabScroll.width, _tabScrollHeight);
    
    for (NSInteger index = 0; index < _tabAry.count; index++) {
        TabItem *tabItem = _tabAry[index];
        tabItem.frame = CGRectMake(index * _tabItemWidth, 0, _tabItemWidth, _tabScroll.height);
    }
    
}

- (void)resetSeletedLineFrame
{
    _selectedLine.frame = CGRectMake(_selectLinePadding, _tabScrollHeight - 2, _tabItemWidth - 2 * _selectLinePadding, 2);
}

- (void)resetPageScrollFrame:(CGRect)frame
{
    _pageScroll.frame = CGRectMake(0, _tabScrollHeight + _pageOffset, frame.size.width, frame.size.height - _tabScrollHeight - _pageOffset);
    _pageScroll.contentSize = CGSizeMake(_pageAry.count * _pageScroll.width, _pageScroll.height);
    
    for (NSInteger index = 0; index < _pageAry.count; index++) {
        UIView *contentView = _pageAry[index];
        contentView.frame = CGRectMake(index * _pageScroll.width, 0, _pageScroll.width, _pageScroll.height);
    }
}

@end
