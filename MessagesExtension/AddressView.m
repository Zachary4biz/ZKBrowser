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
        _urlTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _urlTextField.placeholder = @"Search or Type URL";
        _urlTextField.returnKeyType = UIReturnKeySearch;
        _urlTextField.delegate = self;
        [self addSubview:_urlTextField];
        
        _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareBtn addTarget:self
                      action:@selector(clickShareBtn)
            forControlEvents:UIControlEventTouchUpInside];
        [_shareBtn setImage:[UIImage imageNamed:@"Share"]
                              forState:UIControlStateNormal];
        [self addSubview:_shareBtn];
        
        //功能按钮
        _functionalBtn = [[UIButton alloc]init];
        [_functionalBtn setImage:[UIImage imageNamed:FunctionalTypeStr[aFunctionType]]
                        forState:UIControlStateNormal];
        [_functionalBtn addTarget:self
                             action:@selector(clickFunctionalBtn)
                   forControlEvents:UIControlEventTouchUpInside];
        _functionalBtn.hidden = YES;
        [self addSubview:_functionalBtn];
        
        [self setUpUIConstraints];
    }
    return self;
}
//设置约束
static CGFloat WandH4searchEngineBtn = 22.0;
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
    //最右分享按钮
    [_shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.left.equalTo(self.mas_right);
        make.height.mas_equalTo(WandH4searchEngineBtn);
        make.width.mas_equalTo(WandH4searchEngineBtn);
    }];
    //右边功能按钮
    [_functionalBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.right.equalTo(self.shareBtn.mas_left).offset(-8);
        make.width.mas_equalTo(WandH4searchEngineBtn);
        make.height.mas_equalTo(WandH4searchEngineBtn);
        
    }];
    //中间输入URL或者搜索内容
    [_urlTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.bottom.equalTo(self.mas_bottom).mas_offset(3);
        make.left.equalTo(self.searchEngineBtn.mas_right).offset(5);
        make.right.equalTo(self.functionalBtn.mas_left).offset(-3);
    }];


}

- (void)showall:(BOOL)all
{
    if (all) {
        [self.shareBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_right).offset(-8-WandH4searchEngineBtn);
        }];
    }else{
        [self.shareBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_right);
        }];
    }

}

#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
//    if (self.textFieldBeginEditingBlock) {
//        self.textFieldBeginEditingBlock(nil);
//    }
}
//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    //开始编辑时，按钮变成“清除”状态
//    [self.refreshAndDeleteBtn setImage:[UIImage imageNamed:@"DeleteBtn"] forState:UIControlStateNormal];
//    self.refreshAndDeleteBtn.ZKDescription = @"Delete";
//}
//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    //结束编辑后，按钮变成“刷新”状态
//    [self.refreshAndDeleteBtn setImage:[UIImage imageNamed:@"RefreshBtn"] forState:UIControlStateNormal];
//    self.refreshAndDeleteBtn.ZKDescription = @"Refresh";
//    if (self.urlTextFieldEndEditingBlock) {
//        self.urlTextFieldEndEditingBlock();
//    }
//    
//}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.textFieldRetrunBlock(textField.text);
    [self.urlTextField resignFirstResponder];
    return NO;
}

#pragma mark 响应
- (void)clickSearchEngineBtn
{
    if(self.clickSearchEngineBtnBlock){
        self.clickSearchEngineBtnBlock(nil);
    }
    
}
- (void)clickFunctionalBtn
{
    if (self.clickFunctionalBtnBlock) {
        self.clickFunctionalBtnBlock(nil);
    }
}
- (void)clickShareBtn
{
    if (self.clickShareBtnBlock) {
        self.clickShareBtnBlock(nil);
    }
    
}
@end
