//
//  NSNotificationCenter+RxObserver.m
//  HWKitDemo
//
//  Created by 陈智颖 on 2016/11/14.
//  Copyright © 2016年 YY. All rights reserved.
//

#import "NSNotificationCenter+RxObserver.h"

@implementation NSNotificationCenter (RxObserver)

- (HWRxObserver *(^)(NSString *))Rx {
    return ^(NSString *notifyName) {
        return [HWRxObserver new].then(^(HWRxObserver *observer) {
            observer.keyPath = notifyName;
            [self addRxObserver:observer];
        });
    };
}

- (void)removeRxObserver:(HWRxObserver *)observer {
    [self removeObserver:observer];
    [self.rx_observers removeObject:observer];
}

@end
