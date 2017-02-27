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
@class WebView;
@protocol ZKNavigationDelegate <NSObject>
@optional
- (void)commitNavigationWebView:(WebView *)webView;
- (void)failNavigationWebView:(WebView *)webView withErrorCode:(NSInteger)erCode;
- (void)finishNavigationWebView:(WebView *)webView;
@end

@interface WebViewDelegate : NSObject <WKUIDelegate,WKNavigationDelegate,UIScrollViewDelegate,WKScriptMessageHandler>
@property (nonatomic, weak)WebVC *targetVC;
@property (nonatomic, assign)id <ZKNavigationDelegate>navigationDelegate;
@end
