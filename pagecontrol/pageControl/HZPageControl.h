//
//  HZPageControl.h
//  pagecontrol
//
//  Created by huangzhenyu on 2018/6/22.
//  Copyright © 2018年 huangzhenyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HZPageControl : UIView
- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray<NSString *> *)titles;
@property (nonatomic,strong) NSArray *titles;
@property (nonatomic,assign) CGFloat leftSpace;//最左侧间距，可以设置负值
@property (nonatomic,assign) CGFloat rightSpace;//最右侧间距，可以设置负值
@property (nonatomic,assign) CGFloat itemSpace;//item之间的间距,内部间距（不包括最左边和最右边） 可以设置负值

@property (strong, nonatomic) NSDictionary *normalAttributes;
@property (strong, nonatomic) NSDictionary *selectedAttributes;

@property(nonatomic,copy)  void (^indexChangeBlock)(NSUInteger index);//点击item调用这个block
- (void)setSelectedIndex:(NSUInteger)index;

@end
