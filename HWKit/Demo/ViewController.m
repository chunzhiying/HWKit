//
//  ViewController.m
//  Demo
//
//  Created by 陈智颖 on 2017/6/21.
//  Copyright © 2017年 YY. All rights reserved.
//

#import "ViewController.h"
#import "HWHelper.h"
#import "HWPageView.h"
#import "PullToRefreshView.h"

@interface ViewController () <HWPageViewDataSource, PullToRefreshTableViewDelegate, LoadMoreDelegate, RefreshDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    HWPageView *pageView = [[HWPageView alloc] initWithFrame:ATScreenBounds
                                                     setting:[HWPageSetting
                                                              setting:@{HWPageDelegate : self,
                                                                        HWPageNormalColor : [UIColor greenColor],
                                                                        HWPageHighlightColor : [UIColor blueColor]}]];
    [self.view addSubview:pageView];
    
}


- (NSInteger)numberOfPages {
    return 3;
}

- (NSString *)pageView:(HWPageView *)pageView titleAtIndex:(NSInteger)index {
    return [@[@"我们", @"她们", @"他们"] objectAtIndex:index];
}

- (UIView *)  pageView:(HWPageView *)pageView viewAtIndex:(NSInteger)index {
    
    PullToRefreshView *pullToRefresh = [[PullToRefreshView alloc] initWithFrame:ATScreenBounds style:UITableViewStylePlain];
    pullToRefresh.loadMoreDelegate = self;
    pullToRefresh.refreshDelegate = self;
    pullToRefresh.pullToRefreshDelegate = self;
    [pullToRefresh setRefresh:YES andLoadMore:YES andRefreshTopDistance:0];
    [pullToRefresh reloadDataWithCounts:1];
    
    return pullToRefresh;
}

- (NSInteger)pullToRefresh:(UITableView *)pullTableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)pullToRefresh:(UITableView *)pullTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UITableViewCell new];
}

- (void)pullToRefresh:(PullToRefreshView *)pullToRefresh loadMoreData:(LoadMoreDataCallBack)callBack {
    callBack(YES);
}

- (void)pullToRefresh:(PullToRefreshView *)pullToRefresh refreshData:(RefreshDataCallBack)callBack {
    callBack(YES);
}

@end
