//
//  HWPageView.m
//  Demo
//
//  Created by 陈智颖 on 15/11/30.
//  Copyright © 2015年 YY. All rights reserved.
//

#import "HWPageView.h"

#define defaultTabTag 999

#define defaultTabScrollHeight 50
#define defaultTabIemWidth 80

#define defaultSeparateLineColor [UIColor lightGrayColor]
#define defaultTabScrollBgColor [UIColor whiteColor]

#define defaultSelectLineMask 10

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
    UIColor *_normalColor;
    UIColor *_highlightColor;
}

@property (nonatomic) BOOL isSelected;

@end

@implementation TabItem

- (instancetype)initWithFrame:(CGRect)frame
                    withTitle:(NSString *)title
              withNormalColor:(UIColor *)normalColor
           withHighlightColor:(UIColor *)highlightColor
{
    self = [super initWithFrame:frame];
    if (self) {
        _normalColor = normalColor;
        _highlightColor = highlightColor;
        
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _label.font = [UIFont systemFontOfSize:15];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.text = title;
        _label.textColor = normalColor;
        [self addSubview:_label];
    }
    return self;
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    _label.textColor = isSelected ? _highlightColor : _normalColor;
}

@end

@interface HWPageView () <UIScrollViewDelegate> {
    
    UIView *_separateline;
    UIScrollView *_tabScroll;
    UIScrollView *_pageScroll;
    
    NSMutableArray *_tabAry;
    NSMutableArray *_pageAry;
    
    UIColor *_tabTitleNormalColor;
    UIColor *_tabTitleHighlightColor;
    
    CGFloat _tabScrollHeight;
    CGFloat _tabItemWidth;
    
    CGFloat _selectedLineDiffX;
    CGFloat _selectedTempX;
    
    UIView *_selectedLine;
    BOOL _isTabScrollCanRoll;
}

@end

@implementation HWPageView

- (instancetype)initWithFrame:(CGRect)frame
      withTabTitleNormalColor:(UIColor *)normalColor
   withTabTitleHighlightColor:(UIColor *)highlightColor
               isTabCanScroll:(BOOL)isTabCanScroll
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _tabScrollHeight = defaultTabScrollHeight;
        if (_delegate && [_delegate respondsToSelector:@selector(heightForTab)]) {
            _tabScrollHeight = [_delegate heightForTab];
        }

        _tabAry = [NSMutableArray new];
        _pageAry = [NSMutableArray new];
        
        _tabTitleNormalColor = normalColor;
        _tabTitleHighlightColor = highlightColor;
        _isTabScrollCanRoll = isTabCanScroll;

    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [self removeAllView];
    [self initTabScroll];
    [self initPageScroll];
    [self initSeparateline];
    [self initSelectedLine];
}

- (void)removeAllView {
    [_selectedLine removeFromSuperview];
    [_tabScroll removeFromSuperview];
    [_pageScroll removeFromSuperview];
    [_selectedLine removeFromSuperview];
}

#pragma mark - Custom Method
- (void)initSeparateline {
    _separateline = [[UIView alloc] initWithFrame:CGRectMake(0, _tabScroll.bounds.size.height, _tabScroll.bounds.size.width, 0.5)];
    _separateline.backgroundColor = defaultSeparateLineColor;
    [self addSubview:_separateline];
}

- (void)initSelectedLine {
    _selectedLine = [[UIView alloc] initWithFrame:CGRectMake(defaultSelectLineMask, _tabScrollHeight - 1, _tabItemWidth - 2 * defaultSelectLineMask, 2)];
    _selectedLine.backgroundColor = _tabTitleHighlightColor;
    [self addSubview:_selectedLine];
    
    _selectedLineDiffX = defaultSelectLineMask;
    _selectedTempX = _selectedLine.frame.origin.x;
}

