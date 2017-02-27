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
#import "SpotlightUtil.h"
#import "InputAccessory.h"

#define DesktopUA "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_8; en-us) AppleWebKit/534.50 (KHTML, like Gecko) Version/5.1 Safari/534.50"
#define MobileUA "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_3 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8J2 Safari/6533.18.5"

@interface WebVC ()<WKNavigationDelegate,WKUIDelegate,UIScrollViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ZKNavigationDelegate>

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
 保存当前所有的隐私webView
 */
@property (nonatomic, strong)NSMutableArray *arr4PrivateWebViews;
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
/**
 隐私模式的线程池
 */
@property (nonatomic, strong)WKProcessPool *thePrivateProcessPool;

/**
 用来给百度api识别的图片
 */
@property (nonatomic, strong) UIImage *image4Recognization;
/**
 用来获取相册中图片的pickerController
 */
@property (nonatomic, strong) UIImagePickerController *picker;

@property (nonatomic, strong) NSMutableDictionary *dict4SaveURLOfWebView;

@property (nonatomic, strong) UIButton *testOnlyBtn;
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
#pragma mark - Lazy
//字典： webView名字（ZKDescription） - 存有所有URL的数组
- (NSMutableDictionary *)dict4SaveURLOfWebView
{
    if (!_dict4SaveURLOfWebView) {
        _dict4SaveURLOfWebView = [NSMutableDictionary dictionary];
    }
    return _dict4SaveURLOfWebView;
}
//webView共用一个processPool，这样的功能有一个就是不用重复登录
- (WKProcessPool *)theProcessPool
{
    if (!_theProcessPool) {
        _theProcessPool = [[WKProcessPool alloc]init];
    }
    return _theProcessPool;
}
//隐私webView
- (WKProcessPool *)thePrivateProcessPool
{
    if (!_thePrivateProcessPool) {
        _thePrivateProcessPool = [[WKProcessPool alloc]init];
    }
    return _thePrivateProcessPool;
}
//处理代理的handler，这个要懒加载
//不然在A页面建了一个代理在地址0xe00，B页面又建了一个代理在8xa44这样就是两个不同的代理
- (WebViewDelegate *)aWebViewDelegateHandler
{
    if (!_aWebViewDelegateHandler) {
        _aWebViewDelegateHandler = [WebViewDelegate new];
        _aWebViewDelegateHandler.navigationDelegate = self;
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
//懒加载数组 -- 用来记录所有隐私PrivateView
- (NSMutableArray *)arr4PrivateWebViews
{
    if (!_arr4PrivateWebViews) {
        _arr4PrivateWebViews = [NSMutableArray array];
    }
    return _arr4PrivateWebViews;
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
                                                                           self.view.frame.size.height - height4FunctionView,
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
#pragma mark - LifeCycle
static id instance;
+ (WebVC *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc ]init];
    });
    return instance;
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
        
        NSLog(@"添加了spotlight功能");
        NSData *imgData = [SpotlightUtil getNSDataOfUIImage:[UIImage imageNamed:@"BlurBackGround"]];
        
        NSArray *arr1 = [NSArray arrayWithObjects:@"mode",@"hanmode",@"muhanmode",@"穆罕默德",@"默德",nil];
        CSSearchableItem *item1 = [SpotlightUtil getItemWithTitle:@"穆罕默德" keywordArr:arr1 contentDescription:@"穆罕穆德的百度百科" thumbnailData:imgData spotlightInfo:@"穆罕默德" domainID:@"item1"];
        
        NSArray *arr2 = [NSArray arrayWithObjects:@"zhongguo",@"china",@"中国",@"中华人民共和国",@"中华",nil];
        CSSearchableItem *item2 = [SpotlightUtil getItemWithTitle:@"中国" keywordArr:arr2 contentDescription:@"中国\n中华人民共和国\n的百度百科" thumbnailData:imgData spotlightInfo:@"中国" domainID:@"item2"];
        
        NSArray *arr3 = [NSArray arrayWithObjects:@"Indian",@"印度",@"yindu", nil];
         CSSearchableItem *item3 = [SpotlightUtil getItemWithTitle:@"印度" keywordArr:arr3 contentDescription:@"印度\n印度？？？\n的百度百科" thumbnailData:imgData spotlightInfo:@"印度" domainID:@"item3"];
        
        [SpotlightUtil setUpSpotlightWithItemsArr:@[item1,item2,item3]];
        
        
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
    if (self.dictUnarchived) {
        //如果有本地加载出来的标签dictionary
        
        
    }else{
        self.webView = [self createNewNormalWebView];
    }
    //添加一个KVO监听，修改为在页面willAppear时添加，在willDisappear时移除
    //因为在webPagesVC中会修改sefl.webView的指针
    
