//
//  HZPageControl.m
//  pagecontrol
//
//  Created by huangzhenyu on 2018/6/22.
//  Copyright © 2018年 huangzhenyu. All rights reserved.
//

#import "HZPageControl.h"
#import "ZWVerticalAlignLabel.h"

#define HZPageControlColor(c) [UIColor colorWithRed:((c>>16)&0xFF)/255.0 green:((c>>8)&0xFF)/255.0 blue:(c&0xFF)/255.0 alpha:1.0]

@interface HZPageControl()<UIScrollViewDelegate>
@property (nonatomic,strong) UIScrollView *scrollview;
@property (nonatomic,assign) CGSize scrollviewSize;//scrollView的size
//@property (nonatomic,assign) CGSize scrollViewContentSize;

@property (nonatomic,assign) NSUInteger selectIndex;
@property (nonatomic,assign) NSUInteger preSelectIndex;
@property (nonatomic,strong) NSMutableArray *itemsArray;

@end

@implementation HZPageControl
- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray<NSString *> *)titles{
    if (self = [super initWithFrame:frame]) {
        _scrollviewSize = frame.size;
        _titles = titles;
        [self initUI];
    }
    return self;
}

- (void)initUI{
    //初始化
    self.itemSpace = 2;
    self.leftSpace = 40;
    self.rightSpace = 40;
    self.preSelectIndex = 0;
    self.selectIndex = 0;
    self.normalAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:18.0f],NSForegroundColorAttributeName:HZPageControlColor(0x333333)};
    self.selectedAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:30.0f],NSForegroundColorAttributeName:HZPageControlColor(0x3ebd6e)};
    
    [self addSubview:self.scrollview];
    [self addItemsWithTitles:self.titles];
}

- (void)removeAllItems{
    self.selectIndex = 0;
    self.preSelectIndex = 0;
    NSArray *tempArr = [self.itemsArray copy];
    for (UILabel *label in tempArr) {
        [label removeFromSuperview];
        [self.itemsArray removeObject:label];
    }
}

- (void)addItemsWithTitles:(NSArray<NSString *> *)titles{
    if (!titles || titles.count == 0) {
        return;
    }
    for (int i = 0; i < titles.count; i++) {
        ZWVerticalAlignLabel *label = [[ZWVerticalAlignLabel alloc] init];
//        label.backgroundColor = [UIColor redColor];
        label.tag = i;
        //文字底部对齐
        [label textAlign:^(ZWMaker *make) {
            make.addAlignType(textAlignType_bottom).addAlignType(textAlignType_center);
        }];
        label.textColor = self.normalAttributes[NSForegroundColorAttributeName];
        label.font = self.normalAttributes[NSFontAttributeName];
        label.text = titles[i];
        label.userInteractionEnabled = YES;
        //添加点击事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapItem:)];
        [label addGestureRecognizer:tap];
        [self.itemsArray addObject:label];
        [self.scrollview addSubview:label];
    }
    [self updateFrames];
    [self convertAttribute];
}

- (void)updateFrames{
    if (self.itemsArray.count == 0) {
        return;
    }
    self.scrollview.frame = CGRectMake(0, 0, self.scrollviewSize.width, self.scrollviewSize.height);
    //计算字体宽度
    NSMutableArray *labelWidthArr = [NSMutableArray array];
    CGFloat totalTitlesWidth = 0;
    CGFloat selectWidth = 0;
    CGFloat normalWidth = 0;
    CGFloat width = 0;
    for (int i = 0; i < self.titles.count; i++) {
        NSString *titleStr = self.titles[i];
        //根据文字和文字属性计算label宽度 + 10
        selectWidth = [self getWidthFromText:titleStr withAttribute:self.selectedAttributes] + 2;
        normalWidth = [self getWidthFromText:titleStr withAttribute:self.normalAttributes] + 2;
        width = selectWidth >= normalWidth? selectWidth : normalWidth;
        totalTitlesWidth = totalTitlesWidth + width;
        [labelWidthArr addObject:@(width)];
    }
    
    CGFloat scrollViewContentWidth = self.itemSpace * (self.titles.count - 1) + totalTitlesWidth + self.leftSpace + self.rightSpace;
    self.scrollview.contentSize = CGSizeMake(scrollViewContentWidth, self.scrollviewSize.height);
    for (int i = 0; i < self.itemsArray.count; i++) {
        CGFloat labelWidthCount = 0;
        for (int j = 0; j < i; j++) {
            labelWidthCount = labelWidthCount + [labelWidthArr[j] floatValue];
        }
        ZWVerticalAlignLabel *label = self.itemsArray[i];
        CGFloat X = self.leftSpace + i * self.itemSpace + labelWidthCount;
        label.frame = CGRectMake(X, 0, [labelWidthArr[i] floatValue], self.scrollviewSize.height);
    }
}

