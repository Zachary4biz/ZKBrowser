//
//  WebViewDelegate.h
//  ZKBrowser
//
//  Created by 周桐 on 17/1/6.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
@class WebVC;
@interface WebViewDelegate : NSObject <WKUIDelegate,WKNavigationDelegate,UIScrollViewDelegate,WKScriptMessageHandler>
@property (nonatomic, weak)WebVC *targetVC;
@end
