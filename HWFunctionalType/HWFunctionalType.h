//
//  HWFunctionalType.h
//  HWKitTestDemo
//
//  Created by 陈智颖 on 16/8/30.
//  Copyright © 2016年 YY. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id(^mapType)(id element);
typedef id(^flapMapType)(id element);
typedef id(^reduceType)(id result, id element);
typedef NSNumber *(^filterType)(id obj1);
typedef NSComparisonResult(^sortType)(id obj1, id obj2);

@protocol HWFunctionalType <NSObject>

@optional
@property (nonatomic, readonly) id<HWFunctionalType>(^map)(mapType);
@property (nonatomic, readonly) id<HWFunctionalType>(^flapMap)(flapMapType);
@property (nonatomic, readonly) id<HWFunctionalType>(^sort)(sortType);
@property (nonatomic, readonly) id<HWFunctionalType>(^filter)(filterType);
@property (nonatomic, readonly) id(^reduce)(id, reduceType);

@end
