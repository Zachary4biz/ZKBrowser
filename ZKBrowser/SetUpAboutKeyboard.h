//
//  SetUpAboutKeyboard.h
//  iOS_OA_NET
//
//  Created by 周桐 on 16/11/22.
//  Copyright © 2016年 周桐. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface SetUpAboutKeyboard : UIViewController
//这个纯粹是为了骗过编译器，到时候要把这个方法的实现弄到目标vc中，而目标VC是有self.view的
@property (nonatomic, strong)UIView *view;
//topView键盘上方的那个指示view
@property (nonatomic, strong)UIToolbar *topView;
//目标VC
@property (nonatomic, strong)UIViewController *targetVC;

-(void)initWithPreparation4KeyboardWithVC:(UIViewController *)targetVC andLiftTheViews:(NSArray *)views2Lift;
//-(void)newViewDidDisappear:(BOOL)animated;
@end
