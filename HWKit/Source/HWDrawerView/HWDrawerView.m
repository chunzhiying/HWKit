//
//  DrawerView.m
//  yyfe
//
//  Created by 陈智颖 on 16/3/24.
//  Copyright © 2016年 yy.com. All rights reserved.
//

#import "HWDrawerView.h"
#import "HWDrawerViewCell.h"
#import "HWHelper.h"

#define DrawerTableCellHeight 41
#define SeperateLineHeight 20

#define DefaultSelectedSection -1


@protocol DrawerItemDelegate <NSObject>

- (void)didSelectDrawerItemAtSection:(NSInteger)section;

@end

@interface DrawerItem : UIView {
    UILabel *_titleLabel;
    UIImageView *_arrawImg;
    UIImageView *_bottomArraw;
}

@property (nonatomic, weak) id<DrawerItemDelegate> delegate;
@property (nonatomic, readonly) NSInteger sectionNum;
@property (nonatomic, strong) NSString *title;

- (instancetype)initWithFrame:(CGRect)frame withSectionNum:(NSInteger)section;
- (void)setArrowStatus:(BOOL)open;

@end

@implementation DrawerItem

- (instancetype)initWithFrame:(CGRect)frame withSectionNum:(NSInteger)section {
    self = [super initWithFrame:frame];
    if (self) {
        _sectionNum = section;
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - 30, frame.size.height)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = DefaultGrayTextColor;
        
        _arrawImg = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - 13)/2 + 50, (frame.size.height - 6)/2, 13, 6)];
        _arrawImg.image= [UIImage imageNamed:@"down_arrow"];
        
        _bottomArraw = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - 12 - 30) / 2, frame.size.height - 6, 12, 6)];
        _bottomArraw.image = [UIImage imageNamed:@"bottom_up_arrow"];
        _bottomArraw.hidden = YES;
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 0.5, frame.size.width, 0.5)];
        bottomLine.backgroundColor = DefaultWhiteGrayColor;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onHandleTapGesture)];
        [self addGestureRecognizer:tap];
        
        [self addSubview:_titleLabel];
        [self addSubview:_arrawImg];
        [self addSubview:bottomLine];
        [self addSubview:_bottomArraw];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setArrowStatus:(BOOL)open {
    
    if (_title.length == 0) {
        _bottomArraw.hidden = YES;
        _arrawImg.hidden = YES;
        return;
    }
    _bottomArraw.hidden = !open;
    _arrawImg.hidden = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        _arrawImg.transform = CGAffineTransformMakeRotation(open ? M_PI : 0);
    }];
}

- (void)onHandleTapGesture {
    if (_title.length == 0) {
        return;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectDrawerItemAtSection:)]) {
        [_delegate didSelectDrawerItemAtSection:_sectionNum];
    }
}

@end

@interface HWDrawerView () <UITableViewDelegate, UITableViewDataSource, DrawerItemDelegate> {
    
    BOOL _animationFinished;
    CGFloat _maxHeight;
    
    NSMutableArray<NSMutableArray<NSString *> *> *_originalDataAry;
    NSMutableArray<NSString *> *_showDataAry;
    
    NSMutableArray<DrawerItem *> *_drawerItemAry;
}

@property (nonatomic) NSInteger selectedSection;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *bgView;

@end

@implementation HWDrawerView

- (instancetype)initWithFrame:(CGRect)frame
                 withDelegate:(id<HWDrawerViewDataSource,HWDrawerViewDelegate>)delegate
                withMaxHeight:(CGFloat)maxHeight
{
    self = [super initWithFrame:frame];
    if (self) {
        _delegate = delegate;
        _maxHeight = maxHeight;
        [self reloadData];
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadData {
    
    _originalDataAry = [NSMutableArray new];
    _showDataAry = [NSMutableArray new];
    
    for (NSInteger section = 0; section < [_delegate numberOfSections]; section++) {
        NSMutableArray *rowDataAry = [NSMutableArray new];
        for (NSInteger row = 0; row < [_delegate numberOfRowsInSection:section]; row++) {
            [rowDataAry addObject:[_delegate titleForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]]];
        }
        [_originalDataAry addObject:rowDataAry];
    }
    
}

- (void)initView {
    
    NSInteger sectionCount = [_delegate numberOfSections];
    CGFloat itemWidth = self.bounds.size.width / sectionCount;
    CGFloat itemHeight = self.bounds.size.height;
    
    _drawerItemAry = [NSMutableArray new];
    _selectedRows = [NSMutableArray new];
    
    for (NSInteger i = 0; i < sectionCount; i++) {
        DrawerItem *item = [[DrawerItem alloc] initWithFrame:CGRectMake(i * itemWidth, 0, itemWidth, itemHeight) withSectionNum:i];
        item.title = [[_originalDataAry objectAtIndex:i] firstObject];
        item.delegate = self;
        [self addSubview:item];
        
        [_drawerItemAry addObject:item];
        [_selectedRows addObject:@(0)];
    }
    
    for (DrawerItem *item in _drawerItemAry) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(item.frame.origin.x + item.frame.size.width, (self.bounds.size.height - SeperateLineHeight) / 2, 0.5, SeperateLineHeight)];
        line.backgroundColor = DefaultWhiteGrayColor;
        [self addSubview:line];
    }
    
}

- (void)reloadData {
    
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    
    [_bgView removeFromSuperview];
    [_tableView removeFromSuperview];
    _bgView = nil;
    _tableView = nil;
    _animationFinished = YES;
    
    _selectedSection = DefaultSelectedSection;
    [self loadData];
    [self initView];

}

