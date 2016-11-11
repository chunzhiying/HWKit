//
//  FMDatabaseAsyncQueue.m
//  yyfe
//
//  Created by linmeihui on 16/9/8.
//  Copyright © 2016年 yy.com. All rights reserved.
//

#import "FMDatabaseAsyncQueue.h"
#import "FMDatabase.h"
#import "ATGlobalMacro.h"

@implementation FMDatabaseAsyncQueue

+ (id)databaseQueueWithPath:(NSString*)aPath {
    FMDatabaseAsyncQueue *q = [[self alloc] initWithPath:aPath];
    FMDBAutorelease(q);
    return q;
}

- (id)initWithPath:(NSString*)aPath {
    self = [super init];
    if (self != nil) {
        _db = [FMDatabase databaseWithPath:aPath];
        FMDBRetain(_db);
        if (![_db open]) {
            ATLogError(@"FMDatabaseAsyncQueue", @"Could not create database queue for path %@", aPath);
            FMDBRelease(self);
            return 0x00;
        }
        _path = FMDBReturnRetained(aPath);
        _queue = dispatch_queue_create([[NSString stringWithFormat:@"fmdb.%@", self] UTF8String], NULL);
    }
    return self;
}

- (void)dealloc {
    FMDBRelease(_db);
    FMDBRelease(_path);
    
    if (_queue) {
        FMDBDispatchQueueRelease(_queue);
        _queue = 0x00;
    }
}

- (void)close {
    FMDBRetain(self);
    dispatch_async(_queue, ^() {
        [_db close];
        FMDBRelease(_db);
        _db = 0x00;
        FMDBRelease(self);
    });
}

- (FMDatabase*)database {
    if (!_db) {
        _db = FMDBReturnRetained([FMDatabase databaseWithPath:_path]);
        
        if (![_db open]) {
            ATLogError(@"FMDatabaseAsyncQueue", @"FMDatabaseQueue could not reopen database for path %@", _path);
            FMDBRelease(_db);
            _db  = 0x00;
            return 0x00;
        }
    }
    
    return _db;
}

- (void)inDatabase:(void (^)(FMDatabase *db))block {
    FMDBRetain(self);
    dispatch_async(_queue, ^() {
        
        FMDatabase *db = [self database];
        block(db);
        
        if ([db hasOpenResultSets]) {
           ATLogError(@"FMDatabaseAsyncQueue", @"%@", @"Warning: there is at least one open result set around after performing [FMDatabaseQueue inDatabase:]");
        }
        FMDBRelease(self);
    });
}


- (void)syncBeginTransaction:(BOOL)useDeferred withBlock:(void (^)(FMDatabase *db, BOOL *rollback))block {
    FMDBRetain(self);
    dispatch_sync(_queue, ^() {
        
        BOOL shouldRollback = NO;
        
        if (useDeferred) {
            [[self database] beginDeferredTransaction];
        }
        else {
            [[self database] beginTransaction];
        }
        
        block([self database], &shouldRollback);
        
        if (shouldRollback) {
            [[self database] rollback];
        }
        else {
            [[self database] commit];
        }
        FMDBRelease(self);
    });
}

- (void)beginTransaction:(BOOL)useDeferred withBlock:(void (^)(FMDatabase *db, BOOL *rollback))block {
    FMDBRetain(self);
    dispatch_async(_queue, ^() {
        
        BOOL shouldRollback = NO;
        
        if (useDeferred) {
            [[self database] beginDeferredTransaction];
        }
        else {
            [[self database] beginTransaction];
        }
        
        block([self database], &shouldRollback);
        
        if (shouldRollback) {
            [[self database] rollback];
        }
        else {
            [[self database] commit];
        }
        FMDBRelease(self);
    });
}

- (void)inDeferredTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block {
    [self beginTransaction:YES withBlock:block];
}

- (void)syncInTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block {
    [self syncBeginTransaction:NO withBlock:block];
}

- (void)inTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block {
    [self beginTransaction:NO withBlock:block];
}

#if SQLITE_VERSION_NUMBER >= 3007000
- (NSError*)inSavePoint:(void (^)(FMDatabase *db, BOOL *rollback))block {
    
    static unsigned long savePointIdx = 0;
    __block NSError *err = 0x00;
    FMDBRetain(self);
    dispatch_sync(_queue, ^() {
        
        NSString *name = [NSString stringWithFormat:@"savePoint%ld", savePointIdx++];
        
        BOOL shouldRollback = NO;
        
        if ([[self database] startSavePointWithName:name error:&err]) {
            
            block([self database], &shouldRollback);
            
            if (shouldRollback) {
                [[self database] rollbackToSavePointWithName:name error:&err];
            }
            else {
                [[self database] releaseSavePointWithName:name error:&err];
            }
            
        }
        FMDBRelease(self);
    });
    return err;
}
#endif

@end
