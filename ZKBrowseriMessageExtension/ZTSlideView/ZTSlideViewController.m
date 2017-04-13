//
//  ZTSlideViewController.m
//  APUSBrowser
//
//  Created by Zac on 2017/4/11.
//  Copyright © 2017年 APUS. All rights reserved.
//

#import "ZTSlideViewController.h"
#import "Masonry.h"



@interface ZTSlideViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIView *leftV;
@property (nonatomic, strong) UIView *rightV;
@end

@implementation ZTSlideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self prepareViews];
    [self prepareLayout];

}
- (void)viewWillLayoutSubviews
{
    [self prepareLayout];
}
- (void)prepareViews
{
    //涉及到self.leftV和rightV的alloc，必须先进行 prepareScrollView
    [self prepareScrollView];
    
    [self prepareBtnView];
    [self prepareListTableVC];
    [self prepareWebVC];
}
- (void)prepareScrollView
{
    self.scrollV = [[UIScrollView alloc]init];
    self.scrollV.directionalLockEnabled = YES;
    self.scrollV.alwaysBounceHorizontal = YES;
    self.scrollV.delegate = self;
    self.scrollV.pagingEnabled = YES;
    [self.view addSubview:self.scrollV];
    
    self.leftV = [[UIView alloc]init];
    
    self.rightV = [[UIView alloc]init];
    
    [self.scrollV addSubview:self.leftV];
    [self.scrollV addSubview:self.rightV];
    
    
}
- (void)prepareBtnView
{
    __weak typeof(self) Wself = self;
    self.btnV = [[NSBundle mainBundle] loadNibNamed:@"ButtonView" owner:nil options:nil][0];
    self.btnV.maskV.hidden = NO;
    self.btnV.maskV.layer.cornerRadius = 1;
    [self.leftV addSubview:self.btnV];
    
    
    self.btnV.favoriteBtnBlock = ^(){
        if (Wself.expandedFavoriteBtnBlock) {
            Wself.expandedFavoriteBtnBlock();
        }
    };
    self.btnV.historyBtnBlock = ^(){
        if (Wself.expandedHistoryBtnBlock) {
            Wself.expandedHistoryBtnBlock();
        }
    };
}

- (void)prepareListTableVC
{
    self.listTableVC = [[ZTListTableViewController alloc]init];
    [self addChildViewController:self.listTableVC];
    [self.leftV addSubview:self.listTableVC.view];
    
    
    __weak typeof(self) Wself = self;
    self.listTableVC.didSelectCellBlock = ^(NSString *str){
        if (Wself.didSelectCellBlock) {
            Wself.didSelectCellBlock(str);
        }
    };
    
    self.listTableVC.didScrollBlock = ^(){
        if (Wself.didScrollBlock) {
            Wself.didScrollBlock();
        }
    };
    
}
- (void)prepareWebVC
{
    self.webVC = [[ZTWebViewController alloc]init];
    [self addChildViewController:self.webVC];
    [self.rightV addSubview:self.webVC.view];
    
    __weak typeof(self) Wself = self;
    self.webVC.webViewScrollBlock = ^{
        if (Wself.webViewScrollBlock) {
            Wself.webViewScrollBlock();
        }
    };
    
    
}
- (void)prepareLayout
{
    [self.scrollV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.view.mas_top);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    [self.leftV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.scrollV);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
        make.height.mas_equalTo(self.scrollV.mas_height);
    }];
    
    [self.rightV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scrollV.mas_top);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
        make.height.mas_equalTo(self.scrollV.mas_height);
        make.left.equalTo(self.leftV.mas_right);
        make.right.equalTo(self.scrollV.mas_right);
    }];

    [self.btnV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftV.mas_left).offset(8);
        make.right.equalTo(self.leftV.mas_right).offset(-8);
        make.top.equalTo(self.leftV.mas_top);
        make.height.mas_equalTo(50);
    }];
    [self.listTableVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.btnV.mas_bottom);
        make.left.equalTo(self.btnV.mas_left);
        make.right.equalTo(self.btnV.mas_right);
        make.bottom.equalTo(self.leftV.mas_bottom);
    }];

    [self.webVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.rightV.mas_left).offset(8);
        make.top.equalTo(self.rightV.mas_top);
        make.right.equalTo(self.rightV.mas_right).offset(-8);
        make.bottom.equalTo(self.rightV.mas_bottom);
    }];
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}
@end
