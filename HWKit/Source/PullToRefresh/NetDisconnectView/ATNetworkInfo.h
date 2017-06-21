//
//  NetworkInfo.h
//  YY
//
//  Created by 王 金华 on 13-4-19.
//  Copyright (c) 2013年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 网络状态发生变化通知
 *
 * 字典参数:
 * @li 键值: @ref ATNetworkStateNotificationUserInfoKeyState
 *     类型: NSNumber
 *     取值: @ref ATNetworkState
 */
extern NSString * const ATNetworkStateNotification;
extern NSString * const ATNetworkStateNotificationUserInfoKeyState;

typedef enum {
    ATNetworkStateNotReachable = 0, /**< 当前无可用网络 */
    ATNetworkStateReachableViaWiFi, /**< 当前有Wifi连接 */
    ATNetworkStateReachableViaWWAN, /**< 当前有GPRS连接 */
    ATNetworkStateReachableViaWWAN2G,
    ATNetworkStateReachableViaWWAN3G,
    ATNetworkStateReachableViaWWAN4G,
} ATNetworkState;

/**
 * 用来获取当前网络状态的类. 通过属性@ref networkState 可以查询到当前的网络状态，另外网络状态的变化
 * 会通过@ref ATNetworkStateNotification 主动通知出来
 */
@interface ATNetworkInfo : NSObject
@property (readonly) ATNetworkState networkState; /**< 当前网络状态 */
@property (readonly) ATNetworkState networkWWANState; /**< 当前网络状态细分 */

/**
 * 单体方法，获取ATNetworkInfo对象
 * @return 返回单体对象
 */
+ (ATNetworkInfo *)sharedObject;
@end
