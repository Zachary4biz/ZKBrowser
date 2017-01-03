//
//  WebVC.m
//  ZKBrowser
//
//  Created by 周桐 on 16/12/10.
//  Copyright © 2016年 周桐. All rights reserved.
//
#import "NSObject+Description.h"
#import "SetUpAboutKeyboard.h"
#import "WebVC.h"
#import "WebPagesVC.h"
#import "AddressView.h"
#import "WebView.h"
#import "FunctionView.h"
#import "PagesFunctionView.h"

@interface WebVC ()<WKNavigationDelegate,WKUIDelegate,UIScrollViewDelegate>

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
 用来展示所有网页tab的VC
 */
@property (nonatomic, strong)WebPagesVC *webPagesVC;

@property (nonatomic, strong)NSMutableArray *arr4WebPages;
@property (nonatomic, strong)NSMutableArray *arr4WebViews;

@end

@implementation WebVC

static CGFloat MaxY4AddressView = 44.0+20.0;
static CGFloat height4FunctionView = 44.0;
//懒加载数组arr4WebPages，这是用来存储所有的页面用的
- (NSMutableArray *)arr4WebPages
{
    if (!_arr4WebPages) {
        _arr4WebPages = [NSMutableArray array];
    }
    return _arr4WebPages;
}
//重写方法，顶部状态栏
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
//顶部状态栏
    [self setNeedsStatusBarAppearanceUpdate];
//弱引用
    typeof(self) __weak WeakSelf = self;
    
//地址栏
    self.addressView = [[AddressView alloc]initWithColor:[UIColor cyanColor] SearchEngine:Baidu functionaType:Favorite];
    self.addressView.clickFunctionalBtnBlock = ^(id object){
        //点击功能按钮
        NSLog(@"点击了功能键");
    };
    self.addressView.clickSearchEngineBtnBlock = ^(id object){
        //点击了搜索引擎按钮
        NSLog(@"点击了搜索引擎按钮");
    };
    self.addressView.clickRefreshAndDeleteBtnBlock = ^(id object){
        //点击了刷新（清除）按钮
        if ([WeakSelf.addressView.refreshAndDeleteBtn.ZKDescription isEqualToString:@"Refresh"]) {
            NSLog(@"点击了刷新按钮");
            [WeakSelf.webView reload];
        }else{
            NSLog(@"点击了清除按钮");
            WeakSelf.addressView.urlTextField.text = nil;
        }
    };
    
    self.addressView.textFieldRetrunBlock = ^(id object){
        //点击了键盘的返回
        NSLog(@"输入的网址是：%@",object);
        NSURLRequest *request = nil;
        if([object hasSuffix:@".com"] || [object hasSuffix:@".org"]){
            //结尾.com表示是网页
            //首先全部小写
            object = [object lowercaseString];
            if ([object hasPrefix:@"http://"] || [object hasPrefix:@"https://"]) {
                //有http开头或者https开头，直接请求
                request = [NSURLRequest requestWithURL:[NSURL URLWithString:object]
                                           cachePolicy:0
                                       timeoutInterval:1.0];
            }else{
                //没有http开头的补全一下
                NSString *urlPrefix = @"https://";
                NSString *urlStr = [urlPrefix stringByAppendingString:object];
                request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]
                                           cachePolicy:0
                                       timeoutInterval:1.0];
            }
        }else{
            //没有.com不是网页，调用搜索引擎API搜索
            NSString *PreStrBaidu = @"https://www.baidu.com/s?ie=UTF-8&wd=";
            NSString *urlStr = [PreStrBaidu stringByAppendingString:object];
            request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]
                                       cachePolicy:0
                                   timeoutInterval:1.0];
        }
        [WeakSelf.webView loadRequest:request];
    };
    
    
