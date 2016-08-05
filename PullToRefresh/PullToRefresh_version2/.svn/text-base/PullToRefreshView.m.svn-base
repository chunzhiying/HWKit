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
#import "MessageBox.h"
#import "NetDisconnectView.h"

NSString * const onTabbarChangeNotification = @"onTabbarChangeNotification";

static NSInteger const timerWaitingDuration = 10; 

static NSInteger const refreshHeaderHeight = 50;
static NSInteger const autoRefreshHeaderHeight = refreshHeaderHeight + 1;

static NSInteger const loadMoreCellHeight = 50;
static NSInteger const loadMoreHeaderColor = 0xf5f9fcff;

static CGFloat const cantSeeHeaderFooterHeight = 0.01;

static NSInteger const defalutSectionCount = 1;

static NSInteger const defaultCellHeight = loadMoreCellHeight;

typedef NS_ENUM(NSInteger, RefreshingState) {
    Refreshing,
    CanRefresh,
    WillRefresh,
    RefreshSucceed,
    RefreshFailed
};


@interface PullToRefreshView() <UITableViewDelegate, UITableViewDataSource, NetDisconnectViewDelegate> {
    
    UITableView* _tableView;
    NSInteger _tableViewTopDistance;
    
    NetDisconnectView *_netDisconnectView;
    NSInteger _allDataCount;
    
    UIView *_headRefreshView;
    UILabel *_tipsLabel;
    CAShapeLayer* _shapeLayer;
    
    UIImageView* _refreshArrow;
    UIImageView* _refreshKLine;
    UIImageView* _refreshKLineRed;
    
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
        _tableView = [[UITableView alloc] initWithFrame:frame style:style];
        [self initTableView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame style:UITableViewStylePlain];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setRefresh:(BOOL)refresh andLoadMore:(BOOL)loadMore andRefreshTopDistance:(NSInteger)distance{
    
    _canRefresh = refresh;
    _canLoadMore = loadMore;
    _tableViewTopDistance = distance;
    
    _sectionCount = defalutSectionCount;
    
    [self initRefreshUI];
    [self initNotification];
}

- (void)initTableView {
    _tableView.backgroundColor = [ColorUtil colorWithRGBA:loadMoreHeaderColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self addSubview:_tableView];
}

- (void)initRefreshUI{
    
    _tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2-20, 0, self.frame.size.width/2-20, refreshHeaderHeight)];
    _tipsLabel.font = [UIFont systemFontOfSize:13.0f];
    _tipsLabel.textColor = [ColorUtil colorWithRGBA:0xa5a5a5ff];
    
    _refreshKLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refresh_kLine"]];
    _refreshKLine.frame = CGRectMake(_tipsLabel.frame.origin.x-35, (refreshHeaderHeight-10)/2, 23, 10);
   
    _refreshKLineRed = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refresh_kLine_red"]];
    _refreshKLineRed.frame = _refreshKLine.frame;
    
    _refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refresh_arrow"]];
    _refreshArrow.frame = CGRectMake(_tipsLabel.frame.origin.x-30, (refreshHeaderHeight-22)/2, 22, 22);
    
    UIBezierPath* path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(_refreshKLine.frame.origin.x, _tableViewTopDistance+refreshHeaderHeight/2+5)];
    [path addLineToPoint:CGPointMake(_refreshKLine.frame.origin.x+7, _tableViewTopDistance+refreshHeaderHeight/2-2)];
    [path addLineToPoint:CGPointMake(_refreshKLine.frame.origin.x+14, _tableViewTopDistance+refreshHeaderHeight/2+3)];
    [path addLineToPoint:CGPointMake(_refreshKLine.frame.origin.x+_refreshKLine.frame.size.width-1.5, _tableViewTopDistance+refreshHeaderHeight/2-4)];
    
    _shapeLayer = [CAShapeLayer layer];
    _shapeLayer.path = path.CGPath;
    _shapeLayer.fillColor = [UIColor clearColor].CGColor;
    _shapeLayer.strokeColor = [UIColor redColor].CGColor;
    _shapeLayer.strokeEnd = 0;
    
    _headRefreshView = [[UIView alloc] initWithFrame:CGRectMake(0, -refreshHeaderHeight, self.frame.size.width,refreshHeaderHeight)];
    _headRefreshView.backgroundColor = [ColorUtil colorWithRGBA:loadMoreHeaderColor];
    
    [_headRefreshView addSubview:_tipsLabel];
    [_headRefreshView addSubview:_refreshKLine];
    [_headRefreshView addSubview:_refreshKLineRed];
    [_headRefreshView addSubview:_refreshArrow];
    [_headRefreshView.layer addSublayer:_shapeLayer];
    
    [self willRefresh];
    
    if (_canRefresh) {
        [_tableView addSubview:_headRefreshView];
    }
    
    _netDisconnectView = [NetDisconnectView addNetDisConnectViewIn:self delegate:self];
    
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
    [self autoRefresh];
}

