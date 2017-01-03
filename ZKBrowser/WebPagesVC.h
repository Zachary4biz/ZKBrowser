//
//  WebPagesVC.h
//  ZKBrowser
//
//  Created by 周桐 on 16/12/27.
//  Copyright © 2016年 周桐. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebPagesVC : UIViewController

/**
 保存正常模式下所有网页截图的数组
 */
@property (nonatomic, strong)NSMutableArray *arr4NormalWebPages;

/**
 用来保存隐私模式所有页面截图的数组
 */
@property (nonatomic, strong)NSMutableArray *arr4PrivateWebPages;


/**
 给出WebPagesVC的单例

 @return WebPagesVC*
 */
+ (instancetype) sharedInstance;


/**
 用来在这个VC中显示所有的网页tab

 @param arr4SnapshotOfWebView 一个存储有所有网页截图的数组
 */
- (void)setUpWebPagesView:(NSMutableArray *)arr4SnapshotOfWebView;
@end
