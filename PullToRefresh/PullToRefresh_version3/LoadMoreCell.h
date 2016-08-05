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
    NoMoreData,
    LoadMoreData
};

@interface LoadMoreCell : UITableViewCell

- (void)setLoadMoreType:(LoadMoreState)state;

@end
