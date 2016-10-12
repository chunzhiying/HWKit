//
//  HWPromise.m
//  HWKitDemo
//
//  Created by 陈智颖 on 2016/9/23.
//  Copyright © 2016年 YY. All rights reserved.
//

#define SafeBlock(atBlock, ...) if(atBlock) { atBlock(__VA_ARGS__); }

#import "HWPromise.h"
#import "NSArray+FunctionalType.h"

@implementation HWPromiseResult

+ (instancetype)allocWithStatus:(BOOL)status Object:(id)object {
    HWPromiseResult *result = [HWPromiseResult new];
    result.status = status;
    result.object = object;
    return result;
}

@end

@interface HWPromise ()
{
    thenType _successBlock;
    thenType _failBlock;
    alwaysType _alwaysBlock;
    completeType _completeBlock;
}

@property (nonatomic, strong) NSArray<HWPromiseResult *> *results;

@end

@implementation HWPromise

- (void)setSuccessObj:(id)successObj {
    _successObj = successObj;
    if (!successObj) {
        return;
    }
    SafeBlock(_successBlock, _successObj)
    SafeBlock(_alwaysBlock, [HWPromiseResult allocWithStatus:YES
                                                      Object:_successObj])
}

- (void)setFailObj:(id)failObj {
    _failObj = failObj;
    if (!failObj) {
        return;
    }
    SafeBlock(_failBlock, _failObj)
    SafeBlock(_alwaysBlock, [HWPromiseResult allocWithStatus:NO
                                                      Object:_failObj])
}

- (void)setResults:(NSArray<HWPromiseResult *> *)results {
    _results = results;
    SafeBlock(_completeBlock, results.flatMap(^(HWPromiseResult *result) {
        return [result isKindOfClass:[HWPromiseResult class]] ? result : nil;
    }))
}

- (HWPromise *)combine:(HWPromise *)another {
    HWPromise *promise = [HWPromise new];
    self.complete(^(NSArray<HWPromiseResult *> *result1s) {
        another.always(^(HWPromiseResult *result2) {
            promise.results = @[result1s, result2].flatMap(^(HWPromiseResult *result) {
                return result;
            });
        });
    });
    return promise;
}

@end

@implementation HWPromise (FunctionalType_Extension)

- (HWPromise *(^)(thenType))success {
    return ^(thenType block) {
        _successBlock = block;
        if (_successObj) {
            SafeBlock(block, _successObj)
        }
        return self;
    };
}

- (HWPromise *(^)(thenType))fail {
    return ^(thenType block) {
        _failBlock = block;
        if (_failObj) {
            SafeBlock(block, _failObj)
        }
        return self;
    };
}

- (HWPromise *(^)(alwaysType))always {
    return ^(alwaysType block) {
        _alwaysBlock = block;
        if (_failObj) {
            SafeBlock(_alwaysBlock, [HWPromiseResult allocWithStatus:NO Object:_failObj])
        }
        else if (_successObj) {
            SafeBlock(_alwaysBlock, [HWPromiseResult allocWithStatus:YES Object:_successObj])
        }
        return self;
    };
}

- (HWPromise *(^)(completeType))complete {
    return ^(completeType block){
        _completeBlock = block;
        if (_results.count > 0) {
            self.results = _results;
        }
        return self;
    };
}

@end

@implementation NSArray (Promise_Extension)

- (HWPromise *)promise {
    return self
    .filter(^(HWPromise *promise){
        return @([promise isKindOfClass:[HWPromise class]]);
    })
    .reduce([HWPromise new].then(^(HWPromise *promise) {promise.results = @[[NSNull null]];}),
            ^(HWPromise *promise1, HWPromise *promise2)
            {
                return [promise1 combine:promise2];
            });
}

@end
