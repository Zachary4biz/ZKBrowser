//
//  VerticalCollectionView.m
//  Self-Made-UI
//
//  Created by 周桐 on 17/1/5.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import "VerticalCollectionView.h"
#import "VerticalCollectionViewCell.h"

@interface VerticalCollectionView () <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
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

@end
