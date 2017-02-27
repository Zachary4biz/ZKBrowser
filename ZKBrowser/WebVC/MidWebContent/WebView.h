//
//  WebView.h
//  ZKBrowser
//
//  Created by 周桐 on 16/12/24.
//  Copyright © 2016年 周桐. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface WebView : WKWebView
@property (nonatomic, strong) UIProgressView *theProgressView;
@property (nonatomic, strong) UIImage *snapShot;
@property (nonatomic, assign) BOOL isPrivateWebView;
@property (nonatomic, assign) BOOL isUsingAsSmallWebView;
/**
 是否正在恢复标签中
 */
@property (nonatomic, assign) BOOL isRebooting;
/**
 为了恢复标签，这个webView要加载URL
 */
@property (nonatomic, strong) NSArray *urlArr;
/**
 总共应该加载多少个URL
 */
@property (nonatomic, assign) NSUInteger counter4BackForward;
/**
 已经加载了都少个URL
 */
@property (nonatomic, assign) NSUInteger alreadyCounter4BackForward;
/**
 恢复标签后它的当前页面的URL在URLArr中的索引
 */
@property (nonatomic, assign) NSUInteger index4CurrentURLShouldbe;
@end
