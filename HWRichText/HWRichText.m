//
//  HWRichText.m
//  HWStringDemo
//
//  Created by 陈智颖 on 15/12/5.
//  Copyright © 2015年 YY. All rights reserved.
//

#import "HWRichText.h"

#define defaultFontColor [UIColor blackColor]

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
    
    HWTextView *_contentTxtView;
    CGSize _txtViewContenSize;
    
    NSMutableAttributedString *_contentAttributedStr;
    
    NSMutableDictionary *_strSelectorDic;
    NSMutableDictionary *_imgSelectorDic;
}

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
    
    _contentTxtView.backgroundColor = [UIColor clearColor];
    _defaultFont = [UIFont systemFontOfSize:15];
    
    [self addSubview:_contentTxtView];
}

#pragma mark -
- (void)layoutSubviews {
    [super layoutSubviews];
    [_contentTxtView setFrame:self.bounds];
    
    [self shouldCenterContent];
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


#pragma mark - Public String
- (void)setSelectorTextColor:(UIColor *)color {
    _contentTxtView.linkTextAttributes = @{NSForegroundColorAttributeName : color};
}

- (HWRichText *)insertString:(NSString *)string {
    return [self insertString:string withFont:_defaultFont withTextColor:defaultFontColor];
}

- (HWRichText *)insertString:(NSString *)string withFont:(UIFont *)font withTextColor:(UIColor *)color {
    
    NSAttributedString *newString = [[NSAttributedString alloc] initWithString:[string mutableCopy]
                                                                    attributes:@{NSForegroundColorAttributeName : color,
                                                                                 NSFontAttributeName : font}];
    [_contentAttributedStr appendAttributedString:newString];
    
    _contentTxtView.attributedText = _contentAttributedStr;
    [self setNeedsLayout];
    
    return self;
}

- (HWRichText *)insertString:(NSString *)string withSelector:(TargetSelector)selector {
    return [self insertString:string withFont:_defaultFont withSelector:selector];
}

- (HWRichText *)insertString:(NSString *)string withFont:(UIFont *)font withSelector:(TargetSelector)selector {
    
    NSUInteger location = _contentAttributedStr.length;
    
    NSAttributedString *newString = [[NSAttributedString alloc] initWithString:[string mutableCopy]
                                                                    attributes:@{NSLinkAttributeName : [string mutableCopy],
                                                                                 NSFontAttributeName : font}];
    
    if (selector != nil) {
        [_strSelectorDic setObject:[selector copy] forKey:@(location)];
    }
    
    [_contentAttributedStr insertAttributedString:newString atIndex:location];
    
    _contentTxtView.attributedText = _contentAttributedStr;
    [self setNeedsLayout];
    
    return self;
}

#pragma mark - Public Image
- (HWRichText *)insertImage:(UIImage *)image withBounds:(CGRect)rect {
    return [self insertImage:image withBounds:rect withSelector:nil];
}

- (HWRichText *)insertImage:(UIImage *)image withBounds:(CGRect)rect withSelector:(TargetSelector)selector {
    
    if (image == nil) {
        return self;
    }
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
    attachment.image = image;
    attachment.bounds = rect;
    
    NSAttributedString *newString = [NSAttributedString attributedStringWithAttachment:attachment];
    
    NSUInteger location = _contentAttributedStr.length;
    
    if (selector != nil) {
        [_imgSelectorDic setObject:selector forKey:@(location)];
    }
    
    [_contentAttributedStr insertAttributedString:newString atIndex:location];
    
    _contentTxtView.attributedText = _contentAttributedStr;
    [self setNeedsLayout];
    
    return self;
}

#pragma mark - Setter && Getter
- (void)setFrame:(CGRect)frame {
    [super setFrame: frame];
    [_contentTxtView setFrame:frame];
}

- (NSAttributedString *)richContentText {
    return _contentAttributedStr;
}

#pragma mark - TextView Delegate
- (void)textViewDidChangeSelection:(UITextView *)textView {
    textView.selectedRange = NSMakeRange(0, 0);
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    
    TargetSelector selector = [_strSelectorDic objectForKey:@(characterRange.location)];
    if (selector != nil) {
        selector();
    }
    
    return NO;
}


- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange {
    
    TargetSelector selector = [_imgSelectorDic objectForKey:@(characterRange.location)];
    if (selector != nil) {
        selector();
    }
    
    return YES;
}

@end
