//
//  LoadMoreCell.m
//  yyfe
//
//  Created by chenzy on 15/6/25.
//  Copyright (c) 2015年 yy.com. All rights reserved.
//

#import "LoadMoreCell.h"

@interface LoadMoreCell(){
    __weak IBOutlet UILabel *_tipsLabel;
    __weak IBOutlet UIActivityIndicatorView *_tipsActivity;

}
@end

@implementation LoadMoreCell

- (void)awakeFromNib {
    [_tipsActivity startAnimating];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


- (void)setLoadMoreType:(LoadMoreState)state{
    switch (state) {
        case NetworkNotReachable:
            _tipsLabel.hidden = YES;
            _tipsActivity.hidden = YES;
            break;
        case NoMoreData:
            _tipsLabel.text = @"已经到底啦!";
            _tipsActivity.hidden = YES;
            break;
        case LoadMoreData:
            _tipsLabel.text = @"加载更多..";
            _tipsActivity.hidden = NO;
            break;
    }
}
@end
