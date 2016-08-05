    //
//  PullToRefreshView.m
//  yyfe
//
//  Created by 陈智颖 on 15/9/18.
//  Copyright (c) 2015年 yy.com. All rights reserved.
//


#import "PullToRefreshView.h"
#import "ColorUtil.h"
#import "LoadMoreCell.h"
#import "NetworkInfo.h"
#import "UICenter.h"
#import "NetDisconnectView.h"
#import "RefreshHeader_Macro.h"

NSString * const onTabbarChangeNotification = @"onTabbarChangeNotification";

typedef NS_ENUM(NSInteger, RefreshingState) {
    Refreshing,
    CanRefresh,
    WillRefresh,
    RefreshSucceed,
    RefreshFailed
};


@interface PullToRefreshView() <UITableViewDelegate, UITableViewDataSource, NetDisconnectViewDelegate> {
    
    RefreshHeader_DEC
    
    UITableView* _tableView;
    NSInteger _tableViewTopDistance;
    
    NetDisconnectView *_netDisconnectView;
    NSInteger _allDataCount;
    
    NSTimer * _requestTimer;
    
    BOOL _notFirstSystemReload; //filter first reload
    
    BOOL _canRefresh;
    BOOL _canLoadMore;
    
    BOOL _refreshFailed;
    BOOL _autoRefresh;
    
    BOOL _showNoContentView;
    
}
@property (nonatomic) BOOL isGetRefreshData;
@property (nonatomic) BOOL isGetLoadMoreData;

@property (nonatomic) RefreshingState refreshingState;
@property (nonatomic) NSInteger newDataCount;
@property (nonatomic) NSInteger sectionCount;

@property (nonatomic, copy) RetryResultBlock netDisconnectBlock;

@end

@implementation PullToRefreshView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame];
    if (self) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:style];
        [self initTableView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame style:UITableViewStylePlain];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _tableView = [UITableView new];
        [self initTableView];
        [self setConstrain:UIEdgeInsetsMake(0, 0, 0, 0) withSubView:_tableView andParentView:self];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _noContentView.frame = self.bounds;
    if (_showNoContentView) {
        [self reloadData];
    }
    
    [self layoutIfNeeded];
}

#pragma mark - Custom Method
- (void)setRefresh:(BOOL)refresh andLoadMore:(BOOL)loadMore andRefreshTopDistance:(NSInteger)distance{
    
    _canRefresh = refresh;
    _canLoadMore = loadMore;
    _tableViewTopDistance = distance;
    
    _sectionCount = 1;
    
    [self initRefreshUI];
    [self initNotification];
}

- (void)initTableView {
    _tableView.backgroundColor = DefaultBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self addSubview:_tableView];
    
    for (UIView *subView in _tableView.subviews) {
        if ([subView isKindOfClass:[UIScrollView class]]) {
            [(UIScrollView *)subView setScrollsToTop:NO];
        }
    }
}

- (void)initRefreshUI{
    
    if (_canRefresh) {
        RefreshHeader_IMP(_tableViewTopDistance)
    }
    
    _netDisconnectView = [NetDisconnectView addNetDisConnectViewIn:self delegate:self];
    
    [self willRefresh];
}

- (void)checkIfNoContent:(NSInteger)dataCount {
    
    if (dataCount == 0 && _noContentView && !_showNoContentView) {
        _showNoContentView = YES;
        _netDisconnectView.hidden = YES;
        _tableView.tableHeaderView = nil;
        _tableView.tableFooterView = nil;
        [self reloadData];
        return;
    }
    
    if (!_showNoContentView && _tableHeaderView && _tableView.tableHeaderView == nil) {
        _tableView.tableHeaderView = _tableHeaderView;
    }
    
    if (!_showNoContentView && _tableFooterView && _tableView.tableFooterView == nil) {
        _tableView.tableFooterView = _tableFooterView;
    }
    
    _netDisconnectView.hidden = dataCount == 0 ? NO : YES;
    _showNoContentView = NO;
}

