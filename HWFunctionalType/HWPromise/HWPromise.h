//
//  HWPromise.h
//  HWKitDemo
//
//  Created by 陈智颖 on 2016/9/23.
//  Copyright © 2016年 YY. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^thenType)(id obj);
typedef void(^alwaysType)(BOOL result, id obj);

@interface HWPromise : NSObject

@property (nonatomic, strong) id successObj;
@property (nonatomic, strong) id failObj;

@end

@interface HWPromise (FunctionalType_Extension)

@property (nonatomic, readonly) HWPromise *(^success)(thenType);
@property (nonatomic, readonly) HWPromise *(^fail)(thenType);
@property (nonatomic, readonly) HWPromise *(^always)(alwaysType);

@end
