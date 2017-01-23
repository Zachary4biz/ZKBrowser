//
//  MyButton.m
//  TimeFace-1
//
//  Created by 周桐 on 16/10/4.
//  Copyright © 2016年 周桐. All rights reserved.
//

#import "MyButton.h"

@implementation MyButton

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
//        //设置title的大小、字体颜色
//        self.titleLabel.bounds = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height*2/3);
//        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        self.titleLabel.font = [UIFont systemFontOfSize:10];
//        [self.titleLabel sizeToFit];
////
////        //设置ImageView大小，并设置ScaleToFill
////        self.imageView.bounds = CGRectMake(0,0,self.frame.size.width*2/3,self.frame.size.height*2/3);
//        self.imageView.contentMode = UIViewContentModeScaleToFill;
//        
//        //设置aligment，方便后面UIEdgeInsetsMake
//        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//        self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        
        
    }

    return self;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:10];
    [self.titleLabel sizeToFit];
    //设置ImageView大小，并设置ScaleToFill
    self.imageView.contentMode = UIViewContentModeScaleToFill;
    
    //设置aligment，方便后面UIEdgeInsetsMake
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    
    //获取btn整体
    CGFloat btnW = self.frame.size.width;
    CGFloat btnH = self.frame.size.height;
    
    //获取imageView
    CGFloat imageViewW = self.imageView.frame.size.width;
    CGFloat imageViewH = self.imageView.frame.size.height;
    
    //获取title
    CGFloat titleW = self.titleLabel.frame.size.width;
    CGFloat titleH = self.titleLabel.frame.size.height;
    
    //设计结构是从上到下：空白-图片-空白-文字-空白，三个空白相等
    CGFloat space =(btnH - imageViewH - titleH)*1.0/3;
    self.imageEdgeInsets = UIEdgeInsetsMake(space, (btnW - imageViewW)*0.5, 0, 0);
    self.titleEdgeInsets = UIEdgeInsetsMake(imageViewH + 2*space,-imageViewW+(btnW-titleW)*0.5, 0, 0);
//    self.titleEdgeInsets = UIEdgeInsetsMake(imageViewH + 2*space,0, 0, 0);
    
}

@end
