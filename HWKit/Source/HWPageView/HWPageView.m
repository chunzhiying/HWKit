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

#define TabItemMaxScale 1
#define TabItemMinScale 0.9

#define DefaultSeparateLineColor [UIColor colorWithRed:217.f/255.f green:217.f/255.f blue:217.f/255.f alpha:1]


typedef NS_ENUM(NSUInteger, HWPageTabScrollType) {
    HWPageTabScrollType_Separate,
    HWPageTabScrollType_Combine,
};

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
@property (nonatomic, strong) UIFont *titleFont;
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
        _label.transform = CGAffineTransformMakeScale(TabItemMinScale, TabItemMinScale);
        
        _highlightLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _highlightLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _highlightLabel.font = [UIFont systemFontOfSize:15];
        _highlightLabel.textAlignment = NSTextAlignmentCenter;
        _highlightLabel.textColor = highlightColor;
        _highlightLabel.transform = _label.transform;
        
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
    
    _label.transform = isSelected ? CGAffineTransformMakeScale(TabItemMaxScale, TabItemMaxScale)
                                    : CGAffineTransformMakeScale(TabItemMinScale, TabItemMinScale);
    _highlightLabel.transform = _label.transform;
}

- (void)gradualChangeTo:(CGFloat)value {
    _label.alpha = 1 - value;
    _highlightLabel.alpha = value;
    _dot.hidden = YES;
    
    CGFloat scale = MAX(TabItemMinScale,
                        MIN(TabItemMaxScale,
                            (TabItemMinScale + (TabItemMaxScale - TabItemMinScale) * value)));
    
    _label.transform = CGAffineTransformMakeScale(scale, scale);
    _highlightLabel.transform = _label.transform;
}

- (void)setTitleFont:(UIFont *)titleFont
{
    [_label setFont:titleFont];
    [_highlightLabel setFont:titleFont];
}

@end

@interface HWPageView () <UIScrollViewDelegate> {
    
    HWPageSelectedType _selectedType;
    HWPageTabScrollType _tabScrollType;
    
    HWPageSetting *_setting;
    
    UIView *_separateline;
    UIView *_selectedLine;
    UIScrollView *_tabScroll;
    UIScrollView *_pageScroll;
    
    NSMutableArray *_tabAry;
    NSMutableArray *_pageAry;
}

@property (nonatomic) NSInteger selectedIndex;

@end

@implementation HWPageView