- (void)onTabbarChangeNotification:(NSNotification *)notification {
    [_tableView setContentOffset:CGPointMake(0, 0) animated:NO];
    [self willRefresh];
}

#pragma mark - Getter & Setter
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    _tableView.backgroundColor = backgroundColor;
}

- (void)setFrame:(CGRect)frame {
    [self setTranslatesAutoresizingMaskIntoConstraints:YES];
    [super setFrame:frame];
    _tableView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    _noContentView.frame = _tableView.frame;
}

- (void)setTag:(NSInteger)tag {
    [super setTag:tag];
    [_tableView setTag:tag];
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
    _noContentView.frame = self.bounds;
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

#pragma mark - RequestTimer method
- (void)startTimer
{
    [self stopTimer];
    _refreshFailed = NO;
    _requestTimer = [NSTimer timerWithTimeInterval:timerWaitingDuration
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
    if (self.refreshingState == Refreshing) {
        _refreshFailed = YES;
    }
    self.refreshingState = RefreshFailed;
}

#pragma mark - Refresh Method
- (void)willRefresh{
    if (self.refreshingState == WillRefresh) {
        return;
    }
    _isGetRefreshData = NO;
    self.refreshingState = WillRefresh;
    _refreshArrow.hidden = NO;
    _refreshKLine.hidden = YES;
    _refreshKLineRed.hidden = YES;
    
    _shapeLayer.strokeEnd = 0;
    _tipsLabel.text = @"下拉刷新..";
    
    [self stopTimer];
    [_shapeLayer removeAllAnimations];
}

- (void)canRefresh{
    if (self.refreshingState == CanRefresh) {
        return;
    }
    self.refreshingState = CanRefresh;
    _tipsLabel.text = @"松开立即刷新";
}

- (void)refreshing{
    self.refreshingState = Refreshing;
    _tipsLabel.text = @"正在刷新..";
    _refreshArrow.hidden = YES;
    _refreshKLine.hidden = NO;
    _refreshKLineRed.hidden = YES;
    
    _showNoContentView = NO;
    
    [self startRefreshAnimation];
    [self startTimer];
    
    if (_refreshDelegate) {
        __weak __typeof(self) weakSelf = self;
        [_refreshDelegate refreshData:^(BOOL success) {
            
            if (!weakSelf) { return; }
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            
            if (strongSelf.netDisconnectBlock) {
                strongSelf.netDisconnectBlock();
                strongSelf.netDisconnectBlock = nil;
            }
            
            strongSelf.isGetRefreshData = success;
        }];
    }
}

- (void)refreshFailed{
     self.refreshingState = RefreshFailed;
    _tipsLabel.text = @"刷新失败";
    _refreshKLineRed.hidden = YES;
    _refreshKLine.hidden = NO;
    _shapeLayer.strokeEnd = 0;
    
    [self stopTimer];
    [_shapeLayer removeAllAnimations];
}

- (void)refreshSucceed{
     self.refreshingState = RefreshSucceed;
    _tipsLabel.text = @"刷新成功";
    _refreshKLineRed.hidden = NO;
    _refreshKLine.hidden = YES;
    _shapeLayer.strokeEnd = 1;
    
    [self stopTimer];
    [_shapeLayer removeAllAnimations];
    
    
    if (_autoRefresh) {
        
        __weak __typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!weakSelf) { return; }
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            
            [strongSelf willRefresh];
            [strongSelf->_tableView setContentOffset:CGPointMake(0, 0) animated:YES];
        });
    }
}

