//
//  NSObject+Description.m
//  ZKBrowser
//
//  Created by 周桐 on 16/12/26.
//  Copyright © 2016年 周桐. All rights reserved.
//

#import "NSObject+Description.h"
#import <objc/runtime.h>

@implementation NSObject (Description)
static void *strKey = &strKey;

- (void)setZKDescription:(id)ZKDescription
{
    objc_setAssociatedObject(self, &strKey, ZKDescription, OBJC_ASSOCIATION_COPY);
}
-(id)ZKDescription
{
    return objc_getAssociatedObject(self, &strKey);
}
@end
