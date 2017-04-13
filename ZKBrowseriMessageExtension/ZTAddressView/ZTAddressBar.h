//
//  ZTAddressBar.h
//  ZKBrowser
//
//  Created by Zac on 2017/4/10.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"
@interface ZTAddressBar : UIView
@property (nonatomic, copy) void (^clickEngineBlock)();
@property (nonatomic, copy) void (^sendBtnBlock)();
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIButton *engineBtn;
@property (weak, nonatomic) IBOutlet UITextField *textF;
@end