- (void)initTabScroll {
    
    _tabScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, _tabScrollHeight)];
    
    _tabItemWidth = _isTabScrollCanRoll ? defaultTabIemWidth : _tabScroll.bounds.size.width / [_dataSource numberOfPages];
    
    UIColor *tabBgColor = defaultTabScrollBgColor;
    if (_delegate && [_delegate respondsToSelector:@selector(colorForTabBg)]) {
        tabBgColor = [_delegate colorForTabBg];
    }
    
    for (NSInteger index = 0; index < [_dataSource numberOfPages]; index++) {
        TabItem *tabItem = [[TabItem alloc] initWithFrame:CGRectMake(index * _tabItemWidth, 0, _tabItemWidth, _tabScroll.bounds.size.height)
                                                withTitle:[_dataSource pageView:self titleAtIndex:index]
                                          withNormalColor:_tabTitleNormalColor
                                       withHighlightColor:_tabTitleHighlightColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickTabItem:)];
        [tabItem addGestureRecognizer:tap];
        tabItem.tag = defaultTabTag + index;
        tabItem.backgroundColor = tabBgColor;
        
        [_tabScroll addSubview:tabItem];
        [_tabAry addObject:tabItem];
    }
    
    _tabScroll.delegate = self;
    _tabScroll.scrollEnabled = _isTabScrollCanRoll;
    _tabScroll.scrollsToTop = NO;
    _tabScroll.showsHorizontalScrollIndicator = NO;
    _tabScroll.contentSize = CGSizeMake(_isTabScrollCanRoll ? _tabItemWidth * [_dataSource numberOfPages] : _tabScroll.bounds.size.width, _tabScrollHeight);
    
    [self addSubview:_tabScroll];
}

- (void)initPageScroll {
    
    _pageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _tabScrollHeight, self.frame.size.width, self.frame.size.height - _tabScrollHeight)];
    
    for (NSInteger index = 0; index < [_dataSource numberOfPages]; index++) {
        UIView *contentView = [_dataSource pageView:self viewAtIndex:index];
        contentView.frame = CGRectMake(index * _pageScroll.bounds.size.width, 0, _pageScroll.bounds.size.width, _pageScroll.bounds.size.height);
        
        [_pageScroll addSubview:contentView];
        [_pageAry addObject:contentView];
    }
 
    _pageScroll.delegate = self;
    _pageScroll.pagingEnabled = YES;
    _pageScroll.scrollsToTop = NO;
    _pageScroll.contentSize = CGSizeMake([_dataSource numberOfPages] * _pageScroll.bounds.size.width, _pageScroll.bounds.size.height);
    
    [self addSubview:_pageScroll];
}

- (void)resetTabScroll {
    for (TabItem *item in _tabAry) {
        item.isSelected = NO;
    }
}

#pragma mark - Gesture
- (void)onClickTabItem:(UITapGestureRecognizer *)gesture {
    self.selectedIndex = gesture.view.tag - defaultTabTag;
}

#pragma mark - Setter 
- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    
    [self resetTabScroll];
    TabItem *selectedItem = [_tabAry objectAtIndex:selectedIndex];
    selectedItem.isSelected = YES;
    
    NSInteger visibleItemIndex = selectedIndex;
    if (visibleItemIndex >= [_dataSource numberOfPages] / 2 && visibleItemIndex < [_dataSource numberOfPages] - 1) {
        visibleItemIndex++;
    } else if (visibleItemIndex < [_dataSource numberOfPages] / 2 && visibleItemIndex > 0) {
        visibleItemIndex--;
    }
    
    [_pageScroll setContentOffset:CGPointMake(_pageScroll.bounds.size.width * selectedIndex, 0) animated:NO];
    [_tabScroll scrollRectToVisible:CGRectMake(_tabItemWidth * visibleItemIndex, 0, _tabItemWidth, _tabScrollHeight) animated:YES];
    
    
    _selectedPage = [_pageAry objectAtIndex:selectedIndex];
    if (_delegate && [_delegate respondsToSelector:@selector(pageview:didChangeTabToIndex:)]) {
        [_delegate pageview:self didChangeTabToIndex:selectedIndex];
    }
}

- (void)setSeparateLineColor:(UIColor *)separateLineColor {
    _separateLineColor = separateLineColor;
    _separateline.backgroundColor = separateLineColor;
}


#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _pageScroll) {
        [_selectedLine setX:_selectedLineDiffX + scrollView.contentOffset.x * _tabItemWidth / _pageScroll.bounds.size.width];
        _selectedTempX = scrollView.contentOffset.x * _tabItemWidth / _pageScroll.bounds.size.width + defaultSelectLineMask;
    }
    
    if (scrollView == _tabScroll) {
        [_selectedLine setX:_selectedTempX - scrollView.contentOffset.x];
        _selectedLineDiffX = defaultSelectLineMask - scrollView.contentOffset.x;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _pageScroll) {
        self.selectedIndex = scrollView.contentOffset.x / _pageScroll.bounds.size.width;
    }
}

@end
