//
//  HWAlertController.m
//  HWAlertController
//
//  Created by 陈智颖 on 16/7/18.
//  Copyright © 2016年 YY. All rights reserved.
//

#import "HWAlertController.h"
#import "HWFunctionalType.h"
#import <objc/runtime.h>

#define isIOS8 ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)

#define BlackColor [UIColor colorWithRed:51.f/255.f green:51.f/255.f blue:51.f/255.f alpha:1]
#define BlueColor [UIColor colorWithRed:60.f/255.f green:146.f/255.f blue:232.f/255.f alpha:1]
#define RedColor [UIColor colorWithRed:243.f/255.f green:87.f/255.f blue:91.f/255.f alpha:1]

#define ImageTitleFlag @"ImageTitleFlag"

#define Block_Index @"Index"
#define Block_TextFields @"TextFields"

#define Symbol_Red @"#"
#define Symbol_Blue @"&"

#define ButtonId @".Id"
#define AddButtonId(string) [NSString stringWithFormat:@"%@%@", string, ButtonId]
#define ClearButtonId(string) [string substringToIndex:string.length - ButtonId.length]
#define HasButtonId(string) \
(string.length > ButtonId.length && [[string substringFromIndex:string.length - ButtonId.length] isEqualToString:ButtonId])

#define ChackIsSurroundBy(symbol, string) \
(string.length >= 3 && [[string substringToIndex:1] isEqualToString:symbol] && [[string substringFromIndex:string.length - 1] isEqualToString:symbol])

#define SafeBlock(atBlock, ...) \
if(atBlock) { atBlock(__VA_ARGS__); }

#define WeakSelf \
__weak __typeof(self) weakSelf = self;

#define StrongSelf \
if (!weakSelf) { return; } \
__strong __typeof(weakSelf) strongSelf = weakSelf;


@implementation HWAlertBlockData

+ (instancetype)initWithBase:(NSDictionary *)base {
    HWAlertBlockData *data = [HWAlertBlockData new];
    data.index = [base[Block_Index] integerValue];
    data.textfields = base[Block_TextFields];
    return data;
}

@end


@implementation HWAlertContainerController

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate {
    return YES;
}

@end

@interface UIAlertController (Window)

@property (nonatomic, strong) UIWindow *alertWindow;

- (void)show;

@end

@implementation UIAlertController (Window)

@dynamic alertWindow;

