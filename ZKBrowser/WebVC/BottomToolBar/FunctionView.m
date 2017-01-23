//
//  FunctionView.m
//  ZKBrowser
//
//  Created by 周桐 on 16/12/23.
//  Copyright © 2016年 周桐. All rights reserved.
//

#import "FunctionView.h"
#import "Masonry.h"
@implementation FunctionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
static CGFloat buttonWidth = 0;
static CGFloat buttonHeight = 0;
- (instancetype)initWithFrame:(CGRect)aFrame
{
    if (self = [super initWithFrame:aFrame]) {
  
        
        self.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        buttonWidth = aFrame.size.width/5;
        buttonHeight = aFrame.size.height;
        
        self.leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.leftBtn addTarget:self action:@selector(clickLeftBtn) forControlEvents:UIControlEventTouchUpInside];
        self.leftBtn.imageEdgeInsets = UIEdgeInsetsMake(0,(buttonWidth-30)/2, 0, (buttonWidth-30)/2);
        [self.leftBtn setImage:[UIImage imageNamed:@"LeftBtn"] forState:UIControlStateNormal];
        //初始情况不能点按
        self.leftBtn.enabled = NO;
        [self addSubview:_leftBtn];
        
        self.rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.rightBtn addTarget:self action:@selector(clickRightBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.rightBtn setImage:[UIImage imageNamed:@"RightBtn"] forState:UIControlStateNormal];
        //初始情况不能点按
        self.rightBtn.enabled = NO;
        [self addSubview:_rightBtn];
        
        self.HomePageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.HomePageBtn addTarget:self action:@selector(clickHomePageBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.HomePageBtn setImage:[UIImage imageNamed:@"HomePage"] forState:UIControlStateNormal];
        [self addSubview:_HomePageBtn];
        
        self.PagesBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.PagesBtn addTarget:self action:@selector(clickPagesBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.PagesBtn setImage:[UIImage imageNamed:@"PagesBtn"] forState:UIControlStateNormal];
        [self addSubview:_PagesBtn];
        
        self.SettingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.SettingBtn addTarget:self action:@selector(clickSettingBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.SettingBtn setImage:[UIImage imageNamed:@"SettingBtn"] forState:UIControlStateNormal];
        [self addSubview:_SettingBtn];
        
        [self setUpUIConstraints];
    }
    return self;
}

//设置约束
- (void)setUpUIConstraints
{
    //左按钮（返回）
    [self.leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(self.mas_top);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(buttonHeight);
    }];
    //右按钮
    [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftBtn.mas_right);
        make.top.mas_equalTo(self.mas_top);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(buttonHeight);
    }];
    //主页按钮
    [self.HomePageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.rightBtn.mas_right);
        make.top.mas_equalTo(self.mas_top);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(buttonHeight);
    }];
    //页面按钮
    [self.PagesBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.HomePageBtn.mas_right);
        make.top.mas_equalTo(self.mas_top);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(buttonHeight);
    }];
    //设置按钮
    [self.SettingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.PagesBtn.mas_right);
        make.top.equalTo(self.mas_top);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(buttonHeight);
    }];
}
#pragma mark 响应
- (void)clickLeftBtn
{
    if (self.clickLeftBtnBlock) {
        self.clickLeftBtnBlock();
    }
}

- (void)clickRightBtn
{
    if (self.clickRightBtnBlock) {
        self.clickRightBtnBlock();
    }
}

- (void)clickHomePageBtn
{
    if (self.clickHomePageBtnBlock) {
        self.clickHomePageBtnBlock();
    }
}

- (void)clickPagesBtn
{
    if (self.clickPagesBtnBlock) {
        self.clickPagesBtnBlock();
    }
}
- (void)clickSettingBtn
{
    if (self.clickSettingBtnBlock) {
        self.clickSettingBtnBlock();
    }
}
@end