#pragma mark - Constrain
- (instancetype)initWithConstrain:(UIEdgeInsets)constrain style:(UITableViewStyle)style addToParentView:(UIView *)parentView {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:style];
        [self initTableView];
        [parentView addSubview:self];
        
        [self setConstrain:UIEdgeInsetsMake(0, 0, 0, 0) withSubView:_tableView andParentView:self];
        [self setConstrain:constrain withSubView:self andParentView:parentView];
    }
    return self;
}

- (void)setConstrain:(UIEdgeInsets)edge withSubView:(UIView *)subView andParentView:(UIView *)parentView {
    
    [subView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    for (NSLayoutConstraint *constraint in parentView.constraints) {
        if ([constraint.firstItem isKindOfClass:[PullToRefreshView class]]) {
            [parentView removeConstraint:constraint];
        }
    }
    
    [parentView addConstraints:@[[NSLayoutConstraint constraintWithItem:subView
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:parentView
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0
                                                               constant:edge.top],
                                 
                                 [NSLayoutConstraint constraintWithItem:subView
                                                              attribute:NSLayoutAttributeLeft
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:parentView
                                                              attribute:NSLayoutAttributeLeft
                                                             multiplier:1.0
                                                               constant:edge.left],
                                 
                                 [NSLayoutConstraint constraintWithItem:subView
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:parentView
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:-edge.bottom],
                                 
                                 [NSLayoutConstraint constraintWithItem:subView
                                                              attribute:NSLayoutAttributeRight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:parentView
                                                              attribute:NSLayoutAttributeRight
                                                             multiplier:1.0
                                                               constant:-edge.right]]];

}

#pragma mark - Notification
- (void)initNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppEnterForegroundNotification:)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTabbarChangeNotification:)
                                                 name:onTabbarChangeNotification object:nil];
}

- (void)onAppEnterForegroundNotification:(NSNotification *)notification {
    
    if (!_canRefresh) {
        return;
    }
    
    for (id next = _pullToRefreshDelegate; next; next = [next nextResponder]) {
            
        if ([next isKindOfClass:[UIViewController class]] && [(UIViewController *)next navigationController]) {
            
            if ([[UICenter sharedObject] getCurrentNavigation] != [(UIViewController *)next navigationController]) {
                return;
            }
            
            if ([[UICenter sharedObject] getCurrentViewController] == next) {
                [self autoRefresh];
                return;
            }
            
        }
    }
}

- (void)onTabbarChangeNotification:(NSNotification *)notification {
    if (_tableView.contentOffset.y < 0) {
        [_tableView setContentOffset:CGPointMake(0, 0) animated:NO];
        [self willRefresh];
    }
}

#pragma mark - Getter & Setter
- (void)setFrame:(CGRect)frame {
    [self setTranslatesAutoresizingMaskIntoConstraints:YES];
    [super setFrame:frame];
    _tableView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    _noContentView.frame = _tableView.frame;
}

- (void)setTableHeaderView:(UIView *)tableHeaderView {
    _tableHeaderView = tableHeaderView;
    _tableView.tableHeaderView = tableHeaderView;
}

- (void)setTableFooterView:(UIView *)tableFooterView {
    _tableFooterView = tableFooterView;
    _tableView.tableFooterView = tableFooterView;
}

- (void)setConstrain:(UIEdgeInsets)constrain {
    _constrain = constrain;
    [self setConstrain:constrain withSubView:self andParentView:self.superview];
}

- (void)setEnableNetDisConnect:(BOOL)closeNetWorkTips {
    _enableNetDisConnect = closeNetWorkTips;
    [_netDisconnectView removeFromSuperview];
    _netDisconnectView = nil;
    
    if (_enableNetDisConnect) {
        _netDisconnectView = [NetDisconnectView addNetDisConnectViewIn:self delegate:self];
    }
}

- (void)setNoContentView:(UIView *)noContentView {
    _noContentView = noContentView;
    _noContentView.frame = _tableView.bounds;
}

