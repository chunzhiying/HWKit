//
//  HWWeakTimer.m
//  TimerTest
//
//  Created by 陈智颖 on 15/9/9.
//  Copyright (c) 2015年 YY. All rights reserved.
//

#import "HWWeakTimer.h"

@interface HWWeakTimerTarget : NSObject
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, copy) NSString *runloopMode;
@property (nonatomic, weak) NSTimer *timer;
@end

@implementation HWWeakTimerTarget

- (void)fire:(NSTimer *)timer {
    
    if (self.target) {
        
        [self.target performSelectorOnMainThread:self.selector withObject:timer.userInfo waitUntilDone:false modes:@[self.runloopMode]];
        
    } else {
        [self.timer invalidate];
    }
}

@end

@implementation HWWeakTimer

+ (NSTimer *) scheduledTimerWithTimeInterval:(NSTimeInterval)interval target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)repeats{
    
    HWWeakTimerTarget *timerTarget = [[HWWeakTimerTarget alloc] init];
    timerTarget.target = aTarget;
    timerTarget.selector = aSelector;
    timerTarget.timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                         target:timerTarget
                                                       selector:@selector(fire:)
                                                       userInfo:userInfo
                                                        repeats:repeats];
    
    return timerTarget.timer;
}

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo runloop:(NSRunLoop *)runloop mode:(NSString *)mode {
    
    HWWeakTimerTarget *timerTarget = [[HWWeakTimerTarget alloc] init];
    timerTarget.target = aTarget;
    timerTarget.selector = aSelector;
    timerTarget.runloopMode = mode;
    NSTimer *timer = [NSTimer timerWithTimeInterval:ti
                                             target:timerTarget
                                           selector:@selector(fire:)
                                           userInfo:userInfo
                                            repeats:yesOrNo];

    [runloop addTimer:timer forMode:mode];
    
    timerTarget.timer = timer;
    return timerTarget.timer;
}

@end