//
//  ButtonView.m
//  ZKBrowser
//
//  Created by Zac on 2017/4/10.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import "ButtonView.h"

@interface ButtonView()

@end

@implementation ButtonView
- (IBAction)favoriteBtn:(id)sender {
    NSLog(@"favoriteBtn Clicked");
    if (self.favoriteBtnBlock) {
        self.favoriteBtnBlock();
    }
}
- (IBAction)historyBtn:(id)sender {
    NSLog(@"historyBtn Clicked");
    if (self.historyBtnBlock) {
        self.historyBtnBlock();
    }
}


@end