- (void)setAlertWindow:(UIWindow *)alertWindow {
    objc_setAssociatedObject(self, @selector(alertWindow), alertWindow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIWindow *)alertWindow {
    return objc_getAssociatedObject(self, @selector(alertWindow));
}

- (void)show {
    self.alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.alertWindow.rootViewController = [HWAlertContainerController new];
    
    self.alertWindow.tintColor = [UIApplication sharedApplication].delegate.window.tintColor;
    
    UIWindow *topWindow = [UIApplication sharedApplication].windows.lastObject;
    self.alertWindow.windowLevel = topWindow.windowLevel + 1;
    
    [self.alertWindow makeKeyAndVisible];
    [self.alertWindow.rootViewController presentViewController:self animated:YES completion:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
#ifdef Making_iOS8_Customize
    self.view.tintColor = BlackColor;
    [self getSubView:self.view];
#endif
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.alertWindow.hidden = YES;
    self.alertWindow = nil;
}

- (void)getSubView:(UIView *)view {
    
    if ([view isKindOfClass:[UILabel class]]) {
        [self paserLabelText:(UILabel *)view];
        return;
    }
    
    if ([view isKindOfClass:[UIImageView class]]
        || [view isKindOfClass:[UITextField class]]
        || [view isKindOfClass:[UITextView class]]) {
        return;
    }
    
    for (UIView *sub in view.subviews) {
        [self getSubView:sub];
    }
}

- (void)paserLabelText:(UILabel *)label {
    
    if (!(label.text.length != 0 && HasButtonId(label.text))) {
        return;
    }
    
    if (self.preferredStyle == UIAlertControllerStyleAlert) {
        label.font = [UIFont systemFontOfSize:17];
    } else {
        label.font = [UIFont systemFontOfSize:20];
    }
    
    NSString *realText = ClearButtonId(label.text);
    label.text = realText;
    
    if (realText.length != [self checkStyle:Symbol_Red withTitle:realText].length) {
        label.textColor = RedColor;
        label.tintColor = RedColor;
        label.text = [self checkStyle:Symbol_Red withTitle:realText];
    }
    else if (realText.length != [self checkStyle:Symbol_Blue withTitle:realText].length) {
        label.textColor = BlueColor;
        label.tintColor = BlueColor;
        label.text = [self checkStyle:Symbol_Blue withTitle:realText];
    }
    [label.layer setValue:ButtonId forKey:ButtonId];
    
}

- (NSString *)checkStyle:(NSString *)symbol withTitle:(NSString *)title {
    if (ChackIsSurroundBy(symbol, title))
    {
        title = [title substringWithRange:NSMakeRange(1, title.length - 2)];
    }
    return title;
}

@end

@implementation UILabel (TintColor)

#ifdef Making_iOS8_Customize

- (void)tintColorDidChange {
    if (self.text.length == 0 || ![[self.layer valueForKey:ButtonId] isEqualToString:ButtonId]) {
        return;
    }
    self.tintColor = self.textColor;
}

#endif

@end

#pragma mark - HWAlertController Imp

@interface HWAlertController () <UIAlertViewDelegate, UIActionSheetDelegate> {
    HWAlertControllerStyle _style;
    HWAlertTextStyle _alertTextStyle;
    
    UIAlertView *_alert;
    UIActionSheet *_actionSheet;
    UIAlertController *_alertController;
    
}

@property (nonatomic, copy) AlertBlock cancelBlock;
@property (nonatomic, copy) AlertOtherButtonsBlock cancelTextFieldBlock;
@property (nonatomic, copy) AlertOtherButtonsBlock otherButtonsBlock;
@property (nonatomic, copy) AlertTextFieldConfigBlock textFieldConfigBlock;

@end


@implementation HWAlertController

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                        style:(HWAlertControllerStyle)style
            cancelButtonTitle:(NSString *)cancelButtonTitle cancelButtonBlock:(AlertBlock)cancelBlock
            otherButtonTitles:(NSArray<NSString *> *)otherButtonTitles otherButtonsBlock:(AlertOtherButtonsBlock)otherButtonsBlock
{
    [self dismissWithCancelButtonClicked];
    [self clearUI];
    
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        _style = style;
        _alertTextStyle = HWAlertViewStyleDefault;
        
        self.cancelBlock = cancelBlock;
        self.otherButtonsBlock = otherButtonsBlock;
        self.backgroundColor = [UIColor clearColor];
        
        if (isIOS8) {
            [self setupForCombine:title message:message style:style
                cancelButtonTitle:cancelButtonTitle cancelButtonBlock:cancelBlock
                otherButtonTitles:otherButtonTitles otherButtonsBlock:otherButtonsBlock];
            
        } else {
            [self setupForIOS7:title message:message style:style
             cancelButtonTitle:cancelButtonTitle cancelButtonBlock:cancelBlock
             otherButtonTitles:otherButtonTitles otherButtonsBlock:otherButtonsBlock];
        }
        
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                    textStyle:(HWAlertTextStyle)textStyle
                    textfield:(AlertTextFieldConfigBlock)textFieldConfigBlock
            cancelButtonTitle:(NSString *)cancelButtonTitle cancelButtonBlock:(AlertOtherButtonsBlock)cancelBlock
            otherButtonTitles:(NSArray<NSString *> *)otherButtonTitles otherButtonsBlock:(AlertOtherButtonsBlock)otherButtonsBlock
{
    [self dismissWithCancelButtonClicked];
    [self clearUI];
    
    if (textStyle == HWAlertViewStyleDefault) {
        return [self initWithTitle:title message:message style:HWAlertControllerStyleAlert
                 cancelButtonTitle:cancelButtonTitle cancelButtonBlock:cancelBlock
                 otherButtonTitles:otherButtonTitles otherButtonsBlock:otherButtonsBlock];
    }
    
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        
        _style = HWAlertControllerStyleAlert;
        _alertTextStyle = textStyle;
        
        self.cancelTextFieldBlock = cancelBlock;
        self.otherButtonsBlock = otherButtonsBlock;
        self.textFieldConfigBlock = textFieldConfigBlock;
        self.backgroundColor = [UIColor clearColor];
        
        if (isIOS8) {
            [self setupForCombine:title message:message style:HWAlertControllerStyleAlert
                cancelButtonTitle:cancelButtonTitle cancelButtonBlock:cancelBlock
                otherButtonTitles:otherButtonTitles otherButtonsBlock:otherButtonsBlock];
            
            [self setupTextFieldForCombine];
            
        } else {
            [self setupForIOS7:title message:message style:HWAlertControllerStyleAlert
             cancelButtonTitle:cancelButtonTitle cancelButtonBlock:cancelBlock
             otherButtonTitles:otherButtonTitles otherButtonsBlock:otherButtonsBlock];
            
            _alert.alertViewStyle = (UIAlertViewStyle)textStyle;
            [self setupTextFieldForIOS7];
            
        }
        
        
    }
    return self;
}

- (void)clearUI {
    _alertController = nil;
    _alert = nil;
    _actionSheet = nil;
}

#pragma mark - Setup Main
- (void)setupForCombine:(NSString *)title
                message:(NSString *)message
                  style:(HWAlertControllerStyle)style
      cancelButtonTitle:(NSString *)cancelButtonTitle cancelButtonBlock:(AlertBlock)cancelBlock
      otherButtonTitles:(NSArray<NSString *> *)otherButtonTitles otherButtonsBlock:(AlertOtherButtonsBlock)otherButtonsBlock
{
    
    _alertController = [UIAlertController alertControllerWithTitle:title message:message
                                                    preferredStyle:(UIAlertControllerStyle)style];
    
    WeakSelf
    void (^ cancelActionBlock)(UIAlertAction *) = ^(UIAlertAction *action) {
        StrongSelf
        NSArray *textFields = [[NSArray alloc] initWithArray:strongSelf->_alertController.textFields];
        SafeBlock(strongSelf.cancelBlock)
        SafeBlock(strongSelf.cancelTextFieldBlock, [HWAlertBlockData initWithBase:@{Block_Index : @(NSIntegerMin),
                                                                                    Block_TextFields : textFields}])
        [strongSelf removeFromSuperview];
    };
    
#ifdef Making_iOS8_Customize
    cancelButtonTitle = AddButtonId(cancelButtonTitle);
#endif
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle
                                                           style:UIAlertActionStyleCancel handler:cancelActionBlock];
    [_alertController addAction:cancelAction];
    
    
    if (otherButtonTitles == nil || otherButtonTitles.count == 0) {
        return;
    }
    
    for (NSInteger i = 0; i < otherButtonTitles.count; i++)
    {
        void (^ otherActionBlock)(UIAlertAction *) = ^(UIAlertAction *action) {
            
            StrongSelf
            NSArray *textFields = [[NSArray alloc] initWithArray:strongSelf->_alertController.textFields];
            SafeBlock(strongSelf.otherButtonsBlock, [HWAlertBlockData initWithBase:@{Block_Index : @(i),
                                                                                     Block_TextFields : textFields}])
            [strongSelf removeFromSuperview];
        };
        
        NSString *title = [otherButtonTitles objectAtIndex:i];
        if (title.length == 0) {
            continue;
        }
        
#ifdef Making_iOS8_Customize
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:AddButtonId(title)
                                                              style:UIAlertActionStyleDefault
                                                            handler:otherActionBlock];
        [_alertController addAction:otherAction];
#else
        NSString *actualTitle = [self checkIfDestructiveStyle:title];
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:actualTitle
                                                              style:actualTitle.length != title.length ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault
                                                            handler:otherActionBlock];
        [_alertController addAction:otherAction];
#endif
        
    }
    
}

