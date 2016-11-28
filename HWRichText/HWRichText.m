//
//  HWRichText.m
//  HWStringDemo
//
//  Created by 陈智颖 on 15/12/5.
//  Copyright © 2015年 YY. All rights reserved.
//

#import "HWRichText.h"

#define ImagePlaceHolder @"\U0000fffc"
#define Ellipsis @"..."
#define EllipsisLength 2

#define MinWordCountPerLine floorf(self.bounds.size.width / _font.pointSize)

#define FigureStrHeight(str) \
[str boundingRectWithSize:CGSizeMake(self.bounds.size.width - 2 * _contentTxtView.textContainer.lineFragmentPadding, MAXFLOAT) \
    options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin \
    attributes:@{NSFontAttributeName : _font} \
    context:nil].size.height

#define FigureStrWidth(str) \
[str boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) \
    options:NSStringDrawingUsesFontLeading \
    attributes:@{NSFontAttributeName : _font} \
    context:nil].size.width

#define SafeBlock(atBlock, ...) \
if(atBlock) {\
    atBlock(__VA_ARGS__);\
}\

#define SelKey @"sel"
#define ExtendKey @"extend"

@interface HWTextView : UITextView

@end

@implementation HWTextView

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return NO;
}

- (BOOL)canBecomeFirstResponder {
    return NO;
}

@end

@interface HWRichText() <UITextViewDelegate> {
    
    bool _isFull;
    NSUInteger _realLineCount;
    
    HWTextView *_contentTxtView;
    UITapGestureRecognizer *_contentTxtTap;
    
    NSMutableAttributedString *_contentAttributedStr;
    
    NSMutableDictionary *_strSelectorDic; //{@"location" : @{@"sel" : selector, @"extend" : range}}
    NSMutableDictionary *_imgSelectorDic; //{@"location" : @{@"sel" : selector, @"extend" : imgRectWidth}}
}

@end

@interface HWRichText (FigureMaxShowLine)

- (void)measureShowLine;

@end

@implementation HWRichText

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    _contentAttributedStr = [NSMutableAttributedString new];
    
    _strSelectorDic = [NSMutableDictionary new];
    _imgSelectorDic = [NSMutableDictionary new];
    
    _contentTxtView = [[HWTextView alloc] initWithFrame:self.bounds];
    _contentTxtView.editable = NO;
    _contentTxtView.delegate = self;
    
    _contentTxtTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapResponse:)];
    
    _contentTxtView.backgroundColor = [UIColor clearColor];
    _font = [UIFont systemFontOfSize:15];
    _textColor = [UIColor blackColor];
    _lineSpace = 2;
    
    [_contentTxtView addGestureRecognizer:_contentTxtTap];
    [self addSubview:_contentTxtView];
    self.selectedHighlightEnabled = YES;
}

#pragma mark -
- (void)layoutSubviews {
    [super layoutSubviews];
    [_contentTxtView setFrame:self.bounds];
    
    [self shouldCenterContent];
    [self measureShowLine];
}

