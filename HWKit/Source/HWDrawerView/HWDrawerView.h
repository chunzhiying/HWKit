//
//  DrawerView.h
//  yyfe
//
//  Created by 陈智颖 on 16/3/24.
//  Copyright © 2016年 yy.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HWDrawerViewDataSource <NSObject>

@required
- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSString *)titleForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol HWDrawerViewDelegate <NSObject>

@optional
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface HWDrawerView : UIView

@property (nonatomic, weak) id<HWDrawerViewDataSource, HWDrawerViewDelegate> delegate;
@property (nonatomic, strong, readonly) NSMutableArray *selectedRows; //各section选中的row

- (instancetype)initWithFrame:(CGRect)frame
                 withDelegate:(id<HWDrawerViewDataSource, HWDrawerViewDelegate>)delegate
                withMaxHeight:(CGFloat)maxHeight;

- (void)setStatusToBeSelectedIn:(NSIndexPath *)indexPath;

- (void)reloadData;

@end
