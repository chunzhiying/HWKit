//
//  HWPageView.h
//  Demo
//
//  Created by 陈智颖 on 15/11/30.
//  Copyright © 2015年 YY. All rights reserved.
//

#import <UIKit/UIKit.h>

#define Require
#define Optional
#define HWPagePoint(x, y) [NSValue valueWithCGPoint:CGPointMake(x, y)]

@class HWPageView;

@protocol HWPageViewDataSource <NSObject>

@required
- (NSInteger)numberOfPages;

- (NSString *)pageView:(HWPageView *)pageView titleAtIndex:(NSInteger)index; //support NSAttributedString
- (UIView *)  pageView:(HWPageView *)pageView viewAtIndex:(NSInteger)index;

@optional
- (void)pageView:(HWPageView *)pageView tabItem:(UIView *)view atIndex:(NSInteger)index;
- (void)pageview:(HWPageView *)pageView didChangeTabFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

@end

typedef NS_ENUM(NSInteger, HWPageSelectedType){
    HWPageSelectedType_Dot = 0,
    HWPageSelectedType_Snake = 1,
    HWPageSelectedType_Line = 2,
    HWPageSelectedType_None = 3
};


@interface HWPageSetting : NSObject

Require @property (nonatomic, weak) id<HWPageViewDataSource> delegate;
Require @property (nonatomic, strong) UIColor *itemNormalColor;
Require @property (nonatomic, strong) UIColor *itemHighlightColor;

Optional @property (nonatomic) HWPageSelectedType type; //default: HWPageSelectedType_Line
Optional @property (nonatomic) BOOL isTabCanScroll; //default: NO
Optional @property (nonatomic) CGFloat tabHeight; //default: 36
Optional @property (nonatomic) CGFloat tabItemWidth; //default: 80
Optional @property (nonatomic) CGPoint selectedLinePadding; //default: (10, 0) (Left&Right, Bottom)
Optional @property (nonatomic) CGFloat selectedLineHeight; //default: 2
Optional @property (nonatomic) CGFloat separateLineHeight; //default: 0.5
Optional @property (nonatomic, strong) UIFont *titleFont; //default: 16 for highlight, normal scale 0.9.
Optional @property (nonatomic, strong) UIColor *separateLineColor; //default: DefaultSeparateLineColor
Optional @property (nonatomic, strong) UIColor *tabBgColor; //default: [UIColor whiteColor]

+ (instancetype)setting:(NSDictionary *)dic;

@end

@interface HWPageView : UIView

@property (nonatomic, weak) id<HWPageViewDataSource> dataSource;

@property (nonatomic, strong, readonly) UIView *selectedPage;
@property (nonatomic, assign, readonly) NSInteger selectedIndex;

@property (nonatomic) BOOL pageScrollEnable;

- (instancetype)initWithFrame:(CGRect)frame
                      setting:(HWPageSetting *)setting;

- (instancetype)initWithFrame:(CGRect)frame
                    tabScroll:(UIScrollView *)tabScroll
                      setting:(HWPageSetting *)setting;

- (void)changePageToIndex:(NSInteger)index;
- (void)reloadData;

@end

#pragma mark - 

#define ConstStringExtern(atName) \
    extern NSString * const atName;

ConstStringExtern(HWPageDelegate)               //id<HWPageViewDataSource>
ConstStringExtern(HWPageNormalColor)            //UIColor
ConstStringExtern(HWPageHighlightColor)         //UIColor

ConstStringExtern(HWPageTabCanScroll)           //@(BOOL)
ConstStringExtern(HWPageSelectType)             //@(NSInteger)
ConstStringExtern(HWPageTabHeight)              //@(CGFloat)
ConstStringExtern(HWPageTabItemWidth)           //@(CGFloat)
ConstStringExtern(HWPageSelectedLinePadding)    //HWPagePoint
ConstStringExtern(HWPageSelectedLineHeight)     //@(CGFloat)
ConstStringExtern(HWPageSeparateLineHeight)     //@(CGFloat)
ConstStringExtern(HWPageTitleFont)              //UIFont
ConstStringExtern(HWPageSeparateLineColor)      //UIColor
ConstStringExtern(HWPageTabBgColor)             //UIColor

