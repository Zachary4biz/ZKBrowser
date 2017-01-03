//
//  WebPageView.h
//  ZKBrowser
//
//  Created by 周桐 on 16/12/27.
//  Copyright © 2016年 周桐. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebPageView : UIView
/**
 这个截图所属的webView的URL
 */
@property (nonatomic, strong)NSURL *pageURL;

/**
 这个截图所属的webView的Title
 */
@property (nonatomic, strong)NSString *pageTitle;


- (instancetype)initWithFrame:(CGRect)aFrame andSnapshotOfWebView:(UIView *)aSnapshot;
@end
