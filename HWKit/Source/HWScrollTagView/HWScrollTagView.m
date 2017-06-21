//
//  HWScrollTabView.m
//  yyfe
//
//  Created by 陈智颖 on 16/9/7.
//  Copyright © 2016年 yy.com. All rights reserved.
//

#import "HWScrollTagView.h"
#import "HWHelper.h"

@interface HWScrollTagView ()<UIScrollViewDelegate> {
    CGFloat _padding;
    CGFloat _spacing;
    NSArray<UIView<HWSelectable> *> *_items;
    BOOL _seperatorLineHidden;
}

@property (nonatomic) NSUInteger seletedIndex;
@property (nonatomic, strong) UIScrollView *scroll;
@property (nonatomic, strong) UIView *seperatorView;

@end

@implementation HWScrollTagView

- (instancetype)initWithFrame:(CGRect)frame seperatorLineHidden:(BOOL)isHidden delegate:(id<HWScrollTagDelegate>)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _delegate = delegate;
        _padding = (_delegate && [_delegate respondsToSelector:@selector(paddingOfScrollTagView:)])
        ? [_delegate paddingOfScrollTagView:self] : 15;
        _spacing = (_delegate && [_delegate respondsToSelector:@selector(spacingOfScrollTagView:)])
        ? [_delegate spacingOfScrollTagView:self] : 12;
        _seperatorLineHidden = isHidden;
        [self initView];
    }
    return self;
}

- (void)initView {
    
    _scroll = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scroll.scrollsToTop = NO;
    _scroll.showsVerticalScrollIndicator = NO;
    _scroll.showsHorizontalScrollIndicator = NO;
    _scroll.delegate = self;
    
    _items = [_delegate contentViewsForScrollTagView:self];
    
    if (_items == nil) {
        return;
    }

    CGFloat padding = _padding;
    CGFloat spacing = _spacing;
    
    CGFloat totalItemWidth = 0;
    for (UIView *item in _items) {
        totalItemWidth += item.width;
    }
    
    CGFloat totalWidth = totalItemWidth + (_items.count - 1) * spacing + 2 * padding;
    
    if (self.bounds.size.width >= totalWidth) {
        padding = (self.bounds.size.width - totalItemWidth) / (_items.count + 1);
        spacing = padding;
        _scroll.contentSize = self.bounds.size;
        
    } else {
        _scroll.contentSize = CGSizeMake(totalWidth, self.bounds.size.height);
    }
    
    
    CGFloat lastItemMaxX = 0;
    for (NSUInteger index = 0; index < _items.count; index++) {
        UIView<HWSelectable> *item = [_items objectAtIndex:index];
        if ([item respondsToSelector:@selector(setIsSelected:)]) {
            [item addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickItem:)]];
            item.userInteractionEnabled = YES;
        }
        item.index = index;
        
        item.frame = CGRectMake(index * (spacing + item.bounds.size.width) + padding,
                                (self.bounds.size.height - item.bounds.size.height) / 2,
                                item.bounds.size.width, item.bounds.size.height);
        
        if ([_delegate respondsToSelector:@selector(isFlexibleItemWidth)]) {
            if ([_delegate isFlexibleItemWidth]) {
                item.frame = CGRectMake( index * spacing + lastItemMaxX +  padding,
                                        (self.bounds.size.height - item.bounds.size.height) / 2,
                                        item.bounds.size.width, item.bounds.size.height);
                lastItemMaxX += item.bounds.size.width;
            }
        }
        
        [_scroll addSubview:item];
    }
    
    [self addSubview:_scroll];
    
    if (!_seperatorLineHidden) {
        if (_seperatorView) {
            [self bringSubviewToFront:_seperatorView];
        } else {
            CGFloat seperatorViewHeight = 0.5;
            _seperatorView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - seperatorViewHeight, self.bounds.size.width, seperatorViewHeight)];
            _seperatorView.backgroundColor = DefaultSeperatorViewColor;
            [self addSubview:_seperatorView];
        }
    }
}

- (void)changePageToIndex:(NSInteger)index {
    [self setSeletedIndex:index];
}

- (void)reloadData {
    _items = nil;
    for (UIView *sub in _scroll.subviews) {
        [sub removeFromSuperview];
    }
    [_scroll removeFromSuperview];
    [self initView];
}

- (void)onClickItem:(UITapGestureRecognizer *)tap {
    
    UIView<HWSelectable> *item = (UIView<HWSelectable> *)tap.view;
    self.seletedIndex = [_items indexOfObject:item];
    
}

#pragma mark - scrollView_delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([_delegate respondsToSelector:@selector(scrollTagViewWillBeginDragging:)]) {
        [_delegate scrollTagViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([_delegate respondsToSelector:@selector(scrollTagViewDidEndDragging:willDecelerate:)]) {
        [_delegate scrollTagViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([_delegate respondsToSelector:@selector(scrollTagViewDidEndDecelerating:)]) {
        [_delegate scrollTagViewDidEndDecelerating:scrollView];
    }
}

#pragma mark - Setter
- (void)setSeletedIndex:(NSUInteger)seletedIndex {
    if (!_items.count) {
        return;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(scrollTagView:didClickItem:index:)]) {
        [_delegate scrollTagView:self didClickItem:[_items objectAtIndex:seletedIndex]
                       index:seletedIndex];
    }
    
    _seletedIndex = seletedIndex;
    
    for (int i = 0; i < _items.count; i++) {
        UIView<HWSelectable> *item = [_items objectAtIndex:i];
        if (i == seletedIndex) {
            item.isSelected = YES;
        } else {
            item.isSelected = NO;
        }
    }
    
    UIView *subView = _items[seletedIndex];
    CGFloat subViewX = subView.frame.origin.x;
    CGFloat subViewW = subView.frame.size.width;
    CGFloat contentX = subViewX + subViewW / 2 - ATScreenWidth / 2;
    contentX = MAX(0, MIN(contentX, _scroll.contentSize.width - ATScreenWidth));
    [_scroll setContentOffset:CGPointMake(contentX, 0) animated:YES];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    _scroll.backgroundColor = backgroundColor;
}

@end
