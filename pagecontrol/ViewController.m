//
//  ViewController.m
//  pagecontrol
//
//  Created by huangzhenyu on 2018/6/22.
//  Copyright © 2018年 huangzhenyu. All rights reserved.
//

#import "ViewController.h"
#import "ZWVerticalAlignLabel.h"
#import "HZPageControl.h"
#define HZPageControlColor(c) [UIColor colorWithRed:((c>>16)&0xFF)/255.0 green:((c>>8)&0xFF)/255.0 blue:(c&0xFF)/255.0 alpha:1.0]

@interface ViewController ()<UIScrollViewDelegate>
@property (nonatomic,strong) HZPageControl *control;
@property (nonatomic,strong) UIScrollView *scrollview;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _control = [[HZPageControl alloc] initWithFrame:CGRectMake(0, 200, 300, 40) titles:@[@"案例",@"收藏",@"下载"]];
    __weak typeof(self) weakSelf = self;
    _control.indexChangeBlock = ^(NSUInteger index){
        [weakSelf.scrollview scrollRectToVisible:CGRectMake(300 * index, 0, 300, 200) animated:YES];
    };
    _control.titles = @[@"下载",@"下载",@"下载"];
    _control.backgroundColor = [UIColor yellowColor];
    _control.leftSpace = 20;
    _control.rightSpace = 20;
    _control.itemSpace = -5;
    _control.normalAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:18.0f],NSForegroundColorAttributeName:HZPageControlColor(0x333333)};
    _control.selectedAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:30.0f],NSForegroundColorAttributeName:HZPageControlColor(0x333333)};
    [self.view addSubview:_control];
    
    
    
    [self.view addSubview:self.scrollview];
    self.scrollview.contentSize = CGSizeMake(300 * 3, 210);
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 210)];
    [self setApperanceForLabel:label1];
    label1.text = @"Worldwide";
    [self.scrollview addSubview:label1];
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(300, 0, 300, 210)];
    [self setApperanceForLabel:label2];
    label2.text = @"Local";
    [self.scrollview addSubview:label2];
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(300 * 2, 0, 300, 210)];
    [self setApperanceForLabel:label3];
    label3.text = @"Headlines";
    [self.scrollview addSubview:label3];
}


- (UIScrollView *)scrollview{
    if (!_scrollview) {
        _scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 400, 300, 210)];
        _scrollview.pagingEnabled = YES;
        _scrollview.showsHorizontalScrollIndicator = NO;
        _scrollview.delegate = self;
    }
    return _scrollview;
}

- (void)setApperanceForLabel:(UILabel *)label {
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    label.backgroundColor = color;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:21.0f];
    label.textAlignment = NSTextAlignmentCenter;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = scrollView.contentOffset.x / pageWidth;
    [_control setSelectedIndex:page];
}

@end
