//
//  HWRichText.h
//  HWStringDemo
//
//  Created by 陈智颖 on 15/12/5.
//  Copyright © 2015年 YY. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^TargetSelector)();

@interface HWRichText : UIView

@property (nonatomic, strong, readonly) NSAttributedString *richContentText;

- (void)setSelectorTextColor:(UIColor *)color;

- (HWRichText *)insertString:(NSString *)string;
- (HWRichText *)insertString:(NSString *)string withFont:(UIFont *)font withTextColor:(UIColor *)color;

- (HWRichText *)insertString:(NSString *)string withSelector:(TargetSelector)selector;
- (HWRichText *)insertString:(NSString *)string withFont:(UIFont *)font withSelector:(TargetSelector)selector;

- (HWRichText *)insertImage:(UIImage *)image withBounds:(CGRect)rect;
- (HWRichText *)insertImage:(UIImage *)image withBounds:(CGRect)rect withSelector:(TargetSelector)selector;

@end