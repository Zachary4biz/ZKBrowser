//
//  VerticalFlowLayout.m
//  Self-Made-UI
//
//  Created by 周桐 on 17/1/5.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import "VerticalLayout.h"

@interface VerticalLayout ()
@property (nonatomic, strong) NSMutableArray *arr4Attributes;
@property (nonatomic, strong) NSMutableArray *arr4OriginalFrame;
@property (nonatomic, assign) CGFloat judge;

/**
 1 offset递增，手指是向上滑
 -1 offset递减， 手指是向下滑
 */
@property (nonatomic, assign) int scrollDirection;
@end

@implementation VerticalLayout
- (NSMutableArray *)arr4Attributes
{
    if (!_arr4Attributes) {
        _arr4Attributes = [NSMutableArray array];
        _totalItemNum = [self.collectionView numberOfItemsInSection:0];
        for (int i=0; i<_totalItemNum; i++) {
            UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [_arr4Attributes addObject:attr];
        }
    }
    return _arr4Attributes;
}
//自定义布局
//初始化
- (instancetype)init
{
    if (self = [super init]) {
        self.topInsetWhereTabDisappear = 10.0;
        self.judge = self.topInsetWhereTabDisappear;
        self.collectionView.alwaysBounceVertical = YES;
    }
    return self;
}


- (void)prepareLayout
{
    
    [super prepareLayout];
    //...
    if (!self.itemPileSpacing) {
        //如果初始化的时候没有给itemPileSpacing，就赋值为inset.top
        self.itemPileSpacing = self.edgeInset.top;
    }
    
}

- (CGSize)collectionViewContentSize
{
    
    
    CGFloat width = self.collectionView.frame.size.width;
    /*
     *高度从上到下：
     *self.edgeInset.top
     *(totalItemNum-1)*itemPileSpacing -- n-1个（cell叠加的）距离
     *self.itemSize.height -- 1个cell的高度
     *self.edgeInset.bottom -- 底部距离
     */
    CGFloat height = (_totalItemNum-1)*self.itemPileSpacing + self.itemSize.height + self.edgeInset.bottom + self.edgeInset.top+self.topInsetWhereTabDisappear;
    return CGSizeMake(width, height);
}


- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    if (indexPath.row == 0) {
        //第一个
        attr.frame = CGRectMake(0.5*(self.collectionView.frame.size.width - self.itemSize.width),
                                self.edgeInset.top+self.topInsetWhereTabDisappear,
                                self.itemSize.width,
                                self.itemSize.height);
    }else
    {
        //其他
        attr.frame = CGRectMake(0.5*(self.collectionView.frame.size.width - self.itemSize.width),
                                self.edgeInset.top+self.topInsetWhereTabDisappear+indexPath.row*self.itemPileSpacing,
                                self.itemSize.width,
                                self.itemSize.height);
    }
    return attr;
}


//返回layout需要的属性
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *layoutAttributesArr = [NSMutableArray array];
    [self.arr4Attributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attr, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectIntersectsRect(attr.frame, rect)) {
            [layoutAttributesArr addObject:attr];
        }
    }];
    return layoutAttributesArr;
}

#pragma mark - 自定义的方法
- (void)resetArr4Attributes
{
    /*
     * ->prepareLayout ->collectionViewContentSize ->layoutAttributesForElementsInRect ->collectionViewContentSize
     */
    _arr4Attributes = nil;
    
}
@end
/*
 *init -> prepareLayout ->collectionViewContentSize 
 *->layoutAttributesForItemAtIndexPath ->layoutAttributesForElementsInRect ->arr4Attributes
 *->layoutAttributesForItemAtIndexPath ->layoutAttributesForElementsInRect ->collectionViewContentSize
 */
