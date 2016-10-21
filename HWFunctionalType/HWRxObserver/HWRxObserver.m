//
//  HWRxObserver.m
//  HWKitDemo
//
//  Created by 陈智颖 on 2016/10/20.
//  Copyright © 2016年 YY. All rights reserved.
//

#define SafeBlock(atBlock, ...) if(atBlock) { atBlock(__VA_ARGS__); }
#define ATDelay(sec, block) \
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(sec * NSEC_PER_SEC)), dispatch_get_main_queue(), block);

#import "HWRxObserver.h"
#import "NSArray+FunctionalType.h"

@interface HWRxObserver ()
{
    BOOL _enable;
    CGFloat _debounceValue;
    NSMutableArray<nextType> *_nextBlockAry;
}

@property (nonatomic, strong) NSObject *rxObj;

@end

@implementation HWRxObserver

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tapAction = @selector(onTap);
        _nextBlockAry = [NSMutableArray new];
        _enable = YES;
        _debounceValue = 0;
    }
    return self;
}

- (void)setRxObj:(NSObject *)rxObj {
    if (!_enable) {
        return;
    }
    _enable = NO;
    
    _rxObj = rxObj;
    _nextBlockAry.forEach(^(nextType block) {
        SafeBlock(block, rxObj);
    });
    
    ATDelay(_debounceValue, ^{
        _enable = YES;
    })
}

- (void)onTap {
    self.rxObj = @"onTap";
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (![keyPath isEqualToString:_keyPath]) {
        return;
    }
    self.rxObj = change[@"new"];
}

@end

@implementation HWRxObserver (Functional_Extension)

- (HWRxObserver *(^)(nextType))subscribe {
    return ^(nextType block) {
        [_nextBlockAry addObject:block];
        return self;
    };
}

- (HWRxObserver *(^)(CGFloat))debounce {
    return ^(CGFloat value) {
        _debounceValue = value;
        return self;
    };
}

@end

@implementation NSArray (RxObserver_Extension)

- (HWRxObserver *)merge {
    HWRxObserver *observer = [HWRxObserver new];
    self.filter(^(id obj) {
        return @([obj isKindOfClass:[HWRxObserver class]]);
    }).forEach(^(HWRxObserver *observable) {
        observable.subscribe(^(id data) {
            observer.rxObj = data;
        });
    });
    return observer;
}

- (HWRxObserver *)combineLatest {
    HWRxObserver *observer = [HWRxObserver new];
    NSArray *observers = self.filter(^(id obj) {
        return @([obj isKindOfClass:[HWRxObserver class]]);
    });
    NSMutableArray *results = (NSMutableArray *)observers.map(^(id obj) {
        return @"combineLatest";
    });
    observers.forEachWithIndex(^(HWRxObserver *observable, NSUInteger index) {
        observable.subscribe(^(id obj) {
            [results replaceObjectAtIndex:index withObject:obj];
            
            NSArray *filtered = results.filter(^(id result) {
                return @([result isKindOfClass:[NSString class]] && [result isEqualToString:@"combineLatest"]);
            });
            if (filtered.count == 0) {
                observer.rxObj = results;
            }
        });
    });
    
    return observer;
}

@end