//网页页面
    self.webView = [self createNewWebView];
    //添加一个KVO监听
    [self.webView addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"canGoForward" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
//底部工具条
    self.functionView = [[FunctionView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.webView.frame), self.view.frame.size.width, height4FunctionView)];
    
    self.functionView.clickLeftBtnBlock = ^(){
        NSLog(@"点击了前一页按钮");
        if (WeakSelf.webView.canGoBack) {
            [WeakSelf.webView goBack];
        }
    };
    self.functionView.clickRightBtnBlock = ^(){
        NSLog(@"点击了后一页按钮");
        if (WeakSelf.webView.canGoForward) {
            [WeakSelf.webView goForward];
        }
    };
    self.functionView.clickHomePageBtnBlock = ^(){
        NSLog(@"点击了主页按钮");
    };
    
    /**
     逻辑是进入一个新的VC--WebPagesVC，专门用来管理多个Tab用的

     @return null
     */
    self.functionView.clickPagesBtnBlock = ^(){
        NSLog(@"点击了页面按钮");
        //截图
        UIView *aSnapshotPageView = [WeakSelf takeSnapshotOf:WeakSelf.webView];
        [WeakSelf.arr4WebPages addObject:aSnapshotPageView];
        [WeakSelf.addressView removeFromSuperview];
        [WeakSelf.webView removeFromSuperview];
        
        //webPageVC部分
        [WeakSelf presentViewController:WeakSelf.webPagesVC animated:NO completion:^{
            NSLog(@"sucessfully opened the pages VC");
        }];
        
//        //显示所有webView的截图
//        CGFloat delta = 0.0;
//        for (UIView *aPage in WeakSelf.arr4WebPages)
//        {
//            aPage.frame = CGRectMake((self.view.frame.size.width-300)/2, 50+delta, 300, 500);
//            [WeakSelf.view addSubview:aPage];
//            delta += 10;
//        }
        
    };
    
    self.functionView.clickSettingBtnBlock = ^(){
        NSLog(@"点击了设置按钮");
    };
    
//设置键盘
    [[SetUpAboutKeyboard alloc]initWithPreparation4KeyboardWithVC:self andLiftTheViews:nil];
    
//直接初始化好WebPageVC
    self.webPagesVC = [WebPagesVC sharedInstance];
    
    //按遮挡顺序添加
    [self.view addSubview:self.addressView];
    [self.view addSubview:self.webView];
    [self.view addSubview:self.functionView];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark WKNavigationDelegate(加载状态)
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
    self.addressView.urlTextField.text = webView.URL.absoluteString;
}
//加载失败时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"加载失败时调用-%s",__func__);
}
//接收到服务器跳转请求时调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"接收到服务器跳转请求时调用-%s",__func__);
}
//接收响应后决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    decisionHandler(WKNavigationResponsePolicyAllow);
    NSLog(@"接收响应后决定是否跳转-%s",__func__);
}
//发送请求前是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    decisionHandler(WKNavigationActionPolicyAllow);
    NSLog(@"发送请求前是否跳转-%s",__func__);
}

#pragma mark WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    
}

#pragma mark UIScrollViewDelegate
static CGFloat scrollViewContentOffsetSample = 0;
//在willBeginDragging中赋值为1，表示是用户自己拖的
//因为这里初始化时webView的scrollView会自己滚一次
//没有找到为什么会自动滚动一下
//原因好像是因为内容，有内容就会导致它contentOffset变化
static int judge4UserDrag = 0;
/*
 *这里需要一个判断是否是HomePage，HomePage的滚动逻辑又不一样的
 */
