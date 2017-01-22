//
//  WebView.m
//  ZKBrowser
//
//  Created by 周桐 on 16/12/24.
//  Copyright © 2016年 周桐. All rights reserved.
//

#import "WebView.h"
@interface WebView()
@property (nonatomic, strong)WKProcessPool *aPool;
@property (nonatomic, strong)WKPreferences *aPreference;
@property (nonatomic, strong)WKUserContentController *aUserContentController;

@end
@implementation WebView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (WKProcessPool *)aPool
{
    if (!_aPool) {
        _aPool = [[WKProcessPool alloc]init];
    }
    return _aPool;
}
- (WKPreferences *)aPreference
{
    if (!_aPreference) {
        _aPreference = [[WKPreferences alloc]init];
        //默认参数就可以了不用改什么
    }
    return _aPreference;
}
- (WKUserContentController *)aUserContentController
{
    if (!_aUserContentController) {
        _aUserContentController = [[WKUserContentController alloc]init];
        
    }
    return _aUserContentController;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    WKWebViewConfiguration *aDefualtConfiguration = [[WKWebViewConfiguration alloc]init];
    //通过这个初始化的就共享一个线程池
    aDefualtConfiguration.processPool = self.aPool;
    return [self initWithFrame:frame configuration:aDefualtConfiguration];

}
- (instancetype)initWithFrame:(CGRect)frame configuration:(nonnull WKWebViewConfiguration *)configuration
{
    if (self=[super initWithFrame:frame configuration:configuration]) {
        self.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1.0];
        self.allowsBackForwardNavigationGestures = YES;
        
        //进度条
        _theProgressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
        [_theProgressView setFrame:CGRectMake(0, 0, self.frame.size.width, 3)];
        _theProgressView.progress = 0;
        [self addSubview:self.theProgressView];
        
        //添加一些常用网站

        
        
        
    }
    return self;
}
- (void)dealloc
{
    NSLog(@"-- webView销毁");
    NSLog(@"-- 地址为%p，title是%@,URL是%@",self,self.title,self.URL);
}
@end
