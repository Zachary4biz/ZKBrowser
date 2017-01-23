//
//  InputAccessory.m
//  ZKBrowser
//
//  Created by Zac on 2017/1/23.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import "InputAccessory.h"

@implementation InputAccessory
+ (NSString *)encodeWithDefaultCharactersInString:(NSString *)aString
{
    //考虑到有中文参数，所以需要编码
    //首先设置没有使用的特殊符号--即会被编码掉，最后那个空是空格
    NSString *defaultCharacterStr = @"<>'\"*()$#@!= ";
    //invertedSet 是取反， 即 除了character2Escape中的其他的字符串都是允许的，不会被编码
    NSCharacterSet *allowedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:defaultCharacterStr] invertedSet];
    NSString *resultStr = [aString stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
    return resultStr;
}
+ (NSString *)encodeNotUsedCharacters:(NSString *)characterStr InString:(NSString *)aString
{
    //考虑到有中文参数，所以需要编码
    //invertedSet 是取反， 即 除了character2Escape中的其他的字符串都是允许的，不会被编码
    NSCharacterSet *allowedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:characterStr] invertedSet];
    NSString *resultStr = [aString stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
    return resultStr;
}
@end