#pragma mark - RequestTimer method
- (void)startTimer
{
    [self stopTimer];
    _refreshFailed = NO;
    _requestTimer = [NSTimer timerWithTimeInterval:TimerWaitingDuration
                                            target:self selector:@selector(requestTimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_requestTimer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer
{
    if (_requestTimer) {
        [_requestTimer invalidate];
        _requestTimer = nil;
    }
}

- (void)requestTimeout
{
    if (_refreshingState == Refreshing) {
        _refreshFailed = YES;
    }
    _refreshingState = RefreshFailed;
}

#pragma mark - Refresh Method
- (void)willRefresh{
    if (_refreshingState == WillRefresh) {
        return;
    }
    _refreshingState = WillRefresh;
    _isGetRefreshData = NO;
    
    [self stopTimer];
    
    RefreshHeader_WillRefresh
}

- (void)canRefresh{
    if (_refreshingState == CanRefresh) {
        return;
    }
    _refreshingState = CanRefresh;
    
    RefreshHeader_CanRefresh
}

- (void)refreshing{
    _refreshingState = Refreshing;
    _showNoContentView = NO;
    
    RefreshHeader_Refreshing
    RefreshHeader_DoRefreshAnimation
    
    [self startTimer];
    
    if (_refreshDelegate) {
        
        ATWeakSelf
        [_refreshDelegate refreshData:^(BOOL success) {
            
            ATStrongSelfWithEnsureWeakSelf
            if (strongSelf.netDisconnectBlock) {
                strongSelf.netDisconnectBlock();
                strongSelf.netDisconnectBlock = nil;
            }
            
            strongSelf.isGetRefreshData = success;
        }];
    }
}

- (void)refreshFailed {
    _refreshingState = RefreshFailed;
    [self stopTimer];
    RefreshHeader_RefreshFailed
}

- (void)refreshSucceed {
    _refreshingState = RefreshSucceed;
    [self stopTimer];
    RefreshHeader_RefreshSuccess
    
    if (_autoRefresh) {
        
        Delay(0.5, ^{
            [self willRefresh];
            [_tableView setContentOffset:CGPointMake(0, 0) animated:YES];
        })
    }
}


#pragma mark - AutoRefresh
- (void)autoRefresh {
    if (!_canRefresh) {
        return;
    }

    if (_tableView.contentOffset.y == -AutoRefreshHeaderHeight) {
        return;
    }
    
    [self willRefresh];
    [self canRefresh];
    [_tableView setContentOffset:CGPointMake(0, -AutoRefreshHeaderHeight) animated:YES];
}

- (void)shouldRefreshData {
    [self autoRefresh];
}

#pragma mark - NetDisconnectView Delegate 
- (void)retryConnect:(NetDisconnectView*)disconnectView withCompleted:(RetryResultBlock)block{
    self.netDisconnectBlock = block;
    [self autoRefresh];
}

#pragma mark - Scroll Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([_pullToRefreshDelegate respondsToSelector:@selector(pullToRefresh:scrollViewDidScroll:)]) {
        [_pullToRefreshDelegate pullToRefresh:self scrollViewDidScroll:scrollView];
    }
    
    if (!_canRefresh) {
        return;
    }
    
    if(-scrollView.contentOffset.y <= RefreshHeaderHeight){
        if ( scrollView.dragging) {
            [self willRefresh];
            
        }else{
            switch (_refreshingState) {
                case Refreshing:
                    scrollView.contentOffset = CGPointMake(0, -RefreshHeaderHeight);
                    break;
                
                case RefreshSucceed:
                case RefreshFailed:
                {
                    scrollView.contentOffset = CGPointMake(0, -RefreshHeaderHeight);
                    Delay(0.5, ^{
                        [self willRefresh];
                    })
                    break;
                }
                default:
                    break;
            }
        }
    }
    
    if (-scrollView.contentOffset.y > RefreshHeaderHeight) {
        if (scrollView.dragging) {
            [self canRefresh];
            if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(cancelRefresh)]) {
                [_refreshDelegate cancelRefresh];
            }
            
        }
        else if(!scrollView.dragging && _refreshingState == CanRefresh){
            [self refreshing];
        }
    }
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {

    _autoRefresh = scrollView.contentOffset.y == -AutoRefreshHeaderHeight;
}

