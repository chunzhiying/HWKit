//
//  UIView+RxObserver.m
//  HWKitDemo
//
//  Created by 陈智颖 on 2016/10/20.
//  Copyright © 2016年 YY. All rights reserved.
//

#import "UIView+RxObserver.h"
#import "HWFunctionalType.h"
#import "NSArray+FunctionalType.h"
#import <objc/runtime.h>

@implementation UIView (RxObserver_Base)

- (void)addRxObserver:(HWRxObserver *)observer {
    if ([observer.keyPath isEqualToString:@"tap"]) {
        [self addGestureObserver:observer];
        [self.rx_observers addObject:observer];
    } else {
        [super addRxObserver:observer];
    }
}

- (void)addGestureObserver:(HWRxObserver *)observer {
    if ([self isKindOfClass:[UIButton class]]) {
        [(UIButton *)self addTarget:observer action:observer.tapAction forControlEvents:UIControlEventTouchUpInside];
    } else {
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:observer action:observer.tapAction]];
    }
}


#pragma mark - Method Swizzling
+ (void)load {
    Method originalMethod = class_getInstanceMethod([self class], @selector(removeFromSuperview));
    Method swizzledMethod = class_getInstanceMethod([self class], @selector(RxObserver_removeFromSuperview));
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (void)RxObserver_removeFromSuperview {
    if (self.rx_observers.count != 0) {
        self.rx_observers = (NSMutableArray *)self.rx_observers
        .filter(^(HWRxObserver *observer) {
            return @(![observer.keyPath isEqualToString:@"tap"]);
        });
        [self removeAllRxObserver];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    [self RxObserver_removeFromSuperview];
}

@end


@implementation UIView (RxObserver)

- (HWRxObserver *)rx_tap {
    return self.Rx(@"tap");
}

@end

@implementation UILabel (RxObserver)

- (HWRxObserver *)rx_text {
    return self.Rx(@"text");
}

@end

@implementation UITextField (RxObserver)

- (HWRxObserver *)rx_text {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:)
                                                 name:UITextFieldTextDidChangeNotification object:self];
    return self.Rx(@"text");
}

- (void)textFiledEditChanged:(NSNotification *)notification {
    self.text = self.text;
}

@end
