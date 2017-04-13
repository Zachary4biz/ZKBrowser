//
//  ZTSlideViewController.h
//  APUSBrowser
//
//  Created by Zac on 2017/4/11.
//  Copyright © 2017年 APUS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZTWebViewController.h"
#import "ButtonView.h"
#import "ZTListTableViewController.h"
@interface ZTSlideViewController : UIViewController
@property (nonatomic, copy) void (^expandedFavoriteBtnBlock)();
@property (nonatomic, copy) void (^expandedHistoryBtnBlock)();
@property (nonatomic, copy) void (^didSelectCellBlock)(NSString *str);
@property (nonatomic, copy) void (^didScrollBlock)();
@property (nonatomic, copy) void (^webViewScrollBlock)();
@property (nonatomic, strong) ZTWebViewController *webVC;
@property(nonatomic, strong) UIScrollView *scrollV;
@property (nonatomic, strong) ButtonView *btnV;
@property (nonatomic, strong) ZTListTableViewController *listTableVC;
@end
