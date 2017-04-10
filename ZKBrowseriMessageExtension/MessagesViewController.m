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

@interface MessagesViewController ()

@property (nonatomic, strong) ZTAddressView *addV;

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
    self.addV = [[ZTAddressView alloc]init];
    [self.view addSubview:self.addV];
    
    
    [self prepareLayout];
}
- (void)prepareLayout
{
    [self.addV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.view.mas_centerY);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.8);
        make.height.mas_equalTo(50);
    }];
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
            NSLog(@">>>compact状态");
            break;
        case MSMessagesAppPresentationStyleExpanded:
            NSLog(@">>>expanded状态");
            
            break;
        default:
            break;
    }
}

-(void)didTransitionToPresentationStyle:(MSMessagesAppPresentationStyle)presentationStyle {
    NSLog(@"切换style完成");
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
