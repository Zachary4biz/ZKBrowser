//
//  SmallWebView.h
//  ZKBrowser
//
//  Created by 周桐 on 17/1/9.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "Masonry.h"
#import "WebView.h"
@interface SmallWebView : UIView
@property (nonatomic, strong) WebView *theWebView;
@property (nonatomic, strong) void(^closeBtnBlock)();
@property (nonatomic, strong) void(^dragBtnBlock)();
@property (nonatomic, strong) void(^scaleBtnBlock)();
@property (nonatomic, strong) void(^backBtnBlock)();

- (instancetype)initWithFrame:(CGRect)frame andWebView:(WKWebView *)aWebView;
@end
