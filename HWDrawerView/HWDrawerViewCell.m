//
//  LiveDrawerViewCell.m
//  yyfe
//
//  Created by 陈智颖 on 16/3/24.
//  Copyright © 2016年 yy.com. All rights reserved.
//

#import "HWDrawerViewCell.h"
#import "ColorUtil.h"

@interface HWDrawerViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIImageView *confirmImg;

@end

@implementation HWDrawerViewCell

- (instancetype)initFromNib {
    self = [[[NSBundle mainBundle] loadNibNamed:@"HWDrawerViewCell" owner:nil options:nil] firstObject];
    return self;
}

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setUITitle:(NSString *)title isSelected:(BOOL)selected {
    _title.text = title;
    _title.textColor = selected ? DefaultTintColor : DefaultGrayTextColor;
    _confirmImg.hidden = !selected;
}

@end
