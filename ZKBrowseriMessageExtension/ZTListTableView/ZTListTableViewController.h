//
//  ZTListTableViewController.h
//  ZKBrowser
//
//  Created by Zac on 2017/4/11.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZTListTableViewController : UITableViewController
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, copy) void (^didSelectCellBlock)(NSString *str);
@property (nonatomic, copy) void (^didScrollBlock)();
@property (nonatomic, strong) UIImage *img4cell;
@end
