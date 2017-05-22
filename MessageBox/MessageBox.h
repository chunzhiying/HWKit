//
//  LVMessageBox.h
//  YYLite
//
//  Created by graoke on 14-1-15.
//  Copyright (c) 2014年 yy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageBox : UIView

+ (void)show:(NSString*)text;
+ (void)warning:(NSString*)text;
+ (void)error:(NSString*)text;

+ (void)show:(NSString*)text inView:(UIView *)parentView;
+ (void)warning:(NSString*)text inView:(UIView *)parentView;
+ (void)error:(NSString*)text inView:(UIView *)parentView;

// a weak warning won't display at all if a previous MessageBox is still on
+ (void)weakWarning:(NSString *)text onDisapper:(void(^)())block;

#pragma mark Loading
+ (void)loading:(NSString *)text;
+ (void)loading:(NSString *)text waiting:(NSTimeInterval)waitingTime timeOut:(void(^)())block;
+ (void)hide;

#pragma mark Progress
+ (void)show:(NSString *)text progress:(CGFloat)progress;

@end
