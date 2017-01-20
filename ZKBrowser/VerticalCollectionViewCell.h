//
//  VerticalCollectionViewCell.h
//  Self-Made-UI
//
//  Created by 周桐 on 17/1/18.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VerticalCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *ZKIMGView;

@property (nonatomic, copy) void (^panGestureBlock)(id object);
@end
