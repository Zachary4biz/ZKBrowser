//
//  SettingBtnView.h
//  ZKBrowser
//
//  Created by 周桐 on 17/1/4.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyButton;
@interface SettingBtnView : UIView
@property (nonatomic, strong) void (^clickDesktopBtnBlock)();
@property (nonatomic, strong) void (^clickMultiTabBtnBlock)();
@property (nonatomic, strong) MyButton *DesktopBtn;
@property (nonatomic, strong) MyButton *MultiTabBtn;

/**
 这里是因为切换webView之后，状态是有所改变的，所以要重置一下settingBtnView的状态
 */
- (void)resetAllState;
@end
