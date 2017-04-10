//
//  ZTPickEngineView.m
//  ZKBrowser
//
//  Created by Zac on 2017/4/10.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import "ZTPickEngineView.h"

@interface ZTPickEngineView ()
- (IBAction)BingBtn:(id)sender;
- (IBAction)BaiduBtn:(id)sender;
- (IBAction)GoogleBtn:(id)sender;
- (IBAction)AskBtn:(id)sender;

@end


@implementation ZTPickEngineView

- (IBAction)BingBtn:(id)sender {
    if (self.clickNewEngineBlock) {
        self.clickNewEngineBlock(@"Bing");
    }
}

- (IBAction)BaiduBtn:(id)sender {
    if (self.clickNewEngineBlock) {
        self.clickNewEngineBlock(@"Baidu");
    }
}

- (IBAction)GoogleBtn:(id)sender {
    if (self.clickNewEngineBlock) {
        self.clickNewEngineBlock(@"Google");
    }
}

- (IBAction)AskBtn:(id)sender {
    if (self.clickNewEngineBlock) {
        self.clickNewEngineBlock(@"Ask");
    }
}
@end
