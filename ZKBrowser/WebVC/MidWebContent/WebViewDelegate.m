//
//  WebViewDelegate.m
//  ZKBrowser
//
//  Created by 周桐 on 17/1/6.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import "WebViewDelegate.h"
#import "NSObject+Description.h"
#import "WebVC.h"
#import "WebView.h"
#import "AddressView.h"
#import "FunctionView.h"
#import "SettingBtnView.h"
@interface WebVC ()
/**
 保存有当前所有打开的webView
 */
@property (nonatomic, strong)NSMutableArray *arr4WebViews;

/**
 中间的浏览器内容页面
 */
@property (nonatomic, strong)WebView *webView;

/**
 网页地址
 */
@property (nonatomic, strong)AddressView *addressView;
/**
 底部功能条
 */
@property (nonatomic, strong)FunctionView *functionView;
/**
 点击设置按钮弹出的view
 */
@property (nonatomic, strong)SettingBtnView *aSettingBtnView;

//在willBeginDragging中赋值为1，表示是用户自己拖的
//因为这里初始化时webView的scrollView会自己滚一次
//没有找到为什么会自动滚动一下
//原因好像是因为内容，有内容就会导致它contentOffset变化
@property (nonatomic, assign)int judge4UserDrag;

/*
 *这里需要一个判断是否是HomePage，HomePage的滚动逻辑又不一样的
 */
@property (nonatomic, assign)int judge4HomePage;

@end
static CGFloat MaxY4AddressView = 44.0+20.0;
static CGFloat Height4FunctionView = 44.0;
@interface WebViewDelegate ()

/**
 为了处理scrollView滚动提前算好webView的滚动->隐藏上下栏->改变后的frame
 */
@property (nonatomic, assign)CGRect originalFrame;
@property (nonatomic, assign)CGRect newFrame;
@end

@implementation WebViewDelegate


- (instancetype)init
{
    if (self = [super init]) {
        self.originalFrame = CGRectMake(0, MaxY4AddressView, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - MaxY4AddressView - Height4FunctionView);
        self.newFrame = CGRectMake(0, 20.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 20.0);
        NSLog(@"---------- 原始frame是 %@",NSStringFromCGRect(self.originalFrame));
        NSLog(@"---------- 新的frame是 %@",NSStringFromCGRect(self.newFrame));
    }
    return self;
}
#pragma mark - WKNavigationDelegate(加载状态)
//页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"页面开始加载时调用-%s",__func__);
}
//内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    NSLog(@"内容开始返回时调用-%s",__func__);
}
//加载结束时回调
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSLog(@"加载结束时回调-%s",__func__);
    //    self.addressView.urlTextField.text = webView.URL.absoluteString;
//    [webView evaluateJavaScript:@"document.documentElement.style.webkitUserSelect = 'none'" completionHandler:nil];
    //禁掉自带的长按弹出窗口
    [webView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout = 'none'" completionHandler:nil];
}
//加载失败时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"加载失败时调用-%s",__func__);
    NSLog(@"错误时--%@",error);
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
    
    //    NSLog(@"接收响应后决定是否跳转-%s",__func__);
    NSLog(@"有关navigatioNResponse的信息--\n 是否是主窗口:%@\n  response是:%@\n  是否显示MIMEType:%@",
          navigationResponse.forMainFrame?@"YES":@"NO",
          navigationResponse.response,
          navigationResponse.canShowMIMEType?@"YES":@"NO");
    
}
//发送请求前是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    
    //    NSLog(@"发送请求前是否跳转-%s",__func__);
    NSLog(@"有关navigationAction的信息--------------\ntargetframe窗口的:\n  mainFrame:%@,\n  request:%@,\n  securityOrigin:%@",
          navigationAction.targetFrame.mainFrame?@"YES":@"NO",
          navigationAction.targetFrame.request,
          navigationAction.targetFrame.securityOrigin);
    NSLog(@"\nsourceframe窗口的:\n mainFrame:%@,\n request:%@,\n  securityOrigin:%@",
          navigationAction.sourceFrame.mainFrame?@"YES":@"NO",
          navigationAction.sourceFrame.request,
          navigationAction.sourceFrame.securityOrigin);
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - WKUIDelegate
//开启新的frame时创建新窗口的回调
-(nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    NSLog(@"进入了创建新窗口的回调");
    NSLog(@"*********************");
    [self.targetVC.webView loadRequest:navigationAction.request];
    
//    WebView *aWebView = [self.targetVC createNewNormalWebView];
//    aWebView.ZKDescription = @"经过createWebView回调打开的页面";
//    [self.targetVC.webView removeFromSuperview];
//    self.targetVC.webView = aWebView;
//    [self.targetVC.view insertSubview:self.targetVC.webView belowSubview:self.targetVC.addressView];
//    return aWebView;
    return NULL;
}
//webview关闭时的回调
- (void)webViewDidClose:(WKWebView *)webView
{
    NSLog(@"webView关闭时的回调--%s",__func__);
}
//JS方面要直接弹窗的
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:webView.title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }];
    [alertVC addAction:ok];
    [self.targetVC presentViewController:alertVC animated:YES completion:nil];
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
    [self.targetVC presentViewController:alertVC animated:yes completion:nil];
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
    [self.targetVC presentViewController:alertVC animated:YES completion:nil];
}
#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSLog(@"name--%@",message.name);
    NSLog(@"body--%@",message.body);
    NSLog(@"webview--%@",message.webView);
    NSLog(@"framInfo--%@",message.frameInfo);
    if ([message.name isEqualToString:@"contextMenuMessageHandler"]) {
        NSDictionary *aDic = message.body;
        NSLog(@"aDic -- %@",aDic);
        
        /*
        NSString *className = aDic[@"className"];
        NSString *functionName = aDic[@"functionName"];
        NSLog(@"类名key-className-%@",className);
        NSLog(@"函数名key-functionName-%@",functionName);
        id anInstance;
        if([[NSClassFromString(className) alloc] init]){
            //创建一个新的实例
            anInstance = [[NSClassFromString(className) alloc] init];
            if ([anInstance respondsToSelector:NSSelectorFromString(functionName)]) {
                [anInstance performSelector:NSSelectorFromString(functionName)];
            }else{
                NSLog(@"方法--%@--未找到",functionName);
            }
        }else{
            NSLog(@"类--%@--未找到",className);
        }
        */
        
    }
    
}