- (void)updateAllItemsAttributes{
    for (int i = 0; i < self.itemsArray.count; i++) {
        ZWVerticalAlignLabel *label = self.itemsArray[i];
        label.textColor = self.normalAttributes[NSForegroundColorAttributeName];
        label.font = self.normalAttributes[NSFontAttributeName];
    }
}

- (void)tapItem:(UITapGestureRecognizer *)sender{
    ZWVerticalAlignLabel *label = (ZWVerticalAlignLabel *)sender.view;
//    self.preSelectIndex = self.selectIndex;
//    self.selectIndex = label.tag;
//    NSLog(@"当前 %lu -- 旧的 %lu",(unsigned long)self.selectIndex,(unsigned long)self.preSelectIndex);
//    [self convertAttribute];
    [self setSelectedIndex:label.tag];
    if (self.indexChangeBlock) {
        self.indexChangeBlock(label.tag);
    }
}

#pragma mark getter setter
- (UIScrollView *)scrollview{
    if (!_scrollview) {
        _scrollview = [[UIScrollView alloc] init];
        _scrollview.showsHorizontalScrollIndicator = NO;
        _scrollview.delegate = self;
    }
    return _scrollview;
}

- (NSMutableArray *)itemsArray{
    if (!_itemsArray) {
        _itemsArray = [NSMutableArray arrayWithCapacity:3];
    }
    return _itemsArray;
}

- (void)setTitles:(NSArray *)titles{
    _titles = titles;
    [self removeAllItems];
    [self addItemsWithTitles:self.titles];
}

- (void)setItemSpace:(CGFloat)itemSpace{
    _itemSpace = itemSpace;
    [self updateFrames];
}

- (void)setNormalAttributes:(NSDictionary *)normalAttributes{
    _normalAttributes = normalAttributes;
    [self updateAllItemsAttributes];
    [self updateFrames];
    [self convertAttribute];
}

- (void)setSelectedAttributes:(NSDictionary *)selectedAttributes{
    _selectedAttributes = selectedAttributes;
    //计算文字宽度
    [self updateAllItemsAttributes];
    [self updateFrames];
    [self convertAttribute];
}

#pragma mark private methods
//item之间属性切换
- (void)convertAttribute{
    if (self.itemsArray.count == 0) {
        return;
    }
    ZWVerticalAlignLabel *prelabel = self.itemsArray[self.preSelectIndex];
    ZWVerticalAlignLabel *currentLabel = self.itemsArray[self.selectIndex];
    
    if (_selectIndex != _preSelectIndex) {
        prelabel.textColor = self.normalAttributes[NSForegroundColorAttributeName];
        prelabel.font = self.normalAttributes[NSFontAttributeName];
        currentLabel.textColor = self.selectedAttributes[NSForegroundColorAttributeName];
        currentLabel.font = self.selectedAttributes[NSFontAttributeName];
    } else {
        currentLabel.textColor = self.selectedAttributes[NSForegroundColorAttributeName];
        currentLabel.font = self.selectedAttributes[NSFontAttributeName];
    }
}

/**
 获取给定字符串、给定字体大小、预估宽高、获取实际宽度
 @param text 要计算的字符串
 @return 返回计算后实际尺寸宽、高度
 */
- (CGFloat)getWidthFromText:(NSString *)text withAttribute:(NSDictionary *)attribute{
    if (!text) {
        return 0;
    }
    CGRect rect = [text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil];
    //宽度
    return ceil(rect.size.width);
}

#pragma mark public methods
- (void)setSelectedIndex:(NSUInteger)index{
    if (index > (self.itemsArray.count - 1)) {
        return;
    }
    self.preSelectIndex = self.selectIndex;
    self.selectIndex = index;
    [self convertAttribute];
    ZWVerticalAlignLabel *label = self.itemsArray[index];
    CGFloat scrollCenterX = self.scrollview.center.x;
    CGFloat labelcenterX = label.center.x;
    //计算scrollView可能的最大偏移量
    CGFloat maxOffset = self.scrollview.contentSize.width - self.scrollview.frame.size.width;
    if (maxOffset <= 0) {
        return;
    }
    CGFloat offset = labelcenterX - scrollCenterX;
    offset = offset <= 0?0 : offset;
    offset = offset >= maxOffset?maxOffset : offset;
    [_scrollview setContentOffset:CGPointMake(offset, 0) animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"offset : %f",scrollView.contentOffset.x);
}

@end
