//
//  PagesFunctionView.m
//  ZKBrowser
//
//  Created by 周桐 on 16/12/24.
//  Copyright © 2016年 周桐. All rights reserved.
//

#import "PagesFunctionView.h"
#import "Masonry.h"
@implementation PagesFunctionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.privateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.privateBtn addTarget:self action:@selector(clickPrivateBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.privateBtn setImage:[UIImage imageNamed:@"PrivateBtn"] forState:UIControlStateNormal];
        [self addSubview:self.privateBtn];
        
        self.createPageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.createPageBtn addTarget:self action:@selector(clickCreatePageBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.createPageBtn setImage:[UIImage imageNamed:@"CreatePageBtn"] forState:UIControlStateNormal];
        [self addSubview:self.createPageBtn];
        
        self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.backBtn addTarget:self action:@selector(clickBackBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.backBtn setImage:[UIImage imageNamed:@"BackBtn"] forState:UIControlStateNormal];
        [self addSubview:self.backBtn];
        
        [self setUpUIConstraint];
    }
    return self;
}

static CGFloat buttonWandH = 30.0;
- (void)setUpUIConstraint
{
    [self.privateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.top.equalTo(self.mas_top).offset(8);
        make.width.mas_equalTo(buttonWandH);
        make.height.mas_equalTo(buttonWandH);
    }];
    [self.createPageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.mas_top).offset(8);
        make.width.mas_equalTo(buttonWandH);
        make.height.mas_equalTo(buttonWandH);
    }];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right);
        make.top.equalTo(self.mas_top).offset(8);
        make.width.mas_equalTo(buttonWandH);
        make.height.mas_equalTo(buttonWandH);
    }];
}

- (void)clickPrivateBtn
{
    if (self.clickPrivateBtnBlock) {
        self.clickPrivateBtnBlock();
    }
}
- (void)clickCreatePageBtn
{
    if (self.clickCreatePageBtnBlock) {
        self.clickCreatePageBtnBlock();
    }
}
- (void)clickBackBtn
{
    if (self.clickBackBtnBlock) {
        self.clickBackBtnBlock();
    }
}
@end
