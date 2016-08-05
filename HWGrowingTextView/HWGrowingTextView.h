//
//  HWGrowingTextView.h
//  HWGrowingTextView
//
//  Created by 陈智颖 on 16/6/20.
//  Copyright © 2016年 YY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWGrowingTextView;

@protocol HWGrowingTextDelegate <NSObject>

@required
- (void)growingTextView:(UITextView *)textView didChangeHeightTo:(CGFloat)height;

@optional
- (BOOL)growingTextViewShouldBeginEditing:(UITextView *)textView;
- (BOOL)growingTextViewShouldEndEditing:(UITextView *)textView;

- (void)growingTextViewDidBeginEditing:(UITextView *)textView;
- (void)growingTextViewDidEndEditing:(UITextView *)textView;

- (BOOL)growingTextView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)growingTextViewDidChange:(UITextView *)textView;

@end

@interface HWGrowingTextView : UIView

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIView *inputView;
@property (nonatomic) NSRange selectedRange;
@property (nonatomic) UIReturnKeyType returnKeyType;

@property (nonatomic, weak) id<HWGrowingTextDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)setupWithFont:(UIFont *)font textColor:(UIColor *)color maxShowLines:(NSUInteger)lines
             delegate:(id<HWGrowingTextDelegate>)delegate;

@end
