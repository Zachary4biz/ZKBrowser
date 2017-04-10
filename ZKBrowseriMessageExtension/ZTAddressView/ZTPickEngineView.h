//
//  ZTPickEngineView.h
//  ZKBrowser
//
//  Created by Zac on 2017/4/10.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"


@interface ZTPickEngineView : UIView
@property (nonatomic, copy)void (^clickNewEngineBlock)(NSString *engineName);
@end
