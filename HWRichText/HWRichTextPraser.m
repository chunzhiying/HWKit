//
//  HWStockCodePraser.m
//  yyfe
//
//  Created by 陈智颖 on 2017/3/1.
//  Copyright © 2017年 yy.com. All rights reserved.
//

#import "HWRichTextPraser.h"
#import "ColorUtil.h"

@implementation HWStockCodePraser

- (NSRegularExpression *)regex {
    return [NSRegularExpression regularExpressionWithPattern:@"\\$.{1,5}\\$" options:0 error:nil];
}

- (void)onMactchedWithText:(NSString *)text inRichText:(HWRichText *)richText {
    richText.insertStrFontColor(text, richText.font, DefaultTintColor);
}

@end
