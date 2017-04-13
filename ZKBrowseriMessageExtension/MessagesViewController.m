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
#import "ZTSlideViewController.h"

typedef enum : NSUInteger {
    History,
    Favorite,
} TableViewKind;
@interface MessagesViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) ZTAddressView *addV;
@property (nonatomic, strong) ButtonView *btnV;

@property (nonatomic, strong) UIImage *snapWebV;

@property (nonatomic, strong) ZTSlideViewController *slideVC;

@property (nonatomic, strong) NSMutableArray *hisArr;
@property (nonatomic, strong) NSMutableArray *favArr;

@property (nonatomic, assign) TableViewKind kind;

@end

@implementation MessagesViewController
- (UIImage *)snapWebV
{
    if(!_snapWebV){
        _snapWebV = [[UIImage alloc]init];
    }
    return _snapWebV;
}
- (NSMutableArray *)hisArr
{
    if(!_hisArr){
        _hisArr = [NSMutableArray new];
        _hisArr = [NSMutableArray arrayWithObjects:@"https://www.baidu.com",@"https://www.tencent.com", nil];
    }
    return _hisArr;
}
- (NSMutableArray *)favArr
{
    if(!_favArr){
        _favArr = [NSMutableArray new];
        _favArr = [NSMutableArray arrayWithObjects:@"https://www.youku.com",@"https://www.apusapps.com",@"https://music.163.com", nil];
    }
    return _favArr;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareViews];
    
    //默认是收藏
    self.kind = Favorite;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
#pragma mark - PrepareViews
- (void)prepareViews
{
    //    [self prepareBGV];
    [self prepareAddressView];
    [self prepareBtnView];
    [self prepareSlideView];
    [self prepareLayout];
}

