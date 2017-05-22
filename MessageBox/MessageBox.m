//
//  LVMessageBox.m
//  YYLite
//
//  Created by graoke on 14-1-15.
//  Copyright (c) 2014年 yy. All rights reserved.
//
#import "NSString+Addition.h"
#import "MessageBox.h"
#import <QuartzCore/QuartzCore.h>
#import "ATGlobalMacro.h"
#import "ATAppUtils.h"
#import "UICenter.h"
#import "AppDefines.h"

const int PADDING = 20;
const int MAX_TEXT_WIDTH = 160;
const float SHOW_ANIM_TIME = 0.25;
const int SHOW_DURATION = 2;
const float SHOW_ALPHA = 0.6;
const int MIN_WIDTH = 150;
const float SHAPE_RADIUS = 25;

typedef void(^Block)();

typedef NS_ENUM(NSUInteger, MessageBoxType) {
    MessageBoxType_Unknow,
    MessageBoxType_Normal,
    MessageBoxType_Loading,
    MessageBoxType_Progress
};

@interface UIApplication (KeyboardView)
- (UIView *)keyboardView;
@end;

@interface MessageBox() {
    CAShapeLayer *           _progressShape;
    UILabel*                 _strLabel;
    UILabel*                 _titleLabel;
    UIImageView*             _background;
    UIImageView*             _typeImage;
    UIActivityIndicatorView* _activityIndicator;
    NSTimer*                 _timer;
    BOOL                     _addNewBox;
    Block                    _block;
}

@property (nonatomic) MessageBoxType type;

+ (MessageBox*)shareObject;
- (void)initView;

@end

@implementation MessageBox

+ (MessageBox*)shareObject
{
    static MessageBox *singleInstance;
    static dispatch_once_t onec;
    dispatch_once(&onec, ^{
        singleInstance = [[MessageBox alloc] init];
        [singleInstance initView];
        
        ATWeakify(singleInstance)
        HWRxNoCenter.Rx(UIDeviceOrientationDidChangeNotification).response(^{ ATStrongify(singleInstance)
            if (singleInstance.type == MessageBoxType_Normal) {
                [singleInstance removeFromSuperview];
            }
        });
    });
    return singleInstance;
}

- (void)initView
{
    self.backgroundColor = [UIColor clearColor];
    
    _background = [[UIImageView alloc] init];
    _background.backgroundColor = [UIColor blackColor];
    _background.layer.cornerRadius = 6;
    
    _typeImage = [[UIImageView alloc] init];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SHAPE_RADIUS * 2, SHAPE_RADIUS * 2)];
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
    
    _progressShape = [CAShapeLayer layer];
    _progressShape.frame = CGRectMake(0, 0, SHAPE_RADIUS * 2, SHAPE_RADIUS * 2);
    _progressShape.fillColor = [UIColor clearColor].CGColor;
    _progressShape.strokeColor = [UIColor whiteColor].CGColor;
    _progressShape.path = [UIBezierPath bezierPathWithRoundedRect:_titleLabel.bounds cornerRadius:SHAPE_RADIUS].CGPath;
    _progressShape.lineWidth = 2;
    _progressShape.strokeEnd = 0;
    
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
              inView:(UIView *)parentView type:(MessageBoxType)type
{
    
    if (weak && self.superview != nil ) {
        return;
    }
    
    if (text.length == 0) {
        return;
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
        if( [item isKindOfClass:[MessageBox class]] ) {
            [item removeFromSuperview];
        }
    }
    
    _type = type;
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
    
    if (type == MessageBoxType_Progress) {
        titleSize = CGSizeMake(SHAPE_RADIUS * 2, SHAPE_RADIUS * 2);
        [_titleLabel.layer addSublayer:_progressShape];
    }
    
    float width  = MAX(MIN_WIDTH, PADDING*2 + MAX(titleSize.width, textSize.width));
    float height = PADDING*2.5 + textSize.height + titleSize.height;
    
    float titleTopLeftX = (width - titleSize.width) / 2;
    float titleTopLeftY = PADDING;
    _titleLabel.frame = CGRectMake(titleTopLeftX, titleTopLeftY, titleSize.width, titleSize.height);
    
    
    float strTopLeftX = (width - textSize.width) /2;
    float strTopLeftY = PADDING*1.5 + titleSize.height;
    _strLabel.text = text;
    _strLabel.frame = CGRectMake(strTopLeftX, strTopLeftY, textSize.width, textSize.height);
    
    _activityIndicator.frame = CGRectMake((width - 20) / 2, titleTopLeftY, 20, 20);
    
    float topLeftX = 0.0;
    float topLeftY = 0.0;
    float rotationAngle = 0;
    
    if ([ATAppUtils deviceLandscape])
    {
        if ([[[UICenter sharedObject] getCurrentViewController] supportedInterfaceOrientations] == UIInterfaceOrientationMaskPortrait)
        {
            BOOL orentationLeft = [UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeLeft;
            
            rotationAngle = orentationLeft ? - M_PI / 2 : M_PI / 2;
            
            topLeftX = (ATScreenShort / 3) * 2 - (width / 2);
            topLeftY = ATScreenLong / 2  - height / 2;
            
            topLeftX = orentationLeft ? ATScreenShort - (topLeftX + width) : topLeftX;
            
        } else {
            topLeftX = (ATScreenLong - width) / 2;
            topLeftY = (ATScreenShort - height) / 3;
        }
        
    } else {
        topLeftX = (ATScreenShort - width) / 2;
        topLeftY = (ATScreenLong - height) / 3;
    }
    
    
    self.frame = CGRectMake(topLeftX, topLeftY, width, height);
    _background.frame = self.bounds;
    
    [superView addSubview:self];
    _addNewBox = YES;
    
    self.transform = CGAffineTransformMakeRotation(rotationAngle);
    [self layoutIfNeeded];
    
    [UIView animateWithDuration:SHOW_ANIM_TIME animations:^{
        [self componentShouldShow:YES];
    }];
    
    _activityIndicator.hidden = _type == MessageBoxType_Normal || _type == MessageBoxType_Progress;
    
    [self invalidateTimer:_timer];
    if (title.length > 0 || waiting > 0) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:SHOW_DURATION + waiting
                                                  target:self selector:@selector(hideView) userInfo:nil repeats:NO];
    }
}

