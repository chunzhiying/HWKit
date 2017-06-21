//
//  HWStockCodePraser.m
//  yyfe
//
//  Created by 陈智颖 on 2017/3/1.
//  Copyright © 2017年 yy.com. All rights reserved.
//

#import "HWRichTextPraser.h"
#import "HWHelper.h"

@implementation HWStockCodePraser

- (NSRegularExpression *)regex {
    return [NSRegularExpression regularExpressionWithPattern:@"\\$\\*?[\u4E00-\u9FA5A-Za-z0-9]{2,6}\\([A-Za-z]{1,4}[0-9]{6}\\)\\$" options:0 error:nil];
}

- (void)onMactchedWithText:(NSString *)text inRichText:(HWRichText *)richText {
   
    [richText setSelectorTextColor:DefaultTintColor];
   
//    NSString *stock = [text substringWithRange:NSMakeRange(1, text.length - 2)];
//    NSArray *ary = [[stock componentsSeparatedByString:@")"].firstObject componentsSeparatedByString:@"("];
//    richText.insertStrAction(text, ^{
//        
//    });
}

@end
