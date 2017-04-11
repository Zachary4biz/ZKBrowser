//
//  ZTWebViewController.h
//  ZKBrowser
//
//  Created by Zac on 2017/4/11.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
@interface ZTWebViewController : UIViewController
@property (nonatomic, strong) WKWebView *webV;

//- (void)loadURL:(NSURL *)url;
//- (void)loadRequest:(NSURLRequest *)request;
- (void)loadSearchContent:(NSString *)str complition:(void (^)())complitionBlock;
@end
