//
//  ZTAddressView.h
//  ZKBrowser
//
//  Created by Zac on 2017/4/10.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZTAddressBar.h"
#import "ZTPickEngineView.h"
@interface ZTAddressView : UIView
@property (nonatomic, strong) ZTAddressBar *addBar;
@property (nonatomic, strong) ZTPickEngineView *pickV;
@property (nonatomic, copy) void (^sendBtnBlock)();
@end
