//
//  HWRxObserver.h
//  HWKitDemo
//
//  Created by 陈智颖 on 2016/10/20.
//  Copyright © 2016年 YY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class HWRxObserver;

typedef void(^nextType)(id obj);


@interface HWRxObserver : NSObject

@property (nonatomic, strong) NSString *keyPath;
@property (nonatomic, assign) SEL tapAction;

@end


@interface HWRxObserver (Functional_Extension)

@property (nonatomic, readonly) HWRxObserver *(^subscribe)(nextType);
@property (nonatomic, readonly) HWRxObserver *(^debounce)(CGFloat);

@end


@interface NSArray (RxObserver_Extension)

@property (nonatomic, readonly) HWRxObserver *merge;
@property (nonatomic, readonly) HWRxObserver *combineLatest;

@end
