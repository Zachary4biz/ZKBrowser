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
@property (nonatomic, strong) WebView *webView;
/**
 保存有当前所有打开的webView
 */
@property (nonatomic, strong) NSMutableArray *arr4WebViews;
/**
 保存当前所有的隐私webView
 */
@property (nonatomic, strong)NSMutableArray *arr4PrivateWebViews;
/**
 网页地址
 */
@property (nonatomic, strong) AddressView *addressView;
@end

@interface WebPagesVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate>
/**
 大的背景，里面套俩collectionView
 */
@property (nonatomic, strong) UICollectionView *aCollectionView;
/**
 左侧的collectionView，正常浏览模式
 */
@property (nonatomic, strong) VerticalCollectionView *normalCollectionView;
/**
 右侧的collectionView，隐私模式
 */
@property (nonatomic, strong) VerticalCollectionView *privateColleciontView;
/**
 底部的工具条，三个按钮
 */
@property (nonatomic, strong) PagesFunctionView *aFunctionView;
/**
 用来标记这个webView正在以小窗口模式打开，所以给这个cell加一个模糊
 */
@property (nonatomic, strong) UIImageView *blurIMGView;
/**
 当前是什么浏览模式，主要是判断浏览器有没有开启隐私模式，这影响到aCollectionView有一个还是两个cell
 */
@property (nonatomic, assign) BrowseType currentType;

/**
 加在collectionView上面，通过手势的location找到index，从而获取到手势点选的cell
 不选择给每个cell添加是因为那样太多了，不方便写代理，也是无意义地消耗内存
 */
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture4Cell;

/**
 隐私模式的cell pan手势
 */
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture4PrivateCell;
/**
 一个网页截图的大小
 */
@property (nonatomic, assign) CGSize cellSize;

/**
 这个是正在滑动的cell
 之所以也做成全局变量，首先是因为目前的方法是通过手势的location找到cell
 所以必须在滑动手势的Began状态去取这个cell，并且记录下来，不然之后的location会超出cell布局的frame
 结果就是取不到cell了，出BUG
 */
@property (nonatomic, strong) VerticalCollectionViewCell *handlingCell;
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
 
    self.view.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.7 alpha:1.0];
    
    //判断当前的模式
    _currentType = self.arr4PrivateWebPages.count>0? BrowsePrivateType:BrowseNormalType;
//normalCollectionView和privateCollectionView应该有的大小
    CGFloat width = 0.9*[UIScreen mainScreen].bounds.size.width;
    CGFloat insetHorizontal = 0.05*[UIScreen mainScreen].bounds.size.width;
    CGFloat height = self.view.frame.size.height-80-20-20;
//一个普通网页截图应该有的大小
    _cellSize = CGSizeMake(0.6*width, 0.6*height);
//初始化一个用来当遮罩的UIImageView
    _blurIMGView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"BlurBackGround"]];
    [_blurIMGView setFrame:CGRectMake(0, 0, _cellSize.width, _cellSize.height)];

#pragma mark _aCollectionView
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
    _aCollectionView.pagingEnabled = NO;
    _aCollectionView.scrollEnabled = NO;
    _aCollectionView.backgroundColor = [UIColor greenColor];
    _aCollectionView.alwaysBounceHorizontal = NO;
    [self.view addSubview:_aCollectionView];
    
    
#pragma mark normalcollectionView

    __weak typeof(self)wself = self;
    _normalCollectionView = [[VerticalCollectionView alloc]initWithFrame:CGRectMake(insetHorizontal, 20, width, height)
                                                                 dataArr:_arr4NormalWebPages
                                                          cellIdentifier:normalCellID
                                                                cellSize:_cellSize
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
//                                                              //给它配置block
//                                                              [wself setUpPanGestureBlockOfCell:cell];
                                                              
                                                              //因为跟collectionView的pan冲突了，保存起来看能不能做什么
                                                              //需要注意的是在cell被移除的时候，这个数组里面相应的gesture也要移除
//                                                              [wself.cellPanGestureArr addObject:cell.panGesture];
                                                          }];
    _normalCollectionView.delegate = self;
    _normalCollectionView.alwaysBounceVertical = YES;
    [_normalCollectionView turnOnDefaultPanGesture];
    
