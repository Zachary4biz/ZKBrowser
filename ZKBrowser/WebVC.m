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
#import "SettingBtnView.h"
#import "UIResponder+FindFirstResponder.h"
#import "WebViewDelegate.h"
#import "MyButton.h"
#import "SmallWebView.h"

#define DesktopUA "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_8; en-us) AppleWebKit/534.50 (KHTML, like Gecko) Version/5.1 Safari/534.50"
#define MobileUA "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_3 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8J2 Safari/6533.18.5"

@interface WebVC ()<WKNavigationDelegate,WKUIDelegate,UIScrollViewDelegate,UITextFieldDelegate>

/**
 这是用来测试一下如果在键盘弹出的过程中重新设置新的firstResponder为别的东西会怎么样
 */
@property (nonatomic, strong)UITextField *aTextField;

/**
 中间的浏览器内容页面
 */
@property (nonatomic, strong)WebView *webView;
/**
 保存有当前所有打开的webView
 */
@property (nonatomic, strong)NSMutableArray *arr4WebViews;
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


/**
 这个是在加载过程中，遮住functionView.rightBtn，让它变成一个X，表示可以取消加载
 */
@property (nonatomic, strong)UIButton *cancelBtn;

/**
 点击设置按钮弹出的view
 */
@property (nonatomic, strong)SettingBtnView *aSettingBtnView;

/**
 保存联想搜索用的数组
 */
@property (nonatomic, strong)NSMutableArray *arr4AssociativeSearch;

/**
 展示联想搜索的view
 */
@property (nonatomic, strong)UIView *view4AssociativeSearch;
@property (nonatomic, strong)UIVisualEffectView *visualView4AssociativeSearch;

/**
 把webView的代理都放到另一个文件里面统一处理
 */
@property (nonatomic, strong)WebViewDelegate *aWebViewDelegateHandler;

/**
 小窗口用的webView
 */
@property (nonatomic, strong)SmallWebView *theSmallWebView;

/**
 共用一个线程池，不用重复登录
 */
@property (nonatomic, strong)WKProcessPool *theProcessPool;

//几个判断用的
@property (nonatomic, assign)int judge4HomePage;
@property (nonatomic, assign)int judge4UserDrag;
@end

@implementation WebVC
 
static CGFloat MaxY4AddressView = 44.0+20.0;
static CGFloat height4FunctionView = 44.0;
static CGFloat height4SettingBtnView = 80.0;
//联想搜索的结果中，一行有多高
static CGFloat rowHeight4AssociativeView = 30;

