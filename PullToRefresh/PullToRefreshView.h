//
//  PullToRefreshView.h
//  yyfe
//
//  Created by 陈智颖 on 15/9/18..
//  Copyright (c) 2015年 yy.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RefreshDataCallBack)(BOOL);
typedef void(^LoadMoreDataCallBack)(BOOL);

static NSInteger const defaultRefreshNewDataCount = 0; // for just have refresh
static NSInteger const noNeedtoRefreshDistance = 0;

@protocol RefreshDelegate <NSObject>

@required - (void)refreshData:(RefreshDataCallBack)callBack;
@optional - (void)cancelRefresh;

@end


@protocol LoadMoreDelegate <NSObject>

@required - (void)loadMoreData:(LoadMoreDataCallBack)callBack;
@optional - (NSInteger)numberOfSections;

@end


@protocol PullToRefreshTableViewDelegate <NSObject>

@required
- (NSInteger)pullToRefresh:(UITableView *)pullTableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)pullToRefresh:(UITableView *)pullTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (UIView *)pullToRefresh:(UITableView *)pullTableView viewForFooterInSection:(NSInteger)section;
- (UIView *)pullToRefresh:(UITableView *)pullTableView viewForHeaderInSection:(NSInteger)section;

- (CGFloat)pullToRefresh:(UITableView *)pullTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)pullToRefresh:(UITableView *)pullTableView heightForFooterInSection:(NSInteger)section;
- (CGFloat)pullToRefresh:(UITableView *)pullTableView heightForHeaderInSection:(NSInteger)section;

- (NSInteger)numberOfSectionsInPullToRefresh:(UITableView *)pullTableView;
- (void)pullToRefresh:(UITableView *)pullTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)pullToRefresh:(UITableView *)pullToRefresh canEditRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)pullToRefresh:(UITableView *)pullToRefresh commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface PullToRefreshView : UIView

@property (nonatomic, weak) id<RefreshDelegate> refreshDelegate;
@property (nonatomic, weak) id<LoadMoreDelegate> loadMoreDelegate;
@property (nonatomic, weak) id<PullToRefreshTableViewDelegate> pullToRefreshDelegate;

@property (nonatomic) BOOL scrollsToTop;
@property (nonatomic, strong) UIView* tableHeaderView;

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style;

- (void)setRefresh:(BOOL)refresh andLoadMore:(BOOL)loadMore andRefreshTopDistance:(NSInteger)distance;

- (void)reloadDataWithCounts:(NSInteger)newDataCount;

- (void)beginUpdates;
- (void)endUpdates;
- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
@end



