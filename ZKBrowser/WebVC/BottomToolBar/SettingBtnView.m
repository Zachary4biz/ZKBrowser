//
//  SettingBtnView.m
//  ZKBrowser
//
//  Created by 周桐 on 17/1/4.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import "SettingBtnView.h"
#import "MyButton.h"
#import "NSObject+Description.h"
@implementation SettingBtnView
static CGFloat inset = 5;
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
//        UIImageView *BGIMGView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"BGImage1"]];
//        BGIMGView.contentMode = UIViewContentModeCenter;
//        [self addSubview:BGIMGView];
        
        UIVisualEffectView *visualView = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        visualView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self addSubview:visualView];
        
        self.backgroundColor = [UIColor colorWithWhite:0.97 alpha:0.4];
        
        _DesktopBtn = [[MyButton alloc]initWithFrame:CGRectMake(inset,
                                                                inset,
                                                                0.25*frame.size.width-5*inset,
                                                                frame.size.height-inset)];
        [_DesktopBtn setTitle:@"Desktop" forState:UIControlStateNormal];
        [_DesktopBtn setImage:[UIImage imageNamed:@"DesktopBtn"] forState:UIControlStateNormal];
        [_DesktopBtn addTarget:self action:@selector(clickDesktopBtn) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_DesktopBtn];
        
        _MultiTabBtn = [[MyButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_DesktopBtn.frame)+inset,
                                                                 inset,
                                                                 0.25*frame.size.width-5*inset,
                                                                 frame.size.height-inset)];
        [_MultiTabBtn setTitle:@"MultiTab" forState:UIControlStateNormal];
        [_MultiTabBtn setImage:[UIImage imageNamed:@"MultiTabBtn"] forState:UIControlStateNormal];
        [_MultiTabBtn addTarget:self action:@selector(clickMultiTabBtn) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_MultiTabBtn];
        
        _RecognizationBtn = [[MyButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_MultiTabBtn.frame)+inset,
                                                                      inset,
                                                                      0.25*frame.size.width - 5*inset,
                                                                      frame.size.height-inset)];
        [_RecognizationBtn setTitle:@"RecognizationPic" forState:UIControlStateNormal];
        [_RecognizationBtn setImage:[UIImage imageNamed:@"RecognizationBtn"] forState:UIControlStateNormal];
        [_RecognizationBtn addTarget:self action:@selector(clickRecognizationBtn) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_RecognizationBtn];
        
        
    }
    return self;
}

- (void)resetAllState
{
    [_MultiTabBtn setTitle:@"MultiTab" forState:UIControlStateNormal];
    [_DesktopBtn setTitle:@"Desktop" forState:UIControlStateNormal];
    [_RecognizationBtn setTitle:@"RecognizationPic" forState:UIControlStateNormal];
    self.ZKDescription = @"reseted";
}

- (void)clickDesktopBtn
{
    if (self.clickDesktopBtnBlock) {
        self.clickDesktopBtnBlock();
    }
}

- (void)clickMultiTabBtn
{
    if (self.clickMultiTabBtnBlock) {
        self.clickMultiTabBtnBlock();
    }
}

- (void)clickRecognizationBtn
{
    if (self.clickRecognizationBtnBlock) {
        self.clickRecognizationBtnBlock();
    }
}
@end