//webView共用一个processPool，这样的功能有一个就是不用重复登录
- (WKProcessPool *)theProcessPool
{
    if (!_theProcessPool) {
        _theProcessPool = [[WKProcessPool alloc]init];
    }
    return _theProcessPool;
}
//处理代理的handler，这个要懒加载
//不然在A页面建了一个代理在地址0xe00，B页面又建了一个代理在8xa44这样就是两个不同的代理
- (WebViewDelegate *)aWebViewDelegateHandler
{
    if (!_aWebViewDelegateHandler) {
        _aWebViewDelegateHandler = [WebViewDelegate new];
    }
    return _aWebViewDelegateHandler;
}
//懒加载数组--用来记录所有的webView
- (NSMutableArray *)arr4WebViews
{
    if (!_arr4WebViews) {
        _arr4WebViews = [NSMutableArray array];
    }
    return _arr4WebViews;
}
//懒加载展示联想搜索的view -- self.view的subview
- (UIView *)view4AssociativeSearch
{
    if (!_view4AssociativeSearch) {
        _view4AssociativeSearch = [[UIView alloc]initWithFrame:CGRectMake(0,
                                                                          MaxY4AddressView,
                                                                          self.view.frame.size.width,
                                                                          1*rowHeight4AssociativeView)];
        _view4AssociativeSearch.backgroundColor = [UIColor clearColor];
        _visualView4AssociativeSearch = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        [_view4AssociativeSearch addSubview: _visualView4AssociativeSearch];
    }
    return _view4AssociativeSearch;
}
//懒加载aSettingBtnView -- self.view的subview
- (SettingBtnView *)aSettingBtnView
{
    if (!_aSettingBtnView) {
        _aSettingBtnView = [[SettingBtnView alloc]initWithFrame:CGRectMake(0,
                                                                           CGRectGetMaxY(self.webView.frame),
                                                                           self.view.frame.size.width,
                                                                           height4SettingBtnView)];
        //初始创建出来是hidden
        _aSettingBtnView.hidden = YES;
    }
    if ([_aSettingBtnView.ZKDescription isEqualToString:@"reseted"]) {
        //被重置过了，要根据当前这个webView重新判断一下各个按钮的状态
        if ([self.webView.customUserAgent isEqualToString:@DesktopUA]) {
            [_aSettingBtnView.DesktopBtn setImage:[UIImage imageNamed:@"DesktopBtnClicked"]
                                         forState:UIControlStateNormal];
        }else{
            [_aSettingBtnView.DesktopBtn setImage:[UIImage imageNamed:@"DesktopBtn"]
                                         forState:UIControlStateNormal];
            
        }
    }
    return _aSettingBtnView;
}
//懒加载数组arr4WebPages，这是用来存储所有的页面用的
- (NSMutableArray *)arr4WebPages
{
    if (!_arr4WebPages) {
        _arr4WebPages = [NSMutableArray array];
    }
    return _arr4WebPages;
}
//重写方法，顶部状态栏，目前没用
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

