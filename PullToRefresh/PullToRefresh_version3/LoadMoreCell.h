//
//  LoadMoreCell.h
//  yyfe
//
//  Created by chenzy on 15/6/25.
//  Copyright (c) 2015年 yy.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LoadMoreState){
    NetworkNotReachable,
    NoMore,                 //已经到底啦
    CanLoadMore,            //上拉加载更多
    ClickToReload           //点击重新加载
};

@protocol LoadMoreCellDelegate <NSObject>

- (void)loadMoreCellClickedToReload;

@end

@interface LoadMoreCell : UITableViewCell

@property (nonatomic, weak) id<LoadMoreCellDelegate> delegate;

- (void)setLoadMoreType:(LoadMoreState)state;

@end
