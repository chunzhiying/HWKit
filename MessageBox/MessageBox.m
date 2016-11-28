//
//  LVMessageBox.m
//  YYLite
//
//  Created by graoke on 14-1-15.
//  Copyright (c) 2014年 yy. All rights reserved.
//
#import "NSString+SafeFontSize.h"
#import "MessageBox.h"
#import <QuartzCore/QuartzCore.h>
#import "ATGlobalMacro.h"
#import "ATAppUtils.h"

const int PADDING = 20;
const int MAX_TEXT_WIDTH = 160;
const float SHOW_ANIM_TIME = 0.25;
const int SHOW_DURATION = 2;
const float SHOW_ALPHA = 0.6;
const int MIN_WIDTH = 150;

typedef void(^Block)();

@interface UIApplication (KeyboardView)
- (UIView *)keyboardView;
@end;

@interface MessageBox() {
    UILabel*                 _strLabel;
    UILabel*                 _titleLabel;
    UIImageView*             _background;
    UIImageView*             _typeImage;
    UIActivityIndicatorView* _activityIndicator;
    NSTimer*                 _timer;
    BOOL                     _addNewBox;
    Block                    _block;
}

+ (MessageBox*)shareObject;
- (void)initView;

@end

@implementation MessageBox

+ (MessageBox*)shareObject
{
    static MessageBox* alert = nil;
    if( alert == nil ){
        alert = [[MessageBox alloc] init];
        [alert initView];
    }
    return alert;
}

- (void)initView
{
    self.backgroundColor = [UIColor clearColor];
    
    _background = [[UIImageView alloc] init];
    _background.backgroundColor = [UIColor blackColor];
    _background.layer.cornerRadius = 6;
    
    _typeImage = [[UIImageView alloc] init];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font            = [UIFont systemFontOfSize:16];
    _titleLabel.textColor       = [UIColor whiteColor];
    _titleLabel.textAlignment   = NSTextAlignmentCenter;
    _titleLabel.hidden          = YES;
    
    _strLabel = [[UILabel alloc] init];
    _strLabel.backgroundColor = [UIColor clearColor];
    _strLabel.font			  = [UIFont systemFontOfSize:13];
    _strLabel.minimumScaleFactor = 12;
    _strLabel.numberOfLines	  = 0;
    _strLabel.textColor       = [UIColor whiteColor];
    _strLabel.textAlignment   = NSTextAlignmentCenter;
    _strLabel.lineBreakMode	  = NSLineBreakByCharWrapping;
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activityIndicator.hidden = YES;
    [_activityIndicator startAnimating];
    
    [self addSubview:_background];
    [self addSubview:_typeImage];
    [self addSubview:_strLabel];
    [self addSubview:_titleLabel];
    [self addSubview:_activityIndicator];
    
}

#pragma mark - Main
- (void)showWithText:(NSString *)text andTitle:(NSString *)title weak:(BOOL)weak
         waitingTime:(NSTimeInterval)waiting onDisapper:(Block)block
              inView:(UIView *)parentView
{
    
    if (weak && self.superview != nil ) {
        return;
    }
    
    if (text.length == 0) {
        return;
    }
    
    _block = block;
    _typeImage.hidden = YES;
    _titleLabel.hidden = NO;
    _titleLabel.text = title;
    
    CGSize textSize = [text safeSizeWithFont:_strLabel.font
                           constrainedToSize:CGSizeMake(MAX_TEXT_WIDTH, 1000.0f)
                               lineBreakMode:NSLineBreakByWordWrapping];

    CGSize titleSize = [title safeSizeWithFont:_titleLabel.font
                             constrainedToSize:CGSizeMake(MAX_TEXT_WIDTH, 1000.0f)
                                 lineBreakMode:NSLineBreakByWordWrapping];
    
    float width  = PADDING*2 + MAX(titleSize.width, textSize.width);
    float height = PADDING*2.5 + textSize.height + titleSize.height;
    
    if (width < MIN_WIDTH ) {
        width = MIN_WIDTH;
    }
    UIView *superView = [[UIApplication sharedApplication] keyboardView].superview;
    if(superView == nil ){
        superView = parentView;
    }
    if(parentView == nil){
        superView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    }
    
    NSArray* subViews = [superView subviews];
    for (UIView *item in subViews){
        if( [item isKindOfClass:[MessageBox class]] ){
            [item removeFromSuperview];
        }
    }
    
    float topLeftX;
    float topLeftY;
    if ([ATAppUtils deviceLandscape]) {
        topLeftX = (ATScreenLong - width) / 2;
        topLeftY = (ATScreenShort - height) / 3;
    }else {
        topLeftX = (ATScreenShort - width) / 2;
        topLeftY = (ATScreenLong - height) / 3;
    }
    
    self.frame = CGRectMake(topLeftX, topLeftY, width, height);
    _background.frame = CGRectMake(0, 0, width, height);
    
    float titleTopLeftX = (width - titleSize.width) / 2;
    float titleTopLeftY = PADDING;
    _titleLabel.frame = CGRectMake(titleTopLeftX, titleTopLeftY, titleSize.width, titleSize.height);
    
    float strTopLeftX = (width - textSize.width) /2;
    float strTopLeftY = PADDING*1.5 + titleSize.height;
    _strLabel.text = text;
    _strLabel.frame = CGRectMake(strTopLeftX, strTopLeftY, textSize.width, textSize.height);
    
    _activityIndicator.frame = CGRectMake((width - 20) / 2, titleTopLeftY, 20, 20);
   
    [superView addSubview:self];
    _addNewBox = YES;
    _activityIndicator.hidden = title.length != 0;
    
    [UIView animateWithDuration:SHOW_ANIM_TIME animations:^{
         [self componentShouldShow:YES];
    }];
    
    [self invalidateTimer:_timer];
    if (title.length > 0 || waiting > 0) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:SHOW_DURATION + waiting
                                                  target:self selector:@selector(hideView) userInfo:nil repeats:NO];
    }
}

