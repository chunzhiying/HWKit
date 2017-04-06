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

@property (nonatomic, strong) UIColor *textColor; //default: blackColor
@property (nonatomic, strong) UIFont *font;  //default: 15
@property (nonatomic) CGFloat lineSpace; //default: 2

@property (nonatomic) BOOL showInCenter; //auto offset to center in frame
@property (nonatomic) BOOL scrollEnabled;
@property (nonatomic) BOOL selectedHighlightEnabled; //highlight when selected, default: >= iOS8 ? YES : NO

@property (nonatomic) NSUInteger maxShowLine; //will reset frame.size.height, (NSUIntegerMax to get All content height.)

- (void)setSelectorTextColor:(UIColor *)color; //clickable textColor, default: blue

- (HWRichText *)insertString:(NSString *)string;
- (HWRichText *)insertString:(NSString *)string withFont:(UIFont *)font withTextColor:(UIColor *)color;

- (HWRichText *)insertString:(NSString *)string withSelector:(TargetSelector)selector;
- (HWRichText *)insertString:(NSString *)string withFont:(UIFont *)font withSelector:(TargetSelector)selector;

- (HWRichText *)insertImage:(UIImage *)image withBounds:(CGRect)rect;
- (HWRichText *)insertImage:(UIImage *)image withBounds:(CGRect)rect withSelector:(TargetSelector)selector;

- (void)clearAllText;

@end


@interface HWRichText (Functional_Extension)

@property (nonatomic, readonly) HWRichText *(^insertStr)(NSString *);
@property (nonatomic, readonly) HWRichText *(^insertStrFontColor)(NSString *, UIFont *, UIColor *);
@property (nonatomic, readonly) HWRichText *(^insertStrAction)(NSString *, TargetSelector);
@property (nonatomic, readonly) HWRichText *(^insertStrFontAction)(NSString *, UIFont *, TargetSelector);

@property (nonatomic, readonly) HWRichText *(^insertImgBounds)(UIImage *, CGRect);
@property (nonatomic, readonly) HWRichText *(^insertImgBoundsAction)(UIImage *, CGRect, TargetSelector);

@end


@protocol HWParserSetting <NSObject>

@property (nonatomic, strong, readonly) NSRegularExpression *regex;

- (void)onMactchedWithText:(NSString *)text inRichText:(HWRichText *)richText;

@end

@interface HWRichText (Parser)

- (HWRichText *)appendText:(NSString *)text withFont:(UIFont *)font withTextColor:(UIColor *)color
                withParser:(NSArray<id<HWParserSetting>> *)parsers;

@end
