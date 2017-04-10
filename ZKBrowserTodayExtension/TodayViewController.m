//
//  TodayViewController.m
//  ZKBrowserTodayExtension
//
//  Created by Zac on 2017/4/10.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>
- (IBAction)tmpBtn:(id)sender;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
#ifdef __IPHONE_10_0 //因为是iOS10才有的，还请记得适配
    //如果需要折叠
    self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
#endif
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

- (IBAction)tmpBtn:(id)sender {
    NSLog(@"点击测试");
    NSString *urlScheme = @"zkbrowser://";
    NSURL *url = [NSURL URLWithString:urlScheme];
    
    [self.extensionContext openURL:url completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"跳转成功");
        }else{
            NSLog(@"跳转失败");
        }
    }];
}
@end