- (void)prepareAddressView
{
    self.addV = [[ZTAddressView alloc]init];
    self.addV.addBar.textF.delegate = self;
    [self.view addSubview:self.addV];
    
    __weak typeof(self) Wself = self;
    self.addV.sendBtnBlock = ^(){
        //拿到这个截图
        UIGraphicsBeginImageContext(Wself.slideVC.webVC.view.frame.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [Wself.slideVC.webVC.view.layer renderInContext:context];
        UIImage *snapshotIMG = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        Wself.snapWebV = snapshotIMG;
        
        //发送消息
        [Wself requestPresentationStyle:MSMessagesAppPresentationStyleCompact];
        [Wself createMessage];
        NSLog(@"sendBtn");
    };
}
- (void)prepareBtnView
{
    __weak typeof(self) Wself = self;
    self.btnV = [[NSBundle mainBundle] loadNibNamed:@"ButtonView" owner:nil options:nil][0];
    [self.view addSubview:self.btnV];
    
    
    self.btnV.favoriteBtnBlock = ^(){
        [Wself handleFavoriteBtn];
    };
    self.btnV.historyBtnBlock = ^(){
        [Wself handleHistoryBtn];
    };
}
- (void)prepareSlideView
{
    self.slideVC = [[ZTSlideViewController alloc]init];
    [self addChildViewController:self.slideVC];
    self.slideVC.view.hidden = YES;
    [self.view addSubview:self.slideVC.view];
    
    __weak typeof(self) Wself = self;
    self.slideVC.expandedHistoryBtnBlock = ^(){
        NSLog(@"history!!");
        [Wself handleHistoryBtn];
    };
    self.slideVC.expandedFavoriteBtnBlock = ^(){
        NSLog(@"favorite!!");
        [Wself handleFavoriteBtn];
    };
    
    self.slideVC.didSelectCellBlock = ^(NSString *str){
        Wself.addV.addBar.textF.text = str;
        [Wself.addV endEditing:YES];
        Wself.slideVC.webVC.view.hidden = NO;
        [Wself.slideVC.scrollV setContentOffset:CGPointMake(Wself.slideVC.scrollV.frame.size.width, 0) animated:YES];
        Wself.addV.addBar.sendBtn.enabled = NO;
        [Wself.slideVC.webVC loadSearchContent:str complition:^{
            Wself.addV.addBar.sendBtn.enabled = YES;
        }];
    };
    
    self.slideVC.didScrollBlock = ^(){
        [Wself.addV endEditing:YES];
    };
    
    self.slideVC.webViewScrollBlock = ^(){
        [Wself.addV endEditing:YES];
    };
    
}
#pragma mark - PrepareLayout
- (void)prepareLayout
{
    [self.addV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_centerY).offset(-20);
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.8);
        make.height.mas_equalTo(35);
    }];
    
    [self.btnV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.addV.mas_centerX);
        make.top.equalTo(self.view.mas_centerY).offset(-12);
        make.width.equalTo(self.addV.mas_width);
        make.height.mas_equalTo(50);
    }];
    
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
        make.top.equalTo(self.view.mas_top).offset(100);
        make.height.mas_equalTo(50);
    }];
    
    [self.btnV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.addV.mas_centerX);
        make.top.equalTo(self.addV.mas_bottom).offset(10);
        make.width.equalTo(self.addV.mas_width);
        make.height.mas_equalTo(50);
    }];
    
    [self.slideVC.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.addV.mas_bottom).offset(10);
        make.bottom.equalTo(self.view.mas_bottom).offset(-50);
    }];
}
//
#pragma mark - Button Handler
- (void)handleHistoryBtn
{
    if (self.presentationStyle == MSMessagesAppPresentationStyleExpanded) {
        NSLog(@"His 展开情况下点击，肯定是普通切换");
        self.slideVC.listTableVC.dataArr = self.hisArr;
        self.slideVC.listTableVC.img4cell = [UIImage imageNamed:@"iM_History"];
        [self.slideVC.listTableVC.tableView reloadData];
    }else{
        NSLog(@"His 收缩情况下点击，需要展开并选择到需要的目录");
        self.kind = History;
        [self.slideVC.scrollV setContentOffset:CGPointMake(0, 0)];
        [self requestPresentationStyle:MSMessagesAppPresentationStyleExpanded];
        //让标记用的maskV一开始位移到historyBtn下方
        self.slideVC.btnV.maskV.transform = CGAffineTransformMakeTranslation(self.slideVC.btnV.historyBtn.frame.origin.x-self.slideVC.btnV.favoriteBtn.frame.origin.x, 0);
        
    }
}
- (void)handleFavoriteBtn
{
    if (self.presentationStyle == MSMessagesAppPresentationStyleExpanded) {
        NSLog(@"Fav 展开情况下点击，肯定是普通切换");
        self.slideVC.listTableVC.dataArr = self.favArr;
        self.slideVC.listTableVC.img4cell = [UIImage imageNamed:@"iM_Favorite"];
        [self.slideVC.listTableVC.tableView reloadData];
    }else{
        NSLog(@"Fav 收缩情况下点击，需要展开并选择到需要的目录");
        self.kind = Favorite;
        [self.slideVC.scrollV setContentOffset:CGPointMake(0, 0)];
        [self requestPresentationStyle:MSMessagesAppPresentationStyleExpanded];
        //标记用的maskV初始化时就放在favoriteBtn下方
        self.slideVC.btnV.maskV.transform = CGAffineTransformIdentity;
        
    }
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.slideVC.webVC.view.hidden = NO;
    [self.slideVC.scrollV setContentOffset:CGPointMake(self.slideVC.scrollV.frame.size.width, 0) animated:YES];
    [textField endEditing:YES];
    self.addV.addBar.sendBtn.enabled = NO;
    [self.slideVC.webVC loadSearchContent:textField.text complition:^{
        self.addV.addBar.sendBtn.enabled = YES;
    }];
    return YES;
}
#pragma mark - Create Message
- (void)createMessage
{
    MSMessageTemplateLayout *aLayout = [[MSMessageTemplateLayout alloc]init];
    aLayout.image = self.snapWebV;
    aLayout.imageTitle = self.slideVC.webVC.webV.title;
    
    MSMessage *message = [[MSMessage alloc]init];
    message.layout = aLayout;
    
    message.URL = self.slideVC.webVC.webV.URL;
    
    [self.activeConversation insertMessage:message completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error of sendAlter -- %@",error);
        }
    }];
    
}

