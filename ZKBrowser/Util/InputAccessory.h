//
//  InputAccessory.h
//  ZKBrowser
//
//  Created by Zac on 2017/1/23.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InputAccessory : NSObject
/**
 编码一下。中文和特殊字符（除了URL指定的部分用来分割的字符）都是不能直接放到URL中拼接的

 @param aString <#aString description#>
 @return <#return value description#>
 */
+ (NSString *)encodeWithDefaultCharactersInString:(NSString *)aString;

+ (NSString *)encodeNotUsedCharacters:(NSString *)characterStr InString:(NSString *)aString;
@end