#pragma mark - UIScrollViewDelegate
static CGFloat scrollViewContentOffsetSample = 0;

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.targetVC.webView.scrollView) {
        scrollViewContentOffsetSample = scrollView.contentOffset.y;
        self.targetVC.judge4UserDrag = 1;
    }
    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == self.targetVC.webView.scrollView && scrollView.contentOffset.y > scrollView.contentSize.height - self.newFrame.size.height && scrollView.contentSize.height <= scrollView.frame.size.height && !scrollView.zooming) {
        if (scrollView.contentOffset.y >= scrollViewContentOffsetSample)
        {
            NSLog(@"==================>手指上划");
            [UIView animateWithDuration:0.2 animations:^{
                self.targetVC.addressView.transform = CGAffineTransformMakeTranslation(0, -MaxY4AddressView);
                self.targetVC.functionView.transform = CGAffineTransformMakeTranslation(0, self.targetVC.functionView.frame.size.height);
                self.targetVC.webView.frame = self.newFrame;
            }completion:^(BOOL finished) {
                
            }];
        }else{
            [UIView animateWithDuration:0.2 animations:^{
                self.targetVC.addressView.transform = CGAffineTransformIdentity;
                self.targetVC.functionView.transform = CGAffineTransformIdentity;
                self.targetVC.webView.frame = self.originalFrame;
            }];
            NSLog(@"==================>手指下划");
        }
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //想要通过JS获取一下所有input标签
    //    [self.webView evaluateJavaScript:@"var arr = document.getElementsByTagName('input');return arr" completionHandler:^(id _Nullable object, NSError * _Nullable error) {
    //        if (error) {
    //            NSLog(@"%@", error);
    //        }else{
    //            NSLog(@"%@",object);
    //        }
    //    }];
//    NSLog(@"开始滚动");
    self.targetVC.aSettingBtnView.transform = CGAffineTransformIdentity;
    self.targetVC.aSettingBtnView.hidden = YES;
    

    
    if (scrollView == self.targetVC.webView.scrollView) {
        //        NSLog(@"scrollView.contentOffset = %@",NSStringFromCGPoint(scrollView.contentOffset));
        //加这个判断是因为1.初始化时就会滚动，用户还没有开始用手划过
        //2.因为有bounce所以会有负数，但是实际上bounce会自动弹回来的，所以没必要去处理bounce情况
//        NSLog(@"滚动的offset -- %lf",scrollView.contentOffset.y);

        if (self.targetVC.judge4UserDrag && scrollView.contentOffset.y>0 && scrollView.contentOffset.y <= scrollView.contentSize.height - self.newFrame.size.height && scrollView.contentSize.height > scrollView.frame.size.height && !scrollView.zooming) {
            if (scrollView.contentOffset.y>scrollViewContentOffsetSample) {
                //手指上移滚动，offset变大，页面展示更下方的内容
                [UIView animateWithDuration:0.2 animations:^{
                    self.targetVC.addressView.transform = CGAffineTransformMakeTranslation(0, -MaxY4AddressView);
                    self.targetVC.functionView.transform = CGAffineTransformMakeTranslation(0, self.targetVC.functionView.frame.size.height);
                    self.targetVC.webView.frame = self.newFrame;
                }completion:^(BOOL finished) {
                    
                }];
                scrollViewContentOffsetSample = scrollView.contentOffset.y;
            }else{
                
                [UIView animateWithDuration:0.2 animations:^{
                    self.targetVC.addressView.transform = CGAffineTransformIdentity;
                    self.targetVC.functionView.transform = CGAffineTransformIdentity;
                    self.targetVC.webView.frame = self.originalFrame;
                }];
                scrollViewContentOffsetSample = scrollView.contentOffset.y;
                
            }
            
        }

    }
}
@end