#pragma mark privateCollectionView
    _privateColleciontView = [[VerticalCollectionView alloc]initWithFrame:CGRectMake(insetHorizontal, 20, width, height)
                                                                 dataArr:_arr4PrivateWebPages
                                                          cellIdentifier:privateCellID
                                                                cellSize:_cellSize
                                                          configureBlock:^(id data, VerticalCollectionViewCell *cell) {
                                                              WebView *theView = data;
                                                              cell.ZKIMGView.image = theView.snapShot;
                                                              cell.ZKIMGView.contentMode = UIViewContentModeScaleToFill;
                                                          }];
    _privateColleciontView.delegate = self;
    _privateColleciontView.alwaysBounceVertical = YES;
    [_privateColleciontView turnOnDefaultPanGesture];
    
#pragma mark aFunctionView
    _aFunctionView = [[PagesFunctionView alloc]initWithFrame:CGRectMake(0.5*(self.view.frame.size.width - width4PagesFunctionView), CGRectGetMaxY(_aCollectionView.frame)+insetOfCollectionAndFunctionView, width4PagesFunctionView, height4PagesFunctionView)];
    
    //点击返回按钮的响应
    typeof(self) __weak Wself = self;
    _aFunctionView.clickBackBtnBlock = ^(){
        [Wself dismissViewControllerAnimated:YES completion:^{
            //更改了逻辑，在willDissApppear里面再回调dissmissBlock
            //不然在点击返回和添加按钮都要调用dissmissBlock
        }];
    };
    //点击添加按钮的响应
    _aFunctionView.clickCreatePageBtnBlock = ^(){
        if (Wself.currentType == BrowsePrivateType) {
            WebView *aWebView = [Wself.theWebVC createNewPrivateWebView];
            [Wself changeWebViewWith:aWebView];
        }else if (Wself.currentType == BrowseNormalType){
            WebView *aWebView = [Wself.theWebVC createNewNormalWebView];
            [Wself changeWebViewWith:aWebView];
        }
        [Wself dismissViewControllerAnimated:YES completion:nil];
    };
    //点击隐私模式按钮的响应
    _aFunctionView.clickPrivateBtnBlock = ^(){
        if (_currentType == BrowsePrivateType)
        {
            //当前已经是隐私模式，退出
            Wself.currentType = BrowseNormalType;
            [Wself.aFunctionView.privateBtn setImage:[UIImage imageNamed:@"PrivateBtn"] forState:UIControlStateNormal];
            //移除所有隐私页面
            [Wself.arr4PrivateWebPages removeAllObjects];
            [Wself.theWebVC.arr4PrivateWebViews removeAllObjects];
            //更新一下数组（即重置为0）避免之后BUG
            [Wself.privateColleciontView updateDataArrWith:Wself.arr4PrivateWebPages];
            [Wself.aCollectionView setContentOffset:CGPointMake(0, 0) animated:YES];
            
        }else if (_currentType == BrowseNormalType)
        {
            //当前是正常模式，进入隐私模式，所以这里的意思相当于是第一次进入隐私模式
            Wself.currentType = BrowsePrivateType;
            [Wself.aFunctionView.privateBtn setImage:[UIImage imageNamed:@"PrivateBtnClicked"] forState:UIControlStateNormal];
            //创建一个新的隐私界面
            WebView *aWebView = [Wself.theWebVC createNewPrivateWebView];
            [Wself.theWebVC takeSnapshotOf:aWebView];
            //刷新privateCollectionView
            [Wself.privateColleciontView updateDataArrWith:Wself.arr4PrivateWebPages];
            [Wself.privateColleciontView reloadData];
            [Wself.aCollectionView setContentOffset:CGPointMake(0.5*Wself.aCollectionView.frame.size.width, 0) animated:YES];
            
        }
        
    };
    _aFunctionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_aFunctionView];
    

}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self.normalCollectionView reloadData];

//    [self.normalCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    
//    [self.privateColleciontView reloadData];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.normalCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.arr4NormalWebPages.count-1 inSection:0]
                                      atScrollPosition:UICollectionViewScrollPositionBottom
                                              animated:NO];
