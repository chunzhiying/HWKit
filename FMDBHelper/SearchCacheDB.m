//
//  SearchCacheDB.m
//  yyfe
//
//  Created by 陈智颖 on 2016/10/13.
//  Copyright © 2016年 yy.com. All rights reserved.
//

#import "SearchCacheDB.h"
#import "FMDatabaseAsyncQueue.h"
#import "ATAppUtils.h"
#import "ATGlobalMacro.h"
#import "SearchFromInternetModel.h"
#import "FMDatabaseAdditions.h"
#import "HWFunctionalType.h"

const static int schmeaVersionHistory[] = {1};
#define LATEST_VERSION (schmeaVersionHistory[sizeof(schmeaVersionHistory) / sizeof(schmeaVersionHistory[0]) - 1])

@interface FMResultSet (SafeGet)

- (id)safeObjectForColumnName:(NSString *)name;

@end

@implementation FMResultSet (SafeGet)

- (id)safeObjectForColumnName:(NSString *)name {
    NSObject *object = [self objectForColumnName:name];
    if ([object isKindOfClass:[NSNull class]]) {
        return nil;
    } else {
        return object;
    }
}

@end

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
        NSString *path = [NSString stringWithFormat:@"%@/SearchCacheDB.db",[ATAppUtils appDocumentPath]];
        _fmdbQueue = [FMDatabaseAsyncQueue databaseQueueWithPath:path];
        
        [_fmdbQueue syncInTransaction:^(FMDatabase *db, BOOL *rollback) {
            do {
                *rollback = NO;
                FMResultSet *resultSet = [db executeQuery:@"pragma user_version"];
                if (![resultSet next]) {
                    ATLogError(@"SearchCacheDBTag", @"%@",@"Faile to qurey the public db storage version");
                    break;
                }
                int currentVersion = [resultSet intForColumnIndex:0];
                [resultSet close];
                if (currentVersion >= LATEST_VERSION) {
                    break;
                }
                
                *rollback = YES;
                BOOL result = YES;
                
                for(int i = 0; i < (sizeof(schmeaVersionHistory)/sizeof(schmeaVersionHistory[0])); i++ ) {
                    if (currentVersion >= (schmeaVersionHistory[i])){
                        continue;
                    }
                    switch (schmeaVersionHistory[i]) {
                        case 1:
                            result = [self upgradeToVersion:db];
                            break;
                            
                        default:
                            result = NO;
                            break;
                    }
                    if (!result) {
                        ATLogError(@"SearchCacheDBTag", @"Failed to upgrade the public db storage to version %d", schmeaVersionHistory[i]);
                        break;
                    }
                }
                if (!result)
                    break;
                
                NSString *sql = [NSString stringWithFormat:@"pragma user_version = %d", LATEST_VERSION];
                if(![db executeUpdate:sql]) {
                    ATLogError(@"SearchCacheDBTag", @"Failed to update the public db storage version to %d, error:%@", LATEST_VERSION, [db lastError]);
                    break;
                }
                *rollback = NO;
            } while (NO);
        }];

    }
    return self;
}

- (BOOL)upgradeToVersion:(FMDatabase*)db
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
    
    if (![db executeUpdate:channel] || ![db executeUpdate:teacher]) {
        ATLogError(@"SearchCacheDBTag", @"Failed to create table messages, error:%@", [db lastError]);
        return NO;
    }

    return YES;
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

