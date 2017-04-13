//
//  ButtonView.h
//  ZKBrowser
//
//  Created by Zac on 2017/4/10.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ButtonView : UIView

@property (nonatomic, copy) void (^favoriteBtnBlock)();
@property (nonatomic, copy) void (^historyBtnBlock)();
@property (weak, nonatomic) IBOutlet UIView *maskV;
@property (weak, nonatomic) IBOutlet UIButton *favoriteBtn;
@property (weak, nonatomic) IBOutlet UIButton *historyBtn;
@end