#pragma mark - Conversation Handling
- (void)willBecomeActiveWithConversation:(MSConversation *)conversation
{
    
}
-(void)didBecomeActiveWithConversation:(MSConversation *)conversation {
    NSLog(@"从会话中激活");
    if (conversation.selectedMessage) {
        NSLog(@"点击消息激活");
        //如果是通过点击某条MessageExtension的消息激活的
        NSLog(@"点击消息激活时，该消息的URL是%@",conversation.selectedMessage.URL.absoluteString);
        if (conversation.selectedMessage.URL.absoluteString) {
            [self openHostAppWithParam:conversation.selectedMessage.URL.absoluteString];
        }
    }else{
        NSLog(@"普通激活");
    }
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

-(void)didTransitionToPresentationStyle:(MSMessagesAppPresentationStyle)presentationStyle {
    NSLog(@"切换style完成");
    switch (presentationStyle) {
        case MSMessagesAppPresentationStyleCompact:
            NSLog(@">>>compact状态");
            [self didCompact];
            break;
        case MSMessagesAppPresentationStyleExpanded:
            NSLog(@">>>expanded状态");
            [self didExpanded];
            break;
        default:
            break;
    }
}
- (void)willSelectMessage:(MSMessage *)message conversation:(MSConversation *)conversation
{
    
}
- (void)didSelectMessage:(MSMessage *)message conversation:(MSConversation *)conversation
{
    NSLog(@"Message的URL是 %@",message.URL.absoluteString);
    
    [self openHostAppWithParam:message.URL.absoluteString];
}

#pragma mark - Change During Conversation
//跳转
- (void)openHostAppWithParam:(NSString *)param
{
    NSLog(@"点击测试");
    NSString *urlScheme = @"zkbrowser://action=iMessage&url=";
    urlScheme = [urlScheme stringByAppendingString:param];
    NSURL *url = [NSURL URLWithString:urlScheme];
    
    [self.extensionContext openURL:url completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"跳转成功");
            [self dismiss];
        }else{
            NSLog(@"跳转失败");
        }
    }];
}
//收缩
- (void)willCompact
{
    self.btnV.hidden = YES;
    
    
    
    self.slideVC.view.hidden = YES;
    
    self.addV.hidden = YES;
    [self.addV.addBar.textF resignFirstResponder];
    self.addV.addBar.sendBtn.hidden = YES;
}
- (void)didCompact
{
    [self getCompactLayout];
    self.addV.hidden = NO;
    self.btnV.hidden = NO;
    
}
//展开
- (void)willExpanded
{
    
    self.addV.hidden = YES;
    self.btnV.hidden = YES;
    self.slideVC.view.hidden = YES;
    if (self.kind == History) {
        self.slideVC.listTableVC.dataArr = self.hisArr;
        self.slideVC.listTableVC.img4cell = [UIImage imageNamed:@"iM_History"];
        [self.slideVC.listTableVC.tableView reloadData];
    }else{
        self.slideVC.listTableVC.dataArr = self.favArr;
        self.slideVC.listTableVC.img4cell = [UIImage imageNamed:@"iM_Favorite"];
        [self.slideVC.listTableVC.tableView reloadData];
    }
}
- (void)didExpanded
{
    [self getExpandedLayout];
    
    [self.addV.addBar.textF becomeFirstResponder];
    self.addV.hidden = NO;
    self.addV.addBar.sendBtn.hidden = NO;
    
    self.slideVC.view.hidden = NO;
    [self.slideVC.view layoutSubviews];
}

- (void)hideAll
{
    self.btnV.hidden = YES;
    self.addV.hidden = YES;
    self.slideVC.view.hidden = YES;
}

- (void)showAll
{
    self.btnV.hidden = NO;
    self.addV.hidden = NO;
    
    self.slideVC.view.hidden = NO;
}

@end
