//
//  WebPagesVC.m
//  ZKBrowser
//
//  Created by 周桐 on 16/12/27.
//  Copyright © 2016年 周桐. All rights reserved.
//

#import "WebPagesVC.h"
#import "VerticalCollectionView.h"
#import "VerticalCollectionViewCell.h"
#import "PagesFunctionView.h"
#import "WebView.h"
#import "WebVC.h"
#import "AddressView.h"

typedef enum{
    BrowseNormalType = 0,
    BrowsePrivateType,
}BrowseType;

@interface WebVC ()
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
@end

@interface WebPagesVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
/**
 大的背景，里面套俩collectionView
 */
@property (nonatomic, strong)UICollectionView *aCollectionView;
/**
 左侧的collectionView，正常浏览模式
 */
@property (nonatomic, strong)VerticalCollectionView *normalCollectionView;
/**
 右侧的collectionView，隐私模式
 */
@property (nonatomic, strong)VerticalCollectionView *privateColleciontView;
/**
 用来标记这个webView正在以小窗口模式打开，所以给这个cell加一个模糊
 */
@property (nonatomic, strong)UIImageView *blurIMGView;
/**
 当前是什么浏览模式，主要是判断浏览器有没有开启隐私模式，这影响到aCollectionView有一个还是两个cell
 */



@end

@implementation WebPagesVC

static NSString *cellID = @"collectionViewCell";
static NSString *normalCellID = @"normalCell";
static NSString *privateCellID = @"privateCell";

//这里希望这个VC是一个单例，避免重复一些不必要的东西
static id instance;
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc ]init];
    });
    return instance;
}

//默认是正常模式（隐私模式关闭）
static BrowseType currentType = BrowseNormalType;
- (NSMutableArray *)arr4NormalWebPages
{
    if (!_arr4NormalWebPages) {
        _arr4NormalWebPages = [NSMutableArray array];
    }
    return _arr4NormalWebPages;
}

- (NSMutableArray *)arr4PrivateWebPages
{
    if (!_arr4PrivateWebPages) {
        _arr4PrivateWebPages = [NSMutableArray array];
    }
    return _arr4PrivateWebPages;
}
static CGFloat insetOfCollectionAndFunctionView = 10.0;
static CGFloat height4PagesFunctionView = 80.0;
static CGFloat width4PagesFunctionView = 250.0;
- (void)viewDidLoad {
    [super viewDidLoad];
 
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.7 alpha:1.0];
//normalCollectionView和privateCollectionView应该有的大小
    CGFloat width = 0.9*[UIScreen mainScreen].bounds.size.width;
    CGFloat insetHorizontal = 0.05*[UIScreen mainScreen].bounds.size.width;
    CGFloat height = self.view.frame.size.height-80-20-20;
//一个普通网页截图应该有的大小
    CGSize aWebSize = CGSizeMake(0.7*width, 0.6*height);
//初始化一个用来当遮罩的UIImageView
    _blurIMGView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"BlurBackGround"]];
    [_blurIMGView setFrame:CGRectMake(0, 0, aWebSize.width, aWebSize.height)];

#pragma mark wrapperCollectionView
    CGRect frame4CollectionView = CGRectMake(0,
                                             20,
                                             2*self.view.frame.size.width,
                                             self.view.frame.size.height - height4PagesFunctionView - insetOfCollectionAndFunctionView);
    UICollectionViewFlowLayout *aLayout = [[UICollectionViewFlowLayout alloc]init];
    aLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    aLayout.itemSize = CGSizeMake(self.view.frame.size.width, frame4CollectionView.size.height);
    _aCollectionView = [[UICollectionView alloc]initWithFrame:frame4CollectionView
                                         collectionViewLayout:aLayout];
    [_aCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellID];
    _aCollectionView.delegate = self;
    _aCollectionView.dataSource = self;
    _aCollectionView.pagingEnabled = YES;
    _aCollectionView.scrollEnabled = YES;
    _aCollectionView.backgroundColor = [UIColor greenColor];
    _aCollectionView.alwaysBounceHorizontal = NO;
    [self.view addSubview:_aCollectionView];
    
    
#pragma mark normalcollectionView

    __weak typeof(self)wself = self;
    _normalCollectionView = [[VerticalCollectionView alloc]initWithFrame:CGRectMake(insetHorizontal, 20, width, height)
                                                                 dataArr:_arr4NormalWebPages
                                                          cellIdentifier:normalCellID
                                                                cellSize:aWebSize
                                                          configureBlock:^(id data, VerticalCollectionViewCell *cell) {
                                                              //配置Cell
                                                              //给它截图
                                                              WebView *theView = data;
                                                              cell.ZKIMGView.image = theView.snapShot;
                                                              cell.ZKIMGView.contentMode = UIViewContentModeScaleToFill;
                                                              //正在用作小窗口，就在它上面再覆盖一层blurIMG
                                                              if (theView.isUsingAsSmallWebView) {
                                                                  [cell.contentView addSubview:wself.blurIMGView];
                                                              }
                                                              //给它配置block
                                                              [self setUpPanGestureBlockOfCell:cell];
                                                          }];
    _normalCollectionView.delegate = self;
    
