//
//  HWPageView.h
//  Demo
//
//  Created by 陈智颖 on 15/11/30.
//  Copyright © 2015年 YY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWPageView;

@protocol HWPageViewDataSource <NSObject>

@required
- (NSInteger)numberOfPages;

- (NSString *)pageView:(HWPageView *)pageView titleAtIndex:(NSInteger)index;
- (UIView *)  pageView:(HWPageView *)pageView viewAtIndex:(NSInteger)index;

@end

@protocol HWPageViewDelegate <NSObject>

@optional
- (CGFloat)heightForTab;
- (UIColor *)colorForTabBg;

- (void)pageview:(HWPageView *)pageView didChangeTabToIndex:(NSInteger)index;

@end


@interface HWPageView : UIView

@property (nonatomic, weak) id<HWPageViewDataSource> dataSource;
@property (nonatomic, weak) id<HWPageViewDelegate> delegate;

@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic, strong, readonly) UIView *selectedPage;

@property (nonatomic, strong) UIColor *separateLineColor;


- (instancetype)initWithFrame:(CGRect)frame
      withTabTitleNormalColor:(UIColor *)normalColor
   withTabTitleHighlightColor:(UIColor *)highlightColor
               isTabCanScroll:(BOOL)isTabCanScroll;


@end

