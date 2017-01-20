//
//  VerticalFlowLayout.h
//  Self-Made-UI
//
//  Created by 周桐 on 17/1/5.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VerticalLayout : UICollectionViewLayout

/**
 item的大小
 */
@property (nonatomic, assign) CGSize itemSize;

/**
 section距离顶部的scroll的inset
 */
@property (nonatomic, assign) UIEdgeInsets edgeInset;

/**
 每个Cell之间叠加的间隔
 */
@property (nonatomic, assign) CGFloat itemPileSpacing;

/**
 用在topY那里，tab收拢、消失的位置距离顶部还是应该有一点距离
 */
@property (nonatomic, assign) CGFloat topInsetWhereTabDisappear;

/**
 总共有多少个Item
 */
@property (nonatomic, assign) NSInteger totalItemNum;

/**
 因为外部可能更改了cell个数，而layout内部是懒加载的这个数组，所以要指向nil，重新加载一次
 */
- (void)resetArr4Attributes;
@end
