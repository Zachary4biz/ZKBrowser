//
//  ZTDetection.m
//  ZKBrowser
//
//  Created by Zac on 2017/4/11.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import "ZTDetection.h"

@implementation ZTDetection
+ (NSMutableURLRequest *)detectReqeuestFromString:(NSString *)str
{
    NSString *object = str;
    NSMutableURLRequest *request = nil;
    if([object hasSuffix:@".com"] || [object hasSuffix:@".org"]){
        //结尾.com表示是网页
        //首先全部小写
        object = [object lowercaseString];
        if ([object hasPrefix:@"http://"] || [object hasPrefix:@"https://"]) {
            //有http开头或者https开头，直接请求
            request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:object]];
        }else{
            //没有http开头的补全一下
            NSString *urlPrefix = @"https://";
            NSString *urlStr = [urlPrefix stringByAppendingString:object];
            request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
        }
    }else if (object.length == 0){
        NSLog(@"URL栏输入为空，即加载首页");
    }else{
        //没有.com不是网页，调用搜索引擎API搜索
        NSString *PreStrBaidu = @"https://www.baidu.com/s?ie=UTF-8&wd=";
        //考虑到有中文参数，所以需要编码
        //首先设置没有使用的特殊符号--即会被编码掉
        NSString *character2Escape = @"<>'\"*()$#@! ";
        //invertedSet 是取反， 即 除了character2Escape中的其他的字符串都是允许的，不会被编码
        NSCharacterSet *allowedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:character2Escape] invertedSet];
        object = [object stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        
        NSString *urlStr = [PreStrBaidu stringByAppendingString:object];
        NSURL *url = [NSURL URLWithString:urlStr];
        request = [NSMutableURLRequest requestWithURL:url];
    }
    
    return request;

}

@end