#pragma mark - Animation Delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    if (RefreshHeader_AnimationCheck) {
        if (_refreshingState == WillRefresh){
            return;
        }
        
        if ([NetworkInfo sharedObject].networkState == NetworkStateNotReachable) {
            [self refreshFailed];
            return;
        }
        
        if (_isGetRefreshData) {
            [self refreshSucceed];
            [self reloadData];
            return;
        }
        
        if(_refreshFailed){
            [self refreshFailed];
            return;
        }
        
        RefreshHeader_DoRefreshAnimation
    }
}

#pragma mark - TableView Delegate && Method
- (void)reloadData {
    _notFirstSystemReload = YES;
    _allDataCount = 0;
    [_tableView reloadData];
}

- (void)reloadDataWithCounts:(NSInteger)newDataCount {
    _newDataCount = newDataCount;
    _showNoContentView = NO;
    _isGetLoadMoreData = YES;
    [self reloadData];
}

#pragma mark TableView Action
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_canLoadMore && indexPath.section == _sectionCount) {
        return;
    }
    
    if (_pullToRefreshDelegate && [_pullToRefreshDelegate respondsToSelector:@selector(pullToRefresh:didSelectRowAtIndexPath:)]) {
        [_pullToRefreshDelegate pullToRefresh:tableView didSelectRowAtIndexPath:indexPath];
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_pullToRefreshDelegate && [_pullToRefreshDelegate respondsToSelector:@selector(pullToRefresh:canEditRowAtIndexPath:)]) {
        return [_pullToRefreshDelegate pullToRefresh:tableView canEditRowAtIndexPath:indexPath];
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_pullToRefreshDelegate && [_pullToRefreshDelegate respondsToSelector:@selector(pullToRefresh:commitEditingStyle:forRowAtIndexPath:)]) {
        [_pullToRefreshDelegate pullToRefresh:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
    
}

#pragma mark Section & Row Numbers
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!_notFirstSystemReload && _canLoadMore) {
        return 0;
    }
    
    if (_showNoContentView) {
        return 1;
    }
    
    if ( _pullToRefreshDelegate != nil && [_pullToRefreshDelegate respondsToSelector:@selector(numberOfSectionsInPullToRefresh:)])
    {
        _sectionCount = [_pullToRefreshDelegate numberOfSectionsInPullToRefresh:tableView];
    }
    
    return _canLoadMore ? _sectionCount + 1 : _sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (_showNoContentView) {
        return 0;
    }
    
    if (_pullToRefreshDelegate != nil) {
        if (_canLoadMore && section == _sectionCount) {
            return 1;
        } else {
            NSInteger dataCount = [_pullToRefreshDelegate pullToRefresh:tableView numberOfRowsInSection:section];
            
            _allDataCount += dataCount;
            if (section == _sectionCount - 1 && _notFirstSystemReload) {
                [self checkIfNoContent:_allDataCount];
                _allDataCount = 0;
            }
            
            return dataCount;
        }
    }
    
    return 0;
}

