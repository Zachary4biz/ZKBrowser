//
//  ZTListTableViewCell.h
//  APUSBrowser
//
//  Created by Zac on 2017/4/11.
//  Copyright © 2017年 APUS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZTListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgV;
@property (nonatomic, strong) NSString *dataStr;
@property (nonatomic, strong) UIImage *img;
@end
