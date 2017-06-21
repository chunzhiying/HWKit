//
//  FMDatabaseModel.h
//  yyfe
//
//  Created by 陈智颖 on 2017/1/12.
//  Copyright © 2017年 yy.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "FMDatabaseAsyncQueue.h"
#import "FMDatabaseAdditions.h"

typedef BOOL(^UpdateCallback)(FMDatabase *db, int oldVersion);

@interface FMResultSet (SafeGet)

- (id)safeObjectForColumnName:(NSString *)name;

@end

@interface FMDatabaseModel : NSObject

+ (FMDatabaseAsyncQueue *)getQueueByName:(NSString *)dbName
                           latestVersion:(int)latestVersion
                          updateCallback:(UpdateCallback)callback;

@end
