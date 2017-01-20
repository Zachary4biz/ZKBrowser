//
//  UIResponder+FindFirstResponder.h
//  ZKBrowser
//
//  Created by 周桐 on 17/1/3.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIResponder (FindFirstResponder)
/*
 *用来查找当前的firstResponder
 *使用起来就是用下面这个类方法
 * id theFirstResponder = [UIResponder ZK_getFirstResponder];
 */
+ (id)ZK_getFirstResponder;
@end