//    [self addKVO2theView:self.webView];
//    [self.webView addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionNew context:nil];
//    [self.webView addObserver:self forKeyPath:@"canGoForward" options:NSKeyValueObservingOptionNew context:nil];
//    [self.webView addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew context:nil];
//    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    
#pragma mark 底部工具条functionView
    self.functionView = [[FunctionView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - height4FunctionView, self.view.frame.size.width, height4FunctionView)];
    
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
    //桌面手机UA切换
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
    //小窗口功能
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
    //百度识图API
    _picker = [[UIImagePickerController alloc]init];
    _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _picker.delegate = WeakSelf;
    self.aSettingBtnView.clickRecognizationBtnBlock = ^(){
        [WeakSelf presentViewController:WeakSelf.picker animated:YES completion:nil];
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
    
#pragma mark 测试用Btn
    self.testOnlyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.testOnlyBtn.frame = CGRectMake(20, 44, 80, 30);
    [self.testOnlyBtn setBackgroundColor:[UIColor redColor]];
    [self.testOnlyBtn setTitle:@"testOnlyBtn" forState:UIControlStateNormal];
    [self.testOnlyBtn addTarget:self action:@selector(clickTestOnlyBtn) forControlEvents:UIControlEventTouchUpInside];
    
//按遮挡顺序添加
    [self.view addSubview:self.addressView];
    [self.view addSubview:self.webView];
    //点击设置按钮弹出的View
    [self.view addSubview:self.aSettingBtnView];
    [self.view addSubview:self.functionView];
    
    [self.view addSubview:self.testOnlyBtn];
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

- (void)dealloc{
    NSLog(@"webVC 销毁？？？应该不会被销毁");
}

#pragma mark - 自定义的一些方法
//这个是关掉APP后，再打开，还是自动回复标签，并且回复标签的backForwardList

static int judge4isFromLocalWebViews = 0;
- (void)loadLocalWKWebViews
{
    judge4isFromLocalWebViews = 1;
    NSArray *keyArr = [self.dictUnarchived allKeys];
    NSLog(@"%@",self.dictUnarchived);
    for (int i=0;i<keyArr.count ; i++) {
        [self createNewNormalWebView];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSMutableArray *value = self.dictUnarchived[keyArr[i]];
            WebView *theWebView = self.arr4WebViews[i];
            //正在恢复标签
            theWebView.isRebooting = YES;
            //数组的[0]是截图
            theWebView.snapShot = value[0];
            //数组的[1]是记录了这个webView的curretnItem的URL是在第几个，先赋值出来
            theWebView.index4CurrentURLShouldbe =  [value[1] integerValue];
            //移除掉那两个记录，剩下的都是URL
            [value removeObjectAtIndex:0];
            [value removeObjectAtIndex:0];
            theWebView.urlArr = value;
            //一共有几个
            theWebView.counter4BackForward = theWebView.urlArr.count;
            //从第一个URL开始加载
            [theWebView loadRequest:[NSURLRequest requestWithURL:theWebView.urlArr[0]]];
        });
    }
}
//编码
- (NSString *)urlEncodeStr:(NSString *)targetStr WithParamStrShouldEncode:(NSString *)paramStr
{
    //    NSString *character2Escape = @"<>'\"*()$#@!= ";
    NSString *character2Escape = @"!*'();:@&=+$,/?%#[]";
    if (paramStr) {
        character2Escape = paramStr;
    }
    //invertedSet 是取反， 即 除了character2Escape中的其他的字符串都是允许的，不会被编码
    NSCharacterSet *allowedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:character2Escape] invertedSet];
    NSString *resultStr = [targetStr stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
    
    return resultStr;
}

