//
//  SearchCacheDB.h
//  yyfe
//
//  Created by 陈智颖 on 2016/10/13.
//  Copyright © 2016年 yy.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HWPromise.h"

@class SearchChannelData;
@class SearchTeacherData;

@interface SearchCacheDB : NSObject

- (void)saveChannels:(NSArray<SearchChannelData *> *)datas;
- (NSArray<SearchChannelData *> *)queryAllChannel;
- (HWPromise *)queryChannelCount;

- (void)saveTeachers:(NSArray<SearchTeacherData *> *)datas;
- (NSArray<SearchTeacherData *> *)queryAllTeacher;
- (HWPromise *)queryTeacherCount;

- (void)removeAll;

@end
