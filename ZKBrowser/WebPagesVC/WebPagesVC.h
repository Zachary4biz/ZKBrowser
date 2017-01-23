//
//  WebPagesVC.h
//  ZKBrowser
//
//  Created by 周桐 on 16/12/27.
//  Copyright © 2016年 周桐. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WebVC;
@interface WebPagesVC : UIViewController<UIGestureRecognizerDelegate>
/**
 实际上保存都是WebView，我给这个类加了一个属性是存截图的，使用就直接是aWebView =arr4NormalWebPages[1]; aWebView.snapShot;
 */
@property (nonatomic, strong)NSMutableArray *arr4NormalWebPages;

/**
 用来保存隐私模式所有页面截图的数组
 */
@property (nonatomic, strong)NSMutableArray *arr4PrivateWebPages;

/**
 就是WebVC
 */
@property (nonatomic, weak)WebVC *theWebVC;

@property (nonatomic, copy)void (^dismissBlock)();

/**
 给出WebPagesVC的单例
 不做单例，因为WebPagesVC和WebVC之间没有数据关联，可以直接销毁每次重新创建就行了
 @return WebPagesVC*
 */
//+ (instancetype) sharedInstance;


@end
