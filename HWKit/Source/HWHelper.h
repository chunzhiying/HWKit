//
//  HWViewHelper.h
//  HWKitDemo
//
//  Created by 陈智颖 on 2016/10/17.
//  Copyright © 2016年 YY. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIView (UIViewGeometryHelper)

@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic, readonly) CGFloat bottom;

@end

// Log
#define ATLogError(...)


// Screen
#define ATScreenBounds ([UIScreen mainScreen].bounds)
#define ATScreenSize (ATScreenBounds.size)
#define ATScreenHeight (ATScreenSize.height)
#define ATScreenWidth (ATScreenSize.width)


// Weak & Strong
#define ATWeakify(obj) \
    __weak __typeof__(obj) obj##_weak_ = obj;

#define ATStrongify(obj) \
    __strong __typeof__(obj##_weak_) obj = obj##_weak_;

#define ATStrongifyEnsure(obj) \
    if (!obj##_weak_) { return; } \
        ATStrongify(obj)


// Color
#define ATHexCOLOR(colorInHex) \
    [UIColor colorWithRed:((float)((colorInHex & 0xFF0000) >> 16))/255.0 \
                    green:((float)((colorInHex & 0xFF00) >> 8))/255.0 \
                     blue:((float)(colorInHex & 0xFF))/255.0 \
                    alpha:1.0]

#define DefaultTintColor ATHexCOLOR(0x197ce0)
#define DefaultBgColor ATHexCOLOR(0xf5f9fc)
#define DefaultCellSelectedBgColor ATHexCOLOR(0xeef5fa)

#define DefaultSeperatorViewColor ATHexCOLOR(0xe5e5e5)

#define DefaultGrayTextColor ATHexCOLOR(0x666666)
#define DefaultWhiteGrayColor ATHexCOLOR(0xd9d9d9)
#define DefaultLighterGrayColor ATHexCOLOR(0xBEBEBE)
#define DefaultLightGrayColor ATHexCOLOR(0xA5A5A5)
#define DefaultMidGrayColor ATHexCOLOR(0x999999)
#define DefaultDeepGrayColor ATHexCOLOR(0x333333)

#define DefaultButtonLightGrayColor ATHexCOLOR(0xDBDCDE)
#define DefaultButtonPressBlueColor ATHexCOLOR(0x6CADEE)

#define DefaultOrangeColor ATHexCOLOR(0xFF7E61)
#define DefaultOrangeTextColor ATHexCOLOR(0xFF9227)

#define DefaultYellowColor ATHexCOLOR(0xFFAC36)
#define DefaultDeepYellowColor ATHexCOLOR(0xFF7701)

#define DefaultRedColor ATHexCOLOR(0xF34E52)

#define DefaultPlusRedColor ATHexCOLOR(0xF3575B)
#define DefaultMinusGreenColor ATHexCOLOR(0x64C67A)

#define DefaultLogoutButtonHighligtdColor ATHexCOLOR(0xF67A7D)

#define DefaultLogoutButtonNomalColor ATHexCOLOR(0xF34E52)

