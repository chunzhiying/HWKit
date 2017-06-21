//
//  PullToRefreshCustomTable.m
//  yyfe
//
//  Created by 陈智颖 on 16/8/11.
//  Copyright © 2016年 yy.com. All rights reserved.
//

#import "PullToRefreshCustomTable.h"

@implementation PullToRefreshCustomTable

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return _allowSimultaneousRecognition;
}

@end