- (void)startRefreshAnimation{
    CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    ani.fromValue = @(0);
    ani.toValue = @(1.0f);
    ani.duration = 1.f;
    ani.delegate = self;
    [ani setValue:@"flash" forKey:@"animationFlag"];
    [_shapeLayer addAnimation:ani forKey:nil];
}

#pragma mark - AutoRefresh
- (void)autoRefresh {
    if (!_canRefresh) {
        return;
    }

    if (_tableView.contentOffset.y == -autoRefreshHeaderHeight) {
        return;
    }
    
    [self willRefresh];
    [self canRefresh];
    [_tableView setContentOffset:CGPointMake(0, -autoRefreshHeaderHeight) animated:YES];
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
    if (!_canRefresh) {
        return;
    }
    
    if(-scrollView.contentOffset.y <= refreshHeaderHeight){
        if ( scrollView.dragging) {
            [self willRefresh];
            
        }else{
            switch (self.refreshingState) {
                case Refreshing:
                    scrollView.contentOffset = CGPointMake(0, -refreshHeaderHeight);
                    break;
                
                case RefreshSucceed:
                case RefreshFailed:
                {
                    scrollView.contentOffset = CGPointMake(0, -refreshHeaderHeight);
                    
                    __weak __typeof(self)weakSelf = self;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if (!weakSelf) { return; }
                        __strong __typeof(weakSelf) strongSelf = weakSelf;
                        
                        [strongSelf willRefresh];
                    });
                    break;
                }
                default:
                    break;
            }
        }
    }
    
    if (-scrollView.contentOffset.y > refreshHeaderHeight) {
        if (scrollView.dragging) {
            [self canRefresh];
            if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(cancelRefresh)]) {
                [_refreshDelegate cancelRefresh];
            }
            
        }
        else if(!scrollView.dragging && self.refreshingState == CanRefresh){
            [self refreshing];
        }
    }
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {

    _autoRefresh = scrollView.contentOffset.y == -autoRefreshHeaderHeight;
}

#pragma mark - Animation Delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if ([[anim valueForKey:@"animationFlag"] isEqualToString:@"flash"]) {
        if (self.refreshingState == WillRefresh){
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
        
        [self startRefreshAnimation];
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
            view.backgroundColor = [ColorUtil colorWithRGBA:loadMoreHeaderColor];
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
                
                __weak __typeof(self) weakSelf = self;
                [_loadMoreDelegate loadMoreData:^(BOOL success) {
                    
                    if (!weakSelf) { return; }
                    __strong __typeof(weakSelf) strongSelf = weakSelf;
                    
                    if (success) {
                        strongSelf.isGetLoadMoreData = YES;
                    }
                }];
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
        return cantSeeHeaderFooterHeight;
    }
    
    if (_pullToRefreshDelegate != nil && [_pullToRefreshDelegate respondsToSelector:@selector(pullToRefresh:heightForRowAtIndexPath:)])
    {
        if (_canLoadMore && indexPath.section == _sectionCount) {
            return loadMoreCellHeight;
        } else {
            return [_pullToRefreshDelegate pullToRefresh:tableView heightForRowAtIndexPath:indexPath];
        }
    }
    
    return defaultCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (_showNoContentView) {
        return _noContentView.bounds.size.height;
    }
    
    if (_canLoadMore && section == _sectionCount) {
        return cantSeeHeaderFooterHeight;
    }
    if (_pullToRefreshDelegate && [_pullToRefreshDelegate respondsToSelector:@selector(pullToRefresh:heightForHeaderInSection:)]) {
        return [_pullToRefreshDelegate pullToRefresh:tableView heightForHeaderInSection:section];
    }
    return cantSeeHeaderFooterHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (_showNoContentView) {
        return cantSeeHeaderFooterHeight;
    }
    
    if (_canLoadMore && section == _sectionCount) {
        return cantSeeHeaderFooterHeight;
    }
    if (_pullToRefreshDelegate && [_pullToRefreshDelegate respondsToSelector:@selector(pullToRefresh:heightForFooterInSection:)]) {
        return [_pullToRefreshDelegate pullToRefresh:tableView heightForFooterInSection:section];
    }
    return cantSeeHeaderFooterHeight;
}

@end
