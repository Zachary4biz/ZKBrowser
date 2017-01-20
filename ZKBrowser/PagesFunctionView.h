//
//  PagesFunctionView.h
//  ZKBrowser
//
//  Created by 周桐 on 16/12/24.
//  Copyright © 2016年 周桐. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PagesFunctionView : UIView
@property (nonatomic, strong)UIButton *privateBtn;

@property (nonatomic, strong)UIButton *createPageBtn;

@property (nonatomic, strong)UIButton *backBtn;

@property (nonatomic, copy)void (^clickPrivateBtnBlock)();

@property (nonatomic, copy)void (^clickCreatePageBtnBlock)();

@property (nonatomic, copy)void (^clickBackBtnBlock)();
@end
