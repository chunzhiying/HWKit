//
//  PullToRefreshHeaderView.h
//  yyfe
//
//  Created by 陈智颖 on 16/7/14.
//  Copyright © 2016年 yy.com. All rights reserved.
//

#ifndef PullToRefreshHeaderView_h
#define PullToRefreshHeaderView_h


#define TimerWaitingDuration 10
#define RefreshHeaderHeight 50
#define LoadMoreCellHeight 50
#define DefaultCellHeight LoadMoreCellHeight
#define AutoRefreshHeaderHeight (RefreshHeaderHeight + 1)
#define CantSeeHeaderFooterHeight 0.01


#define Delay(time, block) \
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), block);


#define RefreshHeader_DEC \
    UILabel *tipsLabel;\
    CAShapeLayer *shapeLayer;\
    UIImageView *refreshArrow;\
    UIImageView *refreshKLine;\
    UIImageView *refreshKLineRed;\


#define RefreshHeader_IMP(TopDistance) \
do {\
        tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - 20, 0, self.frame.size.width/2 - 20, RefreshHeaderHeight)];\
        tipsLabel.font = [UIFont systemFontOfSize:13.0f];\
        tipsLabel.textColor = [ColorUtil colorWithRGBA:0xa5a5a5ff];\
\
        refreshKLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refresh_kLine"]];\
        refreshKLine.frame = CGRectMake(tipsLabel.frame.origin.x - 35, (RefreshHeaderHeight - 10)/2, 23, 10);\
        refreshKLineRed = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refresh_kLine_red"]];\
        refreshKLineRed.frame = refreshKLine.frame;\
        refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refresh_arrow"]];\
        refreshArrow.frame = CGRectMake(tipsLabel.frame.origin.x - 30, (RefreshHeaderHeight - 22)/2, 22, 22);\
\
        UIBezierPath* path = [UIBezierPath bezierPath];\
        [path moveToPoint:CGPointMake(refreshKLine.frame.origin.x, TopDistance + RefreshHeaderHeight/2 + 5)];\
        [path addLineToPoint:CGPointMake(refreshKLine.frame.origin.x + 7, TopDistance + RefreshHeaderHeight/2 - 2)];\
        [path addLineToPoint:CGPointMake(refreshKLine.frame.origin.x + 14, TopDistance + RefreshHeaderHeight/2 + 3)];\
        [path addLineToPoint:CGPointMake(refreshKLine.frame.origin.x + refreshKLine.frame.size.width - 1.5, TopDistance + RefreshHeaderHeight/2 - 4)];\
\
        shapeLayer = [CAShapeLayer layer];\
        shapeLayer.path = path.CGPath;\
        shapeLayer.fillColor = [UIColor clearColor].CGColor;\
        shapeLayer.strokeColor = [UIColor redColor].CGColor;\
        shapeLayer.strokeEnd = 0;\
\
        UIView *headView = [UIView new];\
        headView.frame = CGRectMake(0, -RefreshHeaderHeight, self.frame.size.width,RefreshHeaderHeight);\
        headView.backgroundColor = DefaultBgColor;\
\
        [headView addSubview:tipsLabel];\
        [headView addSubview:refreshKLine];\
        [headView addSubview:refreshKLineRed];\
        [headView addSubview:refreshArrow];\
        [headView.layer addSublayer:shapeLayer];\
        [_tableView addSubview:headView];\
\
} while (0);\



#define RefreshHeader_WillRefresh \
do {\
        refreshArrow.hidden = NO;\
        refreshKLine.hidden = YES;\
        refreshKLineRed.hidden = YES;\
        shapeLayer.strokeEnd = 0;\
        tipsLabel.text = @"下拉刷新..";\
        [shapeLayer removeAllAnimations];\
\
} while (0);\



#define RefreshHeader_CanRefresh \
do {\
        tipsLabel.text = @"松开立即刷新";\
\
} while (0);\



#define RefreshHeader_Refreshing \
do {\
        tipsLabel.text = @"正在刷新..";\
        refreshArrow.hidden = YES;\
        refreshKLine.hidden = NO;\
        refreshKLineRed.hidden = YES;\
\
} while (0);\



#define RefreshHeader_RefreshFailed \
do {\
        tipsLabel.text = @"刷新失败";\
        refreshKLineRed.hidden = YES;\
        refreshKLine.hidden = NO;\
        shapeLayer.strokeEnd = 0;\
        [shapeLayer removeAllAnimations];\
\
} while (0);\



#define RefreshHeader_RefreshSuccess \
do {\
        tipsLabel.text = @"刷新成功";\
        refreshKLineRed.hidden = NO;\
        refreshKLine.hidden = YES;\
        shapeLayer.strokeEnd = 1;\
        [shapeLayer removeAllAnimations];\
\
} while (0);\



#define RefreshHeader_DoRefreshAnimation \
do {\
        CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];\
        ani.fromValue = @(0);\
        ani.toValue = @(1.0f);\
        ani.duration = 1.f;\
        ani.delegate = self;\
        [ani setValue:@"flash" forKey:@"animationFlag"];\
        [shapeLayer addAnimation:ani forKey:nil];\
\
} while (0);\


#define RefreshHeader_AnimationCheck \
        [[anim valueForKey:@"animationFlag"] isEqualToString:@"flash"]



#endif /* PullToRefreshHeaderView_h */