//发送post请求到百度识图API
static NSString *access_token = @"24.7d5e1904fb54da55ab1fb411df317b79.2592000.1487928338.282335-9239112";
- (void)sendRequestToBaiduRecognizationWithImg:(UIImage *)anImage
{
    __block NSMutableArray *resultArr = [NSMutableArray array];
    NSString *urlStr = [NSString stringWithFormat:@"https://aip.baidubce.com/rest/2.0/ocr/v1/general?access_token=%@",access_token];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //设置Header
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    //设置Body
    //图片的base64. 使用JPEG会压缩一点，省流量，这里还是用PNG
    NSData *base64Data = UIImagePNGRepresentation(anImage);
    NSString *base64Str = [base64Data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    base64Str = [self urlEncodeStr:base64Str WithParamStrShouldEncode:nil];
    
    NSString *bodyStr = [NSString stringWithFormat:@"image=%@",base64Str];
    NSData *bodyData = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:bodyData];

    
    //设置Method
    request.HTTPMethod = @"POST";
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"reqeust有错误 -- %@",error);
        }else{
            NSError *error = nil;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            if (error) {
                NSLog(@"json解析有错误 -- %@",error);
            }else{
                NSLog(@">>>>>>>JSON是\n");
                NSLog(@"%@",dic);

                NSArray *arr = [NSArray array];
                arr = dic[@"words_result"];
                NSLog(@"--arr是\n");
                NSLog(@"%@",arr);
                for (NSDictionary *dic in arr){
                    [resultArr addObject:dic[@"words"]];
                }
                NSLog(@"relsutArr - %@",resultArr);
                NSString *resultStr = [[NSString alloc]init];
                for (NSString *str in resultArr)
                {
                    resultStr = [NSString stringWithFormat:@"%@%@",resultStr,str];
                }
                NSLog(@"resultStr is %@",resultStr);
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"检测到的内容" message:resultStr preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [alertVC dismissViewControllerAnimated:YES completion:nil];
                }];
                [alertVC addAction:action];
                
                [self presentViewController:alertVC animated:YES completion:nil];
            }
        }
    }];
    [task resume];
    
    
}
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
    if (!aWebView.isPrivateWebView) {
        //如果不是隐私窗口，才可以启用小窗口功能
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
            //3.更新地址栏
            self.addressView.urlTextField.text = self.webView.URL?self.webView.URL.absoluteString:NULL;
        }else{
            NSLog(@"当前只有一个页面，不能开启小窗口模式");
        }
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
    
    //并且把这个截图传给webView，这样就好找了
    aView.snapShot = snapshotIMG;
    //更新pageVC里面的数组，到时候直接用webView.snapShot就找到截图了
    self.webPagesVC.arr4PrivateWebPages = self.arr4PrivateWebViews;
    self.webPagesVC.arr4NormalWebPages = self.arr4WebViews;
    
}
//创造普通页面
- (WebView *)createNewNormalWebView
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
    
    //向这个webview 注册一个JS脚本，handler是自己self，脚本名字是@"XXX"
    NSString *JSPath = [[NSBundle mainBundle] pathForResource:@"ContextMenu"
                                                       ofType:@"js"];
    NSString *JSSource = [NSString stringWithContentsOfFile:JSPath encoding:NSUTF8StringEncoding error:nil];
    WKUserScript *theScript = [[WKUserScript alloc]initWithSource:JSSource
                                                    injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                 forMainFrameOnly:NO];
    [aConfiguration.userContentController addUserScript:theScript];
    [aConfiguration.userContentController addScriptMessageHandler:self.aWebViewDelegateHandler name:@"contextMenuMessageHandler"];
    
    
    //用配置好的configuration制作这个webView
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
    //添加一个长按手势，用手势的location去调用JS，获取到locatin的Element -- document.elementFromPoint
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    [aWebView addGestureRecognizer:longPressGesture];
    aWebView.userInteractionEnabled = YES;

    return aWebView;
}

