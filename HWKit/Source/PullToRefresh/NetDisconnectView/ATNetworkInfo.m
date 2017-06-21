//
//  NetworkInfo.m
//  YY
//
//  Created by 王 金华 on 13-4-19.
//  Copyright (c) 2013年 YY Inc. All rights reserved.
//

#import "ATNetworkInfo.h"
#import "HWHelper.h"
#import <UIKit/UIKit.h>
#import <arpa/inet.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

NSString * const ATNetworkStateNotification = @"ATNetworkStateNotification";
NSString * const ATNetworkStateNotificationUserInfoKeyState = @"ATNetworkStateNotificationUserInfoKeyState";

static SCNetworkReachabilityRef ATNetworkReachability()
{
    //        return SCNetworkReachabilityCreateWithName(NULL, HOST_NAME);
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    return SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&zeroAddress);
}

static ATNetworkState NetworkStateFromReachabilityFlags(SCNetworkReachabilityFlags flags)
{
	if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
		// if target host is not reachable
		return ATNetworkStateNotReachable;
	}
    
	ATNetworkState retVal = ATNetworkStateNotReachable;
	
	if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
		// if target host is reachable and no connection is required
		//  then we'll assume (for now) that your on Wi-Fi
		retVal = ATNetworkStateReachableViaWiFi;
	}
	
	
	if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
        // ... and the connection is on-demand (or on-traffic) if the
        //     calling application is using the CFSocketStream or higher APIs
        
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
            // ... and no [user] intervention is needed
            retVal = ATNetworkStateReachableViaWiFi;
        }
    }
#if	TARGET_OS_IPHONE
	if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
		// ... but WWAN connections are OK if the calling application
		//     is using the CFNetwork (CFSocketStream?) APIs.
		retVal = ATNetworkStateReachableViaWWAN;
	}
#endif // TARGET_OS_IPHONE
	return retVal;
}

static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
    ATNetworkState state = NetworkStateFromReachabilityFlags(flags);
    
    
    NSDictionary *userInfo = @{ATNetworkStateNotificationUserInfoKeyState : [NSNumber numberWithInt:state]};
    [[NSNotificationCenter defaultCenter] postNotificationName:ATNetworkStateNotification object:(__bridge id)(info) userInfo:userInfo];
}

@interface ATNetworkInfo()
{
    SCNetworkReachabilityRef _reachability;
}

@end

@implementation ATNetworkInfo

static ATNetworkInfo *sharedNetworkInfo = nil;

+ (ATNetworkInfo *)sharedObject
{
    if (!sharedNetworkInfo)
        sharedNetworkInfo = [[ATNetworkInfo alloc] init];
    
    return sharedNetworkInfo;
}

- (ATNetworkState)networkState
{
    ATNetworkState state = ATNetworkStateNotReachable;
    //--------------------------------------------------------------------------
    // 这里每次都创建新的Reachbility对象，而没有用_reachability的原因是
    // 发现当SCNetworkReachabilitySetDispatchQueue这个函数被调用后，第一次通过
    // SCNetworkReachabilityGetFlags获得的flags永远是0，即使当前有网络，
    // 目前还没有找到文档描述这两者之间的关联，但是每次创建是能够保证获得状态是正确的。
    //--------------------------------------------------------------------------
    SCNetworkReachabilityRef reachability = ATNetworkReachability();
    SCNetworkReachabilityFlags flags = 0;
    if (!SCNetworkReachabilityGetFlags(reachability, &flags)) {
        ATLogError(@"NetworkInfo", @"Failed to get network reachability flags");
        state = ATNetworkStateNotReachable;
    } else {
        state = NetworkStateFromReachabilityFlags(flags);
    }
    CFRelease(reachability);
    return state;
}

- (ATNetworkState)networkWWANState
{
    ATNetworkState state = ATNetworkStateReachableViaWWAN;
    
    if (self.networkState == ATNetworkStateReachableViaWWAN) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            CTTelephonyNetworkInfo * info = [[CTTelephonyNetworkInfo alloc] init];
            NSString *currentRadioAccessTechnology = info.currentRadioAccessTechnology;
            if (currentRadioAccessTechnology) {
                if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
                    state = ATNetworkStateReachableViaWWAN4G;
                }
                else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS]) {
                    state = ATNetworkStateReachableViaWWAN2G;
                }
                else {
                    state = ATNetworkStateReachableViaWWAN3G;
                }
            }
        }
    }
    return state;
}

- (id)init
{
    if (self = [super init]) {
        do {
            _reachability = ATNetworkReachability();
            if (!_reachability) {
                ATLogError(@"NetworkInfo", @"Failed to create network reachability");
                break;
            }
            
            SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
            if (!SCNetworkReachabilitySetCallback(_reachability, ReachabilityCallback, &context)) {
                ATLogError(@"NetworkInfo", @"Failed to set network reachability callback function");
                break;
            }
            
            if (!SCNetworkReachabilitySetDispatchQueue(_reachability, dispatch_get_main_queue())) {
                ATLogError(@"NetworkInfo", @"Failed to set network reachability callback dispatch queue");
                break;
            }
        } while (false);
    }
    return self;
}

- (void)dealloc
{
    if (_reachability) {
        SCNetworkReachabilitySetDispatchQueue(_reachability, NULL);
        CFRelease(_reachability);
        _reachability = NULL;
    }
}

@end