- (void)hideView {
    if (!_addNewBox) {
        return;
    }
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

- (void)updateProgress:(float)progress {
    float safeProgress = MIN(MAX(0, progress), 1);
    _progressShape.strokeEnd = safeProgress;
    _titleLabel.text = [NSString stringWithFormat:@"%d%%", (int)(safeProgress * 100)];
}

- (void)invalidateTimer:(NSTimer *)timer {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

- (void)removeFromSuperview {
    _type = MessageBoxType_Unknow;
    [_progressShape removeFromSuperlayer];
    _progressShape.strokeEnd = 0;
    self.transform = CGAffineTransformMakeRotation(0);
    [self invalidateTimer:_timer];
    [super removeFromSuperview];
}

#pragma mark - Hide
+ (void)hide {
    [[MessageBox shareObject] hideView];
}

#pragma mark - Loading
+ (void)loading:(NSString *)text
{
    [self loading:text waiting:10 timeOut:nil];
}

+ (void)loading:(NSString *)text waiting:(NSTimeInterval)waitingTime timeOut:(void (^)())block
{
    MessageBox *box = [MessageBox shareObject];
    [box showWithText:text andTitle:@"" weak:NO waitingTime:waitingTime onDisapper:block inView:nil
                 type:MessageBoxType_Loading];
}

#pragma mark - Progress
+ (void)show:(NSString *)text progress:(CGFloat)progress
{
    MessageBox *box = [MessageBox shareObject];
    if (box.type != MessageBoxType_Progress) {
        [self hide];
        [box showWithText:text andTitle:@"0%" weak:NO waitingTime:MAXFLOAT onDisapper:nil inView:nil type:MessageBoxType_Progress];
    } else {
        [box updateProgress:progress];
    }
}

#pragma mark -
+ (void)show:(NSString*)text
{
    [self show:text title:@"提示"];
}

+ (void)warning:(NSString*)text
{
    [self show:text title:@"警告"];
}

+ (void)error:(NSString*)text
{
    [self show:text title:@"错误"];
}

+ (void)show:(NSString *)text title:(NSString *)title
{
    MessageBox *box = [MessageBox shareObject];
    [box showWithText:text andTitle:title weak:NO waitingTime:0 onDisapper:nil inView:nil
                 type:MessageBoxType_Normal];
}

#pragma mark -
+ (void)show:(NSString*)text inView:(UIView *)parentView
{
    [self show:text title:@"提示" inView:parentView];
}

+ (void)warning:(NSString*)text inView:(UIView *)parentView
{
    [self show:text title:@"警告" inView:parentView];
}

+ (void)error:(NSString*)text inView:(UIView *)parentView
{
    [self show:text title:@"错误" inView:parentView];
}

+ (void)show:(NSString *)text title:(NSString *)title inView:(UIView *)parentView {
    MessageBox *box = [MessageBox shareObject];
    [box showWithText:text andTitle:title weak:NO waitingTime:0 onDisapper:nil inView:parentView
                 type:MessageBoxType_Normal];

}

#pragma mark -
+ (void)weakWarning:(NSString *)text onDisapper:(Block)block
{
    MessageBox *box = [MessageBox shareObject];
    [box showWithText:text andTitle:@"提示" weak:YES waitingTime:0 onDisapper:block inView:nil
                 type:MessageBoxType_Normal];
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
