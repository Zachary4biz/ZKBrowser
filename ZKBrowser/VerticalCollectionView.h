//
//  VerticalCollectionView.h
//  Self-Made-UI
//
//  Created by 周桐 on 17/1/5.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VerticalLayout.h"
typedef void(^CollectionViewcellConfigureBlock)(id data, __kindof UICollectionViewCell *cell);
@interface VerticalCollectionView : UICollectionView


/**
 初始化一个竖直的collectionView
 
 @param aFrame          frame
 @param aDataArr        存有cell要用的数据，比如可以是一个modArr
 @param aCellIdentifier cellIdentifier
 @param aCellSize       cellSize
 @param aConfigureBlock block里面自定义要怎么用这个aDataArr[indexPath.row]的数据，简单的有直接自定义cell然后cell.mod = data这种；
 
 @return 初始化得到的collectionView
 */
- (instancetype)initWithFrame:(CGRect)aFrame
                      dataArr:(NSMutableArray *)aDataArr
               cellIdentifier:(NSString *)aCellIdentifier
                     cellSize:(CGSize)aCellSize
               configureBlock:(CollectionViewcellConfigureBlock)aConfigureBlock;

/**
 可能有些关于layout的东西要自定义一下，就用这个方法，把--使用VerticalFlowLayout类自定义的--layout传给aVerticalLayout
 
 @param aFrame          frame
 @param aDataArr        存有cell要用的数据，比如可以是一个modArr
 @param aCellIdentifier cellIdentifier
 @param aVerticalLayout 使用VerticalFlowLayout类自定义出来的layout
 @param aConfigureBlock block里面自定义要怎么用这个aDataArr[indexPath.row]的数据，简单的有直接自定义cell然后cell.mod = data这种；
 
 @return 初始化得到的collectionView
 */
- (instancetype)initWithFrame:(CGRect)aFrame
                      dataArr:(NSMutableArray *)aDataArr
               cellIdentifier:(NSString *)aCellIdentifier
               verticalLayout:(VerticalLayout *)aVerticalLayout
               configureBlock:(CollectionViewcellConfigureBlock)aConfigureBlock;

/**
 有时候会删除添加cell，所以在这里更新dataArr

 @param newDataArr NSMutableArray
 */
- (void)updateDataArrWith:(NSMutableArray *)newDataArr;

@end
