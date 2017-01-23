//
//  WebVC.h
//  ZKBrowser
//
//  Created by 周桐 on 16/12/10.
//  Copyright © 2016年 周桐. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
@class WebView;
@interface WebVC : UIViewController
/**
 这个方法要拿出来公用
 因为在WebPagesVC里面会用到这玩意来创建

 @return <#return value description#>
 */
- (WebView *)createNewNormalWebView;

/**
 要拿出来公用
 webPagesVC会用到它来创建隐私界面

 @return <#return value description#>
 */
- (WebView *)createNewPrivateWebView;
/**
 添加KVO用的

 @param theView <#theView description#>
 */
- (void)addKVO2theView:(UIView *)theView;

/**
 截图并把图赋给aView.snapshot，是UIImage类型

 @param aView <#aView description#>
 */
- (void)takeSnapshotOf:(WebView *)aView;
@end
