//
//  LoadingBox.h
//  yyfe
//
//  Created by chenzy on 15/7/21.
//  Copyright (c) 2015年 yy.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoadingBoxDelegate <NSObject>

- (void)loadingBoxTimeOut;

@end

@interface LoadingBox : UIView

@property (nonatomic) BOOL isHide;
@property (nonatomic, weak) id<LoadingBoxDelegate> delegate;

- (instancetype)initWithDelegate:(id<LoadingBoxDelegate>)delegate;

- (void)showInView:(UIView *)parentView withText:(NSString*)str;
- (void)showInView:(UIView *)parentView withText:(NSString *)str withWaitingTime:(NSTimeInterval)time;

- (void)hide;

@end
