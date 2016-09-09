//
//  HWScrollTabView.m
//  yyfe
//
//  Created by 陈智颖 on 16/9/7.
//  Copyright © 2016年 yy.com. All rights reserved.
//

#import "HWScrollTagView.h"
#import "NSArray+FunctionalType.h"

@interface HWScrollTagView () {
    CGFloat _padding;
    CGFloat _spacing;
    NSArray<UIView<HWSelectable> *> *_items;
}

@property (nonatomic, strong) UIScrollView *scroll;

@end

@implementation HWScrollTagView

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<HWScrollTagDelegate>)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _delegate = delegate;
        _padding = (_delegate && [_delegate respondsToSelector:@selector(paddingOfScrollTagView:)])
        ? [_delegate paddingOfScrollTagView:self] : 15;
        _spacing = (_delegate && [_delegate respondsToSelector:@selector(spacingOfScrollTagView:)])
        ? [_delegate spacingOfScrollTagView:self] : 12;
        [self initView];
    }
    return self;
}

- (void)initView {
    
    _scroll = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scroll.scrollsToTop = NO;
    _scroll.showsVerticalScrollIndicator = NO;
    _scroll.showsHorizontalScrollIndicator = NO;
    
    _items = [_delegate contentViewsForScrollTagView:self];

    CGFloat padding = _padding;
    CGFloat spacing = _spacing;
    
    CGFloat totalItemWidth = [_items.reduce(@0, ^(NSNumber *result, UIView *item) {
        return @([result floatValue] + item.bounds.size.width);
    }) floatValue];
    CGFloat totalWidth = totalItemWidth + (_items.count - 1) * spacing + 2 * padding;
    
    if (self.bounds.size.width >= totalWidth) {
        padding = (self.bounds.size.width - totalItemWidth) / (_items.count + 1);
        spacing = padding;
        _scroll.contentSize = self.bounds.size;
        
    } else {
        _scroll.contentSize = CGSizeMake(totalWidth, self.bounds.size.height);
    }
    
    _items.mapWithIndex(^(UIView<HWSelectable> *item, NSUInteger index) {
        [item addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickItem:)]];
        item.userInteractionEnabled = YES;
        item.index = index;
        item.frame = CGRectMake(index * (spacing + item.bounds.size.width) + padding,
                                (self.bounds.size.height - item.bounds.size.height) / 2,
                                item.bounds.size.width, item.bounds.size.height);
        [_scroll addSubview:item];
        return item;
    });
    
    [self addSubview:_scroll];
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
    for (UIView<HWSelectable> *element in _items) {
        element.isSelected = NO;
    }
    item.isSelected = YES;
    
    if (_delegate && [_delegate respondsToSelector:@selector(scrollTagView:didClickItem:index:)]) {
        [_delegate scrollTagView:self didClickItem:item index:item.index];
    }
}

@end
