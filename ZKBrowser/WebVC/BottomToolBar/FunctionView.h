//
//  FunctionView.h
//  ZKBrowser
//
//  Created by 周桐 on 16/12/23.
//  Copyright © 2016年 周桐. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FunctionView : UIView

@property (nonatomic, strong)UIButton *leftBtn;

@property (nonatomic, strong)UIButton *rightBtn;

@property (nonatomic, strong)UIButton *HomePageBtn;

@property (nonatomic, strong)UIButton *PagesBtn;

@property (nonatomic, strong)UIButton *SettingBtn;

@property (nonatomic, strong)void (^clickLeftBtnBlock)();

@property (nonatomic, strong)void (^clickRightBtnBlock)();

@property (nonatomic, strong)void (^clickHomePageBtnBlock)();

@property (nonatomic, strong)void (^clickPagesBtnBlock)();

@property (nonatomic, strong)void (^clickSettingBtnBlock)();

@end