//创造隐私页面
- (WebView *)createNewPrivateWebView
{
    self.aWebViewDelegateHandler.targetVC = self;
    /*
     *初始化webView时都是在HomePage，标识一下
     *原因是HomePage的scroll动画是不一样的
     */
    _judge4HomePage = 1;
//
    WKWebViewConfiguration *aConfiguration = [[WKWebViewConfiguration alloc]init];
    aConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = NO;
//    //共用一个隐私模式的线程池,
    aConfiguration.processPool = self.thePrivateProcessPool;
//    //测试一下configuration，向这个webview 注册一个JS脚本，handler是自己self，脚本名字是@"XXX"
//    [aConfiguration.userContentController addScriptMessageHandler:self.aWebViewDelegateHandler name:@"ScriptMessageHandler"];
//    
    WebView *aWebView =[[WebView alloc]initWithFrame:CGRectMake(0,
                                                                MaxY4AddressView,
                                                                self.view.frame.size.width,
                                                                self.view.frame.size.height - MaxY4AddressView-height4FunctionView)
                                       configuration:aConfiguration];
//
    aWebView.navigationDelegate = self.aWebViewDelegateHandler;
    aWebView.UIDelegate = self.aWebViewDelegateHandler;
    aWebView.scrollView.delegate = self.aWebViewDelegateHandler;
    aWebView.customUserAgent = @"Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_3 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8J2 Safari/6533.18.5";
    
    aWebView.isPrivateWebView = YES;
//    //添加到arr里
    [self.arr4PrivateWebViews addObject:aWebView];
//    //标记一下，之后小窗口模式用得上， 但是目前隐私模式没有做小窗口功能
//    aWebView.ZKDescription = [NSNumber numberWithInteger:self.arr4PrivateWebViews.count-1];
//
//    
    return aWebView;

}
#pragma mark - KVO
//添加KVO
- (void)addKVO2theView:(UIView *)theView
{
    //先直接做一下赋值，因为这里有可能是从本地恢复标签过来的
    self.functionView.leftBtn.enabled = self.webView.canGoBack;
    self.functionView.rightBtn.enabled = self.webView.canGoForward;
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
#pragma mark - ZKNavigationDelegate
- (void)commitNavigationWebView:(WebView *)webView
{
    if (webView.isRebooting) {
        [webView stopLoading];
    }
}

- (void)failNavigationWebView:(WebView *)webView withErrorCode:(NSInteger)erCode
{
    if (erCode == -999) {
        NSLog(@"连续加载");
        if(webView.isRebooting){
            if (webView.alreadyCounter4BackForward == webView.counter4BackForward - 1) {
                //加载到最后一个了
                WKBackForwardListItem *shouldBeItem = [webView.backForwardList itemAtIndex:webView.index4CurrentURLShouldbe-webView.alreadyCounter4BackForward];
                [webView goToBackForwardListItem:shouldBeItem];
                webView.isRebooting = NO;
            }else{
                webView.alreadyCounter4BackForward ++;
                [webView loadRequest:[NSURLRequest requestWithURL:webView.urlArr[webView.alreadyCounter4BackForward]]];
            }
        }
    }
}
- (void)finishNavigationWebView:(WebView *)webView
{
    NSLog(@"加载完成");
    NSMutableArray *arr4URL = [NSMutableArray array];
    //数组第一个是当前页面的URL在数组里index是几
    NSInteger currentItemIndexOfArr4URL = webView.backForwardList.backList.count;
    if (!webView.isRebooting) {
        //如果不是从本地加载的标签，或者说已经完成了从本地加载的过程
        //数组第二个是一张截图
        [self takeSnapshotOf:webView];
    }
    [arr4URL addObject:webView.snapShot];
    [arr4URL addObject:[NSNumber numberWithInteger:currentItemIndexOfArr4URL]];
    
    for (WKBackForwardListItem *item in webView.backForwardList.backList)
    {
        [arr4URL addObject:item.URL];
    }
    [arr4URL addObject:webView.backForwardList.currentItem.URL];
    for (WKBackForwardListItem *item in webView.backForwardList.forwardList)
    {
        [arr4URL addObject:item.URL];
    }
    /*
     *数组结构如下：
     *第一个是 当前页面的URL在数组里的index是几
     *从第二个是截图
     *第三个及之后都是URL
     */
    [self.dict4SaveURLOfWebView setObject:arr4URL forKey:[NSNumber numberWithInteger:[self.arr4WebViews indexOfObject:webView]]];
    
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"dict4SaveURLOfWebView.archiver"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        BOOL flag = [NSKeyedArchiver archiveRootObject:self.dict4SaveURLOfWebView toFile:path];
        if (flag) {
            NSLog(@"success archived");
        }else{
            NSLog(@"not archive");
        }
    });
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (self.dictUnarchived) {
            //如果有这个字典，那么就是通过加载恢复本地标签来的
            //所以这里可以直接通过这个字典是否存在来判断这里是正常在加载还是恢复本地标签
            //首先由于viewDidLoad里面没有做self.webView = self createNormalWebView，所以self.webView要在这里重新替换一下
            [self changeWebViewWith:self.arr4WebViews[0]];
            
            //然后添加KVO
            [self addKVO2theView:self.webView];
        }
    });

}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    self.image4Recognization = [[UIImage alloc]init];
    self.image4Recognization = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [self sendRequestToBaiduRecognizationWithImg:self.image4Recognization];
    [self.picker dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
}
#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.addressView.urlTextField) {
        [self.view4AssociativeSearch removeFromSuperview];
    }
}
#pragma mark - 一些响应
//点击了测试用的按钮，各种测试功能
- (void)clickTestOnlyBtn
{
//    NSLog(@"尝试使用URLScheme跳转APP");
//    NSString *urlScheme = @"zkbrowser://";
//    NSURL *url = [NSURL URLWithString:urlScheme];
//    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
//        if (success) {
//            NSLog(@"success");
//        }else{
//            NSLog(@"fail");
//        }
//    }];
    NSLog(@"testOnly ----- 8888888888");
    [self.webView stopLoading];
    
}
//长按网页
- (void)handleLongPress:(UILongPressGestureRecognizer *)aLongPress
{
    CGPoint point = [aLongPress locationInView:self.webView];
    NSString *JSStrCMD = [NSString stringWithFormat:@"MyAppGetHTMLElementsAtPoint(%lf,%lf)",point.x,point.y];
    [self.webView evaluateJavaScript:JSStrCMD completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error in longpress webview %@",error);
        }else{
            NSLog(@"obj");
        }
    }];
}
//iMessage打开的响应
- (void)requestWithiMessageURL:(NSURL *)iMessageURL
{
    self.addressView.urlTextField.text = iMessageURL.absoluteString;
    [self.webView loadRequest:[NSURLRequest requestWithURL:iMessageURL cachePolicy:0 timeoutInterval:5]];
}
//spotlight打开的响应
- (void)requestWithSpotlightParam:(NSString *)aParam
{
    NSString *preStr4Baike = @"https://wapbaike.baidu.com/item/";
    NSString *resultParam = [InputAccessory encodeWithDefaultCharactersInString:aParam];
    NSString *resultStr = [preStr4Baike stringByAppendingString:resultParam];
    NSURL *url = [NSURL URLWithString:resultStr];
    self.addressView.urlTextField.text = resultStr;
    [self.webView loadRequest:[NSURLRequest requestWithURL:url cachePolicy:0 timeoutInterval:5]];
}
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
