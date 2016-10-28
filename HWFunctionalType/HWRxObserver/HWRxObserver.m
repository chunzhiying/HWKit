//
//  HWRxObserver.m
//  HWKitDemo
//
//  Created by 陈智颖 on 2016/10/20.
//  Copyright © 2016年 YY. All rights reserved.
//

#define weak(object) \
__weak __typeof(object) weak_##object = object;

#define strong(object) \
if (!weak_##object) { return; } \
__strong __typeof(weak_##object) strong_##object = weak_##object;

#define SafeBlock(atBlock, ...) \
if(atBlock) { atBlock(__VA_ARGS__); }

#import "HWRxObserver.h"
#import "NSArray+FunctionalType.h"

@interface HWRxObserver ()
{
    BOOL _connect;
    
    NSObject *_latestData;
    NSObject *_startWithData;
    NSMutableArray<nextType> *_nextBlockAry;
    
    BOOL _debounceEnable;
    CGFloat _debounceValue;
}

@property (nonatomic, strong) NSObject *rxObj;

@end

@implementation HWRxObserver

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tapAction = @selector(onTap);
        _nextBlockAry = [NSMutableArray new];
        _debounceEnable = YES;
        _connect = YES;
        _debounceValue = 0;
    }
    return self;
}

- (instancetype)initWithBaseData:(id)data {
    self = [self init];
    _latestData = data;
    return self;
}

- (void)dealloc {
    
}

- (void)onTap {
    self.rxObj = @"onTap";
}

- (void)setRxObj:(NSObject *)rxObj {
    if (!(_debounceEnable && _connect)) {
        return;
    }
    [self postAllWith:rxObj];
    
    _debounceEnable = _debounceValue == 0;
    if (_debounceValue > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_debounceValue * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
                           _debounceEnable = YES;
                       });
    }
}

#pragma mark - Post
- (void)postTo:(nextType)block with:(NSObject *)data {
    if (!data || !_connect) {
        return;
    }
    SafeBlock(block, data);
}

- (void)postAllWith:(NSObject *)data {
    _nextBlockAry.forEach(^(nextType block) {
        [self postTo:block with:data];
    });
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    if (![keyPath isEqualToString:_keyPath]) {
        return;
    }
    _latestData = change[@"new"];
    self.rxObj = change[@"new"];
}

@end

@implementation HWRxObserver (Base_Extension)

- (HWRxObserver *(^)(nextType))subscribe {
    return ^(nextType block) {
        [_nextBlockAry addObject:block];
        [self postTo:block with:_startWithData];
        return self;
    };
}

- (HWRxObserver *(^)(CGFloat))debounce {
    return ^(CGFloat value) {
        _debounceValue = value;
        return self;
    };
}

- (HWRxObserver *(^)(id object, NSString *keyPath))bindTo {
    return ^(id object, NSString *keyPath) {
        weak(object)
        self.subscribe(^(id result) {
            strong(object)
            [strong_object setValue:result forKey:keyPath];
        });
        return self;
    };
}

- (HWRxObserver *(^)(NSObject *))disposeBy {
    return ^(NSObject *obj) {
        self.disposer = [NSString stringWithFormat:@"%p", obj];
        return self;
    };
}

- (HWRxObserver *(^)(id))startWith {
    return ^(NSObject *data) {
        _startWithData = data;
        return self;
    };
}

- (HWRxObserver *(^)())behavior {
    return ^() {
        _connect = NO;
        return self;
    };
}

- (HWRxObserver *(^)())connect {
    return ^() {
        if (!_connect) {
            _connect = YES;
            [self postAllWith:_startWithData];
            [self postAllWith:_latestData];
        }
        _connect = YES;
        return self;
    };
}

- (HWRxObserver *(^)())disconnect {
    return ^() {
        _connect = NO;
        _startWithData = nil;
        return self;
    };
}

@end

@implementation HWRxObserver (Functional_Extension)

- (HWRxObserver *(^)(mapType))map {
    return ^(mapType block) {
        HWRxObserver *observer = [HWRxObserver new];
        self.subscribe(^(id obj) {
            id data = block(obj);
            if (data != nil) {
                observer.rxObj = data;
            }
        });
        return observer;
    };
}

- (HWRxObserver *(^)(filterType))filter {
    return ^(filterType block) {
        HWRxObserver *observer = [HWRxObserver new];
        self.subscribe(^(id obj) {
            if ([block(obj) boolValue]) {
                observer.rxObj = obj;
            }
        });
        return observer;
    };
}

- (HWRxObserver *(^)(id, reduceType))reduce {
    return ^(id result, reduceType block) {
        HWRxObserver *observer = [HWRxObserver new];
        weak(result)
        self.subscribe(^(id obj) {
            strong(result)
            strong_result = block(strong_result, obj);
            observer.rxObj = strong_result;
        });
        return observer;
    };
}

- (HWRxObserver *(^)())distinctUntilChanged {
    return ^() {
        HWRxObserver *observer = [HWRxObserver new];
        __block id lastObj = nil;
        self.subscribe(^(id obj) {
            if ((![obj isKindOfClass:[lastObj class]])
                ||([obj isKindOfClass:[NSValue class]] && ![obj isEqualToValue:lastObj])
                ||([obj isKindOfClass:[NSString class]] && ![obj isEqualToString:lastObj]))
            {
                lastObj = obj;
                observer.rxObj = obj;
                return;
            }
        });
        return observer;
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