- (void)setupForIOS7:(NSString *)title
             message:(NSString *)message
               style:(HWAlertControllerStyle)style
   cancelButtonTitle:(NSString *)cancelButtonTitle cancelButtonBlock:(AlertBlock)cancelBlock
   otherButtonTitles:(NSArray<NSString *> *)otherButtonTitles otherButtonsBlock:(AlertOtherButtonsBlock)otherButtonsBlock
{
    switch (style) {
        case HWAlertControllerStyleAlert:
        {
            _alert = [[UIAlertView alloc] initWithTitle:title
                                                message:message
                                               delegate:self
                                      cancelButtonTitle:[self checkIfDestructiveStyle:cancelButtonTitle]
                                      otherButtonTitles:nil];
            
            for (NSString *title in otherButtonTitles) {
                if (title.length == 0) {
                    continue;
                }
                [_alert addButtonWithTitle:[self checkIfDestructiveStyle:title]];
            }
            
            break;
        }
            
        case HWAlertControllerStyleActionSheet:
        {
            _actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
            
            for (NSString *title in otherButtonTitles) {
                if (title.length == 0) {
                    continue;
                }
                
                NSString *actualTitle = [self checkIfDestructiveStyle:title];
                if (title.length != actualTitle.length) {
                    _actionSheet.destructiveButtonIndex = [_actionSheet addButtonWithTitle:actualTitle];
                } else {
                    [_actionSheet addButtonWithTitle:actualTitle];
                }
                
            }
            _actionSheet.cancelButtonIndex = [_actionSheet addButtonWithTitle:cancelButtonTitle];
            
            break;
        }
            
    }
}