- (instancetype)initWithFrame:(CGRect)frame setting:(HWPageSetting *)setting {
    self = [super initWithFrame:frame];
    if (self) {
        [self initWithSetting:setting];
        _tabScrollType = HWPageTabScrollType_Combine;
        
        [self reloadData];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame tabScroll:(UIScrollView *)tabScroll setting:(HWPageSetting *)setting {
    self = [super initWithFrame:frame];
    if (self) {
        [self initWithSetting:setting];
        _tabScrollType = HWPageTabScrollType_Separate;
        
        _tabScroll = tabScroll;
        _setting.tabHeight = tabScroll.height;
        
        [self reloadData];
    }
    return self;
}

- (void)initWithSetting:(HWPageSetting *)setting {
    _setting = setting;
    
    _dataSource = setting.delegate;
    _selectedType = setting.type;
    
    _tabAry = [NSMutableArray new];
    _pageAry = [NSMutableArray new];
}

#pragma mark - Custom
- (void)reloadData {
    
    for (UIView *subView in _tabScroll.subviews) {
        [subView removeFromSuperview];
    }
    
    for (UIView *subView in _pageScroll.subviews) {
        [subView removeFromSuperview];
    }
    
    [_separateline removeFromSuperview];
    [_selectedLine removeFromSuperview];
    [_pageScroll removeFromSuperview];
    
    if (_tabScrollType == HWPageTabScrollType_Combine) {
        [_tabScroll removeFromSuperview];
    }
    
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

- (void)setTitleFont:(UIFont *)titleFont {
    for (TabItem *item in _tabAry) {
        [item setTitleFont:titleFont];
    }
}

#pragma mark - Init
- (void)initSeparateline {
    _separateline = [[UIView alloc] initWithFrame:CGRectMake(0, _tabScroll.height,
                                                             _tabScroll.width,
                                                             _setting.separateLineHeight)];
    _separateline.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _separateline.backgroundColor = _setting.separateLineColor;
    _separateline.hidden = _tabScrollType == HWPageTabScrollType_Separate;
    [self addSubview:_separateline];
}

- (void)initSelectedLine {
    _selectedLine = [[UIView alloc] initWithFrame:CGRectZero];
    _selectedLine.backgroundColor = _setting.itemHighlightColor;
    _selectedLine.hidden = !(_selectedType == HWPageSelectedType_Line || _selectedType == HWPageSelectedType_Snake);
    _separateline.backgroundColor = _setting.separateLineColor;
    
    [_tabScroll addSubview:_selectedLine];
    [self resetSeletedLineFrame];
}

- (void)initTabScroll {
    
    if (!_dataSource) {
        return;
    }
    
    if (_tabScrollType == HWPageTabScrollType_Combine) {
        _tabScroll = [[UIScrollView alloc] initWithFrame:CGRectZero];
    }
    
    for (NSInteger index = 0, count = [_dataSource numberOfPages]; index < count; index++) {
        TabItem *tabItem = [[TabItem alloc] initWithFrame:CGRectZero
                                                withTitle:[_dataSource pageView:self titleAtIndex:index]
                                          withNormalColor:_setting.itemNormalColor
                                       withHighlightColor:_setting.itemHighlightColor
                                           separatorStyle:_selectedType];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickTabItem:)];
        [tabItem addGestureRecognizer:tap];
        [tabItem.layer setValue:@(index) forKey:tabItemTagKey];
        tabItem.backgroundColor = _setting.tabBgColor;
        [tabItem setTitleFont:_setting.titleFont];
        
        [_tabScroll addSubview:tabItem];
        [_tabAry addObject:tabItem];
    }
    
    _tabScroll.delegate = self;
    _tabScroll.scrollEnabled = _setting.isTabCanScroll;
    _tabScroll.scrollsToTop = NO;
    _tabScroll.showsHorizontalScrollIndicator = NO;
    
    if (_tabScrollType == HWPageTabScrollType_Combine) {
        [self addSubview:_tabScroll];
    }
    
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

- (void)handleSelectedLineChangeWithContentOffset:(CGPoint)offset {
    
    if ((int)offset.x % (int)_pageScroll.width == 0) {
        return;
    }
    
    CGFloat offsetX = offset.x;
    switch (_selectedType) {
        case HWPageSelectedType_Line: {
            [_selectedLine setX:_setting.selectedLinePadding.x
                                + offsetX * _setting.tabItemWidth /_pageScroll.width];
            break;
        }
        case HWPageSelectedType_Snake: {
            CGFloat beginPageOffsetX = _selectedIndex * _pageScroll.width;
            CGFloat beginScrollOffsetX = _selectedIndex * _setting.tabItemWidth;
            
            if (fabs(offset.x - beginPageOffsetX) >= _pageScroll.width ) {
                [_selectedLine setX:_setting.selectedLinePadding.x
                                    + offsetX * _setting.tabItemWidth /_pageScroll.width];
                break;
            }
            
            CGFloat scrollOffsetX = _setting.tabItemWidth * fabs(offsetX - beginPageOffsetX) / _pageScroll.width;
            CGFloat lineOriginalWidth = _setting.tabItemWidth - _setting.selectedLinePadding.x * 2;
            
            if (offset.x > beginPageOffsetX) {
                if (offsetX >= beginPageOffsetX + _pageScroll.width / 2) {
                    CGFloat diff = (scrollOffsetX - _setting.tabItemWidth / 2) * 2;
                    _selectedLine.frame = CGRectMake(_setting.selectedLinePadding.x + beginScrollOffsetX + diff,
                                                     _selectedLine.y,
                                                     lineOriginalWidth + _setting.tabItemWidth - diff,
                                                     _selectedLine.height);
                } else {
                    CGFloat diff = scrollOffsetX * 2;
                    _selectedLine.frame = CGRectMake(_setting.selectedLinePadding.x + beginScrollOffsetX,
                                                     _selectedLine.y,
                                                     lineOriginalWidth + diff,
                                                     _selectedLine.height);
                }
            } else {
                if (offsetX >= beginPageOffsetX - _pageScroll.width / 2) {
                    CGFloat diff = scrollOffsetX * 2;
                    _selectedLine.frame = CGRectMake(_setting.selectedLinePadding.x + beginScrollOffsetX - diff,
                                                     _selectedLine.y,
                                                     lineOriginalWidth + diff,
                                                     _selectedLine.height);
                } else {
                    CGFloat diff = (scrollOffsetX - _setting.tabItemWidth / 2) * 2;
                    _selectedLine.frame = CGRectMake(_setting.selectedLinePadding.x + beginScrollOffsetX - _setting.tabItemWidth,
                                                     _selectedLine.y,
                                                     lineOriginalWidth + _setting.tabItemWidth - diff,
                                                     _selectedLine.height);
                }
            }
            break;
        }
        default:
            break;
    }
}

- (void)handleGradualChangeWithContentOffset:(CGPoint)offset {
    CGFloat selectedOffsetX = _selectedIndex * _pageScroll.width;
    
    BOOL isMoreThenTwoOffset = fabs(selectedOffsetX - offset.x) > 2 * _pageScroll.width;
    BOOL isBetweenTwoOffset = fabs(selectedOffsetX - offset.x) > _pageScroll.width
                            && fabs(selectedOffsetX - offset.x) <= 2 * _pageScroll.width;
    
    if (offset.x <= 0
        || offset.x >= (_pageScroll.width * (_tabAry.count - 1))
        || isMoreThenTwoOffset) {
        return;
    }
    
    TabItem *hideItem = [_tabAry objectAtIndex:_selectedIndex];
    TabItem *showItem = [_tabAry objectAtIndex:offset.x > selectedOffsetX ? _selectedIndex + 1 : _selectedIndex - 1];
    
    if (isBetweenTwoOffset) {
        CGFloat change = fabs(selectedOffsetX - offset.x) / _pageScroll.width;
        [showItem gradualChangeTo:2 - change];
        return;
    }
    
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
    
    if (_setting.isTabCanScroll) {
        [_tabScroll scrollRectToVisible:CGRectMake(_setting.tabItemWidth * visibleItemIndex, 0, _setting.tabItemWidth, _setting.tabHeight) animated:YES];
    }
    [UIView animateWithDuration:0.2 animations:^{
        [_selectedLine setX:selectedIndex * _setting.tabItemWidth + _setting.selectedLinePadding.x];
    }];
    
    
    NSInteger lastIndex = _selectedIndex;
    
    _selectedPage = [_pageAry objectAtIndex:selectedIndex];
    _selectedIndex = selectedIndex;
    
    if (lastIndex != selectedIndex
        && _dataSource && [_dataSource respondsToSelector:@selector(pageview:didChangeTabFromIndex:toIndex:)])
    {
        [_dataSource pageview:self didChangeTabFromIndex:lastIndex toIndex:selectedIndex];
    }
}

-(void)setPageScrollEnable:(BOOL)pageScrollEnable {
    _pageScroll.scrollEnabled = pageScrollEnable;
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _pageScroll) {
        [self handleSelectedLineChangeWithContentOffset:scrollView.contentOffset];
        [self handleGradualChangeWithContentOffset:scrollView.contentOffset];
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
    
    [self changePageToIndex:_selectedIndex];
}

- (void)resetTabScrollFrame:(CGRect)frame
{
    NSInteger pageCount = _tabAry.count;
    
    switch (_tabScrollType) {
        case HWPageTabScrollType_Combine:
            _tabScroll.frame = CGRectMake(0, 0, frame.size.width, _setting.tabHeight);
            break;
        case HWPageTabScrollType_Separate:
            break;
    }
    
    _setting.tabItemWidth = _setting.isTabCanScroll ? _setting.tabItemWidth : _tabScroll.width / pageCount;
    
    _tabScroll.contentSize = CGSizeMake(_setting.isTabCanScroll ? _setting.tabItemWidth * pageCount : _tabScroll.width, _setting.tabHeight);
    
    for (NSInteger index = 0; index < _tabAry.count; index++) {
        TabItem *tabItem = _tabAry[index];
        tabItem.frame = CGRectMake(index * _setting.tabItemWidth, 0, _setting.tabItemWidth, _tabScroll.height);
        
        if (_dataSource && [_dataSource respondsToSelector:@selector(pageView:tabItem:atIndex:)]) {
            [_dataSource pageView:self tabItem:tabItem atIndex:index];
        }
    }
    
}

- (void)resetSeletedLineFrame
{
    _selectedLine.frame = CGRectMake(_selectedIndex * _setting.tabItemWidth + _setting.selectedLinePadding.x,
                                     _setting.tabHeight - _setting.selectedLinePadding.y - _setting.selectedLineHeight,
                                     _setting.tabItemWidth - 2 * _setting.selectedLinePadding.x,
                                     _setting.selectedLineHeight);
    _selectedLine.layer.cornerRadius = _setting.selectedLineHeight / 2;
}

- (void)resetPageScrollFrame:(CGRect)frame
{
    switch (_tabScrollType) {
        case HWPageTabScrollType_Combine:
            _pageScroll.frame = CGRectMake(0, _setting.tabHeight, frame.size.width, frame.size.height - _setting.tabHeight);
            break;
        case HWPageTabScrollType_Separate:
            _pageScroll.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
            break;
    }
    _pageScroll.contentSize = CGSizeMake(_pageAry.count * _pageScroll.width, _pageScroll.height);
    
    for (NSInteger index = 0; index < _pageAry.count; index++) {
        UIView *contentView = _pageAry[index];
        contentView.frame = CGRectMake(index * _pageScroll.width, 0, _pageScroll.width, _pageScroll.height);
    }
}

@end

@implementation HWPageSetting

#define SafeGet($key, $default) \
    [dic objectForKey:$key] == nil ? $default : [dic objectForKey:$key]

#define SafeGetNumber($key, $default) \
     [dic objectForKey:$key] == nil ? @($default) : [dic objectForKey:$key]

#define SafeGetPoint($key, $default) \
    [dic objectForKey:$key] == nil ? [NSValue valueWithCGPoint:$default] : [dic objectForKey:$key]

+ (instancetype)setting:(NSDictionary *)dic {
    HWPageSetting *setting = [HWPageSetting new];
    setting.delegate = dic[HWPageDelegate];
    setting.itemNormalColor = dic[HWPageNormalColor];
    setting.itemHighlightColor = dic[HWPageHighlightColor];
    
    setting.isTabCanScroll = [SafeGetNumber(HWPageTabCanScroll, NO) boolValue];
    setting.type = [SafeGetNumber(HWPageSelectType, HWPageSelectedType_Line) integerValue];
    setting.tabHeight  = [SafeGetNumber(HWPageTabHeight, 36) floatValue];
    setting.tabItemWidth = [SafeGetNumber(HWPageTabItemWidth, 80) floatValue];
    setting.selectedLinePadding = [SafeGetPoint(HWPageSelectedLinePadding, CGPointMake(10, 0)) CGPointValue];
    setting.selectedLineHeight = [SafeGetNumber(HWPageSelectedLineHeight, 2) floatValue];
    setting.separateLineHeight = [SafeGetNumber(HWPageSeparateLineHeight, 0.5) floatValue];
    setting.titleFont = SafeGet(HWPageTitleFont, [UIFont systemFontOfSize:16]);
    setting.separateLineColor = SafeGet(HWPageSeparateLineColor, DefaultSeparateLineColor);
    setting.tabBgColor = SafeGet(HWPageTabBgColor, [UIColor whiteColor]);
    
    return setting;
}

@end

#define ConstStringDefine($Name) \
    NSString * const $Name = @#$Name;

ConstStringDefine(HWPageTabCanScroll)
ConstStringDefine(HWPageSelectType)
ConstStringDefine(HWPageDelegate)
ConstStringDefine(HWPageNormalColor)
ConstStringDefine(HWPageHighlightColor)
ConstStringDefine(HWPageTabHeight)
ConstStringDefine(HWPageSelectedLinePadding)
ConstStringDefine(HWPageSelectedLineHeight)
ConstStringDefine(HWPageSeparateLineHeight)
ConstStringDefine(HWPageTitleFont)
ConstStringDefine(HWPageSeparateLineColor)
ConstStringDefine(HWPageTabBgColor)
ConstStringDefine(HWPageTabItemWidth)

