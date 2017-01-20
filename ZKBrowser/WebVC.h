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
 这个方法要拿出来公用，因为在WebPagesVC里面会用到这玩意来创建

 @return <#return value description#>
 */
- (WebView *)createNewWebView;

/**
 添加KVO用的

 @param theView <#theView description#>
 */
- (void)addKVO2theView:(UIView *)theView;
@end