#pragma mark Views
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (_showNoContentView) {
        return _noContentView;
    }
    
    if (_pullToRefreshDelegate != nil && [_pullToRefreshDelegate respondsToSelector:@selector(pullToRefresh:viewForHeaderInSection:)])
    {
        if (_canLoadMore && section == _sectionCount) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
            view.backgroundColor = DefaultBgColor;
            return view;
        } else {
            return [_pullToRefreshDelegate pullToRefresh:tableView viewForHeaderInSection:section];
        }
    }
    
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (_showNoContentView) {
        return nil;
    }
    
    if (_pullToRefreshDelegate && [_pullToRefreshDelegate respondsToSelector:@selector(pullToRefresh:viewForFooterInSection:)]) {
        return [_pullToRefreshDelegate pullToRefresh:tableView viewForFooterInSection:section];
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_showNoContentView || _pullToRefreshDelegate == nil) {
        return nil;
    }
    
    if (_canLoadMore && indexPath.section == _sectionCount && indexPath.row == 0) {
        
        LoadMoreCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"LoadMoreCell" owner:nil options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if ([NetworkInfo sharedObject].networkState == NetworkStateNotReachable) {
            [cell setLoadMoreType:NetworkNotReachable];
            return cell;
        }
        
        if (_newDataCount > 0) {
            
            [cell setLoadMoreType:LoadMoreData];
            
            if (_isGetLoadMoreData) {
                _isGetLoadMoreData = NO;
                
                ATWeakSelf
                Delay(0.5, ^{
                    [_loadMoreDelegate loadMoreData:^(BOOL success) {
                        ATStrongSelfWithEnsureWeakSelf
                        strongSelf.isGetLoadMoreData = success;
                        
                    }];
                })
                
            }
  
        } else {
            [cell setLoadMoreType:NoMoreData];
        }
        
        return cell;
        
    } else {
        return [_pullToRefreshDelegate pullToRefresh:tableView cellForRowAtIndexPath:indexPath];
    }
    
    
}

#pragma mark Heights
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_showNoContentView) {
        return CantSeeHeaderFooterHeight;
    }
    
    if (_pullToRefreshDelegate != nil && [_pullToRefreshDelegate respondsToSelector:@selector(pullToRefresh:heightForRowAtIndexPath:)])
    {
        if (_canLoadMore && indexPath.section == _sectionCount) {
            return LoadMoreCellHeight;
        } else {
            return [_pullToRefreshDelegate pullToRefresh:tableView heightForRowAtIndexPath:indexPath];
        }
    }
    
    return DefaultCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (_showNoContentView) {
        return _noContentView.bounds.size.height;
    }
    
    if (_canLoadMore && section == _sectionCount) {
        return CantSeeHeaderFooterHeight;
    }
    if (_pullToRefreshDelegate && [_pullToRefreshDelegate respondsToSelector:@selector(pullToRefresh:heightForHeaderInSection:)]) {
        return [_pullToRefreshDelegate pullToRefresh:tableView heightForHeaderInSection:section];
    }
    return CantSeeHeaderFooterHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (_showNoContentView) {
        return CantSeeHeaderFooterHeight;
    }
    
    if (_canLoadMore && section == _sectionCount) {
        return CantSeeHeaderFooterHeight;
    }
    if (_pullToRefreshDelegate && [_pullToRefreshDelegate respondsToSelector:@selector(pullToRefresh:heightForFooterInSection:)]) {
        return [_pullToRefreshDelegate pullToRefresh:tableView heightForFooterInSection:section];
    }
    return CantSeeHeaderFooterHeight;
}

@end



@implementation PullToRefreshView (Addition)

#pragma mark -
- (void)setTag:(NSInteger)tag {
    [super setTag:tag];
    [_tableView setTag:tag];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    _tableView.backgroundColor = backgroundColor;
}

#pragma mark ScrollToTop
- (void)setScrollsToTop:(BOOL)scrollsToTop {
    _tableView.scrollsToTop = scrollsToTop;
}

- (BOOL)scrollsToTop {
    return _tableView.scrollsToTop;
}

#pragma mark ScrollEnabled
- (void)setScrollEnabled:(BOOL)scrollEnabled {
    _tableView.scrollEnabled = scrollEnabled;
}

- (BOOL)scrollEnabled {
    return _tableView.scrollEnabled;
}

#pragma mark AllowsSelection
- (void)setAllowsSelection:(BOOL)allowsSelection {
    _tableView.allowsSelection = allowsSelection;
}

- (BOOL)allowsSelection {
    return _tableView.allowsSelection;
}

#pragma mark TableView Public
- (void)beginUpdates {
    [_tableView beginUpdates];
}

- (void)endUpdates {
    [_tableView endUpdates];
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    [_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated
{
    [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
}

@end

