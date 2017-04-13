//
//  ZTListTableViewCell.m
//  APUSBrowser
//
//  Created by Zac on 2017/4/11.
//  Copyright © 2017年 APUS. All rights reserved.
//

#import "ZTListTableViewCell.h"
@interface ZTListTableViewCell()
@property (weak, nonatomic) IBOutlet UITextField *textF;

@end
@implementation ZTListTableViewCell

- (void)setDataStr:(NSString *)dataStr
{
    _dataStr = dataStr;
    _textF.text = dataStr;
}
- (void)setImg:(UIImage *)img
{
    _img = img;
    _imgV.image = img;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
