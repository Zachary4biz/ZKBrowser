//
//  UIResponder+FindFirstResponder.m
//  ZKBrowser
//
//  Created by 周桐 on 17/1/3.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import "UIResponder+FindFirstResponder.h"

@implementation UIResponder (FindFirstResponder)
static __weak id ZKCurrentFirstResponder;

+ (id)ZK_getFirstResponder
{
    //首先初始化为nil
    ZKCurrentFirstResponder = nil;
    //这里后三个参数都设置为nil，系统就会自动帮我们做遍历，结果就是当前的第一响应者firstResponder会响应我们给的方法--ZK_theFirstResponder:
    [[UIApplication sharedApplication] sendAction:@selector(ZK_theFirstResponder:)
                                               to:nil
                                             from:nil
                                         forEvent:nil];
    //在下面那个方法中静态变量被设置为了firstResponder，所以返回它就行了
    return ZKCurrentFirstResponder;
}

- (void)ZK_theFirstResponder:(id)sender
{
    //响应者（这里就应该是firstResponder）会把静态变量ZKCurrentFirstResponder设置为自身
    ZKCurrentFirstResponder = self;
}
@end
