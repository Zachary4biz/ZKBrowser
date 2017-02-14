//
//  VerticalCollectionView.m
//  Self-Made-UI
//
//  Created by 周桐 on 17/1/5.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import "VerticalCollectionView.h"
#import "VerticalCollectionViewCell.h"

@interface VerticalCollectionView () <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UIGestureRecognizerDelegate>
/**
 保存cell数据的数组，模型数组
 */
@property (nonatomic, strong) NSMutableArray *cellDataArr;
/**
 cell重用标识
 */
@property (nonatomic, strong) NSString *cellIdentifier;

/**
 在DataSource中调用这个block，配置cell和DataArr[i]的关系
 */
@property (nonatomic, copy) CollectionViewcellConfigureBlock cellConfigureBlock;
/**
 自定义的布局
 */
@property (nonatomic, strong) VerticalLayout *layOut;

/**
 这个是正在滑动的cell
 之所以也做成全局变量，首先是因为目前的方法是通过手势的location找到cell
 所以必须在滑动手势的Began状态去取这个cell，并且记录下来，不然之后的location会超出cell布局的frame
 结果就是取不到cell了，出BUG
 */
@property (nonatomic, strong) VerticalCollectionViewCell *handlingCell;

/**
 这里搞成全局的是因为在代理里面要判断是不是这个手势，然后判断它能不能响应
 如x>y的时候它才能响应
 */
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@end

@implementation VerticalCollectionView
//使用默认的VerticalLayout
- (instancetype)initWithFrame:(CGRect)aFrame
                      dataArr:(NSMutableArray *)aDataArr
               cellIdentifier:(NSString *)aCellIdentifier
                     cellSize:(CGSize)anItemSize
               configureBlock:(CollectionViewcellConfigureBlock)aConfigureBlock;
{
    _layOut = [[VerticalLayout alloc]init];
    _layOut.itemSize = anItemSize;
    _layOut.edgeInset = UIEdgeInsetsMake(60, 0, 20, 0);
    
    return [self initWithFrame:aFrame
                       dataArr:aDataArr
                cellIdentifier:aCellIdentifier
                verticalLayout:_layOut
                configureBlock:aConfigureBlock];
}

