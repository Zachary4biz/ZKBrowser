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

@property (nonatomic, strong) NSMutableDictionary *dictUnarchived;
- (void)loadLocalWKWebViews;
/**
 获得一个单例，因为不希望WebVC销毁，
 此外考虑从spotlight进来的情况，在AppDelegate中
 didFinishLaunchingWithOptions和continueUserActivity两个方法
 都会要用到这个WebVC，而且如果app只是在后台，那么从spotlight进来了就只会走continueUserActivity不会走didFinishLaunchingWithOptions
 所以必须要在continueUserActivity也直接使用WebVC才行。
 而我又不想给AppDelegate做一个全局变量WebVC，不想让它持有这个VC，因为我觉得这样可能是会有问题的

 @return <#return value description#>
 */
+ (WebVC *)sharedInstance;

//spotlight
@property (nonatomic, strong) NSString *spotlightParam;
- (void)requestWithSpotlightParam:(NSString *)aParam;

//iMessage
- (void)requestWithiMessageURL:(NSURL *)iMessageURL;
@end
