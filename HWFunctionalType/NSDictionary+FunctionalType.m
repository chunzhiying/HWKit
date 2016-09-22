//
//  NSDictionary+FunctionalType.m
//  HWKitDemo
//
//  Created by 陈智颖 on 16/8/31.
//  Copyright © 2016年 YY. All rights reserved.
//

#import "NSDictionary+FunctionalType.h"

@implementation NSDictionary (FunctionalType)

- (NSDictionary *(^)(mapType block))map {
    return ^(mapType block) {
        NSMutableDictionary *result = [NSMutableDictionary new];
        for (id key in self.allKeys) {
            id newElement = block(@{@"key":key, @"value":self[key]});
            if (newElement) {
                [result setObject:newElement forKey:key];
            }
        }
        return result;
    };
}

- (id (^)(flatMapType))flatMap {
    return ^(flatMapType block) {
        id result;
        for (id key in self.allKeys) {
            id newElement = block(@{@"key":key, @"value":self[key]});
            if (newElement) {
                result = newElement;
            }
        }
        return result;
    };
}

- (NSDictionary *(^)(filterType block))filter {
    return ^(filterType block) {
        NSMutableDictionary *result = [NSMutableDictionary new];
        for (id key in self.allKeys) {
            if ([block(@{@"key":key, @"value":self[key]}) boolValue]) {
                [result setObject:self[key] forKey:key];
            }
        }
        return result;
    };
}

- (id (^)(id original, reduceType block))reduce {
    return ^(id original, reduceType block) {
        id result = original;
        for (id key in self.allKeys) {
            result = block(result, @{@"key":key, @"value":self[key]});
        }
        return result;
    };
}

@end

@implementation NSDictionary (FunctionalTypeExample)

- (void)example {

    NSDictionary *dicResult = @{@"a":@1, @"b":@2, @"c":@3}.map(^(NSDictionary *dic) {
        return @([dic[@"value"] intValue] * 5);
    }).filter(^(NSDictionary *dic) {
        return [NSNumber numberWithBool:[dic[@"value"] intValue] > 5];
    });
    
    NSLog(@"dic:%@", dicResult);
    
}

@end

