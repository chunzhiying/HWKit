//
//  PullToRefreshView.h
//  yyfe
//
//  Created by 陈智颖 on 15/9/18..
//  Copyright (c) 2015年 yy.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RefreshDataCallBack)(BOOL refreshSuccess);
typedef void(^LoadMoreDataCallBack)(BOOL loadMoreSuccess);

extern NSString * const onTabbarChangeNotification;

@class PullToRefreshView;


@protocol RefreshDelegate <NSObject>

@required - (void)pullToRefresh:(PullToRefreshView *)pullToRefresh refreshData:(RefreshDataCallBack)callBack;
@optional - (void)cancelRefreshingInPullToRefresh:(PullToRefreshView *)pullToRefresh;

@end


@protocol LoadMoreDelegate <NSObject>

@required - (void)pullToRefresh:(PullToRefreshView *)pullToRefresh loadMoreData:(LoadMoreDataCallBack)callBack;
@optional - (CGFloat)heightOfLoadMoreCellInPullToRefresh:(PullToRefreshView *)pullToRefresh;

@end


@protocol PullToRefreshTableViewDelegate <NSObject>

@required
- (NSInteger)pullToRefresh:(UITableView *)pullTableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)pullToRefresh:(UITableView *)pullTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (NSInteger)numberOfSectionsInPullToRefresh:(UITableView *)pullTableView;

- (UIView *)pullToRefresh:(UITableView *)pullTableView viewForFooterInSection:(NSInteger)section;
- (UIView *)pullToRefresh:(UITableView *)pullTableView viewForHeaderInSection:(NSInteger)section;

- (CGFloat)pullToRefresh:(UITableView *)pullTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)pullToRefresh:(UITableView *)pullTableView heightForFooterInSection:(NSInteger)section;
- (CGFloat)pullToRefresh:(UITableView *)pullTableView heightForHeaderInSection:(NSInteger)section;

- (void)pullToRefresh:(UITableView *)pullTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)pullToRefresh:(UITableView *)pullTableView didEndDisplayingCell:(UITableViewCell *)cell;
- (BOOL)pullToRefresh:(UITableView *)pullToRefresh canEditRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)pullToRefresh:(UITableView *)pullToRefresh commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)pullToRefresh:(PullToRefreshView *)pullToRefresh scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)pullToRefresh:(PullToRefreshView *)pullToRefresh scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;
- (void)pullToRefresh:(PullToRefreshView *)pullToRefresh scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)pullToRefresh:(PullToRefreshView *)pullToRefresh scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)pullToRefresh:(PullToRefreshView *)pullToRefresh scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

@optional
- (BOOL)canShowTableHeaderViewWhenNoContentInPullToRefresh:(UITableView *)pullTableView;
- (BOOL)canShowTableFooterViewWhenNoContentInPullToRefresh:(UITableView *)pullTableView;

@end


@interface PullToRefreshView : UIView

@property (nonatomic, weak) id<RefreshDelegate> refreshDelegate;
@property (nonatomic, weak) id<LoadMoreDelegate> loadMoreDelegate;
@property (nonatomic, weak) id<PullToRefreshTableViewDelegate> pullToRefreshDelegate;

@property (nonatomic) UIEdgeInsets constrain;
@property (nonatomic) CGPoint contentOffset;

@property (nonatomic) BOOL autoUpdateFromBackground; //Default: YES, refresh the current pullToRefreshView when App enter foreground.
@property (nonatomic) BOOL enableNetDisConnect;  //Default: YES, show disconnect view when network broken or without data.
@property (nonatomic, strong) UIView *noContentView;  //Default: nil, set to replace disconnect view when without data.

@property (nonatomic, strong) UIView *tableHeaderView;
@property (nonatomic, strong) UIView *tableFooterView;

@property (nonatomic) BOOL allowSimultaneousRecognition; //YES, tableView allow simultaneous recognition, default NO

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style;
- (instancetype)initWithConstrain:(UIEdgeInsets)constrain style:(UITableViewStyle)style addToParentView:(UIView *)parentView; //Already add to parentView.

- (void)setRefresh:(BOOL)refresh andLoadMore:(BOOL)loadMore andRefreshTopDistance:(NSInteger)distance;

- (void)reloadDataWithCounts:(NSInteger)newDataCount; //Pass new added data count not ALL when can loadMore.

- (void)shouldRefreshData; // Query data with animation.

@end


@interface PullToRefreshView (Addition)

@property (nonatomic) BOOL scrollsToTop;
@property (nonatomic) BOOL scrollEnabled;
@property (nonatomic) BOOL allowsSelection;

@property (nonatomic) BOOL showsHorizontalScrollIndicator;
@property (nonatomic) BOOL showsVerticalScrollIndicator;

@property (nonatomic, readonly) CGSize contentSize;
@property (nonatomic, readonly) NSArray<__kindof UITableViewCell *> *visibleCells;

- (void)beginUpdates;
- (void)endUpdates;

- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;
- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void)reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;

- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated;
- (CGRect)rectForSection:(NSInteger)section;

@end

