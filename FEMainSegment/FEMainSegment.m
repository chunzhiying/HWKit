//
//  FEMainSegment.m
//  yyfe
//
//  Created by 陈智颖 on 16/6/14.
//  Copyright © 2016年 yy.com. All rights reserved.
//

#import "FEMainSegment.h"
#import "UIView+Corner.h"
#import "NSObject+Color.h"
#import "ColorUtil.h"

#define CornerRadius 3
#define SegmentWidth 74
#define SegmentHeight 29

#define NormalColor [ColorUtil colorWithRGBA:0x2f7ac6ff]
#define SelectedColor [UIColor whiteColor]
#define textNormalColor [UIColor whiteColor]
#define textSelectedColor DefaultTintColor

@implementation FEMainSegment

- (instancetype)initWithTitles:(NSArray<NSString *> *)titles {
    self = [super initWithItems:titles];
    if (self) {
        [self customize];
    }
    return self;
}

- (void)customize {

    self.layer.cornerRadius = CornerRadius;
    self.layer.masksToBounds = YES;
    
    UIView *left = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CornerRadius, SegmentHeight)];
    left.backgroundColor = SelectedColor;
    [left addCornerWithRadius:CornerRadius withCornerColor:NormalColor
            byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight
              withBorderWidth:0 withBorderColor:nil];
    
    
    UIView *right = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CornerRadius, SegmentHeight)];
    right.backgroundColor = SelectedColor;
    [right addCornerWithRadius:CornerRadius withCornerColor:NormalColor
            byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft
              withBorderWidth:0 withBorderColor:nil];
    
   
    UIView *selected = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CornerRadius, SegmentHeight)];
    selected.backgroundColor = NormalColor;
    
    UIImage *leftImg = [self getImageFromView:left];
    UIImage *rightImg = [self getImageFromView:right];
    UIImage *selectedImg = [self getImageFromView:selected];
    
    UIImage *normalBgImg = [UIImage imageWithColor:NormalColor size:CGSizeMake(SegmentWidth, SegmentHeight)];
    UIImage *selectedBgImg = [UIImage imageWithColor:SelectedColor size:CGSizeMake(SegmentWidth, SegmentHeight)];
    UIImage *highlightBgImg = [UIImage imageWithColor:NormalColor size:CGSizeMake(SegmentWidth, SegmentHeight)];
    
    [self setBackgroundImage:normalBgImg
                       forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self setBackgroundImage:selectedBgImg
                       forState:UIControlStateSelected  barMetrics:UIBarMetricsDefault];
    [self setBackgroundImage:highlightBgImg
                    forState:UIControlStateSelected | UIControlStateHighlighted barMetrics:UIBarMetricsDefault];

    
    [self setDividerImage:rightImg
      forLeftSegmentState:UIControlStateNormal
        rightSegmentState:UIControlStateSelected
               barMetrics:UIBarMetricsDefault];
    
    [self setDividerImage:leftImg
      forLeftSegmentState:UIControlStateSelected
        rightSegmentState:UIControlStateNormal
               barMetrics:UIBarMetricsDefault];
    
    [self setDividerImage:rightImg
      forLeftSegmentState:UIControlStateHighlighted
        rightSegmentState:UIControlStateSelected
               barMetrics:UIBarMetricsDefault];
    
    [self setDividerImage:leftImg
      forLeftSegmentState:UIControlStateSelected
        rightSegmentState:UIControlStateHighlighted
               barMetrics:UIBarMetricsDefault];
    
    [self setDividerImage:selectedImg
      forLeftSegmentState:UIControlStateNormal
        rightSegmentState:UIControlStateNormal
               barMetrics:UIBarMetricsDefault];
    
    for (NSInteger i = 0; i < self.numberOfSegments; i++) {
        [self setWidth:SegmentWidth forSegmentAtIndex:i];
    }
    
    
    [self setTitleTextAttributes:@{NSForegroundColorAttributeName : textNormalColor,
                                   NSFontAttributeName : [UIFont systemFontOfSize:15]} forState:UIControlStateNormal];
    [self setTitleTextAttributes:@{NSForegroundColorAttributeName : textSelectedColor,
                                   NSFontAttributeName : [UIFont systemFontOfSize:15]} forState:UIControlStateSelected];

}

- (UIImage *)getImageFromView:(UIView *)view {

    UIImage *result;
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [CATransaction setDisableActions:YES];
    [super touchesEnded:touches withEvent:event];
}


@end
