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

static NSInteger const refreshHeaderHeight = 50;
static NSInteger const loadMoreCellHeight = 50;
static NSInteger const loadMoreHeaderColor = 0xf5f9fcff;

static NSInteger const defalutSectionCount = 1;

typedef NS_ENUM(NSInteger, RefreshingState){
    Refreshing,
    CanRefresh,
    WillRefresh,
    RefreshSucceed,
    RefreshFailed
};


@interface PullToRefreshView() <UITableViewDelegate, UITableViewDataSource> {
    
    UITableView* _tableView;
    NSInteger _tableViewTopDistance;
    
//    NetDisconnectView *_netDisconnectView;
//    NSInteger _allDataCount;
    
    UIView *_headRefreshView;
    UILabel *_tipsLabel;
    CAShapeLayer* _shapeLayer;
    
    UIImageView* _refreshArrow;
    UIImageView* _refreshKLine;
    UIImageView* _refreshKLineRed;
    
    NSTimer * _requestTimer;
    
    BOOL _canRefresh;
    BOOL _canLoadMore;
    BOOL _refreshFailed;
}
@property (nonatomic) BOOL isGetRefreshData;
@property (nonatomic) BOOL isGetLoadMoreData;

@property (nonatomic) RefreshingState refreshingState;
@property (nonatomic) NSInteger newDataCount;
@property (nonatomic) NSInteger sectionCount;

@end

@implementation PullToRefreshView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame];
    if (self) {
        _tableView = [[UITableView alloc] initWithFrame:frame style:style];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame style:UITableViewStylePlain];
}


- (void)setRefresh:(BOOL)refresh andLoadMore:(BOOL)loadMore andRefreshTopDistance:(NSInteger)distance{
    
    _canRefresh = refresh;
    _canLoadMore = loadMore;
    _tableViewTopDistance = distance;
    
    _sectionCount = defalutSectionCount;
    
    [self initRefreshUI];
}


- (void)initRefreshUI{
    
    self.refreshingState = WillRefresh;
    
    _tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds)/2-20, 0, CGRectGetWidth([UIScreen mainScreen].bounds)/2-20, refreshHeaderHeight)];
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
    
    _headRefreshView = [[UIView alloc] initWithFrame:CGRectMake(0, -refreshHeaderHeight, CGRectGetWidth([UIScreen mainScreen].bounds),refreshHeaderHeight)];
    _headRefreshView.backgroundColor = [ColorUtil colorWithRGBA:loadMoreHeaderColor];
    
    [_headRefreshView addSubview:_tipsLabel];
    [_headRefreshView addSubview:_refreshKLine];
    [_headRefreshView addSubview:_refreshKLineRed];
    [_headRefreshView addSubview:_refreshArrow];
    [_headRefreshView.layer addSublayer:_shapeLayer];
    
    _tableView.backgroundColor = [ColorUtil colorWithRGBA:loadMoreHeaderColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self addSubview:_tableView];
    
    if (_canRefresh) {
        [_tableView addSubview:_headRefreshView];
    }
    
//    _netDisconnectView = [NetDisconnectView addNetDisConnectViewIn:self delegate:self];
}

#pragma mark - Getter & Setter
- (void)setScrollsToTop:(BOOL)scrollsToTop {
    _tableView.scrollsToTop = scrollsToTop;
}

- (BOOL)scrollsToTop {
    return _tableView.scrollsToTop;
}

- (void)setTableHeaderView:(UIView *)tableHeaderView {
    _tableHeaderView = tableHeaderView;
    _tableView.tableHeaderView = tableHeaderView;
    [self reloadData];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _tableView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

#pragma mark - RequestTimer method
- (void)startTimer
{
    _refreshFailed = NO;
    _requestTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(requestTimeout) userInfo:nil repeats:NO];
}

- (void)stopTimer
{
    if (_requestTimer && [_requestTimer isValid])
        [_requestTimer invalidate];
    _requestTimer = nil;
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
    _isGetRefreshData = NO;
    self.refreshingState = WillRefresh;
    _refreshArrow.hidden = NO;
    _refreshKLine.hidden = YES;
    _refreshKLineRed.hidden = YES;
    
    _shapeLayer.strokeEnd = 0;
    _tipsLabel.text = @"下拉刷新..";
    [_shapeLayer removeAllAnimations];
}

