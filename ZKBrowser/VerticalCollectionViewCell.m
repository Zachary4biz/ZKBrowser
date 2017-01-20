//
//  VerticalCollectionViewCell.m
//  Self-Made-UI
//
//  Created by 周桐 on 17/1/18.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import "VerticalCollectionViewCell.h"

@implementation VerticalCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self doInit];
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGesture:)];
        [self.ZKIMGView addGestureRecognizer:panGesture];
        self.ZKIMGView.userInteractionEnabled = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _ZKIMGView.frame = self.contentView.bounds;
}

- (void)doInit
{
    self.ZKIMGView = [[UIImageView alloc]initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:self.ZKIMGView];
    _ZKIMGView.layer.borderColor = [UIColor cyanColor].CGColor;
    
    _ZKIMGView.layer.borderWidth = 3;
}
- (void)panGesture:(UIPanGestureRecognizer *)aPanGesture
{
    if (self.panGestureBlock) {
        self.panGestureBlock(aPanGesture);
    }else{
        NSLog(@"didn't realize panGestureBlock");
    }
}
@end
