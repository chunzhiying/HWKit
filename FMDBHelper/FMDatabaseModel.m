//
//  FMDatabaseModel.m
//  yyfe
//
//  Created by 陈智颖 on 2017/1/12.
//  Copyright © 2017年 yy.com. All rights reserved.
//

#import "FMDatabaseModel.h"
#import "ATAppUtils.h"
#import "ATGlobalMacro.h"

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

@implementation FMDatabaseModel

+ (FMDatabaseAsyncQueue *)getQueueByName:(NSString *)dbName
                           latestVersion:(int)latestVersion
                          updateCallback:(UpdateCallback)callback
{
    NSString *path = [NSString stringWithFormat:@"%@/%@.db",[ATAppUtils appDocumentPath], dbName];
    FMDatabaseAsyncQueue *fmdbQueue = [FMDatabaseAsyncQueue databaseQueueWithPath:path];
    [fmdbQueue syncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        do {
            *rollback = NO;
            FMResultSet *resultSet = [db executeQuery:@"pragma user_version"];
            if (![resultSet next]) {
                ATLogError(([NSString stringWithFormat:@"%@_DBTag", dbName]),
                           @"%@", @"Faile to qurey the public db storage version");
                break;
            }
            int currentVersion = [resultSet intForColumnIndex:0];
            [resultSet close];
            
            BOOL result;
            if (currentVersion >= latestVersion) {
                break;
            }
            else {
                result = callback(db, currentVersion);
                if (!result) {
                     ATLogError(([NSString stringWithFormat:@"%@_DBTag", dbName]),
                                @"Failed to upgrade the public db storage to version %d", latestVersion);
                    *rollback = YES;
                    break;
                }
            }
            
            NSString *sql = [NSString stringWithFormat:@"pragma user_version = %d", latestVersion];
            if(![db executeUpdate:sql]) {
                ATLogError(([NSString stringWithFormat:@"%@_DBTag", dbName]),
                           @"Failed to update the public db storage version to %d, error:%@", latestVersion,
                           [db lastError]);
                *rollback = YES;
                break;
            }
            
        } while (NO);
    }];
    
    return fmdbQueue;
}

@end