- (void)hideView {
    _addNewBox = NO;
    [UIView animateWithDuration:SHOW_ANIM_TIME animations:^{
        [self componentShouldShow:NO];
    } completion:^(BOOL finished) {
        if (_addNewBox) {
             [self componentShouldShow:YES];
        } else {
            [self removeFromSuperview];
        }
        if (_block) {
            _block();
            _block = nil;
        }
    }];
}

- (void)componentShouldShow:(BOOL)shouldShow {
    _activityIndicator.alpha = shouldShow ? 1 : 0;
    _background.alpha = shouldShow ? SHOW_ALPHA : 0;
    _strLabel.alpha = shouldShow ? 1 : 0;
    _titleLabel.alpha = shouldShow ? 1 : 0;
}

- (void)invalidateTimer:(NSTimer *)timer {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

#pragma mark - Loading
+ (void)hide {
    MessageBox *box = [MessageBox shareObject];
    [box hideView];
}

+ (void)loading:(NSString *)text
{
    MessageBox *box = [MessageBox shareObject];
    [box showWithText:text andTitle:@"" weak:NO waitingTime:10 onDisapper:nil inView:nil];
}

+ (void)loading:(NSString *)text waiting:(NSTimeInterval)waitingTime timeOut:(void (^)())block
{
    MessageBox *box = [MessageBox shareObject];
    [box showWithText:text andTitle:@"" weak:NO waitingTime:waitingTime onDisapper:block inView:nil];
}

#pragma mark -
+ (void)show:(NSString*)text
{
    MessageBox *box = [MessageBox shareObject];
    [box showWithText:text andTitle:@"提示" weak:NO waitingTime:0 onDisapper:nil inView:nil];
}

+ (void)warning:(NSString*)text
{
    MessageBox *box = [MessageBox shareObject];
    [box showWithText:text andTitle:@"警告" weak:NO waitingTime:0 onDisapper:nil inView:nil];
}

+ (void)error:(NSString*)text
{
    MessageBox *box = [MessageBox shareObject];
    [box showWithText:text andTitle:@"错误" weak:NO waitingTime:0 onDisapper:nil inView:nil];
}

#pragma mark -
+ (void)show:(NSString*)text inView:(UIView *)parentView
{
    MessageBox *box = [MessageBox shareObject];
    [box showWithText:text andTitle:@"提示" weak:NO waitingTime:0 onDisapper:nil inView:parentView];
}

+ (void)warning:(NSString*)text inView:(UIView *)parentView
{
    MessageBox *box = [MessageBox shareObject];
    [box showWithText:text andTitle:@"警告" weak:NO waitingTime:0 onDisapper:nil inView:parentView];
}

+ (void)error:(NSString*)text inView:(UIView *)parentView
{
    MessageBox *box = [MessageBox shareObject];
    [box showWithText:text andTitle:@"错误" weak:NO waitingTime:0 onDisapper:nil inView:parentView];
}

#pragma mark -
+ (void)weakWarning:(NSString *)text onDisapper:(Block)block
{
    MessageBox *box = [MessageBox shareObject];
    [box showWithText:text andTitle:@"提示" weak:YES waitingTime:0 onDisapper:block inView:nil];
}
@end

@implementation UIApplication (KeyboardView)
- (UIView *)keyboardView;
{
    NSArray *windows = [self windows];
    for (UIWindow *window in [windows reverseObjectEnumerator]){
        for (UIView *view in [window subviews]){
            if(!strcmp(object_getClassName(view), "UIPeripheralHostView") || !strcmp(object_getClassName(view), "UIKeyboard")){
                return view;
            }
        }
    }
    return nil;
}

@end
