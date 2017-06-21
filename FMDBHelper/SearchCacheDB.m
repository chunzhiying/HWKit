//
//  SearchCacheDB.m
//  yyfe
//
//  Created by 陈智颖 on 2016/10/13.
//  Copyright © 2016年 yy.com. All rights reserved.
//

#import "SearchCacheDB.h"
#import "ATAppUtils.h"
#import "ATGlobalMacro.h"
#import "SearchFromInternetModel.h"
#import "HWFunctionalType.h"
#import "FMDatabaseModel.h"

const static int schmeaVersionHistory[] = {1};
#define LATEST_VERSION (schmeaVersionHistory[sizeof(schmeaVersionHistory) / sizeof(schmeaVersionHistory[0]) - 1])

@interface SearchCacheDB ()
{
    FMDatabaseAsyncQueue *_fmdbQueue;
}
@end

@implementation SearchCacheDB

- (instancetype)init
{
    self = [super init];
    if (self) {
        _fmdbQueue = [FMDatabaseModel getQueueByName:@"SearchCacheDB"
                                       latestVersion:LATEST_VERSION
                                      updateCallback:^(FMDatabase *db, int oldVersion) {
                                          return [self upgradeToVersion:db];
                                      }];
    }
    return self;
}

- (BOOL)upgradeToVersion:(FMDatabase *)db
{
    NSString *channel = @"CREATE TABLE IF NOT EXISTS t_channels (id integer PRIMARY KEY,\
    shortId text,\
    SSid text,\
    name text,\
    url text,\
    type integer)";
    
    NSString *teacher = @"CREATE TABLE IF NOT EXISTS t_teachers (id integer PRIMARY KEY,\
    yunyingName text,\
    yyNickName text, \
    YyNum text,\
    uid text,\
    url text,\
    portaitId integer,\
    type integer)";

    return ([db executeUpdate:channel] && [db executeUpdate:teacher]);
}

- (void)removeAll
{
    [_fmdbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        BOOL channelResult = NO;
        BOOL teacherReesult = NO;
        channelResult = [db executeUpdate:@"delete from t_channels"];
        teacherReesult = [db executeUpdate:@"delete from t_teachers"];
        *rollback = !channelResult || !teacherReesult;
    }];
}


#pragma mark - Channel
- (void)saveChannels:(NSArray<SearchChannelData *> *)datas;
{
    [_fmdbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        BOOL result = NO;
        int count = 0;
        for (SearchChannelData *data in datas) {
            result = [db executeUpdate:@"insert or replace into \
                      t_channels (shortId, SSid, name, url, type) \
                      values (?, ?, ?, ?, ?);",
                      data.shortId, data.SSid, data.name, data.url, @(data.type)];
            count++;
            if (!result) {
                *rollback = !result;
                break;
            }
        }
        NSLog(@"搜索DB数据: 插入频道完共%@", @(count));
    }];
}

- (HWPromise *)queryChannelCount {
    __block HWPromise *promise = [HWPromise new];
    [_fmdbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSInteger count = [db intForQuery:@"select count(*) from t_channels"];
        promise.successObj = @(count);
    }];
    return promise;
}

- (NSArray<SearchChannelData *> *)queryAllChannel
{
    NSMutableArray *channels = [NSMutableArray new];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [_fmdbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = @"SELECT * FROM t_channels;";
        FMResultSet *result = [db executeQuery:sql];
        while ([result next]) {
            [channels addObject:[SearchChannelData new].then(^(SearchChannelData *channel) {
                channel.shortId = [result safeObjectForColumnName:@"shortId"];
                channel.SSid = [result safeObjectForColumnName:@"SSid"];
                channel.name = [result safeObjectForColumnName:@"name"];
                channel.url = [result safeObjectForColumnName:@"url"];
                channel.type = [[result safeObjectForColumnName:@"type"] integerValue];
            })];
        }
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return channels;
}

#pragma mark - Teacher
- (void)saveTeachers:(NSArray<SearchTeacherData *> *)datas;
{
    [_fmdbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        BOOL result = NO;
        int count = 0;
        for (SearchTeacherData *data in datas) {
            result = [db executeUpdate:@"insert or replace into \
                      t_teachers (yunyingName, yyNickName, YyNum, uid, url, portaitId, type)\
                      values (?, ?, ?, ?, ?, ?, ?);",
                      data.yunyingName, data.yyNickName, data.YyNum, data.uid, data.url, @(data.portaitId), @(data.type)];
            count++;
            if (!result) {
                *rollback = !result;
                break;
            }
        }
        NSLog(@"搜索DB数据: 插入老师完成共%@", @(count));
    }];
}

- (HWPromise *)queryTeacherCount {
    __block HWPromise *promise = [HWPromise new];
    [_fmdbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSUInteger count = [db intForQuery:@"select count(*) from t_teachers"];
        promise.successObj = @(count);
    }];
    return promise;
}

- (NSArray<SearchTeacherData *> *)queryAllTeacher
{
    NSMutableArray *teachers = [NSMutableArray new];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [_fmdbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = @"SELECT * FROM t_teachers;";
        FMResultSet *result = [db executeQuery:sql];
        while ([result next]) {
            [teachers addObject:[SearchTeacherData new].then(^(SearchTeacherData *teacher) {
                teacher.yunyingName = [result safeObjectForColumnName:@"yunyingName"];
                teacher.yyNickName = [result safeObjectForColumnName:@"yyNickName"];
                teacher.YyNum = [result safeObjectForColumnName:@"YyNum"];
                teacher.uid = [result safeObjectForColumnName:@"uid"];
                teacher.url = [result safeObjectForColumnName:@"url"];
                teacher.portaitId = [[result safeObjectForColumnName:@"portaitId"] integerValue];
                teacher.type = [[result safeObjectForColumnName:@"type"] integerValue];
            })];
        }
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return teachers;
}

@end

