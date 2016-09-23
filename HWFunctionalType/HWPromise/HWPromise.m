//
//  HWPromise.m
//  HWKitDemo
//
//  Created by 陈智颖 on 2016/9/23.
//  Copyright © 2016年 YY. All rights reserved.
//

#define SafeBlock(atBlock, ...) if(atBlock) { atBlock(__VA_ARGS__); }

#import "HWPromise.h"

@interface HWPromise ()
{
    thenType _successBlock;
    thenType _failBlock;
    alwaysType _alwaysBlock;
}

@end

@implementation HWPromise

- (void)setSuccessObj:(id)successObj {
    _successObj = successObj;
    if (!successObj) {
        return;
    }
    SafeBlock(_successBlock, _successObj)
    SafeBlock(_alwaysBlock, YES, _successObj)
}

- (void)setFailObj:(id)failObj {
    _failObj = failObj;
    if (!failObj) {
        return;
    }
    SafeBlock(_failBlock, _failObj)
    SafeBlock(_alwaysBlock, NO, _failObj)
}

@end

@implementation HWPromise (FunctionalType_Extension)

- (HWPromise *(^)(thenType))success {
    return ^(thenType block) {
        _successBlock = block;
        return self;
    };
}

- (HWPromise *(^)(thenType))fail {
    return ^(thenType block) {
        _failBlock = block;
        return self;
    };
}

- (HWPromise *(^)(alwaysType))always {
    return ^(alwaysType block) {
        _alwaysBlock = block;
        return self;
    };
}

@end
