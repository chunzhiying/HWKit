//
//  LiveDrawerViewCell.h
//  yyfe
//
//  Created by 陈智颖 on 16/3/24.
//  Copyright © 2016年 yy.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HWDrawerViewCell : UITableViewCell

- (instancetype)initFromNib;
- (void)setUITitle:(NSString *)title isSelected:(BOOL)selected;

@end
