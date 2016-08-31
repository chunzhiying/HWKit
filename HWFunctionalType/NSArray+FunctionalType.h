//
//  NSArray+FunctionalType.h
//  HWKitTestDemo
//
//  Created by 陈智颖 on 16/8/30.
//  Copyright © 2016年 YY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HWFunctionalType.h"

@interface NSArray (FunctionalType) <HWFunctionalType>

@property (nonatomic, readonly) NSArray *(^map)(mapType);
@property (nonatomic, readonly) NSArray *(^flapMap)(flapMapType);
@property (nonatomic, readonly) NSArray *(^sort)(sortType);
@property (nonatomic, readonly) NSArray *(^filter)(filterType);
@property (nonatomic, readonly) id (^reduce)(id, reduceType);

@end

