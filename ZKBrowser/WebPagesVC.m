//
//  WebPagesVC.m
//  ZKBrowser
//
//  Created by 周桐 on 16/12/27.
//  Copyright © 2016年 周桐. All rights reserved.
//

#import "WebPagesVC.h"
#import "WebPageView.h"
#import "WebPageLayout.h"
#import "PagesFunctionView.h"
typedef enum{
    BrowseNormalType = 0,
    BrowsePrivateType,
}BrowseType;
@interface WebPagesVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
/**
 大的背景，里面套俩collectionView
 */
@property (nonatomic, strong)UICollectionView *aCollectionView;
/**
 左侧的collectionView，正常浏览模式
 */
@property (nonatomic, strong)UICollectionView *normalCollectionView;
/**
 右侧的collectionView，隐私模式
 */
@property (nonatomic, strong)UICollectionView *privateColleciontView;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//底层的aCollectionView，包裹着两个collectionView用来展示正常模式和隐私模式
    CGRect frame4CollectionView = CGRectMake(0, 0, 2*[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    UICollectionViewFlowLayout *aLayout = [[UICollectionViewFlowLayout alloc]init];
    aLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _aCollectionView = [[UICollectionView alloc]initWithFrame:frame4CollectionView
                                                          collectionViewLayout:aLayout];
    [_aCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellID];
    _aCollectionView.delegate = self;
    _aCollectionView.dataSource = self;
    _aCollectionView.pagingEnabled = YES;
    [self.view addSubview:_aCollectionView];
    
//两个模式可以通用一个layout
    WebPageLayout *layout4NorAndPri = [[WebPageLayout alloc]init];
    layout4NorAndPri.scrollDirection = UICollectionViewScrollDirectionVertical;
    
//正常模式的collectionView
    _normalCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout4NorAndPri];
    _normalCollectionView.delegate = self;
    _normalCollectionView.dataSource = self;
    [_normalCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:normalCellID];
//隐私模式的collectionView
    _privateColleciontView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout4NorAndPri];
    _privateColleciontView.delegate = self;
    _privateColleciontView.dataSource = self;
    [_privateColleciontView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:privateCellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UICollectionViewDataSource


#pragma mark UICollectionViewDelegate
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
        }else{
            //隐私模式开启式有两列
            result = 2;
        }
    }else if (collectionView == _normalCollectionView){
        //这里是正常模式的网页有几个
        result = self.arr4NormalWebPages.count;
    }else if (collectionView == _privateColleciontView){
        //隐私模式的网页有几个
        result = self.arr4PrivateWebPages.count;
    }else{
        NSLog(@"WebPagesVC-UICollectionVIewDelegate-numberOfItemsInSection-出错");
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
                _normalCollectionView.frame = CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height);
                _normalCollectionView.backgroundColor = [UIColor magentaColor];
                [_normalCollectionView reloadData];
                [cell addSubview:_normalCollectionView];
                break;
            case 1:
                //隐私模式的
                _privateColleciontView.frame = CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height);
                _privateColleciontView.backgroundColor = [UIColor cyanColor];
                [cell addSubview:_privateColleciontView];
                break;
        }
    }else if (collectionView == _normalCollectionView){
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:normalCellID forIndexPath:indexPath];
        cell.backgroundColor = [UIColor blueColor];
        [self setUpWebPagesView:self.arr4NormalWebPages];
    }else if (collectionView == _privateColleciontView){
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:privateCellID forIndexPath:indexPath];
        cell.backgroundColor = [UIColor yellowColor];
        [self setUpWebPagesView:self.arr4PrivateWebPages];
    }
    return cell;
}
#pragma mark UICollectionViewDelegateFlowLayout
//cell大小，最终效果是差不多一屏大
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize aSize = CGSizeZero;
    if (collectionView == _aCollectionView) {
        aSize = CGSizeMake(self.view.frame.size.width, collectionView.frame.size.height);
    }else if (collectionView == _normalCollectionView){
        //按说这里是没有用的，因为是隐私模式和正常模式的两collectionView都是使用的自定义layout
        aSize = CGSizeMake(20, 20);
    }else if (collectionView == _privateColleciontView){
        aSize = CGSizeMake(60, 10);
    }
    return aSize;
}
//cell的间隙，应该有一定的距离，就设置为20把
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //距左20
    return UIEdgeInsetsMake(0, 20, 0, 20);
}
//关闭默认的间隙
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0;
}

#pragma mark Self-Made自定义的方法
static CGFloat Y4WebPageView = 44.0;
static CGFloat Width4WebPageView = 200.0;
static CGFloat Height4WebPageView = 300.0;


/**
 目的是把数组中的webView截图放到WebPageView里面
 这样就可以通过这个自己的view来额外添加一些手势响应、属性、头部title之类的
 
 @param arr4SnapshotOfWebView 这个参数主要接arr4NormalWebPages或者arr4PrivateWebPages这俩数组
 */
- (void)setUpWebPagesView:(NSMutableArray *)arr4SnapshotOfWebView
{
    CGRect frame4WebPageView = CGRectMake((self.view.frame.size.width - Width4WebPageView)/2,
                                          Y4WebPageView,
                                          Width4WebPageView,
                                          Height4WebPageView);
    for (int i=0; i<arr4SnapshotOfWebView.count; i++) {
        WebPageView *aWebPageView = [[WebPageView alloc]initWithFrame:frame4WebPageView andSnapshotOfWebView:arr4SnapshotOfWebView[i]];
        [arr4SnapshotOfWebView replaceObjectAtIndex:i withObject:aWebPageView];
    }
}




@end
