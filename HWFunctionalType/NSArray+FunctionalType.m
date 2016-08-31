//
//  NSArray+FunctionalType.m
//  HWKitTestDemo
//
//  Created by 陈智颖 on 16/8/30.
//  Copyright © 2016年 YY. All rights reserved.
//

#import "NSArray+FunctionalType.h"

@implementation NSArray (FunctionalType)

- (NSArray *(^)(mapType block))map {
    return ^(mapType block) {
        NSMutableArray *result = [NSMutableArray new];
        for (id element in self) {
            id newElement = block(element);
            if (newElement) {
                [result addObject:newElement];
            }
        }
        return result;
    };
}

- (NSArray *(^)(flapMapType block))flapMap {
    return ^(flapMapType block) {
        NSMutableArray *result = [NSMutableArray new];
        for (id element in self) {
            if ([element isKindOfClass:[NSArray class]]) {
                NSArray *subResult = ((NSArray *)element).flapMap(block);
                [result addObjectsFromArray:subResult];
            } else {
                id newElement = block(element);
                if (newElement) {
                    [result addObject:newElement];
                }
            }
        }
        return result;
    };
}

- (NSArray *(^)(sortType block))sort {
    return ^(sortType block) {
        NSMutableArray *mAry = [[NSMutableArray alloc] initWithArray:self];
        [mAry sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
            return block(obj1, obj2);
        }];
        return mAry;
    };
}

- (NSArray *(^)(filterType block))filter {
    return ^(filterType block) {
        NSMutableArray *result = [NSMutableArray new];
        for (id element in self) {
            if ([block(element) boolValue]) {
                [result addObject:element];
            }
        }
        return result;
    };
}

- (id (^)(id original, reduceType block))reduce {
    return ^(id original, reduceType block) {
        id result = original;
        for (id element in self) {
            result = block(result, element);
        }
        return result;
    };
}

@end

@implementation NSArray (FunctionalTypeExample)

- (void)example {
    
    NSArray *a = @[@[@2, @3], @4, @1, @9, @5];
    
    NSArray *result = a.flapMap(^(id obj) {
        return @([obj intValue] * 3);
    }).sort(^(id obj1, id obj2) {
        return obj1 > obj2 ? NSOrderedAscending : NSOrderedDescending;
    }).filter(^(id obj) {
        return [NSNumber numberWithBool:[obj intValue] > 5];
    });
    
    id resultTotal = result.reduce(@0, ^(NSNumber *result, NSNumber *element) {
        result = @([result intValue] + [element intValue]);
        return result;
    });
    
    for (NSNumber *element in result) {
        NSLog(@"element:%@", element);
    }
    
    NSLog(@"resultTotal:%@", resultTotal);
}

@end
