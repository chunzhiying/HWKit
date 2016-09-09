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

@property (nonatomic) NSUInteger index;
@property (nonatomic) BOOL isSelected; //重写setter方法定制选中的样式

@end

@protocol HWScrollTagDelegate <NSObject>

@required
- (NSArray<UIView<HWSelectable> *> *)contentViewsForScrollTagView:(HWScrollTagView *)tagView;

@optional
- (CGFloat)paddingOfScrollTagView:(HWScrollTagView *)tagView; //default: 15
- (CGFloat)spacingOfScrollTagView:(HWScrollTagView *)tagView; //default: 12
- (void)scrollTagView:(HWScrollTagView *)scrollTagView didClickItem:(UIView<HWSelectable> *)item index:(NSUInteger)index;

@end

@interface HWScrollTagView : UIView

@property (nonatomic, weak) id<HWScrollTagDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<HWScrollTagDelegate>)delegate;
- (void)reloadData;

@end
