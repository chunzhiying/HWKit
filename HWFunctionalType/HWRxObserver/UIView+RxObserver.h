//
//  UIView+RxObserver.h
//  HWKitDemo
//
//  Created by 陈智颖 on 2016/10/20.
//  Copyright © 2016年 YY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HWRxObserver.h"

@interface UIView (RxObserver)

@property (nonatomic, readonly) HWRxObserver *Rx_tap;
@property (nonatomic, readonly) HWRxObserver *(^Rx)(NSString *keyPath);

@end

@interface UILabel (RxObserver)

@property (nonatomic, readonly) HWRxObserver *Rx_text;

@end


