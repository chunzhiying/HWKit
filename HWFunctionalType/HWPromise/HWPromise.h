//
//  HWPromise.h
//  HWKitDemo
//
//  Created by 陈智颖 on 2016/9/23.
//  Copyright © 2016年 YY. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HWPromiseNetworkFail promise.failObj = @"网络异常";

@class HWPromiseResult;

typedef void(^thenType)(id obj);
typedef void(^alwaysType)(HWPromiseResult *result);
typedef void(^completeType)(NSArray<HWPromiseResult *> *results);

@interface HWPromise<__covariant SuccessT, __covariant FailT> : NSObject

@property (nonatomic, strong) SuccessT successObj;
@property (nonatomic, strong) FailT failObj;

@end

@interface HWPromise (FunctionalType_Extension)

@property (nonatomic, readonly) HWPromise *(^success)(thenType);
@property (nonatomic, readonly) HWPromise *(^fail)(thenType);
@property (nonatomic, readonly) HWPromise *(^always)(alwaysType);
@property (nonatomic, readonly) HWPromise *(^complete)(completeType);

@end

@interface HWPromiseResult : NSObject

@property (nonatomic) BOOL status;
@property (nonatomic, strong) id object; // SuccessT || FailT

@end


@interface NSArray (Promise_Extension) //callback hell, use complete.

@property (nonatomic, readonly) HWPromise *promise;

@end
