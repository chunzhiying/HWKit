//
//  HWScrollTabView.h
//  yyfe
//
//  Created by 陈智颖 on 16/9/7.
//  Copyright © 2016年 yy.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWScrollTagView;

@protocol HWSelectable <NSObject>

@required @property (nonatomic) NSUInteger index;
@optional @property (nonatomic) BOOL isSelected; //重写setter方法定制选中的样式

@end

@protocol HWScrollTagDelegate <NSObject>

@required
- (NSArray<UIView<HWSelectable> *> *)contentViewsForScrollTagView:(HWScrollTagView *)tagView;

@optional
- (BOOL)isFlexibleItemWidth;
- (CGFloat)paddingOfScrollTagView:(HWScrollTagView *)tagView; //default: 15
- (CGFloat)spacingOfScrollTagView:(HWScrollTagView *)tagView; //default: 12

- (void)scrollTagViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)scrollTagViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)scrollTagViewDidEndDecelerating:(UIScrollView *)scrollView;

- (void)scrollTagView:(HWScrollTagView *)scrollTagView
         didClickItem:(UIView<HWSelectable> *)item
                index:(NSUInteger)index;

@end

@interface HWScrollTagView : UIView

@property (nonatomic, weak) id<HWScrollTagDelegate> delegate;
@property (nonatomic, readonly) NSUInteger seletedIndex;

- (instancetype)initWithFrame:(CGRect)frame seperatorLineHidden:(BOOL)isHidden delegate:(id<HWScrollTagDelegate>)delegate;

- (void)changePageToIndex:(NSInteger)index;
- (void)reloadData;

@end
