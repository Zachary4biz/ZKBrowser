//
//  ZTAddressBar.m
//  ZKBrowser
//
//  Created by Zac on 2017/4/10.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import "ZTAddressBar.h"
#import "ZTPickEngineView.h"

@interface ZTAddressBar ()

- (IBAction)engineBtn:(id)sender;

@end


@implementation ZTAddressBar


- (IBAction)engineBtn:(id)sender {
    if(self.clickEngineBlock){
        self.clickEngineBlock();
    }
}
@end
