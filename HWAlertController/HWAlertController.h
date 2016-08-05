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
typedef void(^AlertOtherButtonsBlock)(HWAlertBlockData *data);
typedef void(^AlertTextFieldConfigBlock)(NSInteger txtfieldIndex, UITextField *textField);


@interface HWAlertBlockData : NSObject

@property (nonatomic) NSInteger index; //0, 1, 2, ...
@property (nonatomic, strong) NSArray<UITextField *> *textfields;

@end


@interface HWAlertController : UIView

//without textfield, #xx# for DestructiveStyle
- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                        style:(HWAlertControllerStyle)style
            cancelButtonTitle:(NSString *)cancelButtonTitle cancelButtonBlock:(AlertBlock)cancelBlock
            otherButtonTitles:(NSArray<NSString *> *)otherButtonTitles otherButtonsBlock:(AlertOtherButtonsBlock)otherButtonsBlock;

//have textfield, Alert only
- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                    textStyle:(HWAlertTextStyle)textStyle
                    textfield:(AlertTextFieldConfigBlock)textFieldConfigBlock //customize textField
            cancelButtonTitle:(NSString *)cancelButtonTitle cancelButtonBlock:(AlertOtherButtonsBlock)cancelBlock
            otherButtonTitles:(NSArray<NSString *> *)otherButtonTitles otherButtonsBlock:(AlertOtherButtonsBlock)otherButtonsBlock;

- (void)show;

- (void)dismissWithCancelButtonClicked;
- (void)dismissWithClickedButtonIndex:(NSInteger)index animated:(BOOL)animated;

@end


@interface HWAlertController (AutoDismiss)

- (void)autoDismiss;
- (void)delayShow;

@end
