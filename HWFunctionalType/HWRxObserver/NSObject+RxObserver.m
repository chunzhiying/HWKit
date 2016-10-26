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
    [self addObserver:observer forKeyPath:observer.keyPath
              options:NSKeyValueObservingOptionNew context:NULL];
    [self.observers addObject:observer];
}

- (void)removeRxObserver:(HWRxObserver *)observer {
    [self removeObserver:observer forKeyPath:observer.keyPath];
    [self.observers removeObject:observer];
}

- (void)removeAllRxObserver {
    self.observers.forEach(^(HWRxObserver *observer) {
        [self removeObserver:observer forKeyPath:observer.keyPath];
    });
    [self.observers removeAllObjects];
}

- (void)executeDisposalBy:(NSObject *)disposer {
    self.observers.filter(^(HWRxObserver *observer) {
        return @([observer.disposer isEqualToString:[NSString stringWithFormat:@"%p", disposer]]);
    }).forEach(^(HWRxObserver *observer) {
        [self removeRxObserver:observer];
    });
}

#pragma mark - Observers
- (void)setObservers:(NSMutableArray<HWRxObserver *> *)observers {
    objc_setAssociatedObject(self, @selector(observers), observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray<HWRxObserver *> *)observers {
    if (objc_getAssociatedObject(self, @selector(observers)) == nil) {
        NSMutableArray *array = [NSMutableArray new];
        self.observers = array;
        return array;
    }
    return objc_getAssociatedObject(self, @selector(observers));
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
