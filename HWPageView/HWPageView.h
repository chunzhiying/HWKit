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

- (NSString *)pageView:(HWPageView *)pageView titleAtIndex:(NSInteger)index; //support NSAttributedString
- (UIView *)  pageView:(HWPageView *)pageView viewAtIndex:(NSInteger)index;

@end

@protocol HWPageViewDelegate <NSObject>

@optional
- (CGFloat)heightForTabInPageView:(HWPageView *)pageView; //default: 36
- (UIColor *)colorForTabBgInPageView:(HWPageView *)pageView; //default: [UIColor whiteColor]
- (CGFloat)paddingForSelectedLineInPageView:(HWPageView *)pageView; //default: 10

- (void)pageview:(HWPageView *)pageView didChangeTabFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

@end


typedef NS_ENUM(NSInteger, HWPageSelectedType){
    HWPageSelectedType_Dot = 0,
    HWPageSelectedType_Line,
    HWPageSelectedType_None
};


@interface HWPageView : UIView

@property (nonatomic, weak) id<HWPageViewDataSource> dataSource;
@property (nonatomic, weak) id<HWPageViewDelegate> delegate;

@property (nonatomic, strong, readonly) UIView *selectedPage;

@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic) CGFloat pageOffset; //pageView y offset

@property (nonatomic, strong) UIColor *separateLineColor;

- (instancetype)initWithFrame:(CGRect)frame
      withTabTitleNormalColor:(UIColor *)normalColor
   withTabTitleHighlightColor:(UIColor *)highlightColor
               isTabCanScroll:(BOOL)isTabCanScroll
                 selectedType:(HWPageSelectedType)type
                     delegate:(id<HWPageViewDataSource, HWPageViewDelegate>)delegate;

- (void)reloadData;

@end