//懒加载这个cancelBtn -- self.functionView的subview
- (UIButton *)cancelBtn
{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.frame = _functionView.rightBtn.frame;
        [_cancelBtn setImage:[UIImage imageNamed:@"DeleteBtn"] forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(clickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

//懒加载webPagesVC，目的是当它被手动销毁后（nil）再次用到还能使
- (WebPagesVC *)webPagesVC
{
    if (!_webPagesVC) {
        _webPagesVC = [ WebPagesVC new];
        _webPagesVC.theWebVC = self;
        __weak typeof(self)wself = self;
        _webPagesVC.dismissBlock = ^(){
            WebVC *sself = wself;
            sself->_webPagesVC = nil;
        };
    }
    return _webPagesVC;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
//顶部状态栏
    [self setNeedsStatusBarAppearanceUpdate];
//弱引用
    typeof(self) __weak WeakSelf = self;
    
#pragma mark 地址栏addressView
    self.addressView = [[AddressView alloc]initWithColor:[UIColor colorWithWhite:0.97 alpha:1.0] SearchEngine:Baidu functionaType:Favorite];
    self.addressView.clickFunctionalBtnBlock = ^(id object){
        //点击功能按钮
        NSLog(@"点击了功能键");
        [WeakSelf.webView evaluateJavaScript:@"window.opener = null;window.open('','_self');window.close();" completionHandler:^(id _Nullable object, NSError * _Nullable error) {
            if (error) {
                NSLog(@"%@",error);
            }else{
                NSLog(@"%@",object);
            }
        }];
    };
    self.addressView.clickSearchEngineBtnBlock = ^(id object){
        //点击了搜索引擎按钮
        NSLog(@"点击了搜索引擎按钮");
        NSLog(@"arr4WebViews -- %@",WeakSelf.arr4WebViews);
        NSLog(@"当前的webVIew是--%@",WeakSelf.webView);
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
    
    self.addressView.textFieldRetrunBlock = ^(NSString *object){
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
        }else if (object.length == 0){
            NSLog(@"URL栏输入为空，即加载首页");
        }else{
            //没有.com不是网页，调用搜索引擎API搜索
            NSString *PreStrBaidu = @"https://www.baidu.com/s?ie=UTF-8&wd=";
            //考虑到有中文参数，所以需要编码
            //首先设置没有使用的特殊符号--即会被编码掉
            NSString *character2Escape = @"<>'\"*()$#@! ";
            //invertedSet 是取反， 即 除了character2Escape中的其他的字符串都是允许的，不会被编码
            NSCharacterSet *allowedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:character2Escape] invertedSet];
            object = [object stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
            
            NSString *urlStr = [PreStrBaidu stringByAppendingString:object];
            NSURL *url = [NSURL URLWithString:urlStr];
            request = [NSURLRequest requestWithURL:url
                                       cachePolicy:0
                                   timeoutInterval:1.0];
        }
        NSLog(@"最后加载的request是%@",request);
        [WeakSelf.webView loadRequest:request];
    };
#pragma mark 联想搜索
    [self.addressView.urlTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.addressView.urlTextFieldEndEditingBlock = ^(){
        [WeakSelf.view4AssociativeSearch removeFromSuperview];
    };
    
#pragma mark 网页webView
    self.webView = [self createNewWebView];
    //添加一个KVO监听，修改为在页面willAppear时添加，在willDisappear时移除
    //因为在webPagesVC中会修改sefl.webView的指针
    
//    [self addKVO2theView:self.webView];
//    [self.webView addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionNew context:nil];
//    [self.webView addObserver:self forKeyPath:@"canGoForward" options:NSKeyValueObservingOptionNew context:nil];
//    [self.webView addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew context:nil];
//    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    
#pragma mark 底部工具条functionView
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
        //NSURL *aURL = [NSURL URLWithString:@"http://127.0.0.1:8080"];
        NSURL *aURL = [NSURL URLWithString:@"http://www.baidu.com"];
        NSURLRequest *aRequest = [NSURLRequest requestWithURL:aURL];
        [WeakSelf.webView loadRequest:aRequest];
    };
    
    /**
     逻辑是进入一个新的VC--WebPagesVC，专门用来管理多个Tab用的

     @return null
     */
    self.functionView.clickPagesBtnBlock = ^(){
        NSLog(@"点击了页面按钮");
        //截图，这个截图不用接，在函数里我直接把这个截图赋给了webView当做一个属性
        //同时，还在函数中把webPagesVC的数组arr4NormalWebPages也赋值了--赋的是self.arr4WebViews
        [WeakSelf takeSnapshotOf:WeakSelf.webView];
        //webPageVC部分
        [WeakSelf presentViewController:WeakSelf.webPagesVC animated:NO completion:^{
            
        }];
    };

    self.functionView.clickSettingBtnBlock = ^(){
        NSLog(@"点击了设置按钮");
        if (CGAffineTransformIsIdentity(WeakSelf.aSettingBtnView.transform)) {
            //弹出
            WeakSelf.aSettingBtnView.hidden = NO;
            [UIView animateWithDuration:0.2
                             animations:^{
                                 WeakSelf.aSettingBtnView.transform = CGAffineTransformMakeTranslation(0, -WeakSelf.aSettingBtnView.frame.size.height);
                             }
                             completion:^(BOOL finished) {
                                 WeakSelf.functionView.SettingBtn.ZKDescription = @"AlreadyClicked";
                             }];
        }else{
            //隐藏
            [UIView animateWithDuration:0.2
                             animations:^{
                                 WeakSelf.aSettingBtnView.transform = CGAffineTransformIdentity;
                             }
                             completion:^(BOOL finished) {
                                 WeakSelf.functionView.SettingBtn.ZKDescription = nil;
                                 WeakSelf.aSettingBtnView.hidden = YES;
                             }];
        }
    };
    
#pragma mark 点击设置弹出的页面
    self.aSettingBtnView.clickDesktopBtnBlock = ^(){
        if ([WeakSelf.webView.customUserAgent  isEqual: @DesktopUA]) {
            //当前是桌面模式，切换回手机
            WeakSelf.webView.customUserAgent = @MobileUA;
            [WeakSelf.aSettingBtnView.DesktopBtn setImage:[UIImage imageNamed:@"DesktopBtn"]
                                                 forState:UIControlStateNormal];
            [WeakSelf.webView reload];
            
        }else{
            //当前是手机模式，切换回桌面
            WeakSelf.webView.customUserAgent = @DesktopUA;
            [WeakSelf.aSettingBtnView.DesktopBtn setImage:[UIImage imageNamed:@"DesktopBtnClicked"]
                                                 forState:UIControlStateNormal];
            [WeakSelf.webView reload];
        }
    };
#pragma mark 实现小窗口功能
    self.aSettingBtnView.clickMultiTabBtnBlock = ^(){
        if (!WeakSelf.aSettingBtnView.MultiTabBtn.ZKDescription) {
            //没有点击，触发多页面
            WeakSelf.aSettingBtnView.MultiTabBtn.ZKDescription = @"alreadyClicked";
            //当前页面，即当前的self.webView
            [WeakSelf createMultiWindowWithWebView:WeakSelf.webView];
            
        }else{
            //之前已经点过了，关闭多页面模式
            //之前已经打开过一个小窗口
            WeakSelf.aSettingBtnView.MultiTabBtn.ZKDescription = nil;
        }
        
    };
    
    

//设置键盘
    [[SetUpAboutKeyboard alloc]initWithPreparation4KeyboardWithVC:self andLiftTheViews:nil];
    
//直接初始化好WebPageVC
    //this situation will lead to a crash since the webPagesVC has already been pointed to nil before it's used again.
    //so i gonna create the webPagesVC only when it was called.
//    self.webPagesVC = [WebPagesVC sharedInstance];
//    self.webPagesVC.theWebVC = self;
//    self.webPagesVC.dismissBlock = ^(){
//        WeakSelf.webPagesVC = nil;
//    };
    
//按遮挡顺序添加
    [self.view addSubview:self.addressView];
    [self.view addSubview:self.webView];
    //点击设置按钮弹出的View
    [self.view addSubview:self.aSettingBtnView];
    [self.view addSubview:self.functionView];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addKVO2theView:self.webView];
    if (self.webView.URL) {
        self.addressView.urlTextField.text = self.webView.URL.absoluteString;
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeKVO4theView:self.webView];
    self.addressView.urlTextField.text = nil;
    //重新载入时 新的webView有些状态其实是发生了变化的，所以aSettingBtnView的按钮状态都要重置
    [_aSettingBtnView resetAllState];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 自定义的一些方法
//更换webView
- (void)changeWebViewWith:(WebView *)aView
{
    /*
     *这里出现的问题是 WebVC最开始的时候添加了self.webView，
     *虽然在这一步修改了self.webView的指向，但是之前那个webView没有被销毁没有被removeFromSuperView
     *导致WebVC.subViews里面还是这个老的webView，所以要做的如下
     *1.在改变WebVC的self.webView之前把它removeFromSuperView
     *2.修改self.webView
     *3.将修改后的self.webView重新添加到self.view中
     */
    [self.webView removeFromSuperview];
    self.webView = aView;
    [self.view insertSubview:self.webView belowSubview:self.addressView];
}
//制作一个小窗口webView
- (void)createMultiWindowWithWebView:(WebView *)aWebView
{
    if (self.arr4WebViews.count >1) {
        /*
         *这里不采用直接用changeWebViewWith
         *是因为在theSmallWebView中，是把它的theWebView指针=WebVC.webView指针的
         *所以如果在创建好了theSmallWebView之后----------
         *对webVC的self.webView执行removeFromSuperView的话，
         *等同于对theSmallWebView.theWebView也做removeFromSuperView，会在theSmallWebView中也移除掉
         *如果在创建好theSmallWebView之前--------------
         *changeWebViewWIth又会改变self.webView所指向的webView，这样也不行。
         */
        //1.先手移除self.webView
        [aWebView removeFromSuperview];
        
        //1.2然后把它赋给self.theSmallWebView的theWebView指针
        self.theSmallWebView = [[SmallWebView alloc]initWithFrame:CGRectMake(100, 100, 230, 400) andWebView:aWebView];
        typeof(self) __weak WeakSelf = self;
        //设置关闭按钮的响应
        self.theSmallWebView.closeBtnBlock = ^(){
            NSLog(@"关闭了小窗口");
            //恢复一下frame
            WeakSelf.theSmallWebView.theWebView.frame = WeakSelf.webView.frame;
            //恢复一下正在用作小窗口的标记
            WeakSelf.theSmallWebView.theWebView.isUsingAsSmallWebView = 0;
            //把self.webView替换为这个小窗口的webView
            [WeakSelf.webView removeFromSuperview];
            WeakSelf.webView = WeakSelf.theSmallWebView.theWebView;
            //记得重新注册KVO
            [WeakSelf addKVO2theView:WeakSelf.webView];
            
            [WeakSelf.view insertSubview:WeakSelf.webView belowSubview:WeakSelf.addressView];
            //置为nil
            WeakSelf.theSmallWebView.theWebView = nil;
            [WeakSelf.theSmallWebView removeFromSuperview];
        };
        [self.view.window addSubview:self.theSmallWebView];
        NSLog(@"%ld",[aWebView.ZKDescription integerValue]);
        
        //2.接着判断aWebView是数组self.arr4WebViews里的哪一个，
        //  然后把它前一个赋给self.webView指针
        if([aWebView.ZKDescription integerValue] >= 1){
            //0,1,2,3,4如果这个webView是1及以后的，提取小窗口之后，把self.webView变成前一个
            self.webView = self.arr4WebViews[[aWebView.ZKDescription integerValue]-1];
            [self addKVO2theView:self.webView];
            [self.view insertSubview:self.webView belowSubview:self.addressView];
            
        }else{
            self.webView = [self.arr4WebViews lastObject];
            [self addKVO2theView:self.webView];
            [self.view insertSubview:self.webView belowSubview:self.addressView];
        }
        
    }else{
        NSLog(@"当前只有一个页面，不能开启小窗口模式");
    }
}
//根据联想搜索有多少个条目，生成联想搜索展示用的view
- (void)setUpAssociativeSearchViewWithRowCount:(NSInteger)aRowCount
{
    aRowCount = aRowCount>5?5:aRowCount;
    //移除所有的子View
    [self.view4AssociativeSearch.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //依据aRowCount计算frame
    CGRect aFrameRecorder = self.view4AssociativeSearch.frame;
    //加0.6是为了多一点余地，免得刚刚好 很丑
    aFrameRecorder.size.height = (aRowCount + 0.6)*rowHeight4AssociativeView;
    self.view4AssociativeSearch.frame = aFrameRecorder;
    //更新visualEffectView的frame，并添加为subview
    self.visualView4AssociativeSearch.frame = self.view4AssociativeSearch.bounds;
    [self.view4AssociativeSearch addSubview:self.visualView4AssociativeSearch];
    for (int i=0; i<aRowCount; i++) {
        UIButton *aBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [aBtn setFrame:CGRectMake(self.addressView.urlTextField.frame.origin.x,
                                 i*rowHeight4AssociativeView,
                                 self.view4AssociativeSearch.frame.size.width,
                                  rowHeight4AssociativeView)];
        aBtn.backgroundColor = [UIColor clearColor];
        [aBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        aBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [aBtn setTitle:self.arr4AssociativeSearch[i] forState:UIControlStateNormal];
        [aBtn addTarget:self action:@selector(clickAssociativeResult:) forControlEvents:UIControlEventTouchUpInside];
        [self.view4AssociativeSearch addSubview:aBtn];
    }
}
//对应的一个让JS来调用的方法
- (void)aMethod4JS
{
    NSLog(@"让JS调用的一个OC方法，属于类WebVC--DONE!");
}
//获得一个截图
- (void)takeSnapshotOf:(WebView *)aView
{
    //拿到这个截图
    UIGraphicsBeginImageContext(aView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [aView.layer renderInContext:context];
    UIImage *snapshotIMG = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //并且把这个截图传给webView，这样就好找了，
    aView.snapShot = snapshotIMG;
    //更新pageVC里面的数组，到时候直接用webView.snapShot就找到截图了
    self.webPagesVC.arr4NormalWebPages = self.arr4WebViews;
    

    
}
//创造
- (WebView *)createNewWebView
{
    self.aWebViewDelegateHandler.targetVC = self;
    /*
     *初始化webView时都是在HomePage，标识一下
     *原因是HomePage的scroll动画是不一样的
     */
    _judge4HomePage = 1;
    
    WKWebViewConfiguration *aConfiguration = [[WKWebViewConfiguration alloc]init];
    aConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    //共用一个线程池
    aConfiguration.processPool = self.theProcessPool;
    //测试一下configuration，向这个webview 注册一个JS脚本，handler是自己self，脚本名字是@"XXX"
    [aConfiguration.userContentController addScriptMessageHandler:self.aWebViewDelegateHandler name:@"ScriptMessageHandler"];
    
    WebView *aWebView =[[WebView alloc]initWithFrame:CGRectMake(0,
                                                            MaxY4AddressView,
                                                            self.view.frame.size.width,
                                                            self.view.frame.size.height - MaxY4AddressView-height4FunctionView)
                                       configuration:aConfiguration];
    
    aWebView.navigationDelegate = self.aWebViewDelegateHandler;
    aWebView.UIDelegate = self.aWebViewDelegateHandler;
    aWebView.scrollView.delegate = self.aWebViewDelegateHandler;
    aWebView.customUserAgent = @"Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_3 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8J2 Safari/6533.18.5";
    //添加到arr里
    [self.arr4WebViews addObject:aWebView];
    //标记一下，之后小窗口模式用得上
    aWebView.ZKDescription = [NSNumber numberWithInteger:self.arr4WebViews.count-1];


    return aWebView;
}

#pragma mark - KVO
//添加KVO
- (void)addKVO2theView:(UIView *)theView
{
    [theView addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionNew context:nil];
    [theView addObserver:self forKeyPath:@"canGoForward" options:NSKeyValueObservingOptionNew context:nil];
    [theView addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew context:nil];
    [theView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}
//移除KVO
- (void)removeKVO4theView:(UIView *)theView
{
    [theView removeObserver:self forKeyPath:@"canGoBack"];
    [theView removeObserver:self forKeyPath:@"canGoForward"];
    [theView removeObserver:self forKeyPath:@"URL"];
    [theView removeObserver:self forKeyPath:@"estimatedProgress"];
}
//KVO响应监听
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
            _judge4UserDrag = 0;
            //这里判断是不是HomePage，目前没有HomePage，或者说目前的主页就是空
            if (!urlTemp.absoluteString) {
                _judge4HomePage = 0;
            }
        }else if ([keyPath isEqualToString:@"estimatedProgress"]){
            id estimateProgress = change[NSKeyValueChangeNewKey];
            NSLog(@"%@",estimateProgress);
            //一开始就加一个cancelBtn，它的frame和rightBtn相同，所以直接会盖住rightBtn
            [self.functionView addSubview:self.cancelBtn];
            //事实是没有盖住，因为是PNG图片，所以还是直接remove一下rightBtn，之后再加进来
            self.functionView.rightBtn.hidden = YES;
            if ([estimateProgress floatValue] == 1) {
                //加载完成
                [self.webView.theProgressView setProgress:[estimateProgress floatValue] animated:YES];
                [UIView animateWithDuration:0.5
                                 animations:^{
                                     self.webView.theProgressView.alpha = 0;
                                 }
                                 completion:^(BOOL finished) {
                                     //藏起来
                                     self.webView.theProgressView.hidden = YES;
                                     self.webView.theProgressView.alpha = 1.0;
                                     //归零
                                     [self.webView.theProgressView setProgress:0.0 animated:NO];
                                     //移除cancelBtn并显示rightBtn
                                     [self.cancelBtn removeFromSuperview];
                                     self.functionView.rightBtn.hidden = NO;
                                 }];
            }
            else if ([estimateProgress floatValue] <= 0.6){
                //最开始最好给个假的，避免网不好不能加载的时候一直是空的条看不见
                
                self.webView.theProgressView.hidden = NO;
                [self.webView.theProgressView setProgress:0.6 animated:YES];
            }
            else{
                self.webView.theProgressView.hidden = NO;
                [self.webView.theProgressView setProgress:[estimateProgress floatValue] animated:YES];
            }
            
        }
    }
    
}
#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.addressView.urlTextField) {
        [self.view4AssociativeSearch removeFromSuperview];
    }
}
#pragma mark - 一些响应
//加载网页过程中，底部工具栏出现的取消按钮
- (void)clickCancelBtn
{
    [self.webView stopLoading];
    self.webView.theProgressView.hidden = YES;
    [self.cancelBtn removeFromSuperview];
    self.functionView.rightBtn.hidden = NO;
}
//点击联想搜索的结果
- (void)clickAssociativeResult:(UIButton *)aBtn
{
    self.addressView.urlTextField.text = aBtn.titleLabel.text;
    //调用一下搜索的block ，模拟点击了回车按钮
    self.addressView.textFieldRetrunBlock(self.addressView.urlTextField.text);
    [self.view endEditing:YES];
}
//搜索栏的联想搜索
- (void)textFieldDidChange:(UITextField *)sender
{
    NSLog(@"输入框的文字是--%@",sender.text);
    
    //考虑到有中文参数，所以需要编码
    //首先设置没有使用的特殊符号--即会被编码掉，最后那个空是空格
    NSString *character2Escape = @"<>'\"*()$#@!= ";
    //invertedSet 是取反， 即 除了character2Escape中的其他的字符串都是允许的，不会被编码
    NSCharacterSet *allowedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:character2Escape] invertedSet];
    NSString *paramStr = [sender.text stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
    
    NSString *preStr = @"http://suggestion.baidu.com/su?ie=UTF-8&json=1&cb=&wd=";
    preStr = [preStr stringByAppendingString:paramStr];
    NSLog(@"拼接的网址是--%@",preStr);
    NSURLSessionDataTask *task = [[NSURLSession sharedSession]dataTaskWithURL:[NSURL URLWithString:preStr]
                                                            completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                                if (error) {
                                                                    NSLog(@"网络获取出错--%@",error);
                                                                }else{
                                                                    //刚得到的data结果不是规范JSON，要处理一下小括号和分号
                                                                    NSString *tempStr = [[NSString alloc]initWithData:data
                                                                                                             encoding:NSUTF8StringEncoding];
                                                                    tempStr = [tempStr substringWithRange:NSMakeRange(1, tempStr.length-3)];
                                                                    //处理完了再转回NSData
                                                                    NSData *resultData = [tempStr dataUsingEncoding:NSUTF8StringEncoding];
                                                                    //解析
                                                                    NSError *error4Json = nil;
                                                                    id obj = [NSJSONSerialization JSONObjectWithData:resultData
                                                                                                             options:0
                                                                                                               error:&error4Json];
                                                                    if (error4Json) {
                                                                        NSLog(@"解析JSON出错--%@",error4Json);
                                                                    }else{
//                                                                        NSLog(@"%@",obj[@"g"]);
                                                                        //将目标数组获取到
                                                                        NSMutableArray *arr4AssociativeSearch = [NSMutableArray array];
                                                                        for (id i in obj[@"g"]){
//                                                                            NSLog(@"%@",i[@"q"]);
                                                                            [arr4AssociativeSearch addObject:i[@"q"]];
                                                                        }
                                                                        //赋给全局变量
                                                                        self.arr4AssociativeSearch = arr4AssociativeSearch;
                                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                                            //设置一番
                                                                            [self setUpAssociativeSearchViewWithRowCount:self.arr4AssociativeSearch.count];
                                                                            if (self.view4AssociativeSearch.superview != self.view) {
//                                                                                NSLog(@"第一次添加到self.view");
                                                                                [self.view addSubview:self.view4AssociativeSearch];
                                                                            }
                                                                        });
                                                                    }
                                                                }
                                                            }];
    [task resume];
    
}

@end
