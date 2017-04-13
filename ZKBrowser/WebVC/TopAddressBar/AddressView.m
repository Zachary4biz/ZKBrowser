//
//  AddressView.m
//  ZKBrowser
//
//  Created by 周桐 on 16/12/10.
//  Copyright © 2016年 周桐. All rights reserved.
//

#import "AddressView.h"
#import "Masonry.h"
#import "NSObject+Description.h"

@implementation AddressView
#warning 这块枚举转换字符串没有搞懂是怎么做到的，来自网络。如果放在头文件中会报编译错误
NSString *const SearchEngineTypeStr[]={
    [Bing] = @"Bing",
    [Baidu] = @"Baidu",
    [Google] = @"Google",
    [Ask] = @"Ask",
    [Naver] = @"Naver",
    [Duckduckgo] = @"Duckduckgo",
    [Yandex] = @"Yandex",
    [Yahoo] = @"Yahoo",
};
NSString *const FunctionalTypeStr[]={
    [Favorite] = @"Favorite",
    [Cancel] = @"Cancel",
};
- (instancetype)initWithColor:(UIColor *)aColor SearchEngine:(SearchEngineType)aSearchEngineType functionaType:(FunctionType)aFunctionType
{
    CGRect aFrame = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 44);
    self = [self initWithFrame:aFrame Color:aColor SearchEngine:aSearchEngineType functionaType:aFunctionType];
    return self;
}

- (instancetype)initWithFrame:(CGRect)aFrame Color:(UIColor *)aColor SearchEngine:(SearchEngineType)aSearchEngineType functionaType:(FunctionType)aFunctionType
{
    
    if (self = [super initWithFrame:aFrame]) {
        self.backgroundColor = aColor;
        //搜索引擎按钮
        _searchEngineBtn = [[UIButton alloc]init];
        [_searchEngineBtn setImage:[UIImage imageNamed:SearchEngineTypeStr[aSearchEngineType]]
                          forState:UIControlStateNormal];
        [_searchEngineBtn addTarget:self
                             action:@selector(clickSearchEngineBtn)
                   forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_searchEngineBtn];
        //地址栏
        _urlTextField = [[UITextField alloc]init];
        _urlTextField.placeholder = @"Search or Type URL";
        _urlTextField.returnKeyType = UIReturnKeySearch;
        _urlTextField.delegate = self;
        [self addSubview:_urlTextField];
        //地址栏右边刷新（清除）按钮，默认是刷新，点击输入URL时变成清除按钮
        _refreshAndDeleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        _refreshAndDeleteBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [_refreshAndDeleteBtn addTarget:self
                                 action:@selector(clickRefreshAndDeleteBtn)
                       forControlEvents:UIControlEventTouchUpInside];
        [_refreshAndDeleteBtn setImage:[UIImage imageNamed:@"RefreshBtn"]
                              forState:UIControlStateNormal];
        _refreshAndDeleteBtn.ZKDescription = @"Refresh";
        [self addSubview:_refreshAndDeleteBtn];
        
        //功能按钮
        _functionalBtn = [[UIButton alloc]init];
        [_functionalBtn setImage:[UIImage imageNamed:FunctionalTypeStr[aFunctionType]]
                        forState:UIControlStateNormal];
        [_functionalBtn addTarget:self
                             action:@selector(clickFunctionalBtn)
                   forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_functionalBtn];
        
        [self setUpUIConstraints];
    }
    return self;
}
//设置约束
static CGFloat WandH4searchEngineBtn = 30.0;
- (void)setUpUIConstraints
{
    //位置布局
    //搜索引擎按钮
    [_searchEngineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.left.equalTo(self.mas_left).offset(8);
        make.width.mas_equalTo(WandH4searchEngineBtn);
        make.height.mas_equalTo(WandH4searchEngineBtn);
    }];
    //右边功能按钮
    [_functionalBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.width.mas_equalTo(WandH4searchEngineBtn);
        make.height.mas_equalTo(WandH4searchEngineBtn);
        make.right.equalTo(self.mas_right).offset(-8);
    }];
    //中间输入URL或者搜索内容
    [_urlTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).mas_offset(3);
        make.bottom.equalTo(self.mas_bottom).mas_offset(3);
        make.left.equalTo(self.searchEngineBtn.mas_right).offset(8);
        make.right.equalTo(self.functionalBtn.mas_left).offset(-(3+WandH4searchEngineBtn));
    }];
    //textField右边的清除（刷新）按钮，默认是刷新状态，开始编辑时变成清除
    [_refreshAndDeleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.height.mas_equalTo(WandH4searchEngineBtn);
        make.left.equalTo(self.urlTextField.mas_right);
        make.right.equalTo(self.functionalBtn.mas_left);
    }];
}

#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //开始编辑时，按钮变成“清除”状态
    [self.refreshAndDeleteBtn setImage:[UIImage imageNamed:@"DeleteBtn"] forState:UIControlStateNormal];
    self.refreshAndDeleteBtn.ZKDescription = @"Delete";
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //结束编辑后，按钮变成“刷新”状态
    [self.refreshAndDeleteBtn setImage:[UIImage imageNamed:@"RefreshBtn"] forState:UIControlStateNormal];
    self.refreshAndDeleteBtn.ZKDescription = @"Refresh";
    if (self.urlTextFieldEndEditingBlock) {
        self.urlTextFieldEndEditingBlock();
    }
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.textFieldRetrunBlock(textField.text);
    [self.urlTextField endEditing:YES];
    [self.urlTextField resignFirstResponder];
    return YES;
}

#pragma mark 响应
- (void)clickSearchEngineBtn
{
    self.clickSearchEngineBtnBlock(nil);
}
- (void)clickFunctionalBtn
{
    self.clickFunctionalBtnBlock(nil);
}
- (void)clickRefreshAndDeleteBtn
{
    self.clickRefreshAndDeleteBtnBlock(nil);
}
@end
