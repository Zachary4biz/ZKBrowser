//
//  SmallWebView.m
//  ZKBrowser
//
//  Created by 周桐 on 17/1/9.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import "SmallWebView.h"
#import "WebViewDelegate.h"
@interface SmallWebView ()
@property (nonatomic, assign) CGRect initialFrame;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIImageView *dragBtn;
@property (nonatomic, strong) UIImageView *scaleBtn;
@property (nonatomic, strong) UIImageView *backBtn;
@property (nonatomic, strong) WebViewDelegate *aWebViewDelegateHandler;
@end

@implementation SmallWebView
- (WebViewDelegate *)aWebViewDelegateHandler
{
    if (!_aWebViewDelegateHandler) {
        _aWebViewDelegateHandler = [[WebViewDelegate alloc]init];
    }
    return _aWebViewDelegateHandler;
}
- (instancetype)initWithFrame:(CGRect)frame andWebView:(WebView *)aWebView
{
    if (self = [super initWithFrame:frame]) {
        
        //记录一下初始的frame
        self.initialFrame = frame;
        
        aWebView.isUsingAsSmallWebView = 1;
        self.theWebView = aWebView;
        self.theWebView.frame = frame;
        NSLog(@"原webView的地址是-%p",aWebView);
        NSLog(@"小窗口的webView地址是-%p",self.theWebView);
        [self addSubview:self.theWebView];
        
        self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];

        [self.closeBtn setImage:[UIImage imageNamed:@"SmallWebViewCloseBtn"] forState:UIControlStateNormal];
        [self.closeBtn addTarget:self action:@selector(clickCloseBtn) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.closeBtn];
        [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.top.equalTo(self.mas_top);
            make.width.mas_equalTo(20);
            make.height.mas_equalTo(20);
        }];
        
        self.dragBtn = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"SmallWebViewDragBtn"]];
        self.dragBtn.userInteractionEnabled = YES;

        UIPanGestureRecognizer *panGesture4DragBtn = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGesture4Drag:)];
        [self.dragBtn addGestureRecognizer:panGesture4DragBtn];
        [self addSubview:self.dragBtn];
        [self.dragBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.bottom.equalTo(self.mas_bottom);
            make.width.mas_equalTo(20);
            make.height.mas_equalTo(20);
        }];
        
        self.scaleBtn = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"SmallWebViewScaleBtn"]];
        self.scaleBtn.userInteractionEnabled = YES;

        UIPanGestureRecognizer *panGesture4ScaleBn = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGesture4Scale:)];
        [self.scaleBtn addGestureRecognizer:panGesture4ScaleBn];
        [self addSubview:self.scaleBtn];
        [self.scaleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right);
            make.bottom.equalTo(self.mas_bottom);
            make.width.mas_equalTo(20);
            make.height.mas_equalTo(20);
        }];
        

        
        //描边
        self.layer.borderWidth = 0.3;
        self.layer.borderColor = ([UIColor blackColor].CGColor);
        self.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
        self.layer.shadowRadius = 5.0;
        self.layer.shadowOpacity = 0.4;
        
        
    }
    return self;
}
- (void)layoutSubviews
{
    NSLog(@"smallWebView-- layoutSubviews");
    self.theWebView.frame = self.bounds;
}
- (void)clickCloseBtn
{
    if (self.closeBtnBlock) {
        self.closeBtnBlock();
    }
}
//应该不需要这个按钮
//- (void)clickBackBtn
//{
//    if (self.backBtnBlock) {
//        self.backBtnBlock();
//    }
//}

- (void)panGesture4Scale:(UIPanGestureRecognizer *)aPanGesture
{
    switch (aPanGesture.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"开始panGesture");
            break;
        case UIGestureRecognizerStateChanged:
            NSLog(@"正在改变");
            CGPoint gestureTranslation = [aPanGesture translationInView:self];
            self.frame = CGRectMake(self.frame.origin.x,
                                    self.frame.origin.y,
                                    self.initialFrame.size.width+gestureTranslation.x,
                                    self.initialFrame.size.height+gestureTranslation.y);
            NSLog(@"%@",NSStringFromCGPoint(gestureTranslation));
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"结束");
            self.initialFrame = self.frame;
            break;
        default:
            break;
    }
    
}
- (void)panGesture4Drag:(UIPanGestureRecognizer *)aPanGesture
{
    switch (aPanGesture.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"开始panGesture");
            break;
        case UIGestureRecognizerStateChanged:
            NSLog(@"正在改变");
            CGPoint gestureLocation = [aPanGesture translationInView:self];
            self.frame = CGRectMake(self.initialFrame.origin.x+gestureLocation.x,
                                    self.initialFrame.origin.y+gestureLocation.y,
                                    self.initialFrame.size.width,
                                    self.initialFrame.size.height);
            NSLog(@"%@",NSStringFromCGPoint(gestureLocation));
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"结束");
            self.initialFrame = self.frame;
            break;
        default:
            break;
    }
}
@end