//自定义layout来创建
- (instancetype)initWithFrame:(CGRect)aFrame
                      dataArr:(NSMutableArray *)aDataArr
               cellIdentifier:(NSString *)aCellIdentifier
               verticalLayout:(VerticalLayout *)aVerticalLayout
               configureBlock:(CollectionViewcellConfigureBlock)aConfigureBlock;
{
    if (self = [super initWithFrame:aFrame collectionViewLayout:aVerticalLayout]) {
        self.dataSource = self;
        self.cellDataArr = aDataArr;
        self.cellIdentifier = aCellIdentifier;
        self.cellConfigureBlock = aConfigureBlock;
        [self registerClass:[VerticalCollectionViewCell class] forCellWithReuseIdentifier:aCellIdentifier];
        
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
}
#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.cellDataArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VerticalCollectionViewCell *aCell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
    UIImage *data = self.cellDataArr[indexPath.row];
    if (self.cellConfigureBlock) {
        self.cellConfigureBlock(data,aCell);
    }else{
        NSLog(@"WARNING--没有实现传出数据和cell的block");
    }
    return aCell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

#pragma mark - 自定义的方法
- (void)updateDataArrWith:(NSMutableArray *)newDataArr
{
    //self.cellDataArr和newDataArr其实是一个，地址相同，是当做参数一直在到处传
    self.layOut.totalItemNum = self.cellDataArr.count;
    [self.layOut resetArr4Attributes];
    
}
#pragma mark - 开启滑动删除手势
- (void)turnOnDefaultPanGesture
{
    _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
    _panGesture.delegate = self;
    [self addGestureRecognizer:_panGesture];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)thePanGesture
{
    switch (thePanGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            //根据手势的点取到handlingCell
            CGPoint locationPoint = [thePanGesture locationInView:self];
            NSIndexPath *indexPath4HandlingCell = [self indexPathForItemAtPoint:locationPoint];
            _handlingCell =(VerticalCollectionViewCell *)[self cellForItemAtIndexPath:indexPath4HandlingCell];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            //位移
            CGPoint translationPoint = [thePanGesture translationInView:self];
            _handlingCell.transform = CGAffineTransformMakeTranslation(translationPoint.x, 0);
            //alpha设置一下，最后是大于0.4吧，不然很丑
            CGFloat alphaShouldBe = 1 - fabs(translationPoint.x)/(0.5*self.layOut.itemSize.width);
            _handlingCell.alpha = alphaShouldBe>0.4?alphaShouldBe:0.4;
        }
            break;
        case UIGestureRecognizerStateCancelled:
            NSLog(@"cancel");
        case UIGestureRecognizerStateEnded:
        {
            NSLog(@"end");
            NSLog(@"enter End %@",thePanGesture.isEnabled?@"enabled":@"disabled");
            //结束时判断位置
            CGPoint translationPoint = [thePanGesture translationInView:self];
            if (self.cellDataArr.count>1) {
                //如果Tab多于一个就可以删除
                //删除的阈值是 移动了cell宽度的一半
                CGFloat threshold = 0.5*self.layOut.itemSize.width;
                if (fabs(translationPoint.x)>threshold) {
                    //如果超过了限定，删除
                    NSLog(@"调用了");
                    NSIndexPath *handlingIndex = [self indexPathForCell:_handlingCell];
                    //1.更新数据源
                    [self.cellDataArr removeObjectAtIndex:handlingIndex.row];
                    //2.更新layOut自定义布局需要的东西
                    self.layOut.totalItemNum = self.cellDataArr.count;
                    [self.layOut resetArr4Attributes];
                    //3.最后才能删除cell
                    [self deleteItemsAtIndexPaths:@[handlingIndex]];
                    
                    
                    
                    //看外部是不是也有什么数据是要更新的
                    if (self.panGestureDeleteCellBlock) {
                        self.panGestureDeleteCellBlock(handlingIndex);
                    }
                    /*
                    //更改webVC的页面为这个被移除的页面的前一个
                    NSIndexPath *handlingIndex = [self indexPathForCell:_handlingCell];
                    NSInteger nextIndexShouldBe = handlingIndex.row-1<0?handlingIndex.row+1:handlingIndex.row-1;
                    [self changeWebViewWith:_arr4NormalWebPages[nextIndexShouldBe]];
                    //修改数据源
                    [_arr4NormalWebPages removeObjectAtIndex:handlingIndex.row];
                    //重置一些懒加载的东西为nil
                    [_normalCollectionView updateDataArrWith:_arr4NormalWebPages];
                    //删除cell
                    [_normalCollectionView deleteItemsAtIndexPaths:@[handlingIndex]];
                     */
                }else{
                    [UIView animateWithDuration:0.2 animations:^{
                        _handlingCell.transform = CGAffineTransformIdentity;
                        _handlingCell.alpha = 1.0;
                    }];
                }
            }else{
                [UIView animateWithDuration:0.2 animations:^{
                    _handlingCell.transform = CGAffineTransformIdentity;
                    _handlingCell.alpha = 1.0;
                }];
            }
        }
        default:
            break;
    }

}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"gestureRecognizer:%@",gestureRecognizer);
    if (gestureRecognizer == _panGesture) {
        //转一下类型，获取translation
        CGPoint translationPoint = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self];
        if (fabs(translationPoint.x) > fabs(translationPoint.y) ) {
            //表示是横向pan
            //获取location，如果手势不在cell上也不要响应，不然容易BUG
            CGPoint locationPoint = [(UIPanGestureRecognizer *)gestureRecognizer locationInView:self];
            if (![self indexPathForItemAtPoint:locationPoint]) {
                //如果不在cell上就不响应
                return NO;
            }
            NSLog(@"允许了_panGesture4Cell的响应");
            return YES;
        }else{
            //表示竖直pan，要用collectionView自身的滚动手势
            return NO;
        }
    }
    return YES;
}
@end