- (void)canRefresh{
    self.refreshingState = CanRefresh;
    _tipsLabel.text = @"松开立即刷新";
}

- (void)refreshing{
    self.refreshingState = Refreshing;
    _tipsLabel.text = @"正在刷新..";
    _refreshArrow.hidden = YES;
    _refreshKLine.hidden = NO;
    _refreshKLineRed.hidden = YES;
    
    [self startRefreshAnimation];
    [self startTimer];
    
    if (_refreshDelegate) {
        __weak __typeof(self) weakSelf = self;
        [_refreshDelegate refreshData:^(BOOL success){
            weakSelf.isGetRefreshData = success;
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

#pragma mark - Scroll Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!_canRefresh) {
        return;
    }
    
    // Refreshing
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
                        [weakSelf willRefresh];
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

#pragma mark - Animation Delegate
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if ([[anim valueForKey:@"animationFlag"] isEqualToString:@"flash"]) {
        if (self.refreshingState == WillRefresh){
            return;
        }
        
        if ([NetworkInfo sharedObject].networkState == NetworkStateNotReachable) {
            [MessageBox warning:@"网络故障,请检查你的网络!"];
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
    [_tableView reloadData];
}

- (void)reloadDataWithCounts:(NSInteger)newDataCount {
    _newDataCount = newDataCount;
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
    if (!_canLoadMore && _pullToRefreshDelegate != nil && [_pullToRefreshDelegate respondsToSelector:@selector(numberOfSectionsInPullToRefresh:)])
    {
        return [_pullToRefreshDelegate numberOfSectionsInPullToRefresh:tableView];
    }
    
    if (_loadMoreDelegate != nil && [_loadMoreDelegate respondsToSelector:@selector(numberOfSections)]) {
        _sectionCount = [_loadMoreDelegate numberOfSections];
    }
    
    return _canLoadMore ? _sectionCount + 1 : _sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (_pullToRefreshDelegate != nil) {
        if (_canLoadMore && section == _sectionCount) {
            return 1;
        } else {
            return [_pullToRefreshDelegate pullToRefresh:tableView numberOfRowsInSection:section];
        }
    }
    
    return 0;
}

#pragma mark Views
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
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
    if (_pullToRefreshDelegate && [_pullToRefreshDelegate respondsToSelector:@selector(pullToRefresh:viewForFooterInSection:)]) {
        return [_pullToRefreshDelegate pullToRefresh:tableView viewForFooterInSection:section];
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_pullToRefreshDelegate == nil) {
        return nil;
    }
    
    if (_canLoadMore && indexPath.section == _sectionCount && indexPath.row == 0) {
        
        LoadMoreCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"LoadMoreCell" owner:nil options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if ([NetworkInfo sharedObject].networkState == NetworkStateNotReachable) {
            [MessageBox warning:@"网络故障,请检查你的网络!"];
            [cell setLoadMoreType:NetworkNotReachable];
            return cell;
        }
        
        if (_newDataCount > 0) {
            
            [cell setLoadMoreType:LoadMoreData];
            
            if (_isGetLoadMoreData) {
                _isGetLoadMoreData = NO;
                
                __weak __typeof(self) weakSelf = self;
                [_loadMoreDelegate loadMoreData:^(BOOL success) {
                    if (success) {
                        weakSelf.isGetLoadMoreData = YES;
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
    
    if (_pullToRefreshDelegate != nil && [_pullToRefreshDelegate respondsToSelector:@selector(pullToRefresh:heightForRowAtIndexPath:)])
    {
        if (_canLoadMore && indexPath.section == _sectionCount) {
            return loadMoreCellHeight;
        } else {
            return [_pullToRefreshDelegate pullToRefresh:tableView heightForRowAtIndexPath:indexPath];
        }
    }
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_pullToRefreshDelegate && [_pullToRefreshDelegate respondsToSelector:@selector(pullToRefresh:heightForHeaderInSection:)]) {
        return [_pullToRefreshDelegate pullToRefresh:tableView heightForHeaderInSection:section];
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (_pullToRefreshDelegate && [_pullToRefreshDelegate respondsToSelector:@selector(pullToRefresh:heightForFooterInSection:)]) {
        return [_pullToRefreshDelegate pullToRefresh:tableView heightForFooterInSection:section];
    }
    return 1;
}

@end
