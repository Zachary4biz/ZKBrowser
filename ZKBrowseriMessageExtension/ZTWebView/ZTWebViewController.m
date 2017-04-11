//
//  ZTWebViewController.m
//  ZKBrowser
//
//  Created by Zac on 2017/4/11.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import "ZTWebViewController.h"
#import "Masonry.h"
#import "ZTDetection.h"

@interface ZTWebViewController ()<WKUIDelegate,WKNavigationDelegate>

@property (nonatomic, strong) UIProgressView *progressV;

@property (nonatomic, copy) void (^finishBlock)();

@end

@implementation ZTWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareViews];
}

- (void)prepareViews
{
    [self prepareWebView];
    [self prepareLayout];
}
- (void)prepareWebView
{
    self.webV = [[WKWebView alloc]initWithFrame:CGRectZero configuration:[[WKWebViewConfiguration alloc]init]];
    self.webV.UIDelegate = self;
    self.webV.navigationDelegate = self;
    [self.view addSubview:self.webV];
    
}

- (void)prepareLayout
{
    [self.webV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.view.mas_top);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
}

- (void)loadSearchContent:(NSString *)str complition:(void (^)())complitionBlock
{
    NSURLRequest *req = [ZTDetection detectReqeuestFromString:str];
    [self.webV loadRequest:req];
    self.finishBlock = complitionBlock;
}



#pragma mark - WKUIDelegate
//JS方面要直接弹窗的
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:webView.title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }];
    [alertVC addAction:ok];
    [self presentViewController:alertVC animated:YES completion:nil];
}
//JS方面要弹出一个带有确定或取消这种做选择的弹窗
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:webView.title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }];
    UIAlertAction *no = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }];
    [alertVC addAction:no];
    [alertVC addAction:yes];
    [self presentViewController:alertVC animated:yes completion:nil];
}
//JS方面弹出需要输入的窗口
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:webView.title message:UIActivityTypeMessage preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"测试输入内容的JS";
    }];
    UIAlertAction *done = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertVC.textFields[0].text);
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        nil;
    }];
    [alertVC addAction:done];
    [alertVC addAction:cancel];
    [self presentViewController:alertVC animated:YES completion:nil];
}
#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    
}
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    if (self.finishBlock){
        self.finishBlock();
    }
}
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    
}

//接收到服务器重定向
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"接收到服务器重定向-%s",__func__);
    NSLog(@"**********************，URL被重定向了");
    
}
//进程被终止的回调
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    NSLog(@"进程被终止的回调--%s",__func__);
}

//接收响应后决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    decisionHandler(WKNavigationResponsePolicyAllow);
    
}
//发送请求前是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    
    decisionHandler(WKNavigationActionPolicyAllow);
}
@end
