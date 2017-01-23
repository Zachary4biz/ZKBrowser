//
//  NSObject+Description.h
//  ZKBrowser
//
//  Created by 周桐 on 16/12/26.
//  Copyright © 2016年 周桐. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Description)
/*
 *用来给任意一个类添加一个属性叫--ZKDescription
 *相当于可以给任意类型的实例加一个备注，可能用来标记按钮的状态，可能用来存储某个webView应该有的备注信息
 */
@property (nonatomic, strong)id ZKDescription;
@end
