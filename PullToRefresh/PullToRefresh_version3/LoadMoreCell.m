//
//  LoadMoreCell.m
//  yyfe
//
//  Created by chenzy on 15/6/25.
//  Copyright (c) 2015年 yy.com. All rights reserved.
//

#import "LoadMoreCell.h"

@interface LoadMoreCell() {
    
    LoadMoreState _state;
    
    __weak IBOutlet UILabel *_tipsLabel;
    __weak IBOutlet UIActivityIndicatorView *_tipsActivity;
}
@end

@implementation LoadMoreCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [_tipsActivity startAnimating];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickSelf)];
    [self addGestureRecognizer:tap];
}

- (void)setLoadMoreType:(LoadMoreState)state {
    
    _state = state;
    
    _tipsLabel.hidden = NO;
    _tipsActivity.hidden = NO;
    
    switch (state) {
        case NetworkNotReachable:
            _tipsLabel.hidden = YES;
            _tipsActivity.hidden = YES;
            break;
            
        case NoMore:
            _tipsActivity.hidden = YES;
            _tipsLabel.text = @"已经到底啦!";
            break;
            
        case CanLoadMore:
            _tipsLabel.text = @"加载更多..";
            break;
            
        case ClickToReload:
            _tipsActivity.hidden = YES;
            _tipsLabel.text = @"加载失败, 点击重新加载";
            break;
    }
}

- (void)onClickSelf {
    
    if (_state != ClickToReload) {
        return;
    }
    
    _tipsLabel.hidden = NO;
    _tipsActivity.hidden = NO;
    _tipsLabel.text = @"重新加载中..";
    
    if (_delegate && [_delegate respondsToSelector:@selector(loadMoreCellClickedToReload)]) {
        [_delegate loadMoreCellClickedToReload];
    }
}

@end
