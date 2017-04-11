//
//  MessagesViewController.m
//  ZKBrowseriMessageExtension
//
//  Created by Zac on 2017/4/10.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import "MessagesViewController.h"
#import "Masonry.h"
#import "ZTAddressView.h"
#import "ButtonView.h"

@interface MessagesViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) ZTAddressView *addV;
@property (nonatomic, strong) ButtonView *btnV;



@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareViews];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Layout
- (void)prepareViews
{
    [self prepareAddressView];
    [self prepareBtnView];
    [self prepareLayout];
}
- (void)prepareLayout
{
    [self.addV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).offset(30);
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.8);
        make.height.mas_equalTo(35);
    }];
    
    [self.btnV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.addV.mas_centerX);
        make.top.equalTo(self.addV.mas_bottom).offset(0);
        make.width.equalTo(self.addV.mas_width);
        make.height.mas_equalTo(50);
    }];
}
- (void)prepareAddressView
{
    self.addV = [[ZTAddressView alloc]init];
    [self.view addSubview:self.addV];
    
    self.addV.addBar.textF.delegate = self;
}
- (void)prepareBtnView
{
    self.btnV = [[NSBundle mainBundle] loadNibNamed:@"ButtonView" owner:nil options:nil][0];
    [self.view addSubview:self.btnV];
    __weak typeof(self) Wself = self;
    self.btnV.favoriteBtnBlock = ^(){
        [Wself handleFavoriteBtn];
    };
    self.btnV.historyBtnBlock = ^(){
        [Wself handleHistoryBtn];
    };
}

//compactLayout
- (void)getCompactLayout
{
    [self prepareLayout];
}
//expandedLayout
- (void)getExpandedLayout
{
    
    [self.addV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(8);
        make.right.equalTo(self.view.mas_right).offset(-8);
        make.top.equalTo(self.view.mas_top).offset(110);
        make.height.mas_equalTo(50);
    }];
}
#pragma mark - Button Handler
- (void)handleHistoryBtn
{
    NSLog(@"his");
}
- (void)handleFavoriteBtn
{
    NSLog(@"fav");
}
#pragma mark - UITextFieldDelegate
//针对搜索栏输入框，点击时要如果是compact，需要展开为expanded模式
//重点在于，必须要返回NO，因为切换模式后相当于modal了一个新视图，会遮住之前的键盘
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.presentationStyle==MSMessagesAppPresentationStyleExpanded) {
        return YES;
    }else{
        [self requestPresentationStyle:MSMessagesAppPresentationStyleExpanded];
        return NO;
    }
}


#pragma mark - Conversation Handling

-(void)didBecomeActiveWithConversation:(MSConversation *)conversation {
    NSLog(@"从会话中激活");
}

-(void)willResignActiveWithConversation:(MSConversation *)conversation {
    NSLog(@"ResignActive");
}

-(void)didReceiveMessage:(MSMessage *)message conversation:(MSConversation *)conversation {
    NSLog(@"收到消息");
}

-(void)didStartSendingMessage:(MSMessage *)message conversation:(MSConversation *)conversation {
    NSLog(@"开始发送消息");
}

-(void)didCancelSendingMessage:(MSMessage *)message conversation:(MSConversation *)conversation {
    NSLog(@"取消发送消息");
}

-(void)willTransitionToPresentationStyle:(MSMessagesAppPresentationStyle)presentationStyle {
    NSLog(@"切换style...");
    switch (presentationStyle) {
        case MSMessagesAppPresentationStyleCompact:
            NSLog(@">>>compact状态...");
            [self willCompact];
            break;
        case MSMessagesAppPresentationStyleExpanded:
            NSLog(@">>>expanded状态...");
            [self willExpanded];
            break;
        default:
            break;
    }
}
- (void)willCompact
{
    [self getCompactLayout];
    [self.addV.addBar.textF resignFirstResponder];
}
- (void)willExpanded
{
    self.addV.hidden = YES;
}
-(void)didTransitionToPresentationStyle:(MSMessagesAppPresentationStyle)presentationStyle {
    NSLog(@"切换style完成");
    switch (presentationStyle) {
        case MSMessagesAppPresentationStyleCompact:
            NSLog(@">>>compact状态");
            break;
        case MSMessagesAppPresentationStyleExpanded:
            NSLog(@">>>expanded状态");
            [self didExpanded];
            break;
        default:
            break;
    }
}
- (void)didCompact
{
    
}

- (void)didExpanded
{
    [self.addV.addBar.textF becomeFirstResponder];
    self.addV.hidden = NO;
    [self getExpandedLayout];
}

- (IBAction)tempBtn:(id)sender {
    NSLog(@"点击测试");
    NSString *urlScheme = @"zkbrowser://";
    NSURL *url = [NSURL URLWithString:urlScheme];
    
    [self.extensionContext openURL:url completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"跳转成功");
        }else{
            NSLog(@"跳转失败");
        }
    }];
}
@end
