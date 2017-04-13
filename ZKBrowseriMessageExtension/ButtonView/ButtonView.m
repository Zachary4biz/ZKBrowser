//
//  ButtonView.m
//  ZKBrowser
//
//  Created by Zac on 2017/4/10.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import "ButtonView.h"
#import "Masonry.h"
@interface ButtonView()

@end

@implementation ButtonView
- (IBAction)favoriteBtn:(id)sender {
    NSLog(@"click f");
    
    [UIView animateWithDuration:0.2 animations:^{
        self.maskV.transform = CGAffineTransformIdentity;
    }];
    if (self.favoriteBtnBlock) {
        self.favoriteBtnBlock();
    }
}
- (IBAction)historyBtn:(id)sender {
    NSLog(@"click h");
    
    [UIView animateWithDuration:0.2 animations:^{
        self.maskV.transform = CGAffineTransformMakeTranslation(self.historyBtn.frame.origin.x-self.favoriteBtn.frame.origin.x, 0);
    }];
    if (self.historyBtnBlock) {
        self.historyBtnBlock();
    }
}


@end
