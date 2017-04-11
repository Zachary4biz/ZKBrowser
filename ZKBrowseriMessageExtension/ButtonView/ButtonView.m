//
//  ButtonView.m
//  ZKBrowser
//
//  Created by Zac on 2017/4/10.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import "ButtonView.h"

@interface ButtonView()

@property (weak, nonatomic) IBOutlet UIButton *favoriteBtn;
@property (weak, nonatomic) IBOutlet UIButton *historyBtn;
@end

@implementation ButtonView
- (IBAction)favoriteBtn:(id)sender {
    NSLog(@"click f");
    if (self.favoriteBtnBlock) {
        self.favoriteBtnBlock();
    }
}
- (IBAction)historyBtn:(id)sender {
    NSLog(@"click h");
    if (self.historyBtnBlock) {
        self.historyBtnBlock();
    }
}


@end
