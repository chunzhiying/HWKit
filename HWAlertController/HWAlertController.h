//
//  HWAlertController.h
//  HWAlertController
//
//  Created by 陈智颖 on 16/7/18.
//  Copyright © 2016年 YY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWAlertBlockData;

typedef NS_ENUM(NSInteger, HWAlertControllerStyle) {
    HWAlertControllerStyleActionSheet = 0,
    HWAlertControllerStyleAlert
};

typedef NS_ENUM(NSInteger, HWAlertTextStyle) {
    HWAlertViewStyleDefault = 0,           //without textfiled
    HWAlertViewStyleSecureTextInput,       //one secure textfield
    HWAlertViewStylePlainTextInput,        //one plain textfield
    HWAlertViewStyleLoginAndPasswordInput  //two textfileds, one plain and the other secure
};

typedef void(^AlertBlock)();
typedef void(^AlertOtherButtonsBlock)( HWAlertBlockData * _Nonnull data);
typedef void(^AlertTextFieldConfigBlock)(NSInteger txtfieldIndex, UITextField * _Nonnull textField);


@interface HWAlertContainerController : UIViewController //for AutoRotation

@end

@interface HWAlertBlockData : NSObject

@property (nonatomic) NSInteger index; //0, 1, 2, ...
@property (nonatomic, strong, nonnull) NSArray<UITextField *> *textfields;

@end

#define Making_iOS8_Customize

//#xx# for Red, &xx& for Blue. (default Black)
@interface HWAlertController : UIView

//without textfield
- (nullable instancetype)initWithTitle:(nullable NSString *)title
                               message:(nullable NSString *)message
                                 style:(HWAlertControllerStyle)style
                     cancelButtonTitle:(nonnull NSString *)cancelButtonTitle
                     cancelButtonBlock:(nullable AlertBlock)cancelBlock
                     otherButtonTitles:(nullable NSArray<NSString *> *)otherButtonTitles
                     otherButtonsBlock:(nullable AlertOtherButtonsBlock)otherButtonsBlock;

//have textfield, Alert only
- (nullable instancetype)initWithTitle:(nullable NSString *)title
                               message:(nullable NSString *)message
                             textStyle:(HWAlertTextStyle)textStyle
                             textfield:(nullable AlertTextFieldConfigBlock)textFieldConfigBlock //customize textField
                     cancelButtonTitle:(nonnull NSString *)cancelButtonTitle
                     cancelButtonBlock:(nullable AlertOtherButtonsBlock)cancelBlock
                     otherButtonTitles:(nullable NSArray<NSString *> *)otherButtonTitles
                     otherButtonsBlock:(nullable AlertOtherButtonsBlock)otherButtonsBlock;

- (void)show;
- (BOOL)isShowing;

- (void)dismissWithCancelButtonClicked;
- (void)dismissWithClickedButtonIndex:(NSInteger)index animated:(BOOL)animated;

@end


@interface HWAlertController (Image)

// not support #xx#, &xx&
- (nullable instancetype)initWithImage:(nonnull UIImage *)image
                               message:(nullable NSString *)message
                     cancelButtonTitle:(nonnull NSString *)cancelButtonTitle
                     cancelButtonBlock:(nullable AlertBlock)cancelBlock
                     otherButtonTitles:(nullable NSArray<NSString *> *)otherButtonTitles
                     otherButtonsBlock:(nullable AlertOtherButtonsBlock)otherButtonsBlock;

@end


@interface HWAlertController (AutoDismiss)

- (void)autoDismiss;
- (void)delayShow;

@end