static int judge4HomePage = 0;
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.webView.scrollView) {
        scrollViewContentOffsetSample = scrollView.contentOffset.y;
        judge4UserDrag = 1;
    }
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.webView.scrollView) {
        NSLog(@"scrollView.contentOffset = %@",NSStringFromCGPoint(scrollView.contentOffset));
        //加这个判断是因为1.初始化时就会滚动，用户还没有开始用手划过
        //2.因为有bounce所以会有负数，但是实际上bounce会自动弹回来的，所以没必要去处理bounce情况
        if (judge4UserDrag && scrollView.contentOffset.y>0) {
                if (scrollView.contentOffset.y>scrollViewContentOffsetSample) {
                    [UIView animateWithDuration:0.2 animations:^{
                        self.addressView.transform = CGAffineTransformMakeTranslation(0, -MaxY4AddressView);
                        self.functionView.transform = CGAffineTransformMakeTranslation(0, self.functionView.frame.size.height);
                        /*
                        self.webView.frame = CGRectMake(0,
                                                        0,
                                                        self.webView.bounds.size.width,
                                                        self.webView.bounds.size.height+MaxY4AddressView+height4FunctionView);
                         */
                    }];
                    scrollViewContentOffsetSample = scrollView.contentOffset.y;
                }else{
                    
                    [UIView animateWithDuration:0.2 animations:^{
                        self.addressView.transform = CGAffineTransformIdentity;
                        self.functionView.transform = CGAffineTransformIdentity;
                        /*
                         self.webView.frame = CGRectMake(0,
                                                         MaxY4AddressView,
                                                         self.webView.bounds.size.width,
                                                         self.view.frame.size.height - MaxY4AddressView-height4FunctionView);
                         */
                    }];
                    scrollViewContentOffsetSample = scrollView.contentOffset.y;
                    
                }

        }
    }
}

#pragma mark 自定义的一些方法
//获得一个截图
- (UIView *)takeSnapshotOf:(UIView *)aView
{
    UIView *snapshot = [aView snapshotViewAfterScreenUpdates:YES];
    snapshot.ZKDescription = self.webView.URL;
    NSLog(@"%@",snapshot.ZKDescription);
    
    return snapshot;
}
- (WebView *)createNewWebView
{
    /*
     *初始化webView时都是在HomePage，标识一下
     *原因是HomePage的scroll动画是不一样的
     */
    judge4HomePage = 1;
    WebView *aWebView =[[WebView alloc]initWithFrame:CGRectMake(0,
                                                            MaxY4AddressView,
                                                            self.view.frame.size.width,
                                                            self.view.frame.size.height - MaxY4AddressView-height4FunctionView)];
    aWebView.navigationDelegate = self;
    aWebView.UIDelegate = self;
    aWebView.scrollView.delegate = self;
    return aWebView;
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    if (object == self.webView)
    {
        if ([keyPath isEqualToString:@"canGoBack"]) {
            CFBooleanRef judgeTemp = (__bridge CFBooleanRef)([change allValues][1]);
            self.functionView.leftBtn.enabled = (judgeTemp == kCFBooleanFalse)?NO:YES;
        }else if ([keyPath isEqualToString:@"canGoForward"]){
            CFBooleanRef judgeTemp = (__bridge CFBooleanRef)([change allValues][1]);
            self.functionView.rightBtn.enabled = (judgeTemp == kCFBooleanFalse)?NO:YES;
        }else if ([keyPath isEqualToString:@"URL"]){
            NSURL *urlTemp = change[NSKeyValueChangeNewKey];
            self.addressView.urlTextField.text = urlTemp.absoluteString;
            /*
             *这里放到每次webView加载新的页面时置为0，因为每次加载新页面都会改变contentOffset，这个改变时不希望被上下两个条响应的
             *所以标记一下为0
             */
            judge4UserDrag = 0;
            //这里判断是不是HomePage，目前没有HomePage，或者说目前的主页就是空
            if (!urlTemp.absoluteString) {
                judge4HomePage = 0;
            }
        }else if ([keyPath isEqualToString:@"estimatedProgress"]){
            id estimateProgress = change[NSKeyValueChangeNewKey];
            NSLog(@"%@",estimateProgress);
            if ([estimateProgress floatValue] == 1) {
                [UIView animateWithDuration:0.2 animations:^{
                    self.webView.theProgressView.hidden = YES;
                }];
                
            }else{
                [self.webView.theProgressView setProgress:[estimateProgress floatValue] animated:YES];
            }
            
        }
    }
    
}
@end
