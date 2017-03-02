//
//  HWStockCodePraser.h
//  yyfe
//
//  Created by 陈智颖 on 2017/3/1.
//  Copyright © 2017年 yy.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HWRichText.h"

@interface HWStockCodePraser : NSObject <HWParserSetting>

@property (nonatomic, strong) NSRegularExpression *regex;

- (void)onMactchedWithText:(NSString *)text inRichText:(HWRichText *)richText;

@end
