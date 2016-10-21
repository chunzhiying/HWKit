//
//  UIView+RxObserver.m
//  HWKitDemo
//
//  Created by 陈智颖 on 2016/10/20.
//  Copyright © 2016年 YY. All rights reserved.
//

#import "UIView+RxObserver.h"
#import "HWFunctionalType.h"
#import "NSArray+FunctionalType.h"
#import <objc/runtime.h>

@interface UIView (RxObserver_Base)

@property (nonatomic, strong) NSMutableArray<HWRxObserver *> *observers;

@end

@implementation UIView (RxObserver_Base)

- (void)addObserver:(HWRxObserver *)observer {
    if ([observer.keyPath isEqualToString:@"tap"]) {
        [self addGestureObserver:observer];
    } else {
        [self addObserver:observer forKeyPath:observer.keyPath
                  options:NSKeyValueObservingOptionNew context:NULL];
    }
    [self.observers addObject:observer];
}

- (void)addGestureObserver:(HWRxObserver *)observer {
    if ([self isKindOfClass:[UIButton class]]) {
        [(UIButton *)self addTarget:observer action:observer.tapAction forControlEvents:UIControlEventTouchUpInside];
    } else {
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:observer action:observer.tapAction]];
    }
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

#pragma mark - Method Swizzling
+ (void)load {
    Method originalMethod = class_getInstanceMethod([self class], @selector(removeFromSuperview));
    Method swizzledMethod = class_getInstanceMethod([self class], @selector(RxObserver_removeFromSuperview));
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (void)RxObserver_removeFromSuperview {
    self.observers
    .filter(^(HWRxObserver *observer) {
        return @(![observer.keyPath isEqualToString:@"tap"]);
    })
    .forEach(^(HWRxObserver *observer) {
        [self removeObserver:observer forKeyPath:observer.keyPath];
    });
    [self RxObserver_removeFromSuperview];
}

@end


@implementation UIView (RxObserver)

- (HWRxObserver *)Rx_tap {
    return [HWRxObserver new].then(^(HWRxObserver *observer) {
        observer.keyPath = @"tap";
        [self addObserver:observer];
    });
}

- (HWRxObserver *(^)(NSString *))Rx {
    return ^(NSString *keyPath) {
        return [HWRxObserver new].then(^(HWRxObserver *observer) {
            observer.keyPath = keyPath;
            [self addObserver:observer];
        });
    };
}

@end

@implementation UILabel (RxObserver)

- (HWRxObserver *)Rx_text {
    return [HWRxObserver new].then(^(HWRxObserver *observer) {
        observer.keyPath = @"text";
        [self addObserver:observer];
    });
}

@end
