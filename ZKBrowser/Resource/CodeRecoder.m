//
//  CodeRecoder.m
//  ZKBrowser
//
//  Created by Zac on 2017/1/23.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import <Foundation/Foundation.h>

//1.执行一个关闭当前这个webView的JS脚本
/*
[WeakSelf.webView evaluateJavaScript:@"window.opener = null;window.open('','_self');window.close();" completionHandler:^(id _Nullable object, NSError * _Nullable error) {
    if (error) {
        NSLog(@"%@",error);
    }else{
        NSLog(@"%@",object);
    }
}];
*/

//2.spotlight的点击响应
/*
 if ([[userActivity activityType] isEqualToString:CSSearchableItemActionType]) {
 NSString *uniqueIdentifier = [userActivity.userInfo objectForKey:CSSearchableItemActivityIdentifier];
 //接受事先定义好的竖直，如果是多个参数可以使用Json转成string传递过来，然后再把string转回去
 NSLog(@"传递过来的值是%@",uniqueIdentifier);
 }else{
 NSLog(@"not Equal");
 NSLog(@"userActivityType %@",[userActivity activityType]);
 NSLog(@"CSSearchableItemActionType %@",CSSearchableItemActionType);
 }
 return YES;
*/

//3.单例
/*
 static id instance;
 + (instancetype)sharedInstance
 {
 static dispatch_once_t onceToken;
 dispatch_once(&onceToken, ^{
 instance = [[[self class] alloc ]init];
 });
 return instance;
 }

 */