- (void)shouldCenterContent {
    
    if (!_showInCenter) {
        return;
    }
    
    CGSize contentSize = [_contentAttributedStr boundingRectWithSize:self.bounds.size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    
    CGFloat topCorrect = ([_contentTxtView bounds].size.height - contentSize.height ) / 2.0 - 10;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    
    CGFloat widthCorrect = ([_contentTxtView bounds].size.width - contentSize.width ) / 2.0;
    widthCorrect = ( widthCorrect < 0.0 ? 0.0 : widthCorrect );
    
    _contentTxtView.contentOffset = (CGPoint){.x = -widthCorrect, .y = -topCorrect};
    
}

- (void)clearAllText {
    _contentAttributedStr = [NSMutableAttributedString new];
    _contentTxtView.attributedText = _contentAttributedStr;
    _contentTxtView.bounces = YES;
    
    [_strSelectorDic removeAllObjects];
    [_imgSelectorDic removeAllObjects];
    
    _isFull = NO;
}

#pragma mark - Figrue MaxShowLine
- (void)setMaxShowLine:(NSUInteger)maxShowLine {
    _maxShowLine = maxShowLine;
    [self measureShowLine];
}

#pragma mark - Gesture
- (void)tapResponse:(UITapGestureRecognizer *)recognizer {
    
    UITextView *textView = (UITextView *)recognizer.view;
    
    UITextPosition *tapPosition = [textView closestPositionToPoint:[recognizer locationInView:textView]];
    UITextRange *textRange = [textView.tokenizer rangeEnclosingPosition:tapPosition
                                                        withGranularity:UITextGranularityWord
                                                            inDirection:UITextLayoutDirectionRight];
    NSRange tapRange = [self convertRange:textRange];
    
    for (NSDictionary *strSelDic in _strSelectorDic.allValues) {
        NSRange selRange = [strSelDic[ExtendKey] rangeValue];
        
        if (NSLocationInRange(tapRange.location, selRange) && NSLocationInRange(NSMaxRange(tapRange), selRange)) {
            TargetSelector selector = strSelDic[SelKey];
            SafeBlock(selector);
            break;
        }
    }
}

- (NSRange)convertRange:(UITextRange *)textRange
{
    UITextPosition* beginning = _contentTxtView.beginningOfDocument;
    UITextPosition* selectionStart = textRange.start;
    UITextPosition* selectionEnd = textRange.end;
    
    const NSInteger location = [_contentTxtView offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [_contentTxtView offsetFromPosition:selectionStart toPosition:selectionEnd];
    
    return NSMakeRange(location, length);
}


#pragma mark - Public String
- (void)setSelectorTextColor:(UIColor *)color {
    _contentTxtView.linkTextAttributes = @{NSForegroundColorAttributeName : color};
}

- (HWRichText *)insertString:(NSString *)string {
    return [self insertString:string withFont:_font withTextColor:_textColor];
}

- (HWRichText *)insertString:(NSString *)string withFont:(UIFont *)font withTextColor:(UIColor *)color {
    return [self insertString:string withFont:font withTextColor:color withSelector:nil];
}

- (HWRichText *)insertString:(NSString *)string withSelector:(TargetSelector)selector {
    return [self insertString:string withFont:_font withSelector:selector];
}

- (HWRichText *)insertString:(NSString *)string withFont:(UIFont *)font withSelector:(TargetSelector)selector {
    return [self insertString:string withFont:font withTextColor:_textColor withSelector:selector];
}

- (HWRichText *)insertString:(NSString *)string withFont:(UIFont *)font withTextColor:(UIColor *)color withSelector:(TargetSelector)selector {
    
    if (_isFull) {
        return self;
    }
    
    NSUInteger location = _contentAttributedStr.length;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = _lineSpace;
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    [attributes setObject:font forKey:NSFontAttributeName];
    [attributes setObject:color forKey:NSForegroundColorAttributeName];
    [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    
    if (selector != nil) {
        NSDictionary *strDic = @{SelKey    : selector,
                                 ExtendKey : [NSValue valueWithRange:NSMakeRange(location, string.length)]};
        [_strSelectorDic setObject:strDic forKey:@(location)];
        
        if (_selectedHighlightEnabled) {
            [attributes setObject:[string mutableCopy] forKey:NSLinkAttributeName];
        } else {
            [attributes setObject:_contentTxtView.linkTextAttributes[NSForegroundColorAttributeName]
                           forKey:NSForegroundColorAttributeName];
        }
    }
    
    NSAttributedString *newString = [[NSAttributedString alloc] initWithString:[string mutableCopy]
                                                                    attributes:attributes];
    
    [_contentAttributedStr insertAttributedString:newString atIndex:location];
    
    _contentTxtView.attributedText = _contentAttributedStr;
    
    [self measureShowLine];
    [self setNeedsLayout];
    
    return self;
}

#pragma mark - Public Image
- (HWRichText *)insertImage:(UIImage *)image withBounds:(CGRect)rect {
    return [self insertImage:image withBounds:rect withSelector:nil];
}

- (HWRichText *)insertImage:(UIImage *)image withBounds:(CGRect)rect withSelector:(TargetSelector)selector {
    
    if (image == nil || _isFull) {
        return self;
    }
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
    attachment.image = image;
    attachment.bounds = rect;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = _lineSpace;
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    
    NSMutableAttributedString *newString = [[NSAttributedString attributedStringWithAttachment:attachment] mutableCopy];
    [newString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, newString.length)];
    
    NSUInteger location = _contentAttributedStr.length;
    
    void (^nullBlock)() = ^(){};
    
    if (selector == nil) {
        selector = nullBlock;
    }
    
    NSDictionary *imgDic = @{SelKey : selector,
                             ExtendKey : @(rect.size.width)};
    [_imgSelectorDic setObject:imgDic forKey:@(location)];
    
    [_contentAttributedStr insertAttributedString:newString atIndex:location];
    
    _contentTxtView.attributedText = _contentAttributedStr;
    [self setNeedsLayout];
    
    return self;
}

#pragma mark - Setter && Getter
- (void)setFrame:(CGRect)frame {
    [super setFrame: frame];
    [_contentTxtView setFrame:self.bounds];
}

- (NSAttributedString *)richContentText {
    return _contentAttributedStr;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    _scrollEnabled = scrollEnabled;
    _contentTxtView.scrollEnabled = scrollEnabled;
}

- (void)setSelectedHighlightEnabled:(BOOL)selectedHighlightEnabled {
    _selectedHighlightEnabled = selectedHighlightEnabled;
    _contentTxtTap.enabled = !selectedHighlightEnabled;
}

#pragma mark - TextView Delegate
- (void)textViewDidChangeSelection:(UITextView *)textView {
    textView.selectedRange = NSMakeRange(0, 0);
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    
    NSDictionary *strDic = [_strSelectorDic objectForKey:@(characterRange.location)];
    TargetSelector selector = strDic[SelKey];
    SafeBlock(selector);
    
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange {
    
    NSDictionary *imgDic = [_imgSelectorDic objectForKey:@(characterRange.location)];
    TargetSelector selector = imgDic[SelKey];
    SafeBlock(selector);
    
    return NO;
}

@end

#pragma mark - Figure MaxShowLine

@implementation HWRichText (FigureMaxShowLine)

#define ShowStringKey @"ShowStringKey"
#define RemoveCountKey @"RemoveCountKey"

#define ImgTotalWidthKey @"ImgTotalWidthKey"
#define ImgLocationAryKey @"ImgLocationAryKey"

- (void)measureShowLine {
    if (_maxShowLine == 0 || _contentTxtView.attributedText.length == 0) {
        return;
    }
    
    NSString *showString = [_contentAttributedStr.string stringByReplacingOccurrencesOfString:ImagePlaceHolder
                                                                                   withString:@""];
    
    NSUInteger removeCount = [self cutStringForMaxShowLine:showString];
    
    CGFloat imgTotalWidth = 0;
    NSMutableArray *imgLocationAry = [NSMutableArray new];
    
    for (NSNumber *key in _imgSelectorDic.allKeys) {
        if (removeCount == 0 || [key unsignedIntegerValue] < showString.length ) {
            NSDictionary *imgDic = [_imgSelectorDic objectForKey:key];
            CGFloat imgWidth = [[imgDic objectForKey:ExtendKey] floatValue];
            imgTotalWidth += imgWidth;
            [imgLocationAry addObject:@{@"loc":key, @"width":_imgSelectorDic[key][ExtendKey]}];
        }
    }
    
    [imgLocationAry sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
     {return [obj1[@"loc"] integerValue] > [obj2[@"loc"] integerValue] ? NSOrderedAscending : NSOrderedDescending;}]; //imgLocationAry是倒序的
    
    
    NSDictionary *origData = @{ShowStringKey : showString,
                               RemoveCountKey : @(removeCount),
                               ImgTotalWidthKey : @(imgTotalWidth),
                               ImgLocationAryKey : imgLocationAry};
    
    removeCount = imgTotalWidth > FigureStrWidth(showString)
    ? [self figureMoreImgWithDic:origData]
    : [self figureMoreTextWithDic:origData];
    
    if (removeCount > 0) {
        
        _isFull = YES;
        
        NSMutableAttributedString *showAttributeStr = [_contentAttributedStr mutableCopy];
        
        NSRange ellipsisRange = NSMakeRange(showAttributeStr.length - (removeCount + EllipsisLength), EllipsisLength);
        NSRange deleteRange = NSMakeRange(showAttributeStr.length - (removeCount + EllipsisLength), (removeCount + EllipsisLength));
        NSString *sub = [[showAttributeStr attributedSubstringFromRange:ellipsisRange].string stringByReplacingOccurrencesOfString:ImagePlaceHolder withString:@""];
        
        if (sub.length != EllipsisLength) {
            deleteRange = NSMakeRange(showAttributeStr.length - removeCount, removeCount);
        }
        
        [showAttributeStr deleteCharactersInRange:deleteRange];
        [showAttributeStr appendAttributedString:[[NSAttributedString alloc] initWithString:Ellipsis]];
        _contentTxtView.attributedText = showAttributeStr;
        
    }
    
    NSUInteger realLineCount = removeCount > 0 ? _maxShowLine : _realLineCount;
    
    CGFloat height = realLineCount * _font.lineHeight + (realLineCount - 1) * _lineSpace + _contentTxtView.textContainerInset.bottom + _contentTxtView.textContainerInset.top;
    
    _contentTxtView.bounces = NO;
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}


- (NSUInteger)figureMoreTextWithDic:(NSDictionary *)data {
    
    NSString *showString = data[ShowStringKey];
    
    NSInteger removeCount = [data[RemoveCountKey] integerValue];
    
    NSInteger imgTotalWidth = [data[ImgTotalWidthKey] integerValue];
    NSArray *imgLocationAry = data[ImgLocationAryKey];
    
    
    if (imgTotalWidth > 0) {
        
        CGFloat strWidth;
        NSUInteger wordCount = ceilf(imgTotalWidth / [_font pointSize]);
        while (fabs((strWidth = FigureStrWidth([showString substringFromIndex:showString.length - wordCount])) - imgTotalWidth)
               > [_font pointSize]) {
            wordCount += (strWidth > imgTotalWidth ? -1 : 1);
        }
        wordCount += ((strWidth < imgTotalWidth) ? 1 : 0);
        
        
        if (removeCount != 0) {
            removeCount += wordCount;
            
        } else {
            
            NSString *newString = [NSString stringWithFormat:@"%@%@", showString, [showString substringFromIndex:showString.length - wordCount]];
            removeCount += [self cutStringForMaxShowLine:newString];
            
        }
        
        // 可能有图片在截断处之后，补回这些图片占的空间
        NSString *origStr = [_contentAttributedStr.string stringByReplacingOccurrencesOfString:ImagePlaceHolder
                                                                                    withString:@""];
        NSInteger removeImgCount = 0;
        NSInteger notShowImgCount = _imgSelectorDic.count - imgLocationAry.count;
        
        for (NSInteger i = 0; i < imgLocationAry.count; i++) {
            
            NSUInteger location = [[[imgLocationAry objectAtIndex:i] objectForKey:@"loc"] unsignedIntegerValue];
            
            if (location > _contentAttributedStr.length - removeCount - notShowImgCount) { //location占位
                
                CGFloat imgWidth = [[[_imgSelectorDic objectForKey:@(location)] objectForKey:ExtendKey] floatValue];
                CGFloat strWidth;
                
                NSUInteger wordCount = ceilf(imgWidth / [_font pointSize]);
                while (fabs((strWidth = FigureStrWidth([origStr substringWithRange:NSMakeRange(origStr.length - removeCount, wordCount)])) - imgWidth)
                       > [_font pointSize]) {
                    wordCount += (strWidth > imgWidth ? -1 : 1);
                }
                
                removeCount -= (wordCount + ((strWidth < imgWidth) ? 1 : 0));
                removeCount = MAX(removeCount, _contentAttributedStr.length - location - notShowImgCount); //补回的空间不得进入被截断图片的占位
                removeImgCount++;
            }
        }
        
        removeCount += removeImgCount + notShowImgCount; //图片的占位
    }
    
    return removeCount;
    
}


- (NSUInteger)figureMoreImgWithDic:(NSDictionary *)data {
    
    NSMutableString *showString = [NSMutableString stringWithString:data[ShowStringKey]];
    
    NSInteger removeCount = [data[RemoveCountKey] integerValue];
    
    NSMutableArray *imgLocationAry = [[NSMutableArray alloc] initWithArray:data[ImgLocationAryKey]];
    [imgLocationAry sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
     {return [obj1[@"loc"] integerValue] > [obj2[@"loc"] integerValue] ? NSOrderedDescending : NSOrderedAscending;}];
    
    CGFloat holderOutWidth = FigureStrWidth(@"(&&)");
    CGFloat holderInPerWidth = FigureStrWidth(@"A");
    
    NSUInteger imgHolderTotalCount = 0;
    for (NSInteger i = 0; i < imgLocationAry.count; i++) {
        
        NSDictionary *locationDic = [imgLocationAry objectAtIndex:i];
        NSUInteger location = [locationDic[@"loc"] unsignedIntegerValue];
        CGFloat width = [locationDic[@"width"] floatValue];
        
        NSString *holderStr = [self buildImgHolderWithCount:MAX(0, ceilf((width - holderOutWidth) / holderInPerWidth))];
        [showString insertString:holderStr atIndex:location - i + imgHolderTotalCount];
        imgHolderTotalCount += holderStr.length;
    }
    
    NSUInteger shouldRemove = [self cutStringForMaxShowLine:[showString mutableCopy]]; // 包含了图片的占位符
    removeCount += [self parseImgHolderStr:[showString substringFromIndex:showString.length - shouldRemove]];
    
    return removeCount;
}


- (NSUInteger)cutStringForMaxShowLine:(NSString *)shouldCutStr {
    NSUInteger shouldCutCount = 0;
    NSUInteger realLineCount;
    while ((realLineCount = FigureStrHeight(shouldCutStr) / _font.lineHeight) > _maxShowLine) {
        NSInteger minuend = realLineCount - _maxShowLine > 1 ? MinWordCountPerLine : EllipsisLength;
        shouldCutStr = [shouldCutStr substringToIndex:shouldCutStr.length - minuend];
        shouldCutCount += minuend;
    }
    _realLineCount = realLineCount;
    return shouldCutCount;
}

- (NSString *)buildImgHolderWithCount:(NSInteger)count {
    NSMutableString *result = [[NSMutableString alloc] initWithString:@"(&"];
    for (NSInteger i = 0; i < count; i++) {
        [result appendString:@"A"];
    }
    [result appendString:@"&)"];
    return result;
}

- (NSUInteger)parseImgHolderStr:(NSString *)str {
    
    NSError *error = nil;
    NSString *imgHolderStr = [NSString stringWithFormat:@"(&%@", str];
    NSUInteger withoutImgHolderLength = imgHolderStr.length;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@".(&A*&)."
                                                                           options:NSRegularExpressionDotMatchesLineSeparators
                                                                             error:&error];
    NSArray<NSTextCheckingResult *> *result = [regex matchesInString:imgHolderStr options:0 range:NSMakeRange(0, imgHolderStr.length)];
    if (result) {
        for (NSTextCheckingResult *res in result) {
            NSString *imgHolder = [imgHolderStr substringWithRange:res.range];
            NSLog(@"imgHolder:%@", imgHolder);
            
            withoutImgHolderLength -= imgHolder.length;
            if (res.range.location == 0) {
                withoutImgHolderLength += @"(&".length;
            }
        }
    }
    withoutImgHolderLength += result.count;
    
    return withoutImgHolderLength - @"(&".length;
}

@end

#pragma mark - Parser

@implementation HWRichText (Parser)

#define RangeKey @"range"
#define ParserKey @"parser"

/*
 [_text appendText:@"放大书法大赛反对撒过反对撒放 244088805@qq.com 到萨反对撒疯娃反对撒放到萨反对撒反对撒发撒放到萨发生"
 withFont:[UIFont systemFontOfSize:10] withTextColor:[UIColor blueColor]
 withParser:@[[HttpParser new], [EmailParser new]]];
 */

- (HWRichText *)appendText:(NSString *)text withFont:(UIFont *)font withTextColor:(UIColor *)color
                withParser:(NSArray<id<HWParserSetting>> *)parsers
{
    NSMutableArray *parserLocationAry = [NSMutableArray new]; //[{"range":range, "parser":parser}]
    
    for (id<HWParserSetting> parser in parsers) {
        NSArray *matchs = [parser.regex matchesInString:text options:NSMatchingReportProgress range:NSMakeRange(0, [text length])];
        
        for (NSTextCheckingResult *match in matchs) {
            [parserLocationAry addObject:@{RangeKey : [NSValue valueWithRange:match.range],
                                           ParserKey : parser}];
        }
    }
    
    [parserLocationAry sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        return [obj1[RangeKey] rangeValue].location > [obj2[RangeKey] rangeValue].location ? NSOrderedDescending : NSOrderedAscending;
    }];
    
    NSUInteger currentLocation = 0;
    for (NSDictionary *parserLocationDic in parserLocationAry) {
        
        NSRange parserTextRange = [parserLocationDic[RangeKey] rangeValue];
        id<HWParserSetting> parser = parserLocationDic[ParserKey];
        
        [self insertString:[text substringWithRange:NSMakeRange(currentLocation, parserTextRange.location - currentLocation)]
                  withFont:font withTextColor:color];
        [parser onMactchedWithText:[text substringWithRange:parserTextRange] inRichText:self];
        
        currentLocation = parserTextRange.location + parserTextRange.length;
    }
    
    [self insertString:[text substringFromIndex:currentLocation]
              withFont:font withTextColor:color];
    
    return self;
}

@end


@implementation HWRichText (Functional_Extension)

- (HWRichText *(^)(NSString *))insertStr {
    return ^(NSString *string) {
        [self insertString:string];
        return self;
    };
}

- (HWRichText *(^)(NSString *, UIFont *, UIColor *))insertStrFontColor {
    return ^(NSString *string, UIFont *font, UIColor *color) {
        [self insertString:string withFont:font withTextColor:color];
        return self;
    };
}

- (HWRichText *(^)(NSString *, TargetSelector))insertStrAction {
    return ^(NSString *string, TargetSelector selector) {
        [self insertString:string withSelector:selector];
        return self;
    };
}

- (HWRichText *(^)(NSString *, UIFont *, TargetSelector))insertStrFontAction {
    return ^(NSString *string, UIFont *font, TargetSelector selector) {
        [self insertString:string withFont:font withSelector:selector];
        return self;
    };
}

- (HWRichText *(^)(UIImage *, CGRect))insertImgBounds {
    return ^(UIImage *image, CGRect rect) {
        [self insertImage:image withBounds:rect];
        return self;
    };
}

- (HWRichText *(^)(UIImage *, CGRect, TargetSelector))insertImgBoundsAction {
    return ^(UIImage *image, CGRect rect, TargetSelector selector) {
        [self insertImage:image withBounds:rect withSelector:selector];
        return self;
    };
}

@end
