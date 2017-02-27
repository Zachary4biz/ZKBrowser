//
//  ZKWebView.h
//  ZKBrowser
//
//  Created by 周桐 on 16/12/24.
//  Copyright © 2016年 周桐. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface ZKWebView : WKWebView
@property (nonatomic, strong) UIProgressView *theProgressView;
@property (nonatomic, strong) UIImage *snapShot;
@property (nonatomic, assign) BOOL isPrivateWebView;
@property (nonatomic, assign) BOOL isUsingAsSmallWebView;

@property (nonatomic, strong) void (^deallocBlock)();
@end
