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
- (CGFloat)paddingOfScrollTagView:(HWScrollTagView *)tagView; //default: 15
- (CGFloat)spacingOfScrollTagView:(HWScrollTagView *)tagView; //default: 12
- (void)scrollTagView:(HWScrollTagView *)scrollTagView didClickItem:(UIView<HWSelectable> *)item index:(NSUInteger)index;
- (void)scrollTagViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollTagViewDidEndDecelerating:(UIScrollView *)scrollView;

@end

@interface HWScrollTagView : UIView

@property (nonatomic, weak) id<HWScrollTagDelegate> delegate;
@property (nonatomic) NSUInteger seletedIndex;

- (instancetype)initWithFrame:(CGRect)frame seperatorLineHidden:(BOOL)isHidden delegate:(id<HWScrollTagDelegate>)delegate;
- (void)reloadData;

@end
