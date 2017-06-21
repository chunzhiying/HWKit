//
//  HWGrowingTextView.m
//  HWGrowingTextView
//
//  Created by 陈智颖 on 16/6/20.
//  Copyright © 2016年 YY. All rights reserved.
//

#import "HWGrowingTextView.h"

#define SelfHeight self.bounds.size.height
#define SelfWidth self.bounds.size.width

@interface HWGrowingTextView () <UITextViewDelegate> {
    UITextView *_txtView;
    
    CGFloat _originalHeight; //原始一行的高度
    CGFloat _realHeightForEach; //每一行实际高度
    CGFloat _currentHeight;
    
    NSUInteger _maxLines;
}

@property (nonatomic) CGFloat showHeight;

@end

@implementation HWGrowingTextView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initTxtView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initTxtView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.frame = self.frame;
    
    if (_originalHeight <= 0) {
        _originalHeight = SelfHeight;
        _currentHeight = _originalHeight;
    }
}

#pragma mark - Init
- (void)initTxtView {
    _txtView = [[UITextView alloc] initWithFrame:self.bounds];
    _txtView.delegate = self;
    [self addSubview:_txtView];
}

- (void)setupWithFont:(UIFont *)font textColor:(UIColor *)color maxShowLines:(NSUInteger)lines
             delegate:(id<HWGrowingTextDelegate>)delegate
{
    _maxLines = lines;
    _delegate = delegate;
    
    _txtView.font = font;
    _txtView.textColor = color;
    
    _realHeightForEach = [@"test" boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                               options:NSStringDrawingUsesFontLeading
                                            attributes:@{NSFontAttributeName : _txtView.font}
                                               context:nil].size.height;
}

#pragma mark - Custom Method
- (void)figureTextHeight {
    CGFloat padding = _txtView.textContainer.lineFragmentPadding;
    CGFloat realHeight = [_txtView.text boundingRectWithSize:CGSizeMake(SelfWidth - 2 * padding, MAXFLOAT)
                                              options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName : _txtView.font}
                                              context:nil].size.height;
    
    self.showHeight = MIN(_maxLines, realHeight / _realHeightForEach) * _realHeightForEach;
}

#pragma mark - Setter & Getter
- (void)setShowHeight:(CGFloat)showHeight {
    
    if (_showHeight == showHeight) {
        return;
    }
    _showHeight = showHeight;
    
    if (_delegate && [_delegate respondsToSelector:@selector(growingTextView:didChangeHeightTo:)]) {
        [_delegate growingTextView:_txtView didChangeHeightTo:ceil(MAX(_originalHeight, _showHeight))];
    }
}

- (void)setFrame:(CGRect)frame {
    
    [UIView setAnimationsEnabled:frame.size.height > _currentHeight];
    
    [super setFrame:frame];
    _txtView.frame = self.bounds;
    _currentHeight = SelfHeight;
    
    [_txtView scrollRangeToVisible:NSMakeRange(0, _txtView.text.length)];
    [UIView setAnimationsEnabled:YES];
}

#pragma mark ReturnKeyType
- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType {
    [_txtView setReturnKeyType:returnKeyType];
}

- (UIReturnKeyType)returnKeyType {
    return [_txtView returnKeyType];
}

#pragma mark Text
- (void)setText:(NSString *)text {
    _txtView.text = text;
    [self figureTextHeight];
}

- (NSString *)text {
    return _txtView.text;
}

#pragma mark InputView
- (void)setInputView:(UIView *)inputView {
    _txtView.inputView = inputView;
}

- (UIView *)inputView {
    return _txtView.inputView;
}

#pragma mark SelectedRange
- (void)setSelectedRange:(NSRange)selectedRange {
    _txtView.selectedRange = selectedRange;
}

- (NSRange)selectedRange {
    return _txtView.selectedRange;
}

#pragma mark - UIResponder
- (BOOL)resignFirstResponder {
    [super resignFirstResponder];
    return [_txtView resignFirstResponder];
}

- (BOOL)becomeFirstResponder {
    [super becomeFirstResponder];
    return [_txtView becomeFirstResponder];
}

- (BOOL)isFirstResponder {
    [super isFirstResponder];
    return [_txtView isFirstResponder];
}

- (void)reloadInputViews {
    [_txtView reloadInputViews];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    [self figureTextHeight];
    if (_delegate && [_delegate respondsToSelector:@selector(growingTextViewDidChange:)]) {
        [_delegate growingTextViewDidChange:textView];
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (_delegate && [_delegate respondsToSelector:@selector(growingTextViewShouldBeginEditing:)]) {
        return [_delegate growingTextViewShouldBeginEditing:textView];
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if (_delegate && [_delegate respondsToSelector:@selector(growingTextViewShouldEndEditing:)]) {
        return [_delegate growingTextViewShouldEndEditing:textView];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (_delegate && [_delegate respondsToSelector:@selector(growingTextViewDidBeginEditing:)]) {
        [_delegate growingTextViewDidBeginEditing:textView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (_delegate && [_delegate respondsToSelector:@selector(growingTextViewDidEndEditing:)]) {
        [_delegate growingTextViewDidEndEditing:textView];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (_delegate && [_delegate respondsToSelector:@selector(growingTextView:shouldChangeTextInRange:replacementText:)]) {
        return [_delegate growingTextView:textView shouldChangeTextInRange:range replacementText:text];
    }
    return YES;
}

@end