#pragma mark - Public
- (void)setStatusToBeSelectedIn:(NSIndexPath *)indexPath {
     [self updateSelectedRowsWithSection:indexPath.section withIndex:indexPath.row];
}

#pragma mark - IBAction
- (void)onClickBg {
    self.selectedSection = DefaultSelectedSection;
}

#pragma mark - Animation
- (void)showDrawerTable {
    
    if (self.bgView.alpha == 0.7) {
        return;
    }
    
    _animationFinished = NO;
    
    self.tableView.alpha = 1;
    [UIView animateWithDuration:0.3 animations:^{
        self.bgView.alpha = 0.7;
        
    } completion:^(BOOL finish) {
        _animationFinished = YES;
    }];
}


- (void)hideDrawerTable {
    
    _animationFinished = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.bgView.alpha = 0;
        
    } completion:^(BOOL finish) {
        self.tableView.alpha = 0;
        _animationFinished = YES;
    }];
}

- (void)reloadDataFromSection:(NSInteger)fromSection toSection:(NSInteger)toSection {
    
    if (fromSection == DefaultSelectedSection && toSection == DefaultSelectedSection) {
        return;
    }
    
    NSMutableArray *fromIndexPath = [NSMutableArray new];
    for (NSInteger i = 0; i < (fromSection == DefaultSelectedSection ? 0 : [_originalDataAry objectAtIndex:fromSection].count); i++) {
        [fromIndexPath addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    NSMutableArray *toIndexPath = [NSMutableArray new];
    for (NSInteger i = 0; i < (toSection == DefaultSelectedSection ? 0 : [_originalDataAry objectAtIndex:toSection].count); i++) {
        [toIndexPath addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    
    
    if (toSection != DefaultSelectedSection && fromSection != DefaultSelectedSection) {
            
        [_showDataAry removeAllObjects];
        [_showDataAry addObjectsFromArray:[_originalDataAry objectAtIndex:toSection]];
        [self.tableView reloadData];
        [[_drawerItemAry objectAtIndex:fromSection] setArrowStatus:NO];
        [[_drawerItemAry objectAtIndex:toSection] setArrowStatus:YES];
        
        return;

    }
    
    [self.tableView beginUpdates];
    [_showDataAry removeAllObjects];
    
    if (toSection == DefaultSelectedSection) {
        
        [self.tableView deleteRowsAtIndexPaths:fromIndexPath withRowAnimation:UITableViewRowAnimationTop];
        [[_drawerItemAry objectAtIndex:fromSection] setArrowStatus:NO];
        
        [self hideDrawerTable];
        
    } else if (fromSection == DefaultSelectedSection) {
        
        [_showDataAry addObjectsFromArray:[_originalDataAry objectAtIndex:toSection]];
        [self.tableView insertRowsAtIndexPaths:toIndexPath withRowAnimation:UITableViewRowAnimationBottom];
        [[_drawerItemAry objectAtIndex:toSection] setArrowStatus:YES];
        
        [self showDrawerTable];
    
    }
    
    [self.tableView endUpdates];
    
}

#pragma mark - Setter && Getter
- (void)setSelectedSection:(NSInteger)toSection {
    
    if (!_animationFinished) {
        return;
    }
    
    NSInteger fromSection = _selectedSection;
    if (fromSection == toSection) {
        toSection = DefaultSelectedSection;
    }

    _selectedSection = toSection;
    [self reloadDataFromSection:fromSection toSection:toSection];
    
}

- (void)updateSelectedRowsWithSection:(NSInteger)section withIndex:(NSInteger)index {
    
    if (section >= _originalDataAry.count || index >= [_originalDataAry objectAtIndex:section].count) {
        return;
    }
    
    [_selectedRows setObject:@(index) atIndexedSubscript:section];
    [_drawerItemAry objectAtIndex:section].title = [[_originalDataAry objectAtIndex:section] objectAtIndex:index];
    
    self.selectedSection = DefaultSelectedSection;
    
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView new];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.frame = CGRectMake(0, self.frame.origin.y + self.frame.size.height, ATScreenWidth, _maxHeight);
        
        UIView *view = [[UIView alloc] initWithFrame:_tableView.bounds];
        view.backgroundColor = _tableView.backgroundColor;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickBg)];
        [view addGestureRecognizer:tap];
        _tableView.tableFooterView = view;
        
        [self.superview addSubview:_tableView];
    }
    return _tableView;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.origin.y + self.frame.size.height, ATScreenWidth, ATScreenHeight)];
        _bgView.backgroundColor = [UIColor blackColor];
        _bgView.alpha = 0;
        [self.superview insertSubview:_bgView belowSubview:self];
    }
    return _bgView;
}

#pragma mark - DrawerItem Delegate
- (void)didSelectDrawerItemAtSection:(NSInteger)section {
    self.selectedSection = section;
}

#pragma mark - TableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _showDataAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HWDrawerViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HWDrawerViewCell"];
    if (!cell) {
        cell = [[HWDrawerViewCell alloc] initFromNib];
    }
    
    BOOL isSelected = [[_selectedRows objectAtIndex:_selectedSection] integerValue] == indexPath.row;
    [cell setUITitle:[_showDataAry objectAtIndex:indexPath.row] isSelected:isSelected];
    return cell;
}

#pragma mark - TableView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < 0) {
        scrollView.contentOffset = CGPointMake(0, 0);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DrawerTableCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self updateSelectedRowsWithSection:_selectedSection withIndex:indexPath.row];
    
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectRowAtIndexPath:)]) {
        [_delegate didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
    }
    
}

@end
