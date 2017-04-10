//
//  ZTAddressView.m
//  ZKBrowser
//
//  Created by Zac on 2017/4/10.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import "ZTAddressView.h"

#import "Masonry.h"

@interface ZTAddressView ()


@end



@implementation ZTAddressView
- (instancetype)init
{
    if (self = [super init]) {
        self.addBar = [[NSBundle mainBundle]loadNibNamed:@"AddressView" owner:nil options:nil][0];
        self.pickV = [[NSBundle mainBundle]loadNibNamed:@"AddressView" owner:nil options:nil][1];
        [self addSubview:self.pickV];
        [self addSubview:self.addBar];
        [self prepareLayout];
        [self prepareBlocks];
    }
    return self;
}
- (void)prepareLayout
{
    typeof(self) __weak Wself = self;
    
    [self.addBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(Wself.mas_left);
        make.right.equalTo(Wself.mas_right);
        make.centerY.equalTo(Wself.mas_centerY).offset(-20);
        make.height.mas_equalTo(40);
    }];
    self.addBar.layer.cornerRadius = 8.0;
    
    [self.pickV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(Wself.addBar.mas_leading);
        make.width.equalTo(Wself.addBar.mas_width);
        make.height.mas_equalTo(125);
        make.bottom.equalTo(Wself.addBar.mas_bottom);
    }];
    
    self.pickV.hidden = YES;
}
- (void)prepareBlocks
{
    typeof(self) __weak Wself = self;
    _addBar.clickEngineBlock = ^(){
        Wself.pickV.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            [Wself.pickV mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(Wself.addBar.mas_bottom);
            }];
        }];
    };
    
    _pickV.clickNewEngineBlock = ^(NSString *engineName){
        [Wself.addBar.engineBtn setImage:[UIImage imageNamed:engineName] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.3 animations:^{
            [Wself.pickV mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(Wself.addBar.mas_bottom);
            }];
        }];
    };
}
@end