#pragma mark - Setup TextFields
- (void)setupTextFieldForCombine {
    
    if (_alertTextStyle == HWAlertViewStyleDefault) {
        return;
    }
    
    WeakSelf
    switch (_alertTextStyle) {
        case HWAlertViewStyleSecureTextInput:
        {
            [_alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.secureTextEntry = YES;
                textField.placeholder = @"Password";
                [textField becomeFirstResponder];//fix crash when the keyboard is being displayed
                SafeBlock(weakSelf.textFieldConfigBlock, 0, textField)
            }];
            break;
        }
        case HWAlertViewStylePlainTextInput:
        {
            [_alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                [textField becomeFirstResponder];//fix crash when the keyboard is being displayed
                SafeBlock(weakSelf.textFieldConfigBlock, 0, textField)
            }];
            break;
        }
        case HWAlertViewStyleLoginAndPasswordInput:
        {
            [_alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = @"Login";
                [textField becomeFirstResponder];//fix crash when the keyboard is being displayed
                SafeBlock(weakSelf.textFieldConfigBlock, 0, textField)
            }];
            [_alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.secureTextEntry = YES;
                textField.placeholder = @"Password";
                SafeBlock(weakSelf.textFieldConfigBlock, 1, textField)
            }];
        }
        default:
            break;
    }
    
}

- (void)setupTextFieldForIOS7 {
    
    if (_alertTextStyle == HWAlertViewStyleDefault) {
        return;
    }
    
    switch (_alertTextStyle) {
        case HWAlertViewStyleSecureTextInput:
        case HWAlertViewStylePlainTextInput:
        {
            SafeBlock(self.textFieldConfigBlock, 0, [_alert textFieldAtIndex:0])
            break;
        }
        case HWAlertViewStyleLoginAndPasswordInput:
        {
            SafeBlock(self.textFieldConfigBlock, 0, [_alert textFieldAtIndex:0])
            SafeBlock(self.textFieldConfigBlock, 1, [_alert textFieldAtIndex:1])
            break;
        }
        default:
            break;
    }
}

#pragma mark - Custom
- (NSString *)checkIfDestructiveStyle:(NSString *)title {
    if (ChackIsSurroundBy(Symbol_Red, title) || ChackIsSurroundBy(Symbol_Blue, title))
    {
        title = [title substringWithRange:NSMakeRange(1, title.length - 2)];
    }
    return title;
}

#pragma mark - Action
- (BOOL)isShowing {
    return self.superview != nil;
}

- (void)show {
    
    UIWindow *parentView = [UIApplication sharedApplication].delegate.window;
    
    if (!parentView) {
        return;
    }
    
    [parentView addSubview:self];
    
    if (_alert
        && [[_alert.layer valueForKey:ImageTitleFlag] isEqualToString:ImageTitleFlag]) {
        [_alert show];
        return;
    }
    
    if (isIOS8 && _alertController) {
        [_alertController show];
        return;
    }
    
    if (!isIOS8 && (_alert || _actionSheet)) {
        switch (_style) {
            case HWAlertControllerStyleAlert:
                [_alert show];
                break;
                
            case HWAlertControllerStyleActionSheet:
                [_actionSheet showInView:parentView];
                break;
        }
        return;
    }
}

- (void)dismissWithCancelButtonClicked {
    if (!self.superview) {
        return;
    }
    
    if (_alertController) {
        NSArray *textFields = [[NSArray alloc] initWithArray:_alertController.textFields];
        SafeBlock(self.cancelBlock)
        SafeBlock(self.cancelTextFieldBlock, [HWAlertBlockData initWithBase:@{Block_Index : @(NSIntegerMin),
                                                                              Block_TextFields : textFields}])
        [_alertController dismissViewControllerAnimated:YES completion:nil];
    }
    if (_alert) {
        [self alertView:_alert clickedButtonAtIndex:_alert.cancelButtonIndex];
        [_alert dismissWithClickedButtonIndex:_alert.cancelButtonIndex animated:YES];
    }
    if (_actionSheet) {
        [self actionSheet:_actionSheet clickedButtonAtIndex:_actionSheet.cancelButtonIndex];
        [_actionSheet dismissWithClickedButtonIndex:_actionSheet.cancelButtonIndex animated:YES];
    }
    
    [self removeFromSuperview];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)index animated:(BOOL)animated {
    if (!self.superview) {
        return;
    }
    
    if (_alertController) {
        NSArray *textFields = [[NSArray alloc] initWithArray:_alertController.textFields];
        SafeBlock(self.otherButtonsBlock, [HWAlertBlockData initWithBase:@{Block_Index : @(index),
                                                                           Block_TextFields : textFields}])
        [_alertController dismissViewControllerAnimated:animated completion:nil];
    }
    if (_alert) {
        [self alertView:_alert clickedButtonAtIndex:index + 1];
        [_alert dismissWithClickedButtonIndex:_alert.cancelButtonIndex animated:animated];
    }
    if (_actionSheet) {
        [self actionSheet:_actionSheet clickedButtonAtIndex:index];
        [_actionSheet dismissWithClickedButtonIndex:_actionSheet.cancelButtonIndex animated:animated];
    }
    
    [self removeFromSuperview];
}

