//
//  WebPageView.m
//  ZKBrowser
//
//  Created by 周桐 on 16/12/27.
//  Copyright © 2016年 周桐. All rights reserved.
//

#import "WebPageView.h"
#import "PagesFunctionView.h"
@implementation WebPageView
static CGFloat TitleViewHeight = 30.0;
- (instancetype)initWithFrame:(CGRect)aFrame andSnapshotOfWebView:(UIView *)aSnapshot
{
    if (self = [super initWithFrame:aFrame]) {
        CGRect frame4Snapshot = CGRectMake(0, TitleViewHeight, aFrame.size.width, aFrame.size.height-TitleViewHeight);
        aSnapshot.frame = frame4Snapshot;
        [self addSubview:aSnapshot];
        
        UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, aFrame.size.width, TitleViewHeight)];
        titleView.backgroundColor = [UIColor greenColor];
        [self addSubview:titleView];
    }
    return self;
}
@end