#pragma mark privateCollectionView
  
    
    
#pragma mark bottomToolBar
    PagesFunctionView *aFunctionView = [[PagesFunctionView alloc]initWithFrame:CGRectMake(0.5*(self.view.frame.size.width - width4PagesFunctionView), CGRectGetMaxY(_aCollectionView.frame)+insetOfCollectionAndFunctionView, width4PagesFunctionView, height4PagesFunctionView)];
    //点击返回按钮的响应
    typeof(self) __weak Wself = self;
    aFunctionView.clickBackBtnBlock = ^(){
        [Wself dismissViewControllerAnimated:YES completion:^{
            //更改了逻辑，在willDissApppear里面再回调dissmissBlock
            //不然在点击返回和添加按钮都要调用dissmissBlock
        }];
    };
    //点击添加按钮的响应
    aFunctionView.clickCreatePageBtnBlock = ^(){
        WebView *aWebView = [Wself.theWebVC createNewWebView];
        [Wself changeWebViewWith:aWebView];
        [Wself dismissViewControllerAnimated:YES completion:nil];
    };
    //点击隐私模式按钮的响应
    aFunctionView.clickPrivateBtnBlock = ^(){
        
    };
    aFunctionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:aFunctionView];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.normalCollectionView reloadData];
    [self.normalCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.arr4NormalWebPages.count-1 inSection:0]
                                      atScrollPosition:UICollectionViewScrollPositionTop
                                              animated:NO];
    
//    [self.normalCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    
//    [self.privateColleciontView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.dismissBlock) {
        self.dismissBlock();
    }else{
        NSLog(@"------ 没有实现dismissBlock，PagesVC没有销毁");
    }
}
- (void)dealloc
{
    self.aCollectionView = nil;
    self.arr4NormalWebPages = nil;
    self.arr4PrivateWebPages = nil;
    self.normalCollectionView = nil;
    NSLog(@"WebPagesVC -- 销毁");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource
//总共一组
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//一组里面有两列，这里是横着来，两列分别代表正常模式和隐私模式
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger result = 0;
    if (collectionView == _aCollectionView) {
        if (currentType == BrowseNormalType) {
            //正常模式就只有一列
            result = 1;
            NSLog(@"当前是正常模式");
        }else{
            //隐私模式开启式有两列
            result = 2;
            NSLog(@"当前有开启隐私模式");
        }
    }
    return result;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    if (collectionView == _aCollectionView) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
        switch (indexPath.row) {
            case 0:
                //正常模式的
//                _normalCollectionView.frame = CGRectMake(10, 20, cell.bounds.size.width, cell.bounds.size.height);
                NSLog(@"aCollectionView是在正常模式，normalCollectionView显示黄色");
                _normalCollectionView.backgroundColor = [UIColor yellowColor];
                
                [cell addSubview:_normalCollectionView];
                break;
            case 1:
                //隐私模式的
                _privateColleciontView.frame = CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height);
                NSLog(@"aCollectionView开启了隐私模式，显示青色");
                _privateColleciontView.backgroundColor = [UIColor cyanColor];
                [cell addSubview:_privateColleciontView];
                break;
        }
    }
    return cell;
}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _normalCollectionView) {
        WebView *theClickedWebView = _arr4NormalWebPages[indexPath.row];
        if (theClickedWebView.isUsingAsSmallWebView) {
            //如果正在用作小窗口，就不要显示了
            NSLog(@"正在用作小窗口");
        }else{
            [self changeWebViewWith:theClickedWebView];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}
#pragma mark - UICollectionViewDelegateFlowLayout



#pragma mark - Self-Made自定义的方法
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
    [self.theWebVC.webView removeFromSuperview];
    self.theWebVC.webView = aView;
    [self.theWebVC.view insertSubview:self.theWebVC.webView belowSubview:self.theWebVC.addressView];
    
}
//配置cell的panGestureBlock
- (void)setUpPanGestureBlockOfCell:(VerticalCollectionViewCell *)cell
{
    typeof(cell) __weak Wcell = cell;
    cell.panGestureBlock = ^(UIPanGestureRecognizer *thePanGesture){
        if (thePanGesture.state == UIGestureRecognizerStateChanged) {
            NSIndexPath *index = [_normalCollectionView indexPathForCell:Wcell];
            CGPoint gesturePoint = [thePanGesture translationInView:Wcell];
            Wcell.transform = CGAffineTransformMakeTranslation(gesturePoint.x, 0);
            if (gesturePoint.x>150 || gesturePoint.x<-150) {
                [_arr4NormalWebPages removeObjectAtIndex:index.row];
                [_normalCollectionView updateDataArrWith:_arr4NormalWebPages];
                [_normalCollectionView deleteItemsAtIndexPaths:@[index]];
#warning 这个很重要，因为拖动太快了的话，超过150会在这里调用两次，第二次的时候collectionView已经没有这个cell了，index是nil，会报错的
                thePanGesture.enabled = NO;
            }
        }else if(thePanGesture.state == UIGestureRecognizerStateEnded){
            [UIView animateWithDuration:0.2 animations:^{
                Wcell.transform = CGAffineTransformIdentity;
            }];
        }
    };
}


@end