#pragma mark 最后要根据是不是隐私模式做一些操作
    if (_currentType == BrowseNormalType) {
        [_aFunctionView.privateBtn setImage:[UIImage imageNamed:@"PrivateBtn"] forState:UIControlStateNormal];
        [_aCollectionView setContentOffset:CGPointMake(0, 0) animated:NO];
    }else if (_currentType == BrowsePrivateType){
        [_aFunctionView.privateBtn setImage:[UIImage imageNamed:@"PrivateBtnClicked"] forState:UIControlStateNormal];
        [_aCollectionView setContentOffset:CGPointMake(0.5*self.aCollectionView.frame.size.width, 0) animated:NO];
    }
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
//总共两组
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //一开始就给好两个section
    return 2;
}
//两个section分别表示正常模式和隐私模式
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    if (collectionView == _aCollectionView) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
        switch (indexPath.section) {
            case 0:
                //正常模式的
                _normalCollectionView.backgroundColor = [UIColor yellowColor];
                
                [cell addSubview:_normalCollectionView];
                break;
            case 1:
                //隐私模式的
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
    }else if (collectionView == _privateColleciontView){
        WebView *theClickedWebView = _arr4PrivateWebPages[indexPath.row];
        [self changeWebViewWith:theClickedWebView];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

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
/*
- (void)setUpPanGestureBlockOfCell:(VerticalCollectionViewCell *)cell
{
    typeof(cell) __weak Wcell = cell;
    typeof(self) __weak Wself = self;
    cell.panGestureBlock = ^(UIPanGestureRecognizer *thePanGesture){
        NSIndexPath *index = [_normalCollectionView indexPathForCell:Wcell];
        CGPoint gestureTranslationPoint = [thePanGesture translationInView:Wcell];
        switch (thePanGesture.state) {
            case UIGestureRecognizerStateBegan:
                NSLog(@"gesturePoint.x is %lf y is %lf",gestureTranslationPoint.x, gestureTranslationPoint.y);
                if (ABS(gestureTranslationPoint.y)<4) {
                    //阈值设为4判断一下，竖直方向初始位移小于4就认为是水平，StateChange中执行手势
                }else{
                    //竖直方向的初始位移大于4认为是竖直的要滚动，StateChange中不执行
//                    [thePanGesture requireGestureRecognizerToFail:_normalCollectionView.panGestureRecognizer];
                }
                break;
            case UIGestureRecognizerStateChanged:
                //正在改变时，位移
                Wcell.transform = CGAffineTransformMakeTranslation(gestureTranslationPoint.x, 0);
                break;
            case UIGestureRecognizerStateEnded:
                NSLog(@"enter End %@",thePanGesture.isEnabled?@"enabled":@"disabled");
                //结束时判断位置
                if (_arr4NormalWebPages.count>1) {
                    //如果Tab多于一个
                    if (gestureTranslationPoint.x>150 || gestureTranslationPoint.x<-150) {
                        //如果超过了限定，删除
                        NSLog(@"调用了");
                        //更改webVC的页面为这个被移除的页面的前一个
                        NSInteger pageIndexShouldBe = index.row-1<0?index.row+1:index.row-1;
                        [Wself changeWebViewWith:_arr4NormalWebPages[pageIndexShouldBe]];
                        //移除手势数组中的手势
                        [_cellPanGestureArr removeObjectAtIndex:index.row];
                        [_arr4NormalWebPages removeObjectAtIndex:index.row];
                        [_normalCollectionView updateDataArrWith:_arr4NormalWebPages];
                        [_normalCollectionView deleteItemsAtIndexPaths:@[index]];
                    }else{
                        [UIView animateWithDuration:0.2 animations:^{
                            Wcell.transform = CGAffineTransformIdentity;
                        }];
                    }
                }else{
                    [UIView animateWithDuration:0.2 animations:^{
                        Wcell.transform = CGAffineTransformIdentity;
                    }];
                }
                thePanGesture.enabled = YES;
                break;
            default:
                break;
        }
    };
}
*/

@end