#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSMutableArray *textfields = [NSMutableArray new];
    switch (_alertTextStyle) {
        case HWAlertViewStyleLoginAndPasswordInput:
            [textfields addObject:[alertView textFieldAtIndex:0]];
            [textfields addObject:[alertView textFieldAtIndex:1]];
            break;
        case HWAlertViewStylePlainTextInput:
        case HWAlertViewStyleSecureTextInput:
            [textfields addObject:[alertView textFieldAtIndex:0]];
            break;
        case HWAlertViewStyleDefault:
            break;
    }
    
    if (buttonIndex == 0) {
        SafeBlock(self.cancelBlock)
        SafeBlock(self.cancelTextFieldBlock, [HWAlertBlockData initWithBase:@{Block_Index : @(NSIntegerMin),
                                                                              Block_TextFields : textfields}])
    }
    
    if (buttonIndex != 0) {
        SafeBlock(self.otherButtonsBlock, [HWAlertBlockData initWithBase:@{Block_Index : @(buttonIndex - 1),
                                                                           Block_TextFields : textfields}])
    }
    
    [self removeFromSuperview];
}

#pragma mark - ActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        SafeBlock(self.cancelBlock)
    } else {
        SafeBlock(self.otherButtonsBlock, [HWAlertBlockData initWithBase:@{Block_Index : @(buttonIndex),
                                                                           Block_TextFields : @[]}])
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
    });
}

@end

@implementation HWAlertController (Image)

#define MaxImageWidth 270
#define Spacing 15

- (instancetype)initWithImage:(UIImage *)image
                      message:(NSString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle cancelButtonBlock:(AlertBlock)cancelBlock
            otherButtonTitles:(NSArray<NSString *> *)otherButtonTitles otherButtonsBlock:(AlertOtherButtonsBlock)otherButtonsBlock
{
    [self dismissWithCancelButtonClicked];
    [self clearUI];
    
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        _style = HWAlertControllerStyleAlert;
        _alertTextStyle = HWAlertViewStyleDefault;
        
        self.cancelBlock = cancelBlock;
        self.otherButtonsBlock = otherButtonsBlock;
        self.backgroundColor = [UIColor clearColor];
        
        [self setupForIOS7:nil message:nil style:_style
         cancelButtonTitle:cancelButtonTitle cancelButtonBlock:cancelBlock
         otherButtonTitles:otherButtonTitles otherButtonsBlock:otherButtonsBlock];
        
        
        UIView *bgView = [UIView new];
        UIFont *font = [UIFont systemFontOfSize:15];
        
        if (message.length > 0) {
            
            bgView.frame = CGRectMake(0, 0, MaxImageWidth, image.size.height + font.lineHeight + 3 * Spacing);
            
            [bgView addSubview:[UILabel new].then(^(UILabel *label) {
                label.font = font;
                label.text = message;
                label.textAlignment = NSTextAlignmentCenter;
                label.frame = CGRectMake(Spacing, bgView.frame.size.height - font.lineHeight - Spacing,
                                         MaxImageWidth - Spacing * 2, font.lineHeight);
                label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
            })];
            
            
        } else {
            bgView.frame = CGRectMake(0, 0, MaxImageWidth, image.size.height + 2 * Spacing);
        }
        
        [bgView addSubview:[UIImageView new].then(^(UIImageView *imageView) {
            imageView.image = image;
            imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            imageView.frame = CGRectMake((MaxImageWidth - image.size.width) / 2, Spacing, image.size.width, image.size.height);
        })];
        
        [_alert setValue:bgView forKey:@"accessoryView"];
        [_alert.layer setValue:ImageTitleFlag forKey:ImageTitleFlag];
        
    }
    
    return self;
}

@end

@implementation HWAlertController (AutoDismiss)

- (void)autoDismiss {
    [self show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissWithCancelButtonClicked];
    });
}

- (void)delayShow {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self show];
    });
}

@end

