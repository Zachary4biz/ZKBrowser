//
//  TodayViewController.m
//  ZKBrowserTodayExtension
//
//  Created by Zac on 2017/4/10.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>
@property (weak, nonatomic) IBOutlet UIButton *favoriteBtn;

@property (weak, nonatomic) IBOutlet UIButton *searchBtn;

@property (weak, nonatomic) IBOutlet UIButton *historyBtn;

@property (nonatomic, strong) UIButton *hisBtn;

@end

@implementation TodayViewController
- (IBAction)favoriteBtn:(id)sender {
    
}
- (IBAction)searchBtn:(id)sender {
}
- (IBAction)historyBtn:(id)sender {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
#ifdef __IPHONE_10_0 //因为是iOS10才有的，还请记得适配
    //如果需要折叠
    self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
#endif
    
//    [self prepareButton:@[_favoriteBtn,_searchBtn]];
//    [_favoriteBtn setTitle:@"收藏" forState:UIControlStateNormal];
//    [_favoriteBtn.imageView setImage:[UIImage imageNamed:@"today_favorite"]];
//    
//    [_searchBtn.imageView setImage:[UIImage imageNamed:@"today_search"]];
//    
//    [_historyBtn setImage:[UIImage imageNamed:@"today_history"] forState:UIControlStateNormal];
//    [_historyBtn setTitle:@"历史" forState:UIControlStateNormal];
//    
//    self.hisBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
//    [self.hisBtn.imageView setImage:[UIImage imageNamed:@"today_history"]];
//    [self.hisBtn setTitle:@"历史" forState:UIControlStateNormal];
//    self.hisBtn.backgroundColor = [UIColor redColor];
//    [self.view addSubview:self.hisBtn];
}
- (void)prepareButton:(NSArray *)btnArr
{
    for (UIButton *btn in btnArr){
        btn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 20, 10)];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(btn.frame.size.height-20, 0, 0, 0)];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {


    completionHandler(NCUpdateResultNewData);
}


- (IBAction)tmpBtn:(id)sender {
    NSLog(@"点击测试");
    NSString *urlScheme = @"zkbrowser://";
    NSURL *url = [NSURL URLWithString:urlScheme];
    
    [self.extensionContext openURL:url completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"跳转成功");
        }else{
            NSLog(@"跳转失败");
        }
    }];
}
@end
