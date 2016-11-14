//
//  NSObject+RxObserver.m
//  yyfe
//
//  Created by 陈智颖 on 2016/10/21.
//  Copyright © 2016年 yy.com. All rights reserved.
//

#import "NSObject+RxObserver.h"
#import "NSArray+FunctionalType.h"
#import <objc/runtime.h>

@implementation NSObject (RxObserver_Base)

- (void)addRxObserver:(HWRxObserver *)observer {
    [observer registerObserver:self];
    [self.rx_observers addObject:observer];
}

- (void)removeRxObserver:(HWRxObserver *)observer {
    [self removeObserver:observer forKeyPath:observer.keyPath];
    [self.rx_observers removeObject:observer];
}

- (void)removeAllRxObserver {
    self.rx_observers.forEach(^(HWRxObserver *observer) {
        [self removeObserver:observer forKeyPath:observer.keyPath];
    });
    [self.rx_observers removeAllObjects];
}

- (void)executeDisposalBy:(NSObject *)disposer {
    self.rx_observers.filter(^(HWRxObserver *observer) {
        return @([observer.disposer isEqualToString:[NSString stringWithFormat:@"%p", disposer]]);
    }).forEach(^(HWRxObserver *observer) {
        [self removeRxObserver:observer];
    });
}

#pragma mark - Observers
- (void)setRx_observers:(NSMutableArray<HWRxObserver *> *)observers {
    objc_setAssociatedObject(self, @selector(rx_observers), observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray<HWRxObserver *> *)rx_observers {
    if (objc_getAssociatedObject(self, @selector(rx_observers)) == nil) {
        NSMutableArray *array = [NSMutableArray new];
        self.rx_observers = array;
        return array;
    }
    return objc_getAssociatedObject(self, @selector(rx_observers));
}

@end

@implementation NSObject (RxObserver)

- (HWRxObserver *(^)(NSString *))Rx {
    return ^(NSString *keyPath) {
        return [[HWRxObserver alloc] initWithBaseData:[self valueForKey:keyPath]]
        .then(^(HWRxObserver *observer) {
            observer.keyPath = keyPath;
            [self addRxObserver:observer];
        });
    };
}

@end